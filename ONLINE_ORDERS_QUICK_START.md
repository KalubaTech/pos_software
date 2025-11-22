# 🚀 Online Orders - Quick Integration Guide

## ⚡ 5-Minute Setup

### 1. Add to Navigation (main_side_navigation_bar.dart)

```dart
// Add this import
import 'package:pos_software/controllers/online_orders_controller.dart';

// Add to your navigation items list
NavigationItem(
  icon: Icons.shopping_bag,
  label: 'Online Orders',
  route: '/online-orders',
  // Optional: Show badge for new orders
  badge: () {
    try {
      final controller = Get.find<OnlineOrdersController>();
      return controller.newOrdersCount.value > 0
          ? '${controller.newOrdersCount.value}'
          : null;
    } catch (e) {
      return null;
    }
  }(),
),
```

---

### 2. Add Route (main.dart)

```dart
// Add this import
import 'package:pos_software/views/online_orders/online_orders_view.dart';

// Add to your GetPages list
GetPage(
  name: '/online-orders',
  page: () => const OnlineOrdersView(),
),
```

---

### 3. Initialize Controller (main.dart)

```dart
// Add this import
import 'package:pos_software/controllers/online_orders_controller.dart';

// In your initServices() or main() function, after other controllers
Future<void> initServices() async {
  // ... existing controller initializations
  
  // Initialize Online Orders Controller
  Get.put(OnlineOrdersController());
  
  print('✅ Online Orders Controller initialized');
}
```

---

### 4. Reinitialize After Login

In your login controller or authentication handler:

```dart
// After successful login
final businessId = /* your business ID */;

// Reinitialize online orders controller with business ID
try {
  final onlineOrdersController = Get.find<OnlineOrdersController>();
  await onlineOrdersController.reinitialize(businessId);
  print('✅ Online Orders reinitialized for business: $businessId');
} catch (e) {
  print('⚠️ Online Orders Controller not found: $e');
}
```

---

### 5. Firestore Security Rules

Add to your `firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Existing rules...
    
    // Online orders collection (subcollection of businesses)
    match /businesses/{businessId}/online_orders/{orderId} {
      // Anyone can create orders (customers from Dynamos Market)
      allow create: if request.auth != null;
      
      // Business owners and staff can read and update their orders
      allow read, update: if request.auth != null; 
      // Note: In production, add stricter checks here to ensure user belongs to businessId
      
      // No one can delete orders
      allow delete: if false;
    }
  }
}
```

---

## ✅ Verification Checklist

After integration, verify:

- [ ] "Online Orders" appears in navigation menu
- [ ] Clicking it opens the Online Orders view
- [ ] Statistics cards display (even if showing 0)
- [ ] Tabs are visible (Pending, Active, Completed, All Orders)
- [ ] No console errors
- [ ] Controller initializes successfully

---

## 🧪 Test with Sample Data

Create a test order in Firestore Console:

```javascript
// Collection: businesses/{YOUR_BUSINESS_ID}/online_orders
// Document ID: (auto-generate)
{
  "id": "TEST_ORDER_001",
  "customerId": "CUST_TEST_001",
  "customerName": "Test Customer",
  "customerPhone": "+260971234567",
  "customerEmail": "test@example.com",
  "businessId": "YOUR_BUSINESS_ID", // Replace with your actual business ID
  "businessName": "Your Business Name",
  "businessPhone": "0973232553",
  "items": [
    {
      "productId": "PROD_001",
      "productName": "Test Product",
      "imageUrl": null,
      "price": 50.00,
      "quantity": 2,
      "variant": null,
      "total": 100.00
    }
  ],
  "subtotal": 100.00,
  "deliveryFee": 50.00,
  "total": 150.00,
  "status": "pending",
  "deliveryAddress": {
    "id": "ADDR_001",
    "label": "Home",
    "fullAddress": "123 Test Street, Lusaka",
    "province": "Lusaka",
    "district": "Lusaka",
    "latitude": null,
    "longitude": null,
    "phoneNumber": "+260971234567",
    "instructions": "Test delivery instructions",
    "isDefault": true
  },
  "paymentMethod": "cash_on_delivery",
  "paymentStatus": "pending",
  "createdAt": "2025-11-22T14:30:00.000Z",
  "updatedAt": null,
  "confirmedAt": null,
  "deliveredAt": null,
  "notes": "This is a test order",
  "cancellationReason": null,
  "trackingNumber": null
}
```

---

## 🎯 Expected Behavior

1. **On App Start**:
   - Controller initializes
   - Connects to Firestore
   - Loads existing orders

2. **When New Order Arrives**:
   - Green notification appears at top
   - Badge shows on navigation menu
   - Order appears in "Pending" tab
   - Statistics update

3. **When Confirming Order**:
   - Click "Confirm Order" button
   - Success message appears
   - Order moves to "Active" tab
   - Status badge changes to "Confirmed"

---

## 🐛 Common Issues

### Issue: "No business ID found"
**Solution**: Make sure business ID is saved in GetStorage after login:
```dart
GetStorage().write('businessId', businessId);
```

### Issue: Orders not appearing
**Solution**: 
1. Check Firestore rules
2. Verify business ID matches
3. Check internet connection
4. Look for errors in console

### Issue: Controller not found
**Solution**: Make sure controller is initialized in main.dart:
```dart
Get.put(OnlineOrdersController());
```

---

## 📖 Full Documentation

For complete details, see: **ONLINE_ORDER_INTEGRATION_COMPLETE.md**

---

## 🎉 You're Done!

Your POS system can now receive and manage online orders from Dynamos Market!

**Next Steps**:
1. Test with sample order
2. Confirm order workflow works
3. Customize notifications (optional)
4. Train staff on new feature
5. Go live! 🚀
