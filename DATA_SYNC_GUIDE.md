# Data Synchronization System Documentation

## Overview

The POS system includes a comprehensive data synchronization infrastructure that syncs local data with an external database through APIs. All data is tagged with a **Business ID** to ensure proper isolation and multi-tenancy support.

---

## Architecture

### Components

1. **Models** (`lib/models/sync_models.dart`)
   - `SyncRecord`: Tracks sync status for each entity
   - `ApiResponse`: Standardized API response wrapper
   - `SyncConfig`: Configuration for sync operations
   - `SyncStats`: Sync statistics and metrics
   - `SyncStatus`: Enum for sync states (pending, syncing, synced, failed)
   - `SyncEntityType`: Entity types (product, transaction, stock, customer, cashier, businessSettings)

2. **Services**
   - `MockApiService` (`lib/services/mock_api_service.dart`): Simulates external API calls
   - `DataSyncService` (`lib/services/data_sync_service.dart`): Core sync orchestration service

3. **Repositories**
   - `SyncRepository` (`lib/repositories/sync_repository.dart`): Local sync records management
   - `ProductRepository` (`lib/repositories/product_repository.dart`): Product sync operations
   - `TransactionRepository` (`lib/repositories/transaction_repository.dart`): Transaction sync operations
   - `BusinessRepository` (`lib/repositories/business_repository.dart`): Business settings & cashier sync

4. **Controllers**
   - `SyncController` (`lib/controllers/sync_controller.dart`): UI state management for sync

5. **Views**
   - `SyncSettingsView` (`lib/views/settings/sync_settings_view.dart`): Sync configuration UI

---

## Business ID Integration

### Purpose
The Business ID is a unique identifier that:
- Distinguishes data from different businesses in a multi-tenant system
- Ensures data isolation at the API level
- Enables proper data routing and access control
- Supports franchise or multi-location businesses

### Where Business ID is Used

#### 1. **Products**
```dart
{
  "id": "prod_123",
  "businessId": "BUS_ABC123",  // ← Business identifier
  "name": "Coffee Beans",
  "price": 15.99,
  "stock": 100,
  // ... other fields
}
```

#### 2. **Transactions**
```dart
{
  "id": "txn_456",
  "businessId": "BUS_ABC123",  // ← Business identifier
  "storeId": "store_001",
  "total": 45.50,
  "items": [...],
  // ... other fields
}
```

#### 3. **Stock Updates**
```dart
{
  "productId": "prod_123",
  "businessId": "BUS_ABC123",  // ← Business identifier
  "newStock": 85,
  "reason": "sale",
  // ... other fields
}
```

#### 4. **Business Settings**
```dart
{
  "businessId": "BUS_ABC123",  // ← Business identifier
  "storeName": "Dynamos POS",
  "taxRate": 16.0,
  "currency": "ZMW",
  // ... other fields
}
```

#### 5. **Cashiers/Employees**
```dart
{
  "id": "cashier_789",
  "businessId": "BUS_ABC123",  // ← Business identifier
  "name": "John Doe",
  "role": "cashier",
  // ... other fields
}
```

---

## Setup & Configuration

### 1. Initialize Services

In your `main.dart`, initialize the sync service:

```dart
import 'package:get/get.dart';
import 'services/data_sync_service.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database service first
  Get.put(DatabaseService());
  
  // Initialize sync service
  Get.put(DataSyncService());
  
  runApp(MyApp());
}
```

### 2. Configure Sync Settings

Navigate to: **Settings → Sync Settings**

Required configuration:
- **Business ID**: Your unique business identifier (e.g., `BUS_ABC123`)
- **API Base URL**: External API endpoint (e.g., `https://api.dynamospos.com`)
- **API Key**: Authentication key for API access
- **Auto Sync**: Enable/disable automatic synchronization
- **Sync Interval**: How often to sync (5-60 minutes)
- **WiFi Only**: Restrict sync to WiFi connections

### 3. Test Connection

Before saving, use the "Test Connection" button to verify:
- API is reachable
- Authentication is valid
- Network connectivity

---

## Usage Examples

### Example 1: Adding a Product

```dart
import 'package:get/get.dart';
import 'repositories/product_repository.dart';
import 'models/product_model.dart';

final productRepo = ProductRepository();
final businessId = 'BUS_ABC123'; // Your business ID

final product = ProductModel(
  id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
  name: 'Laptop Computer',
  price: 899.99,
  stock: 15,
  category: 'Electronics',
  // ... other fields
);

// This automatically queues the product for sync
await productRepo.addProduct(
  product: product,
  businessId: businessId,
);
```

### Example 2: Recording a Transaction

```dart
import 'repositories/transaction_repository.dart';
import 'models/transaction_model.dart';

final transactionRepo = TransactionRepository();
final businessId = 'BUS_ABC123';

final transaction = TransactionModel(
  id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
  storeId: 'store_001',
  total: 125.50,
  items: cartItems,
  paymentMethod: PaymentMethod.cash,
  cashierId: 'cashier_001',
  cashierName: 'John Doe',
  transactionDate: DateTime.now(),
  // ... other fields
);

// Automatically queues for sync
await transactionRepo.recordTransaction(
  transaction: transaction,
  businessId: businessId,
);
```

### Example 3: Updating Stock

```dart
import 'repositories/product_repository.dart';

final productRepo = ProductRepository();
final businessId = 'BUS_ABC123';

// Update stock for a single product
await productRepo.updateProductStock(
  productId: 'prod_123',
  newStock: 42,
  businessId: businessId,
  reason: 'inventory_count',
);

// Bulk stock adjustment
await productRepo.bulkStockAdjustment(
  stockChanges: {
    'prod_123': 42,
    'prod_456': 18,
    'prod_789': 63,
  },
  businessId: businessId,
  reason: 'end_of_day_count',
);
```

### Example 4: Syncing Business Settings

```dart
import 'repositories/business_repository.dart';
import 'controllers/business_settings_controller.dart';

final businessRepo = BusinessRepository();
final settingsController = Get.find<BusinessSettingsController>();
final businessId = 'BUS_ABC123';

final settingsData = {
  'storeName': settingsController.storeName.value,
  'storeAddress': settingsController.storeAddress.value,
  'taxRate': settingsController.taxRate.value,
  'currency': settingsController.currency.value,
  // ... other settings
};

await businessRepo.syncBusinessSettings(
  businessId: businessId,
  settings: settingsData,
);
```

### Example 5: Manual Sync Trigger

```dart
import 'services/data_sync_service.dart';

final syncService = Get.find<DataSyncService>();

// Trigger immediate sync
await syncService.syncNow();

// Check sync statistics
final stats = syncService.syncStats.value;
print('Pending: ${stats.totalPending}');
print('Synced: ${stats.totalSynced}');
print('Failed: ${stats.totalFailed}');
```

---

## Sync Flow

### Automatic Sync Flow

```
1. User Action (Add Product, Make Sale, etc.)
   ↓
2. Repository Method Called
   ↓
3. Data Queued with businessId
   ↓
4. Sync Record Created (Status: PENDING)
   ↓
5. Auto-Sync Timer Triggers
   ↓
6. DataSyncService Processes Queue
   ↓
7. MockApiService Called with businessId
   ↓
8. Record Updated (Status: SYNCED or FAILED)
   ↓
9. Statistics Refreshed
```

### Retry Logic

- Failed records are automatically retried
- Max retries: 3 (configurable)
- Exponential backoff not yet implemented (use fixed intervals)
- Manual retry available via "Retry Failed" button

---

## API Endpoints (Mock)

The `MockApiService` simulates these API endpoints:

### 1. Sync Product
```
POST /api/products/sync
Body: {
  "businessId": "BUS_ABC123",
  "productData": { ... }
}
```

### 2. Sync Transaction
```
POST /api/transactions/sync
Body: {
  "businessId": "BUS_ABC123",
  "transactionData": { ... }
}
```

### 3. Sync Stock
```
POST /api/stock/sync
Body: {
  "businessId": "BUS_ABC123",
  "stockData": { ... }
}
```

### 4. Sync Customer
```
POST /api/customers/sync
Body: {
  "businessId": "BUS_ABC123",
  "customerData": { ... }
}
```

### 5. Sync Cashier
```
POST /api/cashiers/sync
Body: {
  "businessId": "BUS_ABC123",
  "cashierData": { ... }
}
```

### 6. Health Check
```
GET /api/health
Response: {
  "success": true,
  "status": "online",
  "version": "1.0.0"
}
```

---

## Replacing Mock API with Real Implementation

### Step 1: Install HTTP Package

Add to `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
```

### Step 2: Create Real API Service

Replace `MockApiService` with real HTTP calls:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class RealApiService {
  final String baseUrl;
  final String apiKey;

  RealApiService({
    required this.baseUrl,
    required this.apiKey,
  });

  Future<ApiResponse<Map<String, dynamic>>> syncProduct({
    required String businessId,
    required Map<String, dynamic> productData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/products/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'businessId': businessId,
          'productData': productData,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  // Implement other methods similarly...
}
```

### Step 3: Update DataSyncService

Replace `MockApiService` with `RealApiService` in `DataSyncService`:

```dart
import './real_api_service.dart';  // Your new service

class DataSyncService extends GetxService {
  late RealApiService _apiService;  // Changed from MockApiService
  
  // ... rest of code
}
```

---

## Monitoring & Statistics

### View Sync Stats

```dart
final syncService = Get.find<DataSyncService>();

// Get current stats
final stats = syncService.syncStats.value;
print('Total Pending: ${stats.totalPending}');
print('Total Synced: ${stats.totalSynced}');
print('Total Failed: ${stats.totalFailed}');
print('Last Sync: ${stats.lastSyncTime}');

// Pending by type
stats.pendingByType.forEach((type, count) {
  print('${type.name}: $count pending');
});
```

### Cleanup Old Records

Remove synced records older than 30 days:

```dart
final syncService = Get.find<DataSyncService>();

await syncService.cleanupOldRecords(days: 30);
```

---

## Troubleshooting

### Problem: Records Not Syncing

**Solution:**
1. Check sync configuration is saved
2. Verify Business ID is set
3. Test API connection
4. Check if auto-sync is enabled
5. Manually trigger sync with "Sync Now"

### Problem: Authentication Failed

**Solution:**
1. Verify API key is correct
2. Check API key hasn't expired
3. Contact API administrator

### Problem: High Failure Rate

**Solution:**
1. Check network connectivity
2. Verify API server status
3. Review failed records for patterns
4. Use "Retry Failed" to requeue

### Problem: Business ID Missing

**Solution:**
1. Ensure Business ID is configured in Sync Settings
2. Pass Business ID to all repository methods
3. Check `SyncConfig` has valid Business ID

---

## Security Considerations

1. **API Key Storage**: Currently stored in GetStorage - consider encrypting
2. **Business ID Validation**: Validate Business ID format before syncing
3. **Data Encryption**: Consider encrypting sensitive data before sync
4. **SSL/TLS**: Use HTTPS for all API calls in production
5. **Rate Limiting**: Implement rate limiting to avoid API throttling

---

## Performance Tips

1. **Batch Sync**: Use batch operations for multiple records
2. **WiFi Only**: Enable "Sync Only on WiFi" to save data
3. **Sync Intervals**: Adjust intervals based on network conditions
4. **Cleanup**: Regularly cleanup old synced records
5. **Indexes**: Database indexes improve query performance

---

## Future Enhancements

- [ ] Conflict resolution for concurrent edits
- [ ] Offline-first with differential sync
- [ ] Exponential backoff for retries
- [ ] Real-time sync with WebSockets
- [ ] Compression for large payloads
- [ ] Delta sync (only changed fields)
- [ ] Sync priority queue
- [ ] Background sync service
- [ ] Sync analytics and insights

---

## Related Documentation

- `SETTINGS_OVERVIEW.md` - Settings system guide
- `DATABASE_MIGRATION_GUIDE.md` - Database setup
- `PROJECT_SUMMARY.md` - Project overview

---

*Last Updated: Data sync system with Business ID support*
