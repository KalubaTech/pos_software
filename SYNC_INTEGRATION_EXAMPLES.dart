// Example: How to integrate sync into your existing code

import 'package:get/get.dart';
import 'repositories/product_repository.dart';
import 'repositories/transaction_repository.dart';
import 'repositories/business_repository.dart';
import 'models/product_model.dart';
import 'models/transaction_model.dart';

/// Example 1: Product Controller Integration
class ProductController extends GetxController {
  final ProductRepository _productRepo = ProductRepository();
  final String businessId = 'BUS_ABC123'; // Get from business settings

  // When adding a new product
  Future<void> addProduct(ProductModel product) async {
    // 1. Save to local database (existing code)
    // await _localDb.insertProduct(product);

    // 2. Queue for sync (new code)
    await _productRepo.addProduct(product: product, businessId: businessId);
  }

  // When updating a product
  Future<void> updateProduct(ProductModel product) async {
    // 1. Update local database
    // await _localDb.updateProduct(product);

    // 2. Queue for sync
    await _productRepo.updateProduct(product: product, businessId: businessId);
  }

  // When adjusting stock
  Future<void> adjustStock(String productId, int newStock) async {
    // 1. Update local database
    // await _localDb.updateStock(productId, newStock);

    // 2. Queue for sync
    await _productRepo.updateProductStock(
      productId: productId,
      newStock: newStock,
      businessId: businessId,
      reason: 'manual_adjustment',
    );
  }
}

/// Example 2: Cart Controller Integration
class CartController extends GetxController {
  final TransactionRepository _transactionRepo = TransactionRepository();
  final String businessId = 'BUS_ABC123';

  // When completing a sale
  Future<void> completeSale({
    required List<CartItemModel> items,
    required PaymentMethod paymentMethod,
    required String cashierId,
    required String cashierName,
  }) async {
    final transaction = TransactionModel(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      storeId: businessId, // Use businessId as storeId
      transactionDate: DateTime.now(),
      items: items,
      subtotal: calculateSubtotal(items),
      tax: calculateTax(items),
      discount: 0,
      total: calculateTotal(items),
      paymentMethod: paymentMethod,
      cashierId: cashierId,
      cashierName: cashierName,
    );

    // 1. Save to local database
    // await _localDb.insertTransaction(transaction);

    // 2. Queue for sync (automatically includes businessId)
    await _transactionRepo.recordTransaction(
      transaction: transaction,
      businessId: businessId,
    );

    // 3. Update local stock
    for (var item in items) {
      // await _localDb.decrementStock(item.productId, item.quantity);

      // 4. Queue stock update for sync
      await ProductRepository().updateProductStock(
        productId: item.productId,
        newStock: item.quantity, // Replace with actual new stock value
        businessId: businessId,
        reason: 'sale',
      );
    }
  }

  double calculateSubtotal(List<CartItemModel> items) {
    return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  double calculateTax(List<CartItemModel> items) {
    // Implement your tax calculation
    return calculateSubtotal(items) * 0.16; // 16% tax
  }

  double calculateTotal(List<CartItemModel> items) {
    return calculateSubtotal(items) + calculateTax(items);
  }
}

/// Example 3: Business Settings Integration
class BusinessSettingsController extends GetxController {
  final BusinessRepository _businessRepo = BusinessRepository();
  final String businessId = 'BUS_ABC123';

  // When saving business settings
  Future<void> saveSettings() async {
    final settingsData = {
      'storeName': storeName.value,
      'storeAddress': storeAddress.value,
      'storePhone': storePhone.value,
      'taxRate': taxRate.value,
      'currency': currency.value,
      'taxEnabled': taxEnabled.value,
      // ... all other settings
    };

    // 1. Save to local storage
    // await _storage.write('settings', settingsData);

    // 2. Queue for sync
    await _businessRepo.syncBusinessSettings(
      businessId: businessId,
      settings: settingsData,
    );
  }

  final storeName = 'My Store'.obs;
  final storeAddress = ''.obs;
  final storePhone = ''.obs;
  final taxRate = 16.0.obs;
  final currency = 'ZMW'.obs;
  final taxEnabled = true.obs;
}

/// Example 4: Auth Controller Integration (Cashier Management)
class AuthController extends GetxController {
  final BusinessRepository _businessRepo = BusinessRepository();
  final String businessId = 'BUS_ABC123';

  // When adding a cashier
  Future<void> addCashier({
    required String name,
    required String pin,
    required String role,
  }) async {
    final cashierId = 'cashier_${DateTime.now().millisecondsSinceEpoch}';

    final cashierData = {
      'id': cashierId,
      'name': name,
      'pin': pin, // Consider hashing in production
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
      'isActive': true,
    };

    // 1. Save to local database
    // await _localDb.insertCashier(cashierData);

    // 2. Queue for sync
    await _businessRepo.syncCashier(
      cashierId: cashierId,
      businessId: businessId,
      cashierData: cashierData,
    );
  }

  // When deleting a cashier
  Future<void> deleteCashier(String cashierId) async {
    // 1. Delete from local database
    // await _localDb.deleteCashier(cashierId);

    // 2. Queue deletion for sync
    await _businessRepo.deleteCashier(
      cashierId: cashierId,
      businessId: businessId,
    );
  }
}

/// Example 5: Manual Sync Trigger
class SyncManagementController extends GetxController {
  final DataSyncService _syncService = Get.find<DataSyncService>();

  // Trigger sync from anywhere in your app
  Future<void> triggerSync() async {
    await _syncService.syncNow();
  }

  // Check sync status
  void checkSyncStatus() {
    final stats = _syncService.syncStats.value;

    if (stats.totalPending > 0) {
      Get.snackbar(
        'Sync Pending',
        '${stats.totalPending} records waiting to sync',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    if (stats.totalFailed > 0) {
      Get.snackbar(
        'Sync Issues',
        '${stats.totalFailed} records failed to sync',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
      );
    }
  }

  // Retry failed records
  Future<void> retryFailed() async {
    await _syncService.retryFailedRecords();
  }
}

/// Example 6: Getting Business ID from Settings
class ConfigHelper {
  static String getBusinessId() {
    // Option 1: From business settings controller
    final businessSettings = Get.find<BusinessSettingsController>();
    // Assuming you add businessId to business settings
    // return businessSettings.businessId.value;

    // Option 2: From storage
    final storage = GetStorage();
    return storage.read('business_id') ?? 'BUS_DEFAULT';

    // Option 3: From sync configuration
    final syncService = Get.find<DataSyncService>();
    return syncService.syncConfig.value?.businessId ?? 'BUS_DEFAULT';
  }
}

/// Example 7: Inventory Adjustment with Sync
class InventoryController extends GetxController {
  final ProductRepository _productRepo = ProductRepository();
  final businessId = ConfigHelper.getBusinessId();

  // Bulk inventory count/adjustment
  Future<void> performInventoryCount(
    Map<String, int> stockCounts, // productId -> actualStock
  ) async {
    // 1. Update local database
    for (var entry in stockCounts.entries) {
      // await _localDb.updateStock(entry.key, entry.value);
    }

    // 2. Queue bulk sync
    await _productRepo.bulkStockAdjustment(
      stockChanges: stockCounts,
      businessId: businessId,
      reason: 'inventory_count',
    );
  }
}

/// Example 8: Using Sync in Background
/// Add this to your main app initialization
void setupAutoSync() async {
  final syncService = Get.put(DataSyncService());

  // Auto-sync will start if configured
  // Configure sync if not done yet
  final hasConfig = syncService.syncConfig.value != null;

  if (!hasConfig) {
    print('⚠️ Sync not configured. Configure in Settings → Sync');
  } else {
    print('✓ Auto-sync is active');

    // Optionally: Sync on app startup
    await syncService.syncNow();
  }
}
