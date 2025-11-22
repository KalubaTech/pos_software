# 🔧 Online Orders - Troubleshooting & FAQ

## 🐛 Common Issues & Solutions

### Issue 1: Orders Not Appearing

#### Symptoms
- Online Orders view is empty
- No orders showing in any tab
- Statistics show 0 for everything

#### Possible Causes & Solutions

**1. Business ID Not Set**
```dart
// Check in console
print('Business ID: ${GetStorage().read('businessId')}');

// If null, ensure it's set after login:
GetStorage().write('businessId', businessId);
```

**2. Firestore Rules Blocking Access**
```javascript
// Verify in Firebase Console → Firestore → Rules
// Should allow read for business owners
allow read: if request.auth != null && 
  resource.data.businessId == request.auth.token.businessId;
```

**3. No Orders in Database**
```
// Check Firebase Console → Firestore → online_orders collection
// Verify orders exist with matching businessId
```

**4. Controller Not Initialized**
```dart
// In main.dart, ensure:
Get.put(OnlineOrdersController());

// Check if controller exists:
try {
  final controller = Get.find<OnlineOrdersController>();
  print('Controller found: ${controller.isInitialized.value}');
} catch (e) {
  print('Controller not found: $e');
}
```

---

### Issue 2: Notifications Not Showing

#### Symptoms
- New orders arrive but no notification
- Badge count doesn't update
- No snackbar appears

#### Solutions

**1. Controller Not Listening**
```dart
// Check console for:
print('🔄 Initializing Online Orders Controller');
print('✅ Online Orders Controller initialized');

// If not present, controller didn't initialize
```

**2. Badge Not Cleared**
```dart
// Manually clear badge:
final controller = Get.find<OnlineOrdersController>();
controller.clearNewOrdersBadge();
```

**3. Notification Permissions (Future Feature)**
```dart
// Currently notifications are in-app only
// Desktop/push notifications coming in Phase 2
```

---

### Issue 3: Status Updates Not Working

#### Symptoms
- Click "Confirm Order" but status doesn't change
- Error message appears
- Order stays in pending

#### Solutions

**1. Check Firestore Write Permissions**
```javascript
// In firestore.rules:
allow update: if request.auth != null && 
  resource.data.businessId == request.auth.token.businessId;
```

**2. Verify Internet Connection**
```dart
// Check connectivity
// Look for cloud icon in app header
// Should be blue/green, not grey
```

**3. Check Console for Errors**
```
❌ Error updating order status: [error details]
```

**4. Verify Order ID**
```dart
// Ensure order ID is valid
print('Updating order: ${order.id}');
```

---

### Issue 4: Statistics Not Updating

#### Symptoms
- Order count doesn't change
- Revenue stays at 0
- Statistics cards show wrong numbers

#### Solutions

**1. Manual Refresh**
```dart
final controller = Get.find<OnlineOrdersController>();
await controller.loadStatistics();
```

**2. Check Firestore Query**
```dart
// Verify orders have correct status values
// Status should be: pending, confirmed, preparing, etc.
// Not: Pending, PENDING, or other variations
```

**3. Revenue Calculation**
```dart
// Revenue only counts delivered orders
// Check if orders are marked as delivered
```

---

### Issue 5: Duplicate Orders Appearing

#### Symptoms
- Same order shows multiple times
- Order count is inflated

#### Solutions

**1. Check Stream Subscriptions**
```dart
// Ensure only one subscription per stream
// Controller should be singleton (Get.put, not Get.lazyPut)
```

**2. Verify Firestore Data**
```
// Check Firebase Console
// Ensure no duplicate documents with same order ID
```

---

### Issue 6: App Crashes When Opening Online Orders

#### Symptoms
- App crashes when clicking "Online Orders"
- Error in console
- Red screen

#### Solutions

**1. Check Dependencies**
```yaml
# In pubspec.yaml, ensure:
dependencies:
  cloud_firestore: ^latest_version
  get: ^latest_version
  intl: ^latest_version
```

**2. Check Imports**
```dart
// Verify all imports are correct
import 'package:pos_software/models/online_order_model.dart';
import 'package:pos_software/controllers/online_orders_controller.dart';
import 'package:pos_software/services/online_orders_service.dart';
```

**3. Check Model Parsing**
```dart
// Look for JSON parsing errors in console
// Verify Firestore data matches model structure
```

---

## ❓ Frequently Asked Questions

### Q1: How do customers place orders?

**A:** Customers use the **Dynamos Market** mobile app to:
1. Browse products from businesses with online store enabled
2. Add products to cart
3. Enter delivery address
4. Choose payment method
5. Place order

The order automatically appears in the merchant's POS system.

---

### Q2: What happens when a new order arrives?

**A:** When a customer places an order:
1. ✅ Order is created in Firestore
2. ✅ POS system receives real-time notification
3. ✅ Green snackbar appears at top of screen
4. ✅ Badge shows on "Online Orders" menu
5. ✅ Order appears in "Pending" tab
6. ✅ Statistics update automatically

---

### Q3: Can I cancel an order after confirming it?

**A:** Yes, orders can be cancelled at these stages:
- ✅ Pending
- ✅ Confirmed
- ❌ Preparing (contact customer first)
- ❌ Out for Delivery (contact customer first)
- ❌ Delivered (cannot cancel, use refund instead)

---

### Q4: What payment methods are supported?

**A:** Currently supported:
- Cash on Delivery (COD)
- Mobile Money (future)
- Card Payment (future)
- Wallet Payment (future)

Payment is handled by the customer app. POS system tracks payment status.

---

### Q5: How do I know which orders need attention?

**A:** Check the **Pending** tab:
- Shows orders awaiting confirmation
- Badge on navigation menu shows count
- Orders sorted by oldest first (FIFO)

---

### Q6: Can I edit order details?

**A:** Currently, you can:
- ✅ Update order status
- ✅ Update payment status
- ✅ Add notes to order
- ❌ Cannot edit items or amounts (contact customer)

---

### Q7: What if a product is out of stock?

**A:** If a product is out of stock:
1. Cancel the order
2. Provide reason: "Product out of stock"
3. Customer receives notification
4. Customer can reorder when available

**Future Feature**: Automatic stock checking before order placement.

---

### Q8: How do I track delivery?

**A:** Current tracking:
- Update status as order progresses
- Customer sees status in their app
- Timestamps recorded for each status change

**Future Feature**: GPS tracking, driver assignment.

---

### Q9: Can I print order receipts?

**A:** Not yet implemented. Coming in Phase 2:
- Print order details
- Print delivery slip
- Print invoice

**Workaround**: Use existing receipt printer for manual printing.

---

### Q10: How do I view order history?

**A:** Use the **All Orders** tab:
- Shows complete order history
- Filter by date (future feature)
- Export to Excel/PDF (future feature)

---

### Q11: What if customer provides wrong address?

**A:** Options:
1. Contact customer using phone number in order
2. Update delivery instructions (add notes)
3. Cancel and ask customer to reorder with correct address

**Future Feature**: Edit delivery address in POS.

---

### Q12: How is delivery fee calculated?

**A:** Currently:
- Fixed fee: K 50.00
- Applied to all orders

**Future Feature**: 
- Distance-based calculation
- Zone-based pricing
- Free delivery threshold

---

### Q13: Can I assign orders to specific staff?

**A:** Not yet. Coming in Phase 2:
- Assign to cashiers
- Assign to delivery drivers
- Track who processed each order

---

### Q14: What reports are available?

**A:** Current analytics:
- Total orders count
- Orders by status
- Total revenue
- Pending orders count

**Future Features**:
- Daily/weekly/monthly reports
- Revenue charts
- Popular products
- Customer analytics
- Peak order times

---

### Q15: How do I enable online ordering for my business?

**A:** Follow these steps:
1. Go to **Settings** → **Business** tab
2. Scroll to **Online Store** section
3. Toggle **Enable Online Store** to ON
4. Go to **Products** section
5. Edit each product you want to sell online
6. Toggle **List on Online Store** to ON
7. Save products

Your products are now visible in Dynamos Market!

---

## 🔍 Debugging Tips

### Enable Verbose Logging

```dart
// In online_orders_controller.dart
// Uncomment or add detailed logs:
print('📦 Order received: ${order.id}');
print('👤 Customer: ${order.customerName}');
print('💰 Total: K ${order.total}');
print('📍 Address: ${order.deliveryAddress.fullAddress}');
```

### Check Firestore Console

1. Open Firebase Console
2. Go to Firestore Database
3. Navigate to `online_orders` collection
4. Verify:
   - Orders exist
   - businessId matches your business
   - Status values are correct (lowercase)
   - Timestamps are valid

### Monitor Network Traffic

```dart
// Check if Firestore is connected
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### Test with Sample Data

Create a test order in Firestore Console:
```javascript
{
  "businessId": "YOUR_BUSINESS_ID",
  "status": "pending",
  "customerName": "Test Customer",
  // ... other required fields
}
```

---

## 📞 Support Escalation

### When to Escalate

Escalate to technical support if:
- ❌ Firestore data is corrupted
- ❌ Multiple merchants report same issue
- ❌ Orders disappearing after creation
- ❌ Payment status not syncing
- ❌ Critical bug affecting order processing

### What to Provide

When reporting an issue:
1. **Error Message**: Full error from console
2. **Steps to Reproduce**: What you did before error
3. **Screenshots**: UI state when error occurred
4. **Order ID**: Affected order ID (if applicable)
5. **Business ID**: Your business ID
6. **Timestamp**: When error occurred

---

## 🎓 Best Practices

### For Merchants

1. **Check Orders Regularly**
   - Monitor pending tab frequently
   - Respond to orders within 15 minutes
   - Update status as you progress

2. **Communicate with Customers**
   - Call if there are issues
   - Update status promptly
   - Add notes for special instructions

3. **Manage Inventory**
   - Keep stock levels updated
   - Disable products when out of stock
   - Re-enable when restocked

4. **Track Performance**
   - Monitor order statistics
   - Review completed orders
   - Identify popular products

### For Developers

1. **Error Handling**
   - Always wrap Firestore calls in try-catch
   - Provide user-friendly error messages
   - Log errors for debugging

2. **Data Validation**
   - Validate order data before processing
   - Check for required fields
   - Handle null values gracefully

3. **Performance**
   - Use indexed queries
   - Limit query results
   - Implement pagination for large lists

4. **Security**
   - Validate business ID
   - Check user permissions
   - Sanitize user input

---

## 🚀 Performance Tips

### Optimize Firestore Queries

```dart
// Use indexed fields
.where('businessId', isEqualTo: businessId)
.where('status', isEqualTo: 'pending')
.orderBy('createdAt', descending: false)
```

### Reduce Rebuilds

```dart
// Use Obx only where needed
Obx(() => Text('${controller.pendingOrders.length}'))

// Not:
Obx(() => EntireWidget())
```

### Cache Data Locally

```dart
// GetStorage for persistence
final storage = GetStorage();
storage.write('lastOrderCheck', DateTime.now());
```

---

## 📚 Additional Resources

- **ONLINE_ORDER_INTEGRATION_COMPLETE.md** - Full implementation guide
- **ONLINE_ORDERS_QUICK_START.md** - Quick setup guide
- **ONLINE_ORDERS_WORKFLOW.md** - Visual workflow diagrams
- **DYNAMOS_MARKET_AGENT_GUIDE.md** - Agent training manual
- **DYNAMOS_MARKET_ARCHITECTURE.md** - System architecture

---

## ✅ Health Check Checklist

Run this checklist to verify system health:

```
□ Controller initialized successfully
□ Firestore connection active
□ Business ID set correctly
□ Stream subscriptions active
□ No console errors
□ Orders loading in UI
□ Statistics displaying correctly
□ Notifications working
□ Status updates working
□ Navigation menu shows badge
```

If all checked, system is healthy! ✅

---

**Need More Help?**

1. Check the documentation files
2. Review console logs
3. Test with sample data
4. Contact technical support

Remember: Most issues are configuration-related and can be fixed by verifying business ID, Firestore rules, and controller initialization.
