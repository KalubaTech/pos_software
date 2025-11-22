# 📊 Data Fetching API Guide for Dynamos Market Agents

**Version:** 1.0  
**Last Updated:** January 2025  
**Target Audience:** Dynamos Market Support Agents

---

## 📑 Table of Contents

1. [Overview](#overview)
2. [Model Changes Summary](#model-changes-summary)
3. [Firestore Data Structure](#firestore-data-structure)
4. [FiredartSyncService API Reference](#firedartsynserviceapi-reference)
5. [Fetching Businesses](#fetching-businesses)
6. [Fetching Products](#fetching-products)
7. [Filtering & Queries](#filtering--queries)
8. [Code Examples](#code-examples)
9. [Error Handling](#error-handling)
10. [Common Scenarios](#common-scenarios)

---

## Overview

### What Changed?

The POS system now supports **online store functionality**:

- **Businesses** can enable/disable their online store
- **Products** can be listed individually on the online marketplace
- **Real-time tracking** of online product counts
- **Firestore-based** data storage for cloud access

### Why This Guide?

Agents need to:
- Query businesses to check online store status
- Fetch products to see what's listed online
- Help merchants troubleshoot visibility issues
- Generate reports on online store adoption

---

## Model Changes Summary

### 🏢 BusinessModel Changes

**New Field Added:**
```dart
final bool onlineStoreEnabled;
```

**Details:**
- **Type:** Boolean
- **Default:** `false`
- **JSON Key:** `'online_store_enabled'`
- **Purpose:** Indicates if business has activated their online store
- **Location:** `lib/models/business_model.dart` (line 24)

**JSON Serialization:**
```json
{
  "id": "BUS_1234567890",
  "name": "John's Electronics",
  "email": "john@electronics.com",
  "online_store_enabled": true,
  "status": "active",
  ...
}
```

---

### 📦 ProductModel Changes

**New Field Added:**
```dart
final bool listedOnline;
```

**Details:**
- **Type:** Boolean
- **Default:** `false`
- **JSON Key:** `'listedOnline'`
- **Purpose:** Indicates if product is visible in online marketplace
- **Location:** `lib/models/product_model.dart` (line 18)

**JSON Serialization:**
```json
{
  "id": "PROD_0987654321",
  "name": "Samsung Galaxy A54",
  "price": 2499.99,
  "stock": 15,
  "listedOnline": true,
  "category": "Smartphones",
  ...
}
```

**Additional Component:**
- `ProductVariant` class exists for size/color variations
- Variants inherit the parent product's online status

---

## Firestore Data Structure

### Collection Hierarchy

```
firestore/
│
├── business_registrations/          ← Registration audit trail
│   └── BUS_XXXXX/
│       ├── name, email, phone
│       ├── status: "active" | "pending" | "inactive"
│       ├── createdAt
│       └── admin_cashier {...}     ← Embedded admin data
│
└── businesses/                      ← Operational data (active only)
    ├── default_business_001/        ← Test/demo business
    └── BUS_XXXXX/                   ← Real businesses
        ├── id, name, email
        ├── online_store_enabled ⭐   NEW
        ├── status
        │
        ├── business_settings/
        │   └── default/
        │       ├── storeName
        │       ├── storeAddress
        │       ├── onlineStoreEnabled ⭐ NEW
        │       └── onlineProductCount ⭐ NEW
        │
        ├── products/
        │   ├── PROD_001/
        │   │   ├── name, price, stock
        │   │   └── listedOnline ⭐     NEW
        │   └── PROD_002/
        │       └── ...
        │
        ├── cashiers/
        │   └── CASH_XXX/
        │       └── name, email, role, pin
        │
        ├── customers/
        │   └── CUST_XXX/
        │
        └── transactions/
            └── TXN_XXX/
```

### Key Points:

1. **Two Collections for Businesses:**
   - `business_registrations` = Registration records (all)
   - `businesses` = Active operational businesses

2. **Sub-Collections:**
   - Products, cashiers, customers are under `businesses/{id}/`
   - Settings are under `businesses/{id}/business_settings/default/`

3. **Online Store Fields:**
   - Business-level: `online_store_enabled` (in business doc)
   - Settings-level: `onlineStoreEnabled` + `onlineProductCount`
   - Product-level: `listedOnline`

---

## FiredartSyncService API Reference

**Service Location:** `lib/services/firedart_sync_service.dart`

The `FiredartSyncService` provides methods to query Firestore data:

### Method 1: `getCollectionData()`

**Purpose:** Fetch sub-collections under a specific business

```dart
Future<List<Map<String, dynamic>>> getCollectionData(String collection)
```

**Parameters:**
- `collection` (String) - Collection name (e.g., 'products', 'customers')

**Returns:**
- `List<Map<String, dynamic>>` - List of documents with IDs

**Firestore Path:**
```
businesses/{businessId}/{collection}/
```

**Requirements:**
- Business ID must be set via `initialize(businessId)`

**Example:**
```dart
final syncService = Get.find<FiredartSyncService>();
await syncService.initialize('BUS_1234567890');

final products = await syncService.getCollectionData('products');
// Returns: [{'id': 'PROD_001', 'name': '...', 'listedOnline': true}, ...]
```

**Line Number:** 248

---

### Method 2: `getTopLevelCollectionData()`

**Purpose:** Fetch top-level collections (not business-specific)

```dart
Future<List<Map<String, dynamic>>> getTopLevelCollectionData(String collection)
```

**Parameters:**
- `collection` (String) - Collection name (e.g., 'businesses', 'business_registrations')

**Returns:**
- `List<Map<String, dynamic>>` - List of documents with IDs

**Firestore Path:**
```
{collection}/
```

**Requirements:**
- None (doesn't require business ID)

**Example:**
```dart
final syncService = Get.find<FiredartSyncService>();

final businesses = await syncService.getTopLevelCollectionData('businesses');
// Returns: [{'id': 'BUS_001', 'name': '...', 'online_store_enabled': true}, ...]
```

**Line Number:** 269

---

### Method 3: `getDocument()`

**Purpose:** Fetch a single document from a top-level collection

```dart
Future<Map<String, dynamic>?> getDocument(String collection, String documentId)
```

**Parameters:**
- `collection` (String) - Collection name
- `documentId` (String) - Document ID

**Returns:**
- `Map<String, dynamic>?` - Document data or null if not found

**Firestore Path:**
```
{collection}/{documentId}
```

**Example:**
```dart
final syncService = Get.find<FiredartSyncService>();

final business = await syncService.getDocument('businesses', 'BUS_1234567890');
if (business != null) {
  print('Business: ${business['name']}');
  print('Online Store: ${business['online_store_enabled']}');
}
```

**Line Number:** 285

---

### Method 4: `getBusinessDocument()`

**Purpose:** Fetch a single document from a business sub-collection

```dart
Future<Map<String, dynamic>?> getBusinessDocument(String collection, String documentId)
```

**Parameters:**
- `collection` (String) - Sub-collection name
- `documentId` (String) - Document ID

**Returns:**
- `Map<String, dynamic>?` - Document data or null if not found

**Firestore Path:**
```
businesses/{businessId}/{collection}/{documentId}
```

**Requirements:**
- Business ID must be set

**Example:**
```dart
final syncService = Get.find<FiredartSyncService>();
await syncService.initialize('BUS_1234567890');

final product = await syncService.getBusinessDocument('products', 'PROD_001');
if (product != null) {
  print('Product: ${product['name']}');
  print('Listed Online: ${product['listedOnline']}');
}
```

**Line Number:** 306

---

## Fetching Businesses

### Scenario 1: Get All Businesses

```dart
import 'package:get/get.dart';
import '../services/firedart_sync_service.dart';
import '../models/business_model.dart';

Future<List<BusinessModel>> getAllBusinesses() async {
  final syncService = Get.find<FiredartSyncService>();
  
  // Fetch all businesses from Firestore
  final businessesData = await syncService.getTopLevelCollectionData('businesses');
  
  // Convert to BusinessModel
  final businesses = businessesData
      .map((data) => BusinessModel.fromJson(data))
      .toList();
  
  print('✅ Fetched ${businesses.length} businesses');
  return businesses;
}
```

---

### Scenario 2: Get Single Business by ID

```dart
Future<BusinessModel?> getBusinessById(String businessId) async {
  final syncService = Get.find<FiredartSyncService>();
  
  // Fetch specific business
  final businessData = await syncService.getDocument('businesses', businessId);
  
  if (businessData == null) {
    print('❌ Business not found: $businessId');
    return null;
  }
  
  // Convert to BusinessModel
  final business = BusinessModel.fromJson(businessData);
  
  print('✅ Found business: ${business.name}');
  return business;
}
```

---

### Scenario 3: Get Businesses with Online Store Enabled

```dart
Future<List<BusinessModel>> getOnlineStoreBusinesses() async {
  final syncService = Get.find<FiredartSyncService>();
  
  // Fetch all businesses
  final businessesData = await syncService.getTopLevelCollectionData('businesses');
  
  // Filter for online store enabled
  final onlineBusinesses = businessesData
      .where((data) => data['online_store_enabled'] == true)
      .map((data) => BusinessModel.fromJson(data))
      .toList();
  
  print('✅ Found ${onlineBusinesses.length} businesses with online stores');
  return onlineBusinesses;
}
```

---

### Scenario 4: Get Business Settings

```dart
Future<Map<String, dynamic>?> getBusinessSettings(String businessId) async {
  final syncService = Get.find<FiredartSyncService>();
  await syncService.initialize(businessId);
  
  // Fetch business settings
  final settingsData = await syncService.getCollectionData('business_settings');
  
  if (settingsData.isEmpty) {
    print('❌ No settings found for business: $businessId');
    return null;
  }
  
  // Settings is a single document collection
  final settings = settingsData.first;
  
  print('✅ Settings found:');
  print('   Store Name: ${settings['storeName']}');
  print('   Online Store: ${settings['onlineStoreEnabled']}');
  print('   Online Products: ${settings['onlineProductCount']}');
  
  return settings;
}
```

---

## Fetching Products

### Scenario 1: Get All Products for a Business

```dart
import '../models/product_model.dart';

Future<List<ProductModel>> getProductsByBusinessId(String businessId) async {
  final syncService = Get.find<FiredartSyncService>();
  await syncService.initialize(businessId);
  
  // Fetch all products
  final productsData = await syncService.getCollectionData('products');
  
  // Convert to ProductModel
  final products = productsData
      .map((data) => ProductModel.fromJson(data))
      .toList();
  
  print('✅ Fetched ${products.length} products for business: $businessId');
  return products;
}
```

---

### Scenario 2: Get Only Online Products

```dart
Future<List<ProductModel>> getOnlineProducts(String businessId) async {
  final syncService = Get.find<FiredartSyncService>();
  await syncService.initialize(businessId);
  
  // Fetch all products
  final productsData = await syncService.getCollectionData('products');
  
  // Filter for listed online
  final onlineProducts = productsData
      .where((data) => data['listedOnline'] == true)
      .map((data) => ProductModel.fromJson(data))
      .toList();
  
  print('✅ Found ${onlineProducts.length} online products');
  return onlineProducts;
}
```

---

### Scenario 3: Get Single Product by ID

```dart
Future<ProductModel?> getProductById(String businessId, String productId) async {
  final syncService = Get.find<FiredartSyncService>();
  await syncService.initialize(businessId);
  
  // Fetch specific product
  final productData = await syncService.getBusinessDocument('products', productId);
  
  if (productData == null) {
    print('❌ Product not found: $productId');
    return null;
  }
  
  // Convert to ProductModel
  final product = ProductModel.fromJson(productData);
  
  print('✅ Found product: ${product.name}');
  print('   Listed Online: ${product.listedOnline}');
  print('   Stock: ${product.stock}');
  
  return product;
}
```

---

### Scenario 4: Get Products by Category

```dart
Future<List<ProductModel>> getProductsByCategory(
  String businessId, 
  String category,
) async {
  final syncService = Get.find<FiredartSyncService>();
  await syncService.initialize(businessId);
  
  // Fetch all products
  final productsData = await syncService.getCollectionData('products');
  
  // Filter by category
  final categoryProducts = productsData
      .where((data) => data['category'] == category)
      .map((data) => ProductModel.fromJson(data))
      .toList();
  
  print('✅ Found ${categoryProducts.length} products in category: $category');
  return categoryProducts;
}
```

---

### Scenario 5: Get Low Stock Online Products

```dart
Future<List<ProductModel>> getLowStockOnlineProducts(
  String businessId,
  {int threshold = 10}
) async {
  final syncService = Get.find<FiredartSyncService>();
  await syncService.initialize(businessId);
  
  // Fetch all products
  final productsData = await syncService.getCollectionData('products');
  
  // Filter for online + low stock
  final lowStockProducts = productsData
      .where((data) => 
          data['listedOnline'] == true && 
          (data['stock'] as num) <= threshold
      )
      .map((data) => ProductModel.fromJson(data))
      .toList();
  
  print('⚠️ Found ${lowStockProducts.length} low stock online products');
  return lowStockProducts;
}
```

---

## Filtering & Queries

### Filter Patterns

#### 1. Single Condition Filter

```dart
// Get active businesses
final activeBusinesses = businessesData
    .where((data) => data['status'] == 'active')
    .toList();

// Get products with stock > 0
final inStockProducts = productsData
    .where((data) => (data['stock'] as num) > 0)
    .toList();
```

---

#### 2. Multiple Conditions (AND)

```dart
// Get online products with stock > 0
final availableOnlineProducts = productsData
    .where((data) => 
        data['listedOnline'] == true && 
        (data['stock'] as num) > 0
    )
    .toList();

// Get active businesses with online stores
final activeOnlineBusinesses = businessesData
    .where((data) => 
        data['status'] == 'active' && 
        data['online_store_enabled'] == true
    )
    .toList();
```

---

#### 3. Multiple Conditions (OR)

```dart
// Get products in Electronics or Smartphones category
final techProducts = productsData
    .where((data) => 
        data['category'] == 'Electronics' || 
        data['category'] == 'Smartphones'
    )
    .toList();
```

---

#### 4. Range Filters

```dart
// Get products priced between K100 and K500
final midRangeProducts = productsData
    .where((data) {
      final price = data['price'] as num;
      return price >= 100 && price <= 500;
    })
    .toList();

// Get products with low to medium stock (1-50 units)
final limitedStockProducts = productsData
    .where((data) {
      final stock = data['stock'] as num;
      return stock >= 1 && stock <= 50;
    })
    .toList();
```

---

#### 5. Text Search (Contains)

```dart
// Search products by name
String searchTerm = 'samsung';
final searchResults = productsData
    .where((data) => 
        (data['name'] as String)
            .toLowerCase()
            .contains(searchTerm.toLowerCase())
    )
    .toList();
```

---

#### 6. Null Checks

```dart
// Get products without images
final noImageProducts = productsData
    .where((data) => 
        data['image'] == null || 
        (data['image'] as String).isEmpty
    )
    .toList();
```

---

### Sorting Results

```dart
// Sort products by price (ascending)
final sortedByPrice = productsData
    .map((data) => ProductModel.fromJson(data))
    .toList()
    ..sort((a, b) => a.price.compareTo(b.price));

// Sort products by stock (descending)
final sortedByStock = productsData
    .map((data) => ProductModel.fromJson(data))
    .toList()
    ..sort((a, b) => b.stock.compareTo(a.stock));

// Sort businesses by name (alphabetical)
final sortedByName = businessesData
    .map((data) => BusinessModel.fromJson(data))
    .toList()
    ..sort((a, b) => a.name.compareTo(b.name));
```

---

### Pagination

```dart
// Get first 20 products
final firstPage = productsData.take(20).toList();

// Get next 20 products (offset 20)
final secondPage = productsData.skip(20).take(20).toList();

// Generic pagination
List<Map<String, dynamic>> getPage(
  List<Map<String, dynamic>> data, 
  int page, 
  int pageSize,
) {
  final offset = (page - 1) * pageSize;
  return data.skip(offset).take(pageSize).toList();
}

// Usage
final page1 = getPage(productsData, 1, 50); // First 50 products
final page2 = getPage(productsData, 2, 50); // Next 50 products
```

---

## Code Examples

### Example 1: Generate Online Store Report

```dart
Future<void> generateOnlineStoreReport(String businessId) async {
  final syncService = Get.find<FiredartSyncService>();
  
  // 1. Get business details
  final business = await syncService.getDocument('businesses', businessId);
  if (business == null) {
    print('❌ Business not found');
    return;
  }
  
  // 2. Get business settings
  await syncService.initialize(businessId);
  final settingsData = await syncService.getCollectionData('business_settings');
  final settings = settingsData.isNotEmpty ? settingsData.first : null;
  
  // 3. Get all products
  final productsData = await syncService.getCollectionData('products');
  final onlineProducts = productsData
      .where((p) => p['listedOnline'] == true)
      .toList();
  
  // 4. Calculate statistics
  final totalProducts = productsData.length;
  final onlineProductCount = onlineProducts.length;
  final onlinePercentage = totalProducts > 0 
      ? (onlineProductCount / totalProducts * 100).toStringAsFixed(1)
      : '0';
  
  // 5. Generate report
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📊 ONLINE STORE REPORT');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🏢 Business: ${business['name']}');
  print('📧 Email: ${business['email']}');
  print('🌐 Online Store: ${business['online_store_enabled'] ? 'ENABLED ✅' : 'DISABLED ❌'}');
  print('');
  print('📦 PRODUCTS:');
  print('   Total Products: $totalProducts');
  print('   Online Products: $onlineProductCount');
  print('   Online Percentage: $onlinePercentage%');
  print('');
  
  if (settings != null) {
    print('⚙️ SETTINGS:');
    print('   Store Name: ${settings['storeName']}');
    print('   Online Product Count: ${settings['onlineProductCount']}');
  }
  
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}
```

---

### Example 2: Verify Online Product Visibility

```dart
Future<void> verifyProductOnlineStatus(String businessId, String productId) async {
  final syncService = Get.find<FiredartSyncService>();
  await syncService.initialize(businessId);
  
  // 1. Check business online store status
  final business = await syncService.getDocument('businesses', businessId);
  if (business == null) {
    print('❌ Business not found');
    return;
  }
  
  final storeEnabled = business['online_store_enabled'] ?? false;
  
  // 2. Get product details
  final product = await syncService.getBusinessDocument('products', productId);
  if (product == null) {
    print('❌ Product not found');
    return;
  }
  
  final listedOnline = product['listedOnline'] ?? false;
  
  // 3. Verify visibility
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🔍 PRODUCT VISIBILITY CHECK');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📦 Product: ${product['name']}');
  print('🆔 Product ID: $productId');
  print('');
  print('🏢 Business Online Store: ${storeEnabled ? 'ENABLED ✅' : 'DISABLED ❌'}');
  print('📍 Product Listed Online: ${listedOnline ? 'YES ✅' : 'NO ❌'}');
  print('');
  
  if (storeEnabled && listedOnline) {
    print('✅ VISIBLE: Product is visible in online marketplace');
  } else if (!storeEnabled) {
    print('❌ NOT VISIBLE: Business online store is disabled');
    print('💡 Solution: Business must enable online store in Settings');
  } else if (!listedOnline) {
    print('❌ NOT VISIBLE: Product not listed online');
    print('💡 Solution: Toggle "List Online" when editing product');
  }
  
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}
```

---

### Example 3: Find All Active Online Stores

```dart
Future<List<Map<String, dynamic>>> getAllActiveOnlineStores() async {
  final syncService = Get.find<FiredartSyncService>();
  
  // Get all businesses
  final businessesData = await syncService.getTopLevelCollectionData('businesses');
  
  // Filter for active + online store enabled
  final onlineStores = businessesData
      .where((b) => 
          b['status'] == 'active' && 
          (b['online_store_enabled'] ?? false) == true
      )
      .toList();
  
  print('✅ Found ${onlineStores.length} active online stores');
  
  // Print summary
  for (var store in onlineStores) {
    print('  - ${store['name']} (${store['id']})');
  }
  
  return onlineStores;
}
```

---

### Example 4: Audit Online Product Consistency

```dart
Future<void> auditOnlineProductCount(String businessId) async {
  final syncService = Get.find<FiredartSyncService>();
  await syncService.initialize(businessId);
  
  // 1. Get actual online products
  final productsData = await syncService.getCollectionData('products');
  final actualOnlineCount = productsData
      .where((p) => p['listedOnline'] == true)
      .length;
  
  // 2. Get stored count in settings
  final settingsData = await syncService.getCollectionData('business_settings');
  final storedCount = settingsData.isNotEmpty 
      ? (settingsData.first['onlineProductCount'] ?? 0)
      : 0;
  
  // 3. Compare
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🔍 ONLINE PRODUCT COUNT AUDIT');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📊 Actual Online Products: $actualOnlineCount');
  print('💾 Stored Count (Settings): $storedCount');
  print('');
  
  if (actualOnlineCount == storedCount) {
    print('✅ SYNCHRONIZED: Counts match');
  } else {
    print('❌ MISMATCH: Counts do not match!');
    print('⚠️ Difference: ${(actualOnlineCount - storedCount).abs()} products');
    print('💡 Action: Sync may be needed');
  }
  
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}
```

---

## Error Handling

### Common Errors & Solutions

#### Error 1: Business ID Not Set

```dart
// ❌ Error
Future<void> badExample() async {
  final syncService = Get.find<FiredartSyncService>();
  
  // This will throw: Exception('Business ID not set')
  final products = await syncService.getCollectionData('products');
}

// ✅ Solution
Future<void> goodExample(String businessId) async {
  final syncService = Get.find<FiredartSyncService>();
  
  // Always initialize first
  await syncService.initialize(businessId);
  
  // Now this works
  final products = await syncService.getCollectionData('products');
}
```

---

#### Error 2: Null Document

```dart
// ❌ Without null check
Future<void> riskyCode(String businessId) async {
  final syncService = Get.find<FiredartSyncService>();
  final business = await syncService.getDocument('businesses', businessId);
  
  // This could crash if business is null
  print(business['name']);
}

// ✅ With null check
Future<void> safeCode(String businessId) async {
  final syncService = Get.find<FiredartSyncService>();
  final business = await syncService.getDocument('businesses', businessId);
  
  if (business == null) {
    print('❌ Business not found: $businessId');
    return;
  }
  
  print('✅ Business: ${business['name']}');
}
```

---

#### Error 3: Empty Collection

```dart
// ❌ Without check
Future<void> riskyCode(String businessId) async {
  final syncService = Get.find<FiredartSyncService>();
  await syncService.initialize(businessId);
  
  final settings = await syncService.getCollectionData('business_settings');
  
  // This could crash if collection is empty
  final storeName = settings.first['storeName'];
}

// ✅ With check
Future<void> safeCode(String businessId) async {
  final syncService = Get.find<FiredartSyncService>();
  await syncService.initialize(businessId);
  
  final settings = await syncService.getCollectionData('business_settings');
  
  if (settings.isEmpty) {
    print('⚠️ No settings found');
    return;
  }
  
  final storeName = settings.first['storeName'];
  print('✅ Store: $storeName');
}
```

---

### Error Handling Template

```dart
Future<T?> safeFirestoreOperation<T>(
  Future<T?> Function() operation, {
  String? errorMessage,
}) async {
  try {
    final result = await operation();
    
    if (result == null) {
      print('⚠️ ${errorMessage ?? 'No data found'}');
      return null;
    }
    
    return result;
  } catch (e) {
    print('❌ Error: ${errorMessage ?? 'Operation failed'}: $e');
    return null;
  }
}

// Usage
final business = await safeFirestoreOperation(
  () => syncService.getDocument('businesses', businessId),
  errorMessage: 'Failed to fetch business',
);
```

---

## Common Scenarios

### Scenario 1: Customer Can't See Their Product Online

**Agent Checklist:**

```dart
Future<void> troubleshootProductVisibility(
  String businessId, 
  String productId,
) async {
  print('🔍 Troubleshooting product visibility...\n');
  
  final syncService = Get.find<FiredartSyncService>();
  
  // Check 1: Business exists and online store enabled
  final business = await syncService.getDocument('businesses', businessId);
  if (business == null) {
    print('❌ ISSUE: Business not found in Firestore');
    print('💡 SOLUTION: Business may need to re-register');
    return;
  }
  
  final storeEnabled = business['online_store_enabled'] ?? false;
  if (!storeEnabled) {
    print('❌ ISSUE: Online store is disabled');
    print('💡 SOLUTION: Go to Settings → Enable "Online Store"');
    return;
  }
  print('✅ CHECK 1: Online store enabled\n');
  
  // Check 2: Product exists
  await syncService.initialize(businessId);
  final product = await syncService.getBusinessDocument('products', productId);
  if (product == null) {
    print('❌ ISSUE: Product not found');
    print('💡 SOLUTION: Check product ID or create product first');
    return;
  }
  print('✅ CHECK 2: Product exists: ${product['name']}\n');
  
  // Check 3: Product listed online
  final listedOnline = product['listedOnline'] ?? false;
  if (!listedOnline) {
    print('❌ ISSUE: Product not marked as "Listed Online"');
    print('💡 SOLUTION: Edit product → Toggle "List Online" to ON');
    return;
  }
  print('✅ CHECK 3: Product listed online\n');
  
  // Check 4: Product has stock
  final stock = product['stock'] ?? 0;
  if (stock <= 0) {
    print('⚠️ WARNING: Product has no stock (${stock} units)');
    print('💡 NOTE: Product may be hidden if marketplace filters out-of-stock items');
  } else {
    print('✅ CHECK 4: Product has stock (${stock} units)\n');
  }
  
  // All checks passed
  print('✅ RESULT: Product should be visible online!');
  print('   Business: ${business['name']}');
  print('   Product: ${product['name']}');
  print('   Stock: $stock');
}
```

---

### Scenario 2: Business Wants to Know Online Product Count

```dart
Future<void> reportOnlineProductCount(String businessId) async {
  final syncService = Get.find<FiredartSyncService>();
  await syncService.initialize(businessId);
  
  // Get all products
  final productsData = await syncService.getCollectionData('products');
  
  // Count online products
  final totalProducts = productsData.length;
  final onlineProducts = productsData
      .where((p) => p['listedOnline'] == true)
      .toList();
  final onlineCount = onlineProducts.length;
  
  // Calculate percentage
  final percentage = totalProducts > 0 
      ? (onlineCount / totalProducts * 100).toStringAsFixed(1)
      : '0';
  
  // Report
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📊 ONLINE PRODUCT SUMMARY');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📦 Total Products: $totalProducts');
  print('🌐 Online Products: $onlineCount');
  print('📈 Percentage: $percentage%');
  print('');
  print('💡 TIP: To add more products online:');
  print('   1. Go to Products → Edit Product');
  print('   2. Toggle "List Online" to ON');
  print('   3. Save changes');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}
```

---

### Scenario 3: List All Products for a Business

```dart
Future<void> listAllProducts(String businessId) async {
  final syncService = Get.find<FiredartSyncService>();
  await syncService.initialize(businessId);
  
  // Get all products
  final productsData = await syncService.getCollectionData('products');
  
  if (productsData.isEmpty) {
    print('⚠️ No products found for this business');
    return;
  }
  
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📦 PRODUCT LIST (${productsData.length} products)');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  
  for (var i = 0; i < productsData.length; i++) {
    final product = productsData[i];
    final onlineStatus = (product['listedOnline'] ?? false) ? '🌐 ONLINE' : '📴 OFFLINE';
    
    print('${i + 1}. ${product['name']}');
    print('   ID: ${product['id']}');
    print('   Price: K${product['price']}');
    print('   Stock: ${product['stock']} units');
    print('   Status: $onlineStatus');
    print('');
  }
  
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}
```

---

### Scenario 4: Export Online Products to CSV

```dart
import 'dart:io';

Future<void> exportOnlineProductsToCSV(String businessId) async {
  final syncService = Get.find<FiredartSyncService>();
  await syncService.initialize(businessId);
  
  // Get online products
  final productsData = await syncService.getCollectionData('products');
  final onlineProducts = productsData
      .where((p) => p['listedOnline'] == true)
      .toList();
  
  if (onlineProducts.isEmpty) {
    print('⚠️ No online products to export');
    return;
  }
  
  // Build CSV
  final csv = StringBuffer();
  csv.writeln('Product ID,Name,Price,Stock,Category,Listed Online');
  
  for (var product in onlineProducts) {
    csv.writeln(
      '${product['id']},'
      '"${product['name']}",'
      '${product['price']},'
      '${product['stock']},'
      '"${product['category'] ?? 'N/A'}",'
      'Yes'
    );
  }
  
  // Save to file
  final filename = 'online_products_${businessId}_${DateTime.now().millisecondsSinceEpoch}.csv';
  final file = File(filename);
  await file.writeAsString(csv.toString());
  
  print('✅ Exported ${onlineProducts.length} online products to: $filename');
}
```

---

## Quick Reference Card

### Essential API Calls

| Task | Method | Code |
|------|--------|------|
| Get all businesses | `getTopLevelCollectionData()` | `await syncService.getTopLevelCollectionData('businesses')` |
| Get single business | `getDocument()` | `await syncService.getDocument('businesses', businessId)` |
| Get all products | `getCollectionData()` | `await syncService.getCollectionData('products')` |
| Get single product | `getBusinessDocument()` | `await syncService.getBusinessDocument('products', productId)` |
| Get business settings | `getCollectionData()` | `await syncService.getCollectionData('business_settings')` |

---

### Field Mapping

| Model | Field Name | JSON Key | Type | Default |
|-------|------------|----------|------|---------|
| BusinessModel | `onlineStoreEnabled` | `online_store_enabled` | bool | false |
| ProductModel | `listedOnline` | `listedOnline` | bool | false |
| Settings | `onlineStoreEnabled` | `onlineStoreEnabled` | bool | false |
| Settings | `onlineProductCount` | `onlineProductCount` | int | 0 |

---

### Filter Cheat Sheet

```dart
// Online products only
.where((p) => p['listedOnline'] == true)

// Products with stock
.where((p) => (p['stock'] as num) > 0)

// Active businesses with online stores
.where((b) => b['status'] == 'active' && b['online_store_enabled'] == true)

// Price range
.where((p) => (p['price'] as num) >= min && (p['price'] as num) <= max)

// Search by name
.where((p) => (p['name'] as String).toLowerCase().contains(searchTerm.toLowerCase()))
```

---

## Support & Escalation

### When to Escalate to Development Team

1. **Database Inconsistencies:**
   - Online product count doesn't match actual count
   - Business exists in one collection but not the other

2. **Sync Issues:**
   - Data not appearing in Firestore after 5+ minutes
   - Settings not updating across devices

3. **Data Corruption:**
   - Missing required fields in documents
   - Malformed JSON data

4. **Performance Issues:**
   - Queries taking longer than 5 seconds
   - Timeout errors when fetching data

### Contact Information

- **Technical Support:** support@dynamospos.com
- **Developer Team:** dev@dynamospos.com
- **Documentation:** https://docs.dynamospos.com

---

## Changelog

### Version 1.0 (January 2025)
- ✅ Initial release
- ✅ Online store feature documentation
- ✅ Model changes summary
- ✅ Complete API reference
- ✅ Code examples and troubleshooting guide

---

**📚 Related Documentation:**
- [Dynamos Market Agent Guide](DYNAMOS_MARKET_AGENT_GUIDE.md) - Complete training manual
- [Agent Quick Reference](AGENT_QUICK_REFERENCE.md) - Quick setup guide
- [Technical Changelog](ONLINE_STORE_TECHNICAL_CHANGELOG.md) - Code changes log

---

**End of Guide** • Last Updated: January 2025 • Version 1.0
