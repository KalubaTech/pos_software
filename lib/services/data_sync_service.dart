import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/sync_models.dart';
import '../repositories/sync_repository.dart';
import './mock_api_service.dart';
import './subscription_service.dart';
import 'package:get_storage/get_storage.dart';

/// Service for synchronizing data with external database
class DataSyncService extends GetxService {
  final SyncRepository _syncRepo = SyncRepository();
  final _storage = GetStorage();

  late MockApiService _apiService;
  Timer? _syncTimer;

  // Observables
  final isSyncing = false.obs;
  final syncStats = Rx<SyncStats>(SyncStats.empty());
  final syncConfig = Rx<SyncConfig?>(null);

  @override
  void onInit() {
    super.onInit();
    _initializeSync();
  }

  Future<void> _initializeSync() async {
    await _syncRepo.initializeSyncTable();
    await _loadSyncConfig();

    if (syncConfig.value != null) {
      _apiService = MockApiService(
        baseUrl: syncConfig.value!.apiBaseUrl,
        apiKey: syncConfig.value!.apiKey,
      );

      await refreshStats();

      if (syncConfig.value!.autoSync) {
        startAutoSync();
      }
    }
  }

  /// Load sync configuration from storage
  Future<void> _loadSyncConfig() async {
    final configData = _storage.read('sync_config');
    if (configData != null) {
      syncConfig.value = SyncConfig.fromJson(
        configData as Map<String, dynamic>,
      );
    }
  }

  /// Save sync configuration
  Future<void> saveSyncConfig(SyncConfig config) async {
    await _storage.write('sync_config', config.toJson());
    syncConfig.value = config;

    _apiService = MockApiService(
      baseUrl: config.apiBaseUrl,
      apiKey: config.apiKey,
    );

    if (config.autoSync) {
      startAutoSync();
    } else {
      stopAutoSync();
    }
  }

  /// Start automatic sync timer
  void startAutoSync() {
    stopAutoSync(); // Clear existing timer

    final config = syncConfig.value;
    if (config == null) return;

    _syncTimer = Timer.periodic(
      Duration(minutes: config.syncIntervalMinutes),
      (_) => syncPendingRecords(),
    );
  }

  /// Stop automatic sync timer
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Queue data for synchronization
  Future<void> queueForSync({
    required String entityId,
    required SyncEntityType entityType,
    required Map<String, dynamic> data,
  }) async {
    final config = syncConfig.value;
    if (config == null) {
      print('Sync not configured. Data not queued.');
      return;
    }

    final record = SyncRecord(
      id: '${entityType.name}_${entityId}_${DateTime.now().millisecondsSinceEpoch}',
      entityId: entityId,
      entityType: entityType,
      businessId: config.businessId,
      status: SyncStatus.pending,
      lastAttempt: DateTime.now(),
      data: data,
    );

    await _syncRepo.addSyncRecord(record);
    await refreshStats();
  }

  /// Sync all pending records
  Future<void> syncPendingRecords() async {
    if (isSyncing.value) {
      print('Sync already in progress');
      return;
    }

    final config = syncConfig.value;
    if (config == null) {
      print('Sync not configured');
      return;
    }

    // Check subscription access
    final subscriptionService = Get.find<SubscriptionService>();
    if (!subscriptionService.hasAccessToSync) {
      Get.snackbar(
        'Subscription Required',
        'Please upgrade your subscription to use cloud sync features.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
      return;
    }

    isSyncing.value = true;

    try {
      final pendingRecords = await _syncRepo.getPendingRecords(
        businessId: config.businessId,
      );

      print('Syncing ${pendingRecords.length} pending records...');

      for (var record in pendingRecords) {
        await _syncSingleRecord(record);
      }

      // Retry failed records (within max retries)
      final failedRecords = await _syncRepo.getFailedRecords(
        businessId: config.businessId,
        maxRetries: config.maxRetries,
      );

      for (var record in failedRecords) {
        await _syncSingleRecord(record);
      }

      await refreshStats();

      Get.snackbar(
        'Sync Complete',
        'Successfully synced ${pendingRecords.length} records',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      print('Sync error: $e');
      Get.snackbar(
        'Sync Error',
        'Failed to sync: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    } finally {
      isSyncing.value = false;
    }
  }

  /// Sync a single record
  Future<void> _syncSingleRecord(SyncRecord record) async {
    try {
      // Update status to syncing
      await _syncRepo.updateSyncRecord(
        record.copyWith(
          status: SyncStatus.syncing,
          lastAttempt: DateTime.now(),
        ),
      );

      ApiResponse<Map<String, dynamic>> response;

      // Call appropriate API based on entity type
      switch (record.entityType) {
        case SyncEntityType.product:
          response = await _apiService.syncProduct(
            businessId: record.businessId,
            productData: record.data,
          );
          break;
        case SyncEntityType.transaction:
          response = await _apiService.syncTransaction(
            businessId: record.businessId,
            transactionData: record.data,
          );
          break;
        case SyncEntityType.stock:
          response = await _apiService.syncStock(
            businessId: record.businessId,
            stockData: record.data,
          );
          break;
        case SyncEntityType.customer:
          response = await _apiService.syncCustomer(
            businessId: record.businessId,
            customerData: record.data,
          );
          break;
        case SyncEntityType.cashier:
          response = await _apiService.syncCashier(
            businessId: record.businessId,
            cashierData: record.data,
          );
          break;
        case SyncEntityType.businessSettings:
          response = await _apiService.syncBusinessSettings(
            businessId: record.businessId,
            settingsData: record.data,
          );
          break;
      }

      if (response.success) {
        // Update record as synced
        await _syncRepo.updateSyncRecord(
          record.copyWith(
            status: SyncStatus.synced,
            lastSuccess: DateTime.now(),
            errorMessage: null,
          ),
        );
        print('✓ Synced ${record.entityType.name} ${record.entityId}');
      } else {
        // Update as failed
        await _syncRepo.updateSyncRecord(
          record.copyWith(
            status: SyncStatus.failed,
            retryCount: record.retryCount + 1,
            errorMessage: response.message,
          ),
        );
        print(
          '✗ Failed to sync ${record.entityType.name} ${record.entityId}: ${response.message}',
        );
      }
    } catch (e) {
      // Handle exceptions
      await _syncRepo.updateSyncRecord(
        record.copyWith(
          status: SyncStatus.failed,
          retryCount: record.retryCount + 1,
          errorMessage: e.toString(),
        ),
      );
      print(
        '✗ Exception syncing ${record.entityType.name} ${record.entityId}: $e',
      );
    }
  }

  /// Refresh sync statistics
  Future<void> refreshStats() async {
    final config = syncConfig.value;
    final stats = await _syncRepo.getSyncStats(businessId: config?.businessId);
    syncStats.value = stats;
  }

  /// Test API connection
  Future<bool> testConnection() async {
    try {
      final response = await _apiService.healthCheck();
      return response.success;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  /// Validate authentication
  Future<bool> validateAuth() async {
    final config = syncConfig.value;
    if (config == null) return false;

    try {
      final response = await _apiService.validateAuth(
        businessId: config.businessId,
      );
      return response.success;
    } catch (e) {
      print('Auth validation failed: $e');
      return false;
    }
  }

  /// Reset failed records for retry
  Future<void> retryFailedRecords() async {
    final config = syncConfig.value;
    if (config == null) return;

    await _syncRepo.resetFailedRecords(businessId: config.businessId);
    await refreshStats();

    Get.snackbar(
      'Retry Queued',
      'Failed records have been queued for retry',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  /// Cleanup old synced records
  Future<void> cleanupOldRecords({int days = 30}) async {
    final config = syncConfig.value;
    if (config == null) return;

    final deletedCount = await _syncRepo.cleanupOldRecords(
      olderThanDays: days,
      businessId: config.businessId,
    );

    await refreshStats();

    Get.snackbar(
      'Cleanup Complete',
      'Deleted $deletedCount old records',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  /// Manual trigger for immediate sync
  Future<void> syncNow() async {
    await syncPendingRecords();
  }

  @override
  void onClose() {
    stopAutoSync();
    super.onClose();
  }
}
