# Database Migration Guide

## Overview
This guide helps migrate the POS system from GetStorage/dummy data to SQLite for full offline support.

## Step 1: Initialize Database Service

Add to `main.dart`:

```dart
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final dbService = Get.put(DatabaseService());
  await dbService.database; // Ensures database is created
  
  // ... rest of initialization
  runApp(MyApp());
}
```

## Step 2: Update ProductController

Replace dummy data loading with database queries:

```dart
class ProductController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  
  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }
  
  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      final dbProducts = await _dbService.getAllProducts();
      products.value = dbProducts;
      filteredProducts.value = dbProducts;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> addProduct(ProductModel product) async {
    try {
      await _dbService.insertProduct(product);
      await loadProducts(); // Refresh
      Get.snackbar('Success', 'Product added');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: $e');
    }
  }
  
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _dbService.updateProduct(product);
      await loadProducts();
      Get.snackbar('Success', 'Product updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update product: $e');
    }
  }
  
  Future<void> deleteProduct(String id) async {
    try {
      await _dbService.deleteProduct(id);
      await loadProducts();
      Get.snackbar('Success', 'Product deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: $e');
    }
  }
}
```

## Step 3: Update CartController

Modify checkout to save to database:

```dart
Future<bool> checkout({
  PaymentMethod paymentMethod = PaymentMethod.cash,
  double amountPaid = 0,
  bool printReceipt = true,
}) async {
  if (cartItems.isEmpty) {
    Get.snackbar('Error', 'Cart is empty');
    return false;
  }

  try {
    final DatabaseService _dbService = Get.find<DatabaseService>();
    final cashierName = _authController.currentCashierName;
    final cashierId = _authController.currentCashierId;

    final transaction = TransactionModel(
      id: 't${DateTime.now().millisecondsSinceEpoch}',
      storeId: 's1',
      transactionDate: DateTime.now(),
      items: List.from(cartItems),
      subtotal: subtotal,
      tax: tax,
      discount: discount.value,
      total: total,
      status: TransactionStatus.completed,
      paymentMethod: paymentMethod,
      customerId: selectedCustomerId.value.isEmpty
          ? null
          : selectedCustomerId.value,
      customerName: selectedCustomerName.value.isEmpty
          ? null
          : selectedCustomerName.value,
      cashierId: cashierId,
      cashierName: cashierName,
    );

    // Save to database (also updates stock automatically)
    await _dbService.insertTransaction(transaction);

    // Generate and print receipt if requested
    if (printReceipt) {
      final receipt = _generateReceipt(transaction, amountPaid);
      if (_printerService.isConnected.value) {
        await _printerService.printReceipt(receipt);
      }
    }

    Get.snackbar(
      'Success',
      'Transaction completed successfully',
      duration: Duration(seconds: 2),
    );

    clearCart();
    return true;
  } catch (e) {
    Get.snackbar('Error', 'Failed to complete transaction: $e');
    return false;
  }
}
```

## Step 4: Update BusinessSettingsController

Replace GetStorage with SQLite:

```dart
class BusinessSettingsController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  
  // Observable settings
  var storeName = 'My Store'.obs;
  var currency = 'ZMW'.obs;
  // ... other settings
  
  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }
  
  Future<void> loadSettings() async {
    try {
      storeName.value = await _dbService.getSetting('storeName', 'string') ?? 'My Store';
      currency.value = await _dbService.getSetting('currency', 'string') ?? 'ZMW';
      // Load other settings...
    } catch (e) {
      print('Error loading settings: $e');
    }
  }
  
  Future<void> saveSettings() async {
    try {
      await _dbService.saveSetting('storeName', storeName.value, 'string');
      await _dbService.saveSetting('currency', currency.value, 'string');
      // Save other settings...
      
      Get.snackbar('Success', 'Settings saved');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save settings: $e');
    }
  }
}
```

## Step 5: Update CustomerController

```dart
class CustomerController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  var customers = <ClientModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }
  
  Future<void> loadCustomers() async {
    try {
      final dbCustomers = await _dbService.getAllCustomers();
      customers.value = dbCustomers;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load customers: $e');
    }
  }
  
  Future<void> addCustomer(ClientModel customer) async {
    try {
      await _dbService.insertCustomer(customer);
      await loadCustomers();
      Get.snackbar('Success', 'Customer added');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add customer: $e');
    }
  }
}
```

## Step 6: Add Sample Data (Optional)

Create a method to populate initial data:

```dart
Future<void> seedDatabase() async {
  final dbService = Get.find<DatabaseService>();
  
  // Check if products exist
  final products = await dbService.getAllProducts();
  if (products.isNotEmpty) return; // Already seeded
  
  // Add sample products
  await dbService.insertProduct(ProductModel(
    id: 'p1',
    storeId: 's1',
    name: 'Coca Cola',
    description: 'Refreshing soft drink',
    price: 15.00,
    category: 'Beverages',
    imageUrl: 'https://example.com/coke.jpg',
    stock: 100,
    sku: 'BEV-COKE-001',
    barcode: '123456789',
    variants: [
      ProductVariant(
        id: 'v1',
        name: '330ml',
        attributeType: 'Size',
        priceAdjustment: 0,
        stock: 50,
        sku: 'BEV-COKE-330',
      ),
      ProductVariant(
        id: 'v2',
        name: '500ml',
        attributeType: 'Size',
        priceAdjustment: 5.00,
        stock: 50,
        sku: 'BEV-COKE-500',
      ),
    ],
  ));
  
  // Add more sample data...
}
```

Call in `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dbService = Get.put(DatabaseService());
  await dbService.database;
  
  // Seed sample data
  await seedDatabase();
  
  runApp(MyApp());
}
```

## Step 7: Test Migration

1. **Clear old data**:
   ```dart
   await dbService.clearAllData();
   ```

2. **Run app** - Database will be created

3. **Add test product** - Check if it persists after restart

4. **Complete test transaction** - Verify stock updates

5. **Check database file** - Use DB Browser for SQLite

## Common Issues & Solutions

### Issue: "Database is locked"
**Solution**: Ensure database is closed properly when app closes.

### Issue: "Table doesn't exist"
**Solution**: Delete database file and restart app to recreate tables.

### Issue: "Foreign key constraint failed"
**Solution**: Ensure related records exist before inserting.

### Issue: Stock not updating
**Solution**: Check `trackInventory` is true for products.

## Rollback Plan

If migration fails, restore GetStorage:
1. Keep old controller code commented
2. Switch back to dummy data
3. Remove database calls
4. Restart app

## Performance Tips

1. **Batch Operations**: Use transactions for multiple inserts
2. **Lazy Loading**: Load products on demand
3. **Caching**: Keep frequently used data in memory
4. **Indexes**: Already created for common queries
5. **Pagination**: Implement for large datasets

## Next: Cloud Sync

After local database works:
1. Add `lastSynced` timestamp to tables
2. Create sync service
3. Upload changes to cloud
4. Download updates
5. Resolve conflicts

---

**Note**: Test thoroughly before deploying to production!
