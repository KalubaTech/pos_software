# Mobile Real-Time Streams Implementation Guide

## 📱 Overview

This guide explains how to use real-time Firestore streams on mobile devices (Android/iOS) for instant, reactive UI updates in the Dynamos POS app.

**Date:** November 19, 2025  
**System:** Firebase Firestore + Flutter + GetX  
**Platforms:** Android, iOS (Mobile-specific feature)

---

## 🎯 What's New

### Desktop vs Mobile Architecture

**Desktop (Windows):**
- Uses **callback-based listeners** with `.listen()` pattern
- Updates local SQLite database, then refreshes UI
- Pattern: `stream.listen((data) { updateLocal(data); refreshUI(); })`

**Mobile (Android/iOS):**
- Uses **direct Firestore streams** with `StreamBuilder`
- UI updates instantly when Firestore data changes
- Pattern: `StreamBuilder<List<Map>>(stream: controller.productsStream, builder: ...)`

### Why This Matters

Mobile users expect **instant, reactive updates**. When data changes in Firestore:
- ✅ Mobile UI updates immediately
- ✅ No manual refresh needed
- ✅ True real-time synchronization
- ✅ Native mobile app feel

---

## 🔧 Technical Implementation

### UniversalSyncController Updates

#### 1. Platform Detection

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';

bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
bool get isDesktop => !kIsWeb && Platform.isWindows;
```

#### 2. Stream Getters (8 Available)

All stream getters return `Stream<List<Map<String, dynamic>>>` from Firestore:

```dart
// Products
Stream<List<Map<String, dynamic>>> get productsStream =>
    _syncService.listenToCollection('products');

// Transactions
Stream<List<Map<String, dynamic>>> get transactionsStream =>
    _syncService.listenToCollection('transactions');

// Customers
Stream<List<Map<String, dynamic>>> get customersStream =>
    _syncService.listenToCollection('customers');

// Wallets
Stream<List<Map<String, dynamic>>> get walletsStream =>
    _syncService.listenToCollection('wallets');

// Subscriptions
Stream<List<Map<String, dynamic>>> get subscriptionsStream =>
    _syncService.listenToCollection('subscriptions');

// Business Settings
Stream<List<Map<String, dynamic>>> get businessSettingsStream =>
    _syncService.listenToCollection('business_settings');

// Price Tag Templates
Stream<List<Map<String, dynamic>>> get priceTagTemplatesStream =>
    _syncService.listenToCollection('price_tag_templates');

// Cashiers
Stream<List<Map<String, dynamic>>> get cashiersStream =>
    _syncService.listenToCollection('cashiers');
```

#### 3. Conditional Listener Setup

```dart
void _startListeningToAllCollections() {
  if (isDesktop) {
    // Desktop: Use callback-based listeners
    _listenToProducts();
    _listenToTransactions();
    // ... etc
  } else if (isMobile) {
    // Mobile: Streams available for views to consume
    print('📱 Mobile: Stream getters available for StreamBuilder');
  }
}
```

---

## 📖 Usage Examples

### Example 1: Products List (Mobile)

**Before (Desktop callback pattern):**
```dart
// Desktop uses ProductController.fetchProducts() which loads from SQLite
class ProductListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();
    
    return Obx(() => ListView.builder(
      itemCount: controller.products.length,
      itemBuilder: (context, index) {
        final product = controller.products[index];
        return ListTile(title: Text(product.name));
      },
    ));
  }
}
```

**After (Mobile stream pattern):**
```dart
// Mobile uses Firestore streams directly
class ProductListView extends StatelessWidget {
  final syncController = Get.find<UniversalSyncController>();
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: syncController.productsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No products found'));
        }
        
        final products = snapshot.data!
            .map((data) => ProductModel.fromJson(data))
            .toList();
        
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
              leading: product.imageUrl.isNotEmpty
                  ? Image.network(product.imageUrl, width: 50, height: 50)
                  : Icon(Icons.inventory_2),
            );
          },
        );
      },
    );
  }
}
```

### Example 2: Subscription Status (Mobile)

```dart
class SubscriptionView extends StatelessWidget {
  final syncController = Get.find<UniversalSyncController>();
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: syncController.subscriptionsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No active subscription'),
            ),
          );
        }
        
        final sub = SubscriptionModel.fromJson(snapshot.data!.first);
        
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plan: ${sub.planName}', 
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Status: ${sub.status.name}'),
                Text('End Date: ${sub.endDate.toString().split(' ')[0]}'),
                SizedBox(height: 16),
                LinearProgressIndicator(
                  value: sub.getRemainingDaysPercentage(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

### Example 3: Wallet Balance (Mobile)

```dart
class WalletCard extends StatelessWidget {
  final syncController = Get.find<UniversalSyncController>();
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: syncController.walletsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Card(child: Text('No wallet data'));
        }
        
        final wallet = WalletModel.fromJson(snapshot.data!.first);
        
        return Card(
          color: Colors.blue[800],
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wallet Balance', 
                     style: TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(height: 8),
                Text('ZMW ${wallet.balance.toStringAsFixed(2)}',
                     style: TextStyle(color: Colors.white, 
                                      fontSize: 32, 
                                      fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(wallet.businessName,
                     style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

### Example 4: Customer List with Search (Mobile)

```dart
class CustomerListView extends StatefulWidget {
  @override
  _CustomerListViewState createState() => _CustomerListViewState();
}

class _CustomerListViewState extends State<CustomerListView> {
  final syncController = Get.find<UniversalSyncController>();
  String searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search customers...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: syncController.customersStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No customers found'));
              }
              
              var customers = snapshot.data!
                  .map((data) => ClientModel.fromJson(data))
                  .toList();
              
              // Filter by search query
              if (searchQuery.isNotEmpty) {
                customers = customers.where((customer) {
                  return customer.name.toLowerCase().contains(searchQuery) ||
                         customer.email.toLowerCase().contains(searchQuery) ||
                         customer.phone.contains(searchQuery);
                }).toList();
              }
              
              return ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(customer.name[0].toUpperCase()),
                    ),
                    title: Text(customer.name),
                    subtitle: Text('${customer.email}\n${customer.phone}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        // Navigate to customer details
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
```

---

## 🎨 StreamBuilder Best Practices

### 1. Always Handle Connection States

```dart
StreamBuilder<List<Map<String, dynamic>>>(
  stream: syncController.productsStream,
  builder: (context, snapshot) {
    // Loading state
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }
    
    // Error state
    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 60),
            SizedBox(height: 16),
            Text('Error: ${snapshot.error}'),
            ElevatedButton(
              onPressed: () {
                // Retry logic
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    // Empty state
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('No data available'),
          ],
        ),
      );
    }
    
    // Success state - render data
    final items = snapshot.data!;
    return ListView.builder(...);
  },
);
```

### 2. Use initialData for Smooth Transitions

```dart
StreamBuilder<List<Map<String, dynamic>>>(
  stream: syncController.productsStream,
  initialData: [], // Prevents null errors while waiting
  builder: (context, snapshot) {
    final products = snapshot.data!
        .map((data) => ProductModel.fromJson(data))
        .toList();
    
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) => ProductCard(products[index]),
    );
  },
);
```

### 3. Cache Parsed Models for Performance

```dart
class ProductListView extends StatefulWidget {
  @override
  _ProductListViewState createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final syncController = Get.find<UniversalSyncController>();
  List<ProductModel> cachedProducts = [];
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: syncController.productsStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Update cache when new data arrives
          cachedProducts = snapshot.data!
              .map((data) => ProductModel.fromJson(data))
              .toList();
        }
        
        // Always show cached data (even while loading new data)
        return ListView.builder(
          itemCount: cachedProducts.length,
          itemBuilder: (context, index) => ProductCard(cachedProducts[index]),
        );
      },
    );
  }
}
```

### 4. Combine Streams with Local Filters

```dart
StreamBuilder<List<Map<String, dynamic>>>(
  stream: syncController.transactionsStream,
  builder: (context, snapshot) {
    if (!snapshot.hasData) return LoadingWidget();
    
    final transactions = snapshot.data!
        .map((data) => TransactionModel.fromJson(data))
        .where((t) => t.date.isAfter(DateTime.now().subtract(Duration(days: 7))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
    
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) => TransactionCard(transactions[index]),
    );
  },
);
```

---

## 🔄 Platform-Specific UI Code

### Approach 1: Separate Files (Recommended)

```
lib/views/products/
  ├── product_list_view_desktop.dart  (Uses ProductController + Obx)
  ├── product_list_view_mobile.dart   (Uses StreamBuilder)
  └── product_list_view.dart          (Platform router)
```

**product_list_view.dart (Router):**
```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'product_list_view_desktop.dart';
import 'product_list_view_mobile.dart';

class ProductListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      return ProductListViewMobile();
    } else {
      return ProductListViewDesktop();
    }
  }
}
```

### Approach 2: Conditional Rendering

```dart
class ProductListView extends StatelessWidget {
  final syncController = Get.find<UniversalSyncController>();
  final productController = Get.find<ProductController>();
  
  @override
  Widget build(BuildContext context) {
    if (syncController.isMobile) {
      // Mobile: Use StreamBuilder
      return StreamBuilder<List<Map<String, dynamic>>>(
        stream: syncController.productsStream,
        builder: (context, snapshot) {
          // Stream-based UI
        },
      );
    } else {
      // Desktop: Use Obx
      return Obx(() {
        return ListView.builder(
          itemCount: productController.products.length,
          itemBuilder: (context, index) {
            // Controller-based UI
          },
        );
      });
    }
  }
}
```

---

## ⚡ Performance Considerations

### 1. Stream Memory Management

StreamBuilder automatically manages subscriptions, but for manual subscriptions:

```dart
class MyView extends StatefulWidget {
  @override
  _MyViewState createState() => _MyViewState();
}

class _MyViewState extends State<MyView> {
  final syncController = Get.find<UniversalSyncController>();
  StreamSubscription? _subscription;
  
  @override
  void initState() {
    super.initState();
    _subscription = syncController.productsStream.listen((data) {
      // Handle data
    });
  }
  
  @override
  void dispose() {
    _subscription?.cancel(); // IMPORTANT: Clean up
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // UI
  }
}
```

### 2. Large Lists with ListView.builder

Always use `ListView.builder` (not `ListView`) for large datasets:

```dart
// ✅ GOOD: Builds items on-demand
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(items[index]),
);

// ❌ BAD: Builds all items immediately
ListView(
  children: items.map((item) => ItemCard(item)).toList(),
);
```

### 3. Debounce Search Inputs

```dart
import 'package:rxdart/rxdart.dart';

class SearchView extends StatefulWidget {
  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final searchSubject = BehaviorSubject<String>();
  
  @override
  void initState() {
    super.initState();
    searchSubject
        .debounceTime(Duration(milliseconds: 300))
        .distinct()
        .listen((query) {
          // Perform search
        });
  }
  
  @override
  void dispose() {
    searchSubject.close();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) => searchSubject.add(value),
      decoration: InputDecoration(hintText: 'Search...'),
    );
  }
}
```

---

## 🐛 Debugging Streams

### Console Output

When app starts on mobile, you'll see:

```
📱 Mobile detected: Stream getters available for StreamBuilder
ℹ️ Mobile views should use UniversalSyncController stream getters:
   - productsStream
   - transactionsStream
   - customersStream
   - walletsStream
   - subscriptionsStream
   - businessSettingsStream
   - priceTagTemplatesStream
   - cashiersStream
```

### Test Stream Connection

```dart
final syncController = Get.find<UniversalSyncController>();

// Test subscription stream
syncController.subscriptionsStream.listen(
  (data) {
    print('📥 Subscription data: ${data.length} items');
    data.forEach((sub) => print('   - ${sub['plan_name']}'));
  },
  onError: (error) {
    print('❌ Stream error: $error');
  },
  onDone: () {
    print('✅ Stream completed');
  },
);
```

### Verify Firestore Connection

```dart
import 'package:get/get.dart';
import '../services/firedart_sync_service.dart';

void checkFirestoreConnection() {
  final syncService = Get.find<FiredartSyncService>();
  
  print('Connection Status: ${syncService.isOnline.value}');
  print('Business ID: ${syncService.businessId}');
  print('Last Sync: ${syncService.lastSyncTime.value}');
}
```

---

## 📋 Migration Checklist

To migrate a view from desktop callback pattern to mobile streams:

- [ ] Import `UniversalSyncController`
- [ ] Add `final syncController = Get.find<UniversalSyncController>();`
- [ ] Replace `Obx(() => ...)` with `StreamBuilder(stream: syncController.xxxStream, builder: ...)`
- [ ] Handle connection states (waiting, error, empty, success)
- [ ] Parse data with `Model.fromJson()`
- [ ] Test on mobile device (Android/iOS)
- [ ] Verify real-time updates work (change data in Firestore console)
- [ ] Check performance with large datasets
- [ ] Add error handling and loading states

---

## 🎯 Next Steps

### 1. Update Priority Views

High-traffic mobile screens to update first:
- Products List
- Transaction History
- Customer List
- Subscription Status
- Wallet Balance

### 2. Test Real-Time Updates

1. Open app on mobile device
2. Open Firestore console
3. Add/edit/delete a document
4. Verify mobile UI updates instantly (within 1-2 seconds)

### 3. Monitor Performance

- Use Flutter DevTools to monitor stream subscriptions
- Check for memory leaks (subscriptions not cancelled)
- Profile frame rendering times
- Test with poor network conditions

---

## 📞 Support

If you encounter issues:

1. **Check Platform Detection**: Verify `syncController.isMobile` returns true
2. **Check Stream Connection**: Listen to stream and print data
3. **Check Firestore Rules**: Ensure read permissions are set
4. **Check Business ID**: Verify `syncService.businessId` is set correctly
5. **Check Logs**: Look for "📱 Mobile detected" message on app start

---

## 🎉 Benefits Summary

✅ **Instant Updates**: UI updates within 1-2 seconds of Firestore changes  
✅ **No Manual Refresh**: Streams push data automatically  
✅ **Better UX**: Native mobile app feel with reactive UI  
✅ **Simple API**: Single line to get stream: `syncController.productsStream`  
✅ **Type Safety**: All streams return `Stream<List<Map<String, dynamic>>>`  
✅ **Platform Agnostic**: Desktop uses callbacks, mobile uses streams, no conflicts  
✅ **Production Ready**: No breaking changes to existing desktop code  
✅ **Scalable**: Works with any collection in Firestore  

---

**Last Updated:** November 19, 2025  
**Version:** 1.0.0  
**Status:** ✅ Production Ready
