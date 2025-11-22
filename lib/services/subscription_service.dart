import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import '../models/subscription_model.dart';
import '../models/unresolved_transaction_model.dart';
import '../services/database_service.dart';
import '../controllers/universal_sync_controller.dart';

class SubscriptionService extends GetxService {
  final _storage = GetStorage();
  final _db = Get.find<DatabaseService>();

  final Rx<SubscriptionModel?> currentSubscription = Rx<SubscriptionModel?>(
    null,
  );
  final RxBool isLoading = false.obs;

  // Unresolved transactions
  final RxList<UnresolvedTransactionModel> unresolvedTransactions =
      <UnresolvedTransactionModel>[].obs;

  static const String _storageKey = 'current_subscription';
  static const String _tableName = 'subscriptions';
  static const String _unresolvedTableName = 'unresolved_transactions';

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeTable();
    await _initializeUnresolvedTransactionsTable();
    await _loadSubscription();
    await _loadUnresolvedTransactions();
    _startExpiryCheck();

    // Migrate existing subscription to cloud (for subscriptions created before sync was implemented)
    await _migrateExistingSubscriptionToCloud();
  }

  /// Migrate existing subscription to cloud (one-time migration for pre-sync subscriptions)
  Future<void> _migrateExistingSubscriptionToCloud() async {
    try {
      // Check if we have a subscription that needs migration
      final currentSub = currentSubscription.value;
      if (currentSub == null) {
        print('📋 No subscription to migrate');
        return;
      }

      // Try to sync to cloud
      print('🔄 Checking if subscription needs cloud migration...');
      final universalSync = Get.find<UniversalSyncController>();

      // Push current subscription to cloud
      await universalSync.syncSubscription(currentSub);
      print('✅ Migrated subscription to cloud: ${currentSub.planName}');

      // Also trigger full sync to ensure it propagates
      await universalSync.forceSubscriptionSync();
      print('✅ Migration complete - subscription synced');
    } catch (e) {
      print('⚠️ Subscription migration skipped (sync not ready yet): $e');
      // This is OK - will sync later when UniversalSyncController is ready
    }
  }

  Future<void> _initializeTable() async {
    final db = await _db.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id TEXT PRIMARY KEY,
        businessId TEXT NOT NULL,
        plan TEXT NOT NULL,
        status TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT DEFAULT 'ZMW',
        transactionId TEXT,
        paymentMethod TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        UNIQUE(businessId, startDate)
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_subscription_business 
      ON $_tableName(businessId)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_subscription_status 
      ON $_tableName(status)
    ''');
  }

  Future<void> _initializeUnresolvedTransactionsTable() async {
    try {
      print('🔷 [Service] Initializing unresolved transactions table...');
      final db = await _db.database;

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_unresolvedTableName (
          id TEXT PRIMARY KEY,
          businessId TEXT NOT NULL,
          plan TEXT NOT NULL,
          transactionId TEXT NOT NULL,
          lencoReference TEXT,
          phone TEXT NOT NULL,
          operator TEXT NOT NULL,
          amount REAL NOT NULL,
          status TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          lastCheckedAt TEXT,
          checkAttempts INTEGER DEFAULT 0,
          lastError TEXT
        )
      ''');
      print('✅ [Service] Table created/verified');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_unresolved_business 
        ON $_unresolvedTableName(businessId)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_unresolved_status 
        ON $_unresolvedTableName(status)
      ''');
      print('✅ [Service] Indexes created/verified');

      // Verify table exists and check record count
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_unresolvedTableName',
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      print('📊 [Service] Table verified: $count records exist');
    } catch (e) {
      print('❌ [Service] Error initializing unresolved transactions table: $e');
      print('🔍 [Service] Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _loadUnresolvedTransactions() async {
    try {
      print('🔄 [Service] _loadUnresolvedTransactions called');
      final db = await _db.database;
      print('💾 [Service] Querying database...');

      final results = await db.query(
        _unresolvedTableName,
        where: 'status != ?',
        whereArgs: ['resolved'],
        orderBy: 'createdAt DESC',
      );

      print('📊 [Service] Query returned ${results.length} records');

      final transactions = results
          .map((json) => UnresolvedTransactionModel.fromJson(json))
          .toList();

      print('📋 [Service] Parsed ${transactions.length} transactions');
      print(
        '📝 [Service] Transaction IDs: ${transactions.map((t) => t.transactionId).toList()}',
      );

      print('🔧 [Service] Setting observable value...');
      print(
        '🔧 [Service] Before: unresolvedTransactions.length = ${unresolvedTransactions.length}',
      );

      unresolvedTransactions.value = transactions;

      print(
        '🔧 [Service] After: unresolvedTransactions.length = ${unresolvedTransactions.length}',
      );
      print(
        '✅ [Service] Loaded ${unresolvedTransactions.length} unresolved transactions',
      );

      // Force a manual update to ensure observers are notified
      unresolvedTransactions.refresh();
      print('🔔 [Service] Called refresh() on observable');
    } catch (e) {
      print('❌ [Service] Error loading unresolved transactions: $e');
      print('🔍 [Service] Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _loadSubscription() async {
    try {
      isLoading.value = true;

      // First check storage
      final storedData = _storage.read(_storageKey);
      if (storedData != null) {
        final subscription = SubscriptionModel.fromJson(storedData);
        if (subscription.isActive) {
          currentSubscription.value = subscription;
          return;
        }
      }

      // Load from database
      final db = await _db.database;
      final results = await db.query(
        _tableName,
        where: 'status = ?',
        whereArgs: ['active'],
        orderBy: 'endDate DESC',
        limit: 1,
      );

      if (results.isNotEmpty) {
        final subscription = SubscriptionModel.fromJson(results.first);
        if (subscription.isActive) {
          currentSubscription.value = subscription;
          await _storage.write(_storageKey, subscription.toJson());
        } else {
          // Expired, update status
          await _updateSubscriptionStatus(
            subscription.id,
            SubscriptionStatus.expired,
          );
        }
      } else {
        // No subscription found, create a free one
        await _createFreeSubscription();
      }
    } catch (e) {
      print('Error loading subscription: $e');
      await _createFreeSubscription();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createFreeSubscription() async {
    final freeSubscription = SubscriptionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      businessId: 'default',
      plan: SubscriptionPlan.free,
      status: SubscriptionStatus.active,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 36500)), // 100 years
      amount: 0,
      createdAt: DateTime.now(),
    );

    await _saveSubscription(freeSubscription);
    currentSubscription.value = freeSubscription;
  }

  Future<void> _saveSubscription(SubscriptionModel subscription) async {
    final db = await _db.database;
    await db.insert(
      _tableName,
      subscription.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _storage.write(_storageKey, subscription.toJson());
  }

  /// Public method to save subscription (for sync purposes)
  Future<void> saveSubscription(SubscriptionModel subscription) async {
    await _saveSubscription(subscription);
    currentSubscription.value = subscription;
  }

  Future<void> _updateSubscriptionStatus(
    String subscriptionId,
    SubscriptionStatus status,
  ) async {
    final db = await _db.database;
    await db.update(
      _tableName,
      {'status': status.name, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [subscriptionId],
    );

    if (currentSubscription.value?.id == subscriptionId) {
      currentSubscription.value = currentSubscription.value?.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await _storage.write(_storageKey, currentSubscription.value?.toJson());
    }
  }

  void _startExpiryCheck() {
    // Check subscription expiry every hour
    Future.delayed(Duration(hours: 1), () async {
      await checkAndUpdateExpiredSubscriptions();
      _startExpiryCheck();
    });
  }

  Future<void> checkAndUpdateExpiredSubscriptions() async {
    final current = currentSubscription.value;
    if (current != null &&
        current.isExpired &&
        current.status == SubscriptionStatus.active) {
      await _updateSubscriptionStatus(current.id, SubscriptionStatus.expired);

      // Sync expired subscription status to cloud
      try {
        final universalSync = Get.find<UniversalSyncController>();
        if (currentSubscription.value != null) {
          await universalSync.syncSubscription(currentSubscription.value!);
          print('✅ Expired subscription status synced to cloud');
        }
      } catch (e) {
        print('⚠️ Failed to sync expired subscription to cloud: $e');
      }

      Get.snackbar(
        'Subscription Expired',
        'Your subscription has expired. Upgrade to continue using cloud sync.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    }
  }

  Future<bool> activateSubscription({
    required String businessId,
    required SubscriptionPlan plan,
    required String transactionId,
    String? paymentMethod,
  }) async {
    try {
      if (plan == SubscriptionPlan.free) {
        Get.snackbar(
          'Error',
          'Cannot activate free plan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      final now = DateTime.now();
      final durationInDays = SubscriptionModel.getPlanDurationInDays(plan);
      final endDate = now.add(Duration(days: durationInDays));
      final amount = SubscriptionModel.getPlanPrice(plan);

      // Deactivate current subscription if exists
      if (currentSubscription.value != null &&
          currentSubscription.value!.plan != SubscriptionPlan.free) {
        await _updateSubscriptionStatus(
          currentSubscription.value!.id,
          SubscriptionStatus.cancelled,
        );
      }

      // Create new subscription
      final newSubscription = SubscriptionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        businessId: businessId,
        plan: plan,
        status: SubscriptionStatus.active,
        startDate: now,
        endDate: endDate,
        amount: amount,
        transactionId: transactionId,
        paymentMethod: paymentMethod,
        createdAt: now,
      );

      await _saveSubscription(newSubscription);
      currentSubscription.value = newSubscription;

      // Sync subscription to cloud immediately
      try {
        final universalSync = Get.find<UniversalSyncController>();
        await universalSync.syncSubscription(newSubscription);
        print('✅ Subscription synced to cloud');
      } catch (e) {
        print('⚠️ Failed to sync subscription to cloud: $e');
        // Continue even if sync fails - will be synced later
      }

      Get.snackbar(
        'Subscription Activated',
        'Your ${newSubscription.planName} subscription is now active!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      print('Error activating subscription: $e');
      Get.snackbar(
        'Error',
        'Failed to activate subscription: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<void> cancelSubscription() async {
    final current = currentSubscription.value;
    if (current == null || current.plan == SubscriptionPlan.free) {
      Get.snackbar(
        'Error',
        'No active subscription to cancel',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    await _updateSubscriptionStatus(current.id, SubscriptionStatus.cancelled);

    // Sync subscription status to cloud
    try {
      final universalSync = Get.find<UniversalSyncController>();
      if (currentSubscription.value != null) {
        await universalSync.syncSubscription(currentSubscription.value!);
        print('✅ Cancelled subscription synced to cloud');
      }
    } catch (e) {
      print('⚠️ Failed to sync cancelled subscription to cloud: $e');
    }

    Get.snackbar(
      'Subscription Cancelled',
      'Your subscription will remain active until ${current.endDate.toString().split(' ')[0]}',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: Duration(seconds: 4),
    );
  }

  bool get hasAccessToSync {
    return currentSubscription.value?.hasAccessToSync ?? false;
  }

  bool get isSubscriptionActive {
    return currentSubscription.value?.isActive ?? false;
  }

  SubscriptionPlan get currentPlan {
    return currentSubscription.value?.plan ?? SubscriptionPlan.free;
  }

  int get daysRemaining {
    return currentSubscription.value?.daysRemaining ?? 0;
  }

  Future<List<SubscriptionModel>> getSubscriptionHistory(
    String businessId,
  ) async {
    final db = await _db.database;
    final results = await db.query(
      _tableName,
      where: 'businessId = ?',
      whereArgs: [businessId],
      orderBy: 'createdAt DESC',
    );

    return results.map((json) => SubscriptionModel.fromJson(json)).toList();
  }

  // Real payment integration with Lenco Mobile Money API
  Future<Map<String, dynamic>?> processPayment({
    required SubscriptionPlan plan,
    required String businessId,
    required String phoneNumber,
    required String operator, // 'airtel', 'mtn', 'zamtel'
  }) async {
    try {
      final amount = SubscriptionModel.getPlanPrice(plan);
      final reference =
          'SUB-${businessId}-${DateTime.now().millisecondsSinceEpoch}';

      // Prepare request
      var headers = {'Content-Type': 'application/json'};

      var request = http.Request(
        'POST',
        Uri.parse(
          'https://kalootech.com/pay/lenco/mobile-money/collection.php',
        ),
      );

      request.body = json.encode({
        "amount": amount,
        "reference": reference,
        "phone": phoneNumber,
        "operator": operator.toLowerCase(), // airtel, mtn, zamtel
        "country": "zm",
        "bearer": "merchant",
      });

      request.headers.addAll(headers);

      print('Sending payment request: $reference');

      // Send request
      http.StreamedResponse response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);

        // Check if payment was successful based on Lenco API response
        if (responseData['status'] == true) {
          final data = responseData['data'];
          final status = data['status'];

          print('Payment initiated with status: $status');
          print('Payment data: ${data.toString()}');

          // Payment initiated successfully
          // Status can be: "pay-offline" (awaiting approval), "completed", etc.
          return {
            'success': true,
            'status': status,
            'transactionId': reference,
            // Handle both snake_case and camelCase
            'lencoReference': data['lenco_reference'] ?? data['lencoReference'],
            'amount': amount,
            'phone': phoneNumber,
            'operator': operator,
            'message': responseData['message'] ?? 'Payment initiated',
            'paymentId': data['id'],
            'initiatedAt': data['initiated_at'] ?? data['initiatedAt'],
            'rawResponse': responseData,
          };
        } else {
          // Payment failed (status: false)
          return {
            'success': false,
            'error': responseData['message'] ?? 'Payment failed',
            'statusCode': response.statusCode,
          };
        }
      } else if (response.statusCode == 400) {
        // Bad request (e.g., duplicate reference)
        final responseData = json.decode(responseBody);
        return {
          'success': false,
          'error': responseData['message'] ?? 'Bad request',
          'statusCode': 400,
        };
      } else {
        // Other errors
        return {
          'success': false,
          'error': response.reasonPhrase ?? 'Payment failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Payment error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Helper to validate and format phone number
  String formatPhoneNumber(String phone) {
    // Remove any spaces or special characters
    phone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Ensure Zambian format (0XXX... or +260XXX...)
    if (phone.startsWith('0')) {
      return phone; // Keep as is (0973232553)
    } else if (phone.startsWith('+260')) {
      return '0${phone.substring(4)}'; // Convert +260973232553 to 0973232553
    } else if (phone.startsWith('260')) {
      return '0${phone.substring(3)}'; // Convert 260973232553 to 0973232553
    }

    return phone;
  }

  // Determine operator from phone number
  String? detectOperator(String phone) {
    phone = formatPhoneNumber(phone);

    // Remove leading 0
    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    // MTN: 096, 076
    if (phone.startsWith('96') || phone.startsWith('76')) {
      return 'mtn';
    }

    // Airtel: 097, 077
    if (phone.startsWith('97') || phone.startsWith('77')) {
      return 'airtel';
    }

    // Zamtel: 095, 075
    if (phone.startsWith('95') || phone.startsWith('75')) {
      return 'zamtel';
    }

    return null;
  }

  // Check transaction status via Lenco API
  // Can check by either reference (our transaction ID) or lenco_reference (Lenco's ID)
  Future<Map<String, dynamic>?> checkTransactionStatus(
    String reference, {
    String? lencoReference,
  }) async {
    try {
      // Use lenco_reference if provided, otherwise use reference
      final queryParam = lencoReference != null
          ? 'lenco_reference=$lencoReference'
          : 'reference=$reference';

      final url = Uri.parse(
        'https://kalootech.com/pay/lenco/transaction.php?$queryParam',
      );

      print('Checking transaction status: $queryParam');

      final response = await http.get(url);

      print('Status check response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Status response body: ${response.body}');

        // Parse response with new structure
        if (responseData['status'] == true) {
          final data = responseData['data'];

          return {
            'success': true,
            'found': true,
            'status': data['status'], // completed, failed, pay-offline, etc.
            'event': data['event'], // collection.completed, collection.failed
            'transactionId': data['reference'],
            'lencoReference': data['lenco_reference'],
            'lencoId': data['lenco_id'],
            'amount': double.tryParse(data['amount'].toString()) ?? 0.0,
            'fee': data['fee'],
            'bearer': data['bearer'],
            'currency': data['currency'],
            'type': data['type'],
            'completedAt': data['completed_at'],
            'initiatedAt': data['initiated_at'],
            'reasonForFailure': data['reason_for_failure'],
            'settlementStatus': data['settlement_status'],
            // Mobile Money details
            'mmCountry': data['mm_country'],
            'mmPhone': data['mm_phone'],
            'mmOperator': data['mm_operator'],
            'mmAccountName': data['mm_account_name'],
            'mmOperatorTxnId': data['mm_operator_txn_id'],
            'rawResponse': responseData,
          };
        } else {
          // Transaction not found yet
          return {
            'success': true,
            'found': false,
            'message': responseData['message'] ?? 'Transaction not found',
            'reference': reference,
          };
        }
      } else {
        return {
          'success': false,
          'found': false,
          'error': response.reasonPhrase ?? 'Failed to check status',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Status check error: $e');
      return {'success': false, 'found': false, 'error': e.toString()};
    }
  }

  // Wait for payment confirmation with polling
  Future<Map<String, dynamic>?> waitForPaymentConfirmation({
    required Map<String, dynamic> paymentResult,
    int maxAttempts = 5, // 5 attempts
    Duration pollInterval = const Duration(seconds: 5), // Check every 5 seconds
  }) async {
    if (paymentResult['success'] != true) {
      return paymentResult; // Already failed
    }

    final status = paymentResult['status'];
    final reference = paymentResult['transactionId'];
    final lencoReference = paymentResult['lencoReference'];

    // If already completed, return immediately
    if (status == 'completed') {
      return paymentResult;
    }

    // If status is "pay-offline", user needs to approve on their phone
    if (status == 'pay-offline') {
      print('Payment initiated. Waiting for user approval...');
      print('Reference: $reference, Lenco Reference: $lencoReference');

      // Poll for status updates
      for (int i = 0; i < maxAttempts; i++) {
        await Future.delayed(pollInterval);

        print('Checking status... Attempt ${i + 1}/$maxAttempts');

        // Check the payment status via API using lenco_reference
        final statusCheck = await checkTransactionStatus(
          reference,
          lencoReference: lencoReference,
        );

        if (statusCheck != null && statusCheck['success'] == true) {
          // Check if transaction was found
          if (statusCheck['found'] == true) {
            final currentStatus = statusCheck['status'];

            print('Current status: $currentStatus');

            if (currentStatus == 'completed') {
              print('Payment completed successfully!');
              return {
                ...paymentResult,
                'status': 'completed',
                'completedAt': statusCheck['completedAt'],
                'mmAccountName': statusCheck['mmAccountName'],
                'mmOperatorTxnId': statusCheck['mmOperatorTxnId'],
                'confirmedViaPolling': true,
              };
            } else if (currentStatus == 'failed') {
              print('Payment failed: ${statusCheck['reasonForFailure']}');
              return {
                'success': false,
                'error': statusCheck['reasonForFailure'] ?? 'Payment failed',
                'status': 'failed',
                'mmAccountName': statusCheck['mmAccountName'],
              };
            }
            // If still pay-offline, continue polling
          } else {
            // Transaction not found yet - continue polling
            print('Transaction not found yet, continuing...');
          }
        }
      }

      // Timeout - payment not confirmed within expected time
      print(
        'Payment confirmation timeout after ${maxAttempts * pollInterval.inSeconds} seconds',
      );
      return {
        'success': false,
        'error': 'Payment confirmation pending',
        'status': 'not-found',
        'note': 'Transaction not found. Please check status manually.',
        'transactionId': reference,
        'lencoReference': lencoReference,
      };
    }

    return paymentResult;
  }

  // Helper method to check if payment was successful
  bool isPaymentSuccessful(Map<String, dynamic>? paymentResult) {
    if (paymentResult == null) return false;

    // Payment is successful if:
    // 1. success flag is true
    // 2. status is either "completed" or "pay-offline" (initiated successfully)
    final success = paymentResult['success'] == true;
    final status = paymentResult['status'];

    return success && (status == 'completed' || status == 'pay-offline');
  }

  // ========== Unresolved Transactions Management ==========

  /// Add a transaction to unresolved list
  Future<void> addUnresolvedTransaction({
    required String businessId,
    required SubscriptionPlan plan,
    required String transactionId,
    String? lencoReference,
    required String phone,
    required String operator,
    required double amount,
  }) async {
    try {
      print('🔷 [Service] Adding unresolved transaction...');
      print('📝 [Service] Transaction ID: $transactionId');
      print('📝 [Service] Phone: $phone');
      print('📝 [Service] Operator: $operator');
      print('📝 [Service] Amount: $amount');

      final transaction = UnresolvedTransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        businessId: businessId,
        plan: plan,
        transactionId: transactionId,
        lencoReference: lencoReference,
        phone: phone,
        operator: operator,
        amount: amount,
        status: TransactionStatus.pending,
        createdAt: DateTime.now(),
        checkAttempts: 0,
      );

      print('💾 [Service] Inserting into database...');
      final db = await _db.database;
      await db.insert(
        _unresolvedTableName,
        transaction.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ [Service] Database insert successful');

      print('🔄 [Service] Reloading unresolved transactions...');
      await _loadUnresolvedTransactions();
      print(
        '✅ [Service] Added unresolved transaction: ${transaction.transactionId}',
      );
      print('📊 [Service] Current count: ${unresolvedTransactions.length}');
      print(
        '📋 [Service] List contents: ${unresolvedTransactions.map((t) => t.transactionId).toList()}',
      );
    } catch (e) {
      print('❌ [Service] Error adding unresolved transaction: $e');
      print('🔍 [Service] Stack trace: ${StackTrace.current}');
    }
  }

  /// Update an unresolved transaction
  Future<void> updateUnresolvedTransaction(
    String id, {
    TransactionStatus? status,
    DateTime? lastCheckedAt,
    int? checkAttempts,
    String? lastError,
  }) async {
    try {
      final db = await _db.database;

      final current = unresolvedTransactions.firstWhere(
        (t) => t.id == id,
        orElse: () => throw Exception('Transaction not found'),
      );

      final updated = current.copyWith(
        status: status,
        lastCheckedAt: lastCheckedAt,
        checkAttempts: checkAttempts,
        lastError: lastError,
      );

      await db.update(
        _unresolvedTableName,
        updated.toJson(),
        where: 'id = ?',
        whereArgs: [id],
      );

      await _loadUnresolvedTransactions();
      print('Updated unresolved transaction: $id');
    } catch (e) {
      print('Error updating unresolved transaction: $e');
    }
  }

  /// Remove a resolved transaction
  Future<void> removeUnresolvedTransaction(String id) async {
    try {
      final db = await _db.database;

      // Mark as resolved instead of deleting (for history)
      await db.update(
        _unresolvedTableName,
        {'status': TransactionStatus.resolved.name},
        where: 'id = ?',
        whereArgs: [id],
      );

      await _loadUnresolvedTransactions();
      print('Marked transaction as resolved: $id');
    } catch (e) {
      print('Error removing unresolved transaction: $e');
    }
  }

  /// Retry checking status for an unresolved transaction
  Future<Map<String, dynamic>?> retryUnresolvedTransaction(
    UnresolvedTransactionModel transaction,
  ) async {
    try {
      print('=== RETRYING TRANSACTION CHECK ===');
      print('Transaction ID: ${transaction.transactionId}');
      print('Lenco Reference: ${transaction.lencoReference}');
      print('Attempt: ${transaction.checkAttempts + 1}');

      // Update status to checking
      await updateUnresolvedTransaction(
        transaction.id,
        status: TransactionStatus.checking,
        lastCheckedAt: DateTime.now(),
        checkAttempts: transaction.checkAttempts + 1,
      );

      // Check transaction status
      final statusCheck = await checkTransactionStatus(
        transaction.transactionId,
        lencoReference: transaction.lencoReference,
      );

      if (statusCheck != null && statusCheck['success'] == true) {
        if (statusCheck['found'] == true) {
          final status = statusCheck['status'];
          print('Transaction status: $status');

          if (status == 'completed') {
            // Payment successful - activate subscription
            final success = await activateSubscription(
              businessId: transaction.businessId,
              plan: transaction.plan,
              transactionId: transaction.transactionId,
              paymentMethod:
                  '${transaction.operatorName} (${transaction.phone})',
            );

            if (success) {
              // Remove from unresolved
              await removeUnresolvedTransaction(transaction.id);

              return {
                'success': true,
                'status': 'completed',
                'message': 'Payment completed! Subscription activated.',
                'mmAccountName': statusCheck['mmAccountName'],
                'mmOperatorTxnId': statusCheck['mmOperatorTxnId'],
              };
            }
          } else if (status == 'failed') {
            // Payment failed - remove from unresolved
            await removeUnresolvedTransaction(transaction.id);

            return {
              'success': false,
              'status': 'failed',
              'message': statusCheck['reasonForFailure'] ?? 'Payment failed',
              'mmAccountName': statusCheck['mmAccountName'],
            };
          } else {
            // Still pending
            await updateUnresolvedTransaction(
              transaction.id,
              status: TransactionStatus.pending,
              lastError: 'Payment still pending',
            );

            return {
              'success': false,
              'status': 'pending',
              'message': 'Payment is still being processed',
            };
          }
        } else {
          // Transaction not found
          await updateUnresolvedTransaction(
            transaction.id,
            status: TransactionStatus.notFound,
            lastError: 'Transaction not found',
          );

          return {
            'success': false,
            'status': 'not-found',
            'message': 'Transaction not found yet. Please try again later.',
          };
        }
      } else {
        // API error
        await updateUnresolvedTransaction(
          transaction.id,
          status: TransactionStatus.timeout,
          lastError: statusCheck?['error'] ?? 'API error',
        );

        return {
          'success': false,
          'status': 'error',
          'message': statusCheck?['error'] ?? 'Failed to check status',
        };
      }
    } catch (e) {
      print('Error retrying transaction: $e');

      await updateUnresolvedTransaction(
        transaction.id,
        status: TransactionStatus.timeout,
        lastError: e.toString(),
      );

      return {'success': false, 'status': 'error', 'message': 'Error: $e'};
    }

    return null; // Fallback return
  }

  /// Clean up old resolved transactions (older than 30 days)
  Future<void> cleanupOldTransactions() async {
    try {
      final db = await _db.database;
      final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));

      await db.delete(
        _unresolvedTableName,
        where: 'status = ? AND createdAt < ?',
        whereArgs: [
          TransactionStatus.resolved.name,
          thirtyDaysAgo.toIso8601String(),
        ],
      );

      print('Cleaned up old resolved transactions');
    } catch (e) {
      print('Error cleaning up old transactions: $e');
    }
  }
}
