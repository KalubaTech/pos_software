import 'package:get/get.dart';
import '../models/sync_models.dart';
import '../services/data_sync_service.dart';

/// Repository for business settings sync operations
class BusinessSettingsRepository {
  final DataSyncService _syncService = Get.find<DataSyncService>();

  /// Sync business settings to external database
  Future<void> syncBusinessSettings({
    required String businessId,
    required Map<String, dynamic> settings,
  }) async {
    final settingsData = {
      ...settings,
      'businessId': businessId,
      'action': 'update',
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _syncService.queueForSync(
      entityId: businessId,
      entityType: SyncEntityType.businessSettings,
      data: settingsData,
    );

    print('✓ Business settings queued for sync');
  }

  /// Sync cashier/employee data
  Future<void> syncCashier({
    required String cashierId,
    required String businessId,
    required Map<String, dynamic> cashierData,
  }) async {
    final data = {
      ...cashierData,
      'businessId': businessId,
      'action': 'upsert',
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _syncService.queueForSync(
      entityId: cashierId,
      entityType: SyncEntityType.cashier,
      data: data,
    );

    print('✓ Cashier data queued for sync');
  }

  /// Delete cashier
  Future<void> deleteCashier({
    required String cashierId,
    required String businessId,
  }) async {
    final data = {
      'cashierId': cashierId,
      'businessId': businessId,
      'action': 'delete',
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _syncService.queueForSync(
      entityId: cashierId,
      entityType: SyncEntityType.cashier,
      data: data,
    );

    print('✓ Cashier deletion queued for sync');
  }

  /// Sync customer data
  Future<void> syncCustomer({
    required String customerId,
    required String businessId,
    required Map<String, dynamic> customerData,
  }) async {
    final data = {
      ...customerData,
      'businessId': businessId,
      'action': 'upsert',
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _syncService.queueForSync(
      entityId: customerId,
      entityType: SyncEntityType.customer,
      data: data,
    );

    print('✓ Customer data queued for sync');
  }

  /// Delete customer
  Future<void> deleteCustomer({
    required String customerId,
    required String businessId,
  }) async {
    final data = {
      'customerId': customerId,
      'businessId': businessId,
      'action': 'delete',
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _syncService.queueForSync(
      entityId: customerId,
      entityType: SyncEntityType.customer,
      data: data,
    );

    print('✓ Customer deletion queued for sync');
  }
}
