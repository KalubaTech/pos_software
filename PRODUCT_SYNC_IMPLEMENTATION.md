# Product Sync Implementation

## Overview
The product sync system enables real-time synchronization of products between Windows desktop and Android mobile app using Firedart (pure Dart Firestore implementation).

## How It Works

### 1. Initial Sync (On App Start)
When the app launches:
- `ProductController.onInit()` is called
- Connects to `FiredartSyncService`
- **Pushes all local products to cloud** (`_performInitialSync()`)
- **Starts listening to cloud changes** (`_startListeningToCloudProducts()`)

```dart
// In ProductController.onInit()
_performInitialSync();        // Upload local products
_startListeningToCloudProducts();  // Listen for cloud updates
```

### 2. Real-Time Cloud Listener
The listener monitors Firestore collection `businesses/default_business_001/products`:

```dart
_syncService!.listenToCollection('products').listen((cloudProducts) {
  // For each cloud product:
  // - If exists locally → Update it
  // - If not exists → Insert it
  // - Refresh products list
});
```

**This means:**
- Products added on Android → Automatically appear on Windows
- Products updated on Android → Windows gets the update instantly
- Products deleted on Android → Removed from Windows

### 3. Local to Cloud Sync (Push)
When you add/update/delete a product on Windows:

**Add Product:**
```dart
addProduct(product) {
  await _dbService.insertProduct(product);  // Save locally
  _syncToCloud(product);                    // Push to cloud
}
```

**Update Product:**
```dart
updateProduct(product) {
  await _dbService.updateProduct(product);  // Update locally
  _syncToCloud(product);                    // Push to cloud
}
```

**Delete Product:**
```dart
deleteProduct(id) {
  await _dbService.deleteProduct(id);       // Delete locally
  await _syncService!.deleteFromCloud('products', id);  // Delete from cloud
}
```

### 4. Offline Support
Firedart handles offline scenarios:
- If offline → Operations queued in `syncQueue`
- When online → Queue is processed automatically
- Retry logic: Max 3 attempts per operation

## Architecture

```
┌─────────────────┐         ┌──────────────────┐
│  Windows App    │         │   Android App    │
│                 │         │                  │
│ ┌─────────────┐ │         │ ┌──────────────┐ │
│ │  SQLite DB  │ │         │ │  SQLite DB   │ │
│ └──────┬──────┘ │         │ └──────┬───────┘ │
│        │        │         │        │         │
│ ┌──────▼──────┐ │         │ ┌──────▼───────┐ │
│ │ProductCtrl  │ │         │ │ProductCtrl   │ │
│ └──────┬──────┘ │         │ └──────┬───────┘ │
│        │        │         │        │         │
│ ┌──────▼──────┐ │         │ ┌──────▼───────┐ │
│ │FiredartSync │◄┼─────────┼─┤FiredartSync  │ │
│ └──────┬──────┘ │         │ └──────┬───────┘ │
└────────┼────────┘         └────────┼─────────┘
         │                           │
         │     ┌──────────────┐     │
         └─────►   Firestore   ◄────┘
               │              │
               │ businesses/  │
               │   default_   │
               │   business_  │
               │   001/       │
               │   products/  │
               └──────────────┘
```

## Firestore Data Structure

```
businesses/
  └── default_business_001/
      └── products/
          ├── product_id_1
          │   ├── id: "product_id_1"
          │   ├── name: "Product Name"
          │   ├── price: 100.0
          │   ├── category: "Electronics"
          │   ├── stock: 50
          │   └── syncMetadata:
          │       ├── lastModified: "2025-11-17T10:30:00Z"
          │       ├── modifiedBy: "windows_PC_12345"
          │       ├── deviceId: "windows_PC_12345"
          │       └── version: 1
          │
          ├── product_id_2
          └── product_id_3
```

## Current Implementation Status

### ✅ Completed Features:
1. **FiredartSyncService** - Pure Dart sync (no C++ SDK issues)
2. **ProductController Integration** - Sync on add/update/delete
3. **Initial Sync** - Upload local products on app start
4. **Real-Time Listener** - Receive cloud updates instantly
5. **Offline Queue** - Operations queued when offline
6. **Business ID Support** - Multi-tenant architecture
7. **Connectivity Monitoring** - Online/offline detection
8. **Sync Status UI** - Cloud icon in AppBar

### ⏳ Pending Tasks:
1. **Conflict Resolution** - Handle simultaneous edits
2. **Sync Timestamps** - Compare modification times
3. **Full Sync Button** - Manual sync trigger in settings
4. **Sync History** - Track sync operations
5. **Error Handling** - Better error messages
6. **Android Setup** - Configure Firedart on Android

## Testing the Sync

### Test 1: Windows to Cloud
1. Run app on Windows
2. Check console for: `🔄 Starting initial product sync...`
3. Add a new product
4. Check console for: `☁️ Product [name] synced to cloud`
5. Go to Firebase Console → Firestore → businesses/default_business_001/products
6. Verify product appears there

### Test 2: Cloud to Windows (Manual)
1. Go to Firebase Console → Firestore
2. Navigate to `businesses/default_business_001/products`
3. Add a document manually with fields:
   ```json
   {
     "id": "test_product_001",
     "name": "Cloud Product",
     "price": 99.99,
     "category": "Test",
     "description": "Added from cloud",
     "storeId": "store1",
     "imageUrl": "",
     "type": "generic",
     "isAvailable": true,
     "stock": 100,
     "unit": "pcs",
     "trackInventory": true
   }
   ```
4. Windows app should receive it automatically
5. Check console for: `📥 Received X products from cloud`

### Test 3: Android to Windows (Future)
1. Run app on Android (after Android setup)
2. Add product on Android
3. Windows app should update automatically
4. Check Windows console for: `📥 Received X products from cloud`

## Configuration

### Business ID
Located in: `lib/main.dart`
```dart
final businessId = GetStorage().read('business_id') ?? 'default_business_001';
```

**To change:**
1. Update the default business ID
2. Or store it in settings for multi-business support

### Firebase Project
Located in: `lib/services/firedart_sync_service.dart`
```dart
Firestore.initialize('dynamos-pos');  // Your project ID
```

## Console Output Reference

### Successful Sync:
```
✅ Firedart sync service initialized
📱 Device ID: windows_YOUR-PC_12345
🏢 Sync initialized for business: default_business_001
✅ ProductController: Sync service connected
👂 Listening to cloud product changes
🔄 Starting initial product sync...
📦 Found 5 local products to sync
✅ Synced: Product 1
✅ Synced: Product 2
...
✅ Initial sync complete!
```

### Adding Product:
```
☁️ Product [name] synced to cloud
```

### Receiving from Cloud:
```
📥 Received 6 products from cloud
➕ Added new product from cloud: Cloud Product
🔄 Updated local product: Existing Product
```

### Offline:
```
⚠️ Currently offline - operation queued
📦 Sync queue: 1 operations pending
```

## Troubleshooting

### Products not syncing to cloud
**Check:**
1. Internet connection (green cloud icon in AppBar)
2. Business ID is set in main.dart
3. Firestore rules allow write access
4. Console shows: `☁️ Product [name] synced to cloud`

### Products not syncing from cloud
**Check:**
1. Listener is active: `👂 Listening to cloud product changes`
2. Firestore rules allow read access
3. Product structure matches ProductModel
4. No errors in console

### Sync icon shows offline
**Check:**
1. Internet connection
2. Firestore URL is accessible
3. Firebase project ID is correct

## Next Steps

1. **Run the app** and check console output
2. **Test adding a product** - should sync to cloud
3. **Check Firebase Console** - product should appear in Firestore
4. **Configure Android app** - same setup on mobile
5. **Test cross-platform** - add on one device, see on other

## Important Notes

- **Business ID**: Currently using `default_business_001` - change this for production
- **Firestore Rules**: Currently open for development - add authentication in production
- **Conflict Resolution**: Last-write-wins (can be improved with timestamps)
- **Delete Cascade**: Deleting from one device deletes from all (by design)
- **Initial Sync**: Only pushes to cloud (doesn't pull existing cloud products on first run)

## Future Enhancements

1. **Batch Sync** - Sync multiple products in one operation
2. **Selective Sync** - Sync only specific categories
3. **Sync Statistics** - Track upload/download counts
4. **Conflict UI** - Show user when conflicts occur
5. **Sync Log** - Detailed history of all sync operations
6. **Manual Sync** - Force sync button in settings
7. **Sync Filters** - Don't sync certain fields (e.g., local-only flags)
