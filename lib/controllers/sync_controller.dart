import 'package:get/get.dart';
import '../models/sync_models.dart';
import '../services/data_sync_service.dart';

/// Controller for managing sync UI and operations
class SyncController extends GetxController {
  final DataSyncService _syncService = Get.find<DataSyncService>();

  // Observables
  final isConfigured = false.obs;
  final isTesting = false.obs;
  final testResult = Rx<String?>(null);

  // Form fields
  final businessIdController = ''.obs;
  final apiUrlController = 'https://api.dynamospos.com'.obs;
  final apiKeyController = ''.obs;
  final autoSync = true.obs;
  final syncInterval = 15.obs; // minutes
  final syncOnlyWifi = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadExistingConfig();
  }

  void _loadExistingConfig() {
    final config = _syncService.syncConfig.value;
    if (config != null) {
      businessIdController.value = config.businessId;
      apiUrlController.value = config.apiBaseUrl;
      apiKeyController.value = config.apiKey;
      autoSync.value = config.autoSync;
      syncInterval.value = config.syncIntervalMinutes;
      syncOnlyWifi.value = config.syncOnlyOnWifi;
      isConfigured.value = true;
    }
  }

  /// Save sync configuration
  Future<void> saveConfiguration() async {
    if (businessIdController.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Business ID is required',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (apiKeyController.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'API Key is required',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final config = SyncConfig(
      businessId: businessIdController.value,
      apiBaseUrl: apiUrlController.value,
      apiKey: apiKeyController.value,
      autoSync: autoSync.value,
      syncIntervalMinutes: syncInterval.value,
      syncOnlyOnWifi: syncOnlyWifi.value,
    );

    await _syncService.saveSyncConfig(config);
    isConfigured.value = true;

    Get.snackbar(
      'Success',
      'Sync configuration saved successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  /// Test API connection
  Future<void> testConnection() async {
    isTesting.value = true;
    testResult.value = null;

    try {
      final isHealthy = await _syncService.testConnection();

      if (isHealthy) {
        final isAuthenticated = await _syncService.validateAuth();

        if (isAuthenticated) {
          testResult.value = 'SUCCESS';
          Get.snackbar(
            'Connection Successful',
            'API is reachable and authentication is valid',
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 3),
          );
        } else {
          testResult.value = 'AUTH_FAILED';
          Get.snackbar(
            'Authentication Failed',
            'API is reachable but authentication failed',
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 3),
          );
        }
      } else {
        testResult.value = 'CONNECTION_FAILED';
        Get.snackbar(
          'Connection Failed',
          'Unable to reach API server',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      testResult.value = 'ERROR';
      Get.snackbar(
        'Test Error',
        'Error testing connection: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    } finally {
      isTesting.value = false;
    }
  }

  /// Trigger manual sync
  Future<void> syncNow() async {
    if (!isConfigured.value) {
      Get.snackbar(
        'Not Configured',
        'Please configure sync settings first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await _syncService.syncNow();
  }

  /// Retry failed records
  Future<void> retryFailed() async {
    await _syncService.retryFailedRecords();
  }

  /// Cleanup old records
  Future<void> cleanup({int days = 30}) async {
    await _syncService.cleanupOldRecords(days: days);
  }

  /// Get sync stats
  SyncStats get stats => _syncService.syncStats.value;

  /// Check if sync is in progress
  bool get isSyncing => _syncService.isSyncing.value;

  /// Get sync config
  SyncConfig? get config => _syncService.syncConfig.value;

  /// Reset configuration
  void resetConfiguration() {
    businessIdController.value = '';
    apiKeyController.value = '';
    autoSync.value = true;
    syncInterval.value = 15;
    syncOnlyWifi.value = false;
    isConfigured.value = false;
    testResult.value = null;
  }
}
