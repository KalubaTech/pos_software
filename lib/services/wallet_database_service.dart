import 'package:sqflite/sqflite.dart';
import '../models/wallet_model.dart';
import '../models/wallet_transaction_model.dart';
import '../models/withdrawal_request_model.dart';

class WalletDatabaseService {
  final Database db;

  WalletDatabaseService(this.db);

  // Initialize wallet tables
  Future<void> initializeTables() async {
    // Wallets table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS wallets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id TEXT UNIQUE NOT NULL,
        business_name TEXT NOT NULL,
        balance REAL DEFAULT 0.0,
        currency TEXT DEFAULT 'USD',
        status TEXT DEFAULT 'active',
        is_enabled INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Wallet transactions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS wallet_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        wallet_id INTEGER NOT NULL,
        business_id TEXT NOT NULL,
        transaction_id TEXT UNIQUE NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        charge_amount REAL DEFAULT 0.0,
        net_amount REAL NOT NULL,
        balance_before REAL NOT NULL,
        balance_after REAL NOT NULL,
        status TEXT DEFAULT 'pending',
        payment_method TEXT,
        customer_phone TEXT,
        customer_name TEXT,
        reference_id TEXT,
        description TEXT,
        metadata TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (wallet_id) REFERENCES wallets(id) ON DELETE CASCADE
      )
    ''');

    // Withdrawal requests table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS withdrawal_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        wallet_id INTEGER NOT NULL,
        business_id TEXT NOT NULL,
        request_id TEXT UNIQUE NOT NULL,
        amount REAL NOT NULL,
        withdrawal_method TEXT NOT NULL,
        account_details TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        requested_by TEXT,
        requested_at TEXT NOT NULL,
        processed_by TEXT,
        processed_at TEXT,
        rejection_reason TEXT,
        transaction_id INTEGER,
        notes TEXT,
        FOREIGN KEY (wallet_id) REFERENCES wallets(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_wallets_business_id ON wallets(business_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_wallet_transactions_wallet_id ON wallet_transactions(wallet_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_wallet_transactions_transaction_id ON wallet_transactions(transaction_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_withdrawal_requests_wallet_id ON withdrawal_requests(wallet_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_withdrawal_requests_status ON withdrawal_requests(status)',
    );
  }

  // ==================== WALLET OPERATIONS ====================

  Future<WalletModel?> getWalletByBusinessId(String businessId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'wallets',
      where: 'business_id = ?',
      whereArgs: [businessId],
    );

    if (maps.isEmpty) return null;
    return WalletModel.fromJson(maps.first);
  }

  Future<List<WalletModel>> getAllWallets() async {
    final List<Map<String, dynamic>> maps = await db.query('wallets');
    return List.generate(maps.length, (i) {
      return WalletModel.fromJson(maps[i]);
    });
  }

  Future<WalletModel> createWallet(WalletModel wallet) async {
    final id = await db.insert('wallets', wallet.toJson());
    return wallet.copyWith(id: id);
  }

  Future<void> updateWallet(WalletModel wallet) async {
    await db.update(
      'wallets',
      wallet.toJson(),
      where: 'id = ?',
      whereArgs: [wallet.id],
    );
  }

  Future<void> updateWalletBalance(int walletId, double newBalance) async {
    await db.update(
      'wallets',
      {'balance': newBalance, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [walletId],
    );
  }

  Future<void> enableWallet(String businessId, bool enabled) async {
    await db.update(
      'wallets',
      {
        'is_enabled': enabled ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'business_id = ?',
      whereArgs: [businessId],
    );
  }

  // ==================== TRANSACTION OPERATIONS ====================

  Future<WalletTransactionModel> createTransaction(
    WalletTransactionModel transaction,
  ) async {
    final id = await db.insert('wallet_transactions', {
      ...transaction.toJson(),
      'metadata': transaction.metadata != null
          ? transaction.metadata.toString()
          : null,
    });
    return WalletTransactionModel(
      id: id,
      walletId: transaction.walletId,
      businessId: transaction.businessId,
      transactionId: transaction.transactionId,
      type: transaction.type,
      amount: transaction.amount,
      chargeAmount: transaction.chargeAmount,
      netAmount: transaction.netAmount,
      balanceBefore: transaction.balanceBefore,
      balanceAfter: transaction.balanceAfter,
      status: transaction.status,
      paymentMethod: transaction.paymentMethod,
      customerPhone: transaction.customerPhone,
      customerName: transaction.customerName,
      referenceId: transaction.referenceId,
      description: transaction.description,
      metadata: transaction.metadata,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }

  Future<List<WalletTransactionModel>> getTransactionsByWalletId(
    int walletId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'wallet_transactions',
      where: 'wallet_id = ?',
      whereArgs: [walletId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return WalletTransactionModel.fromJson(maps[i]);
    });
  }

  Future<List<WalletTransactionModel>> getRecentTransactions(
    int walletId, {
    int limit = 10,
  }) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'wallet_transactions',
      where: 'wallet_id = ?',
      whereArgs: [walletId],
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return WalletTransactionModel.fromJson(maps[i]);
    });
  }

  Future<WalletTransactionModel?> getTransactionByTransactionId(
    String transactionId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'wallet_transactions',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );

    if (maps.isEmpty) return null;
    return WalletTransactionModel.fromJson(maps.first);
  }

  Future<void> updateTransactionStatus(
    String transactionId,
    String status,
  ) async {
    await db.update(
      'wallet_transactions',
      {'status': status, 'updated_at': DateTime.now().toIso8601String()},
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );
  }

  // Get transaction statistics
  Future<Map<String, dynamic>> getTransactionStats(
    int walletId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String whereClause = 'wallet_id = ? AND status = ?';
    List<dynamic> whereArgs = [walletId, 'completed'];

    if (startDate != null) {
      whereClause += ' AND created_at >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClause += ' AND created_at <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final deposits = await db.rawQuery('''
      SELECT 
        COUNT(*) as count,
        COALESCE(SUM(net_amount), 0) as total
      FROM wallet_transactions
      WHERE $whereClause AND type = 'deposit'
    ''', whereArgs);

    final withdrawals = await db.rawQuery('''
      SELECT 
        COUNT(*) as count,
        COALESCE(SUM(amount), 0) as total
      FROM wallet_transactions
      WHERE $whereClause AND type = 'withdrawal'
    ''', whereArgs);

    final charges = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(charge_amount), 0) as total
      FROM wallet_transactions
      WHERE $whereClause
    ''', whereArgs);

    return {
      'deposits': {
        'count': deposits.first['count'],
        'total': deposits.first['total'],
      },
      'withdrawals': {
        'count': withdrawals.first['count'],
        'total': withdrawals.first['total'],
      },
      'charges': {'total': charges.first['total']},
    };
  }

  // ==================== WITHDRAWAL REQUEST OPERATIONS ====================

  Future<WithdrawalRequestModel> createWithdrawalRequest(
    WithdrawalRequestModel request,
  ) async {
    final id = await db.insert('withdrawal_requests', {
      ...request.toJson(),
      'account_details': request.accountDetails.toString(),
    });
    return WithdrawalRequestModel(
      id: id,
      walletId: request.walletId,
      businessId: request.businessId,
      requestId: request.requestId,
      amount: request.amount,
      withdrawalMethod: request.withdrawalMethod,
      accountDetails: request.accountDetails,
      status: request.status,
      requestedBy: request.requestedBy,
      requestedAt: request.requestedAt,
    );
  }

  Future<List<WithdrawalRequestModel>> getWithdrawalRequestsByWalletId(
    int walletId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'withdrawal_requests',
      where: 'wallet_id = ?',
      whereArgs: [walletId],
      orderBy: 'requested_at DESC',
    );

    return List.generate(maps.length, (i) {
      return WithdrawalRequestModel.fromJson(maps[i]);
    });
  }

  Future<List<WithdrawalRequestModel>> getPendingWithdrawalRequests(
    int walletId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'withdrawal_requests',
      where: 'wallet_id = ? AND status = ?',
      whereArgs: [walletId, 'pending'],
      orderBy: 'requested_at DESC',
    );

    return List.generate(maps.length, (i) {
      return WithdrawalRequestModel.fromJson(maps[i]);
    });
  }

  Future<void> updateWithdrawalRequestStatus(
    String requestId,
    String status, {
    String? processedBy,
    String? rejectionReason,
    int? transactionId,
  }) async {
    await db.update(
      'withdrawal_requests',
      {
        'status': status,
        'processed_by': processedBy,
        'processed_at': DateTime.now().toIso8601String(),
        'rejection_reason': rejectionReason,
        'transaction_id': transactionId,
      },
      where: 'request_id = ?',
      whereArgs: [requestId],
    );
  }

  // ==================== UTILITY METHODS ====================

  Future<void> deleteAllWalletData() async {
    await db.delete('withdrawal_requests');
    await db.delete('wallet_transactions');
    await db.delete('wallets');
  }
}
