import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../models/sync_models.dart';
import '../services/data_sync_service.dart';

/// Repository for transaction operations with sync support
class TransactionRepository {
  final DataSyncService _syncService = Get.find<DataSyncService>();

  /// Record transaction with automatic sync queueing
  Future<void> recordTransaction({
    required TransactionModel transaction,
    required String businessId,
  }) async {
    // Enrich transaction data with business ID
    final transactionData = {
      ...transaction.toJson(),
      'businessId': businessId,
      'action': 'create',
      'syncTimestamp': DateTime.now().toIso8601String(),

      // Additional metadata for sync
      'deviceId': _getDeviceId(),
      'syncVersion': '1.0',
    };

    // Queue for sync
    await _syncService.queueForSync(
      entityId: transaction.id,
      entityType: SyncEntityType.transaction,
      data: transactionData,
    );

    print('✓ Transaction ${transaction.id} queued for sync');
  }

  /// Update transaction status
  Future<void> updateTransactionStatus({
    required String transactionId,
    required TransactionStatus newStatus,
    required String businessId,
    String? reason,
  }) async {
    final updateData = {
      'transactionId': transactionId,
      'businessId': businessId,
      'newStatus': newStatus.name,
      'reason': reason,
      'action': 'status_update',
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _syncService.queueForSync(
      entityId: transactionId,
      entityType: SyncEntityType.transaction,
      data: updateData,
    );

    print('✓ Transaction status update queued for sync');
  }

  /// Process refund
  Future<void> processRefund({
    required String transactionId,
    required double refundAmount,
    required String businessId,
    String? reason,
  }) async {
    final refundData = {
      'transactionId': transactionId,
      'businessId': businessId,
      'refundAmount': refundAmount,
      'reason': reason ?? 'customer_request',
      'action': 'refund',
      'refundDate': DateTime.now().toIso8601String(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _syncService.queueForSync(
      entityId: transactionId,
      entityType: SyncEntityType.transaction,
      data: refundData,
    );

    print('✓ Refund queued for sync');
  }

  /// Batch sync daily transactions
  Future<void> batchSyncDailyTransactions({
    required List<TransactionModel> transactions,
    required String businessId,
  }) async {
    for (var transaction in transactions) {
      await recordTransaction(transaction: transaction, businessId: businessId);
    }

    print('✓ ${transactions.length} transactions queued for batch sync');
  }

  /// Get device identifier (mock - implement proper device ID in production)
  String _getDeviceId() {
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Cancel transaction
  Future<void> cancelTransaction({
    required String transactionId,
    required String businessId,
    String? reason,
  }) async {
    final cancelData = {
      'transactionId': transactionId,
      'businessId': businessId,
      'action': 'cancel',
      'reason': reason ?? 'manual_cancellation',
      'cancelledAt': DateTime.now().toIso8601String(),
    };

    await _syncService.queueForSync(
      entityId: transactionId,
      entityType: SyncEntityType.transaction,
      data: cancelData,
    );

    print('✓ Transaction cancellation queued for sync');
  }
}
