# Quick Integration Guide - Subscription System

## 🚀 To Enable Subscriptions in Your App

### Step 1: Initialize Services in main.dart

```dart
import 'package:get/get.dart';
import 'services/database_service.dart';
import 'services/subscription_service.dart';
import 'services/data_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services in order
  Get.put(DatabaseService());
  Get.put(SubscriptionService()); // NEW - Add this line
  Get.put(DataSyncService());
  
  runApp(MyApp());
}
```

### Step 2: Access Settings

Navigate to: **Settings → Subscription** tab (4th tab with crown icon 👑)

### Step 3: Test the System

1. **Free User Experience:**
   - Go to Settings → Sync tab
   - You'll see a premium gate
   - Click "View Plans"
   - Choose a plan
   
2. **Subscribe (Mock Payment):**
   - Select plan (K500, K1,500, or K2,400)
   - Click "Subscribe"
   - Enter any phone number (e.g., 0977123456)
   - Select payment method
   - Click "Pay"
   - Wait 2 seconds for mock processing
   - Subscription activates automatically

3. **Access Sync Features:**
   - Go to Settings → Sync tab
   - Now you can configure sync
   - Enter Business ID
   - Set API URL and Key
   - Enable auto-sync

## 📱 Navigation

### Settings Tab Structure:
1. ⚙️ System - Printers & Cashiers
2. 🏪 Business - Store Settings
3. 🎨 Appearance - Dark Mode
4. 👑 **Subscription** - Manage Plans ← NEW
5. ☁️ Sync - Cloud Sync (Premium)

## 🔐 Subscription Gates

### Where Sync is Gated:
- **Settings → Sync Tab**: Shows premium gate if no subscription
- **DataSyncService.syncPendingRecords()**: Checks subscription before syncing
- **All offline features**: Always free, no restrictions

### Check Subscription in Your Code:
```dart
final subscriptionService = Get.find<SubscriptionService>();

if (subscriptionService.hasAccessToSync) {
  // User has active subscription
  await dataSyncService.syncPendingRecords();
} else {
  // Show upgrade prompt
  Get.snackbar(
    'Premium Feature',
    'Upgrade to use cloud sync',
    backgroundColor: Colors.orange,
    colorText: Colors.white,
  );
}
```

## 💳 Real Payment Integration

### To Replace Mock Payment:

Edit `lib/services/subscription_service.dart`, line ~291:

```dart
Future<String?> processPayment({
  required SubscriptionPlan plan,
  required String businessId,
  required String phoneNumber,
}) async {
  // Replace this mock implementation:
  
  // Option 1: MTN Mobile Money
  final response = await mtnMobileMoneyAPI.requestToPay(
    amount: SubscriptionModel.getPlanPrice(plan),
    phone: phoneNumber,
    currency: 'ZMW',
  );
  
  // Option 2: Airtel Money
  final response = await airtelMoneyAPI.initiatePayment(
    amount: SubscriptionModel.getPlanPrice(plan),
    msisdn: phoneNumber,
  );
  
  // Option 3: Payment Gateway (e.g., Flutterwave)
  final response = await flutterwaveAPI.initializePayment(
    amount: SubscriptionModel.getPlanPrice(plan),
    phoneNumber: phoneNumber,
    email: '$businessId@pos.local',
  );
  
  if (response.success) {
    return response.transactionId;
  }
  
  return null;
}
```

## 🎯 Testing Scenarios

### Scenario 1: New User
1. Launch app
2. Free subscription created automatically
3. All offline features work
4. Sync shows premium gate
5. Can view subscription plans

### Scenario 2: Subscribe
1. Go to Settings → Subscription
2. Choose "1 Year" plan (K1,500)
3. Enter phone: 0977123456
4. Select: MTN Mobile Money
5. Click "Pay K1,500.00"
6. Wait for processing
7. See success message
8. Subscription card shows "Active"
9. Sync tab now accessible

### Scenario 3: Expired Subscription
1. Subscription end date passes
2. App checks hourly
3. Status changes to "Expired"
4. Snackbar notification shown
5. Sync tab shows premium gate again
6. Can renew from Subscription tab
7. Offline features continue working

## ⚙️ Configuration

### Default Free Subscription
- Plan: Free
- Duration: 100 years (effectively permanent)
- Features: All offline POS features
- Restriction: No cloud sync

### Subscription Expiry Check
- Frequency: Every 1 hour
- Auto-update: Status changes to expired
- Notification: Snackbar shown to user
- Grace period: None (can be added)

### Storage
- **Database**: SQLite (subscriptions table)
- **Cache**: GetStorage (current_subscription key)
- **Sync**: Automatic between DB and cache

## 📊 Monitoring

### Check Current Subscription:
```dart
final subscription = subscriptionService.currentSubscription.value;

print('Plan: ${subscription?.planName}');
print('Status: ${subscription?.status.name}');
print('Days Remaining: ${subscription?.daysRemaining}');
print('Has Sync Access: ${subscription?.hasAccessToSync}');
```

### Get Subscription History:
```dart
final history = await subscriptionService.getSubscriptionHistory(businessId);

for (var sub in history) {
  print('${sub.planName}: ${sub.status.name} (${sub.startDate} - ${sub.endDate})');
}
```

## 🐛 Troubleshooting

### Subscription Not Loading?
```dart
// Force reload
final subscriptionService = Get.find<SubscriptionService>();
await subscriptionService.checkAndUpdateExpiredSubscriptions();
```

### Sync Still Restricted?
1. Check subscription status: `subscriptionService.currentSubscription.value`
2. Verify plan is not free: `subscription.plan != SubscriptionPlan.free`
3. Check expiry: `subscription.isActive`
4. Restart app to reload subscription

### Payment Failed?
- Mock payment always succeeds
- For real payment: Check API credentials
- Verify phone number format
- Check network connection
- Review payment provider logs

## 🎨 Customization

### Change Prices:
Edit `lib/models/subscription_model.dart`, line ~75:
```dart
static double getPlanPrice(SubscriptionPlan plan) {
  switch (plan) {
    case SubscriptionPlan.free:
      return 0;
    case SubscriptionPlan.monthly:
      return 500;  // Change here
    case SubscriptionPlan.yearly:
      return 1500; // Change here
    case SubscriptionPlan.twoYears:
      return 2400; // Change here
  }
}
```

### Add Trial Period:
```dart
// In subscription_service.dart
final trialSubscription = SubscriptionModel(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  businessId: businessId,
  plan: SubscriptionPlan.yearly, // Full features
  status: SubscriptionStatus.trial, // Trial status
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 14)), // 14-day trial
  amount: 0,
  createdAt: DateTime.now(),
);
```

## 📝 Summary

✅ Add one line to main.dart: `Get.put(SubscriptionService());`  
✅ Navigate to Settings → Subscription  
✅ System auto-creates free subscription  
✅ Sync features gated behind subscription  
✅ Mock payment works immediately  
✅ Ready for real payment integration  

Everything is configured and ready to use! 🚀
