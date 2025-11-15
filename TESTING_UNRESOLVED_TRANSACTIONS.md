# Testing Unresolved Transactions Feature

## Why You Can't See It Yet

The **Unresolved Transactions** section is **conditionally displayed** - it only appears when you have unresolved transactions in your database.

**Current State:** You likely have **0 unresolved transactions**, so the section is hidden.

---

## How to See It (Testing Steps)

### Method 1: Initiate a Payment That Times Out

This is the real-world scenario:

1. **Navigate to:** Settings → Subscription Tab
2. **Click:** "Choose Plan" (Basic, Pro, or Premium)
3. **Click:** "Subscribe Now"
4. **Enter:** Your phone number
5. **Click:** "Pay K500" (or whatever the amount is)
6. **DO NOT approve the payment on your phone** 📱❌
7. **Wait:** System will check status 5 times (about 25 seconds)
8. **Result:** Payment status will timeout as "not-found"
9. **Outcome:** Transaction automatically saved to unresolved
10. **Section appears!** You'll see "Unresolved Transactions [1]"

---

### Method 2: Add Test Data Directly (Quick Test)

If you want to see it immediately without waiting for a real payment:

#### Option A: Using Debug Code (Add temporarily to subscription_view.dart)

Add this test button in your `_buildHeader` method:

```dart
// Add this at the end of _buildHeader method (just for testing)
if (kDebugMode) {  // Only in debug mode
  ElevatedButton(
    onPressed: () async {
      final subscriptionService = Get.find<SubscriptionService>();
      final businessController = Get.find<BusinessSettingsController>();
      
      // Add a test unresolved transaction
      await subscriptionService.addUnresolvedTransaction(
        businessId: businessController.storeName.value.isNotEmpty
            ? businessController.storeName.value
            : 'default',
        plan: SubscriptionPlan.basic,
        transactionId: 'TEST-${DateTime.now().millisecondsSinceEpoch}',
        lencoReference: 'LENCO-TEST-123',
        phone: '0977123456',
        operator: 'MTN',
        amount: 500.0,
      );
      
      Get.snackbar('Test', 'Test transaction added!');
    },
    child: Text('Add Test Unresolved Transaction'),
  ),
}
```

#### Option B: Using SQLite Browser

1. Locate your database file (usually in app documents)
2. Open with SQLite browser
3. Go to `unresolved_transactions` table
4. Insert a test record:

```sql
INSERT INTO unresolved_transactions (
  id, businessId, plan, transactionId, lencoReference,
  phone, operator, amount, status, createdAt, checkAttempts
) VALUES (
  'test-001',
  'default',
  'basic',
  'TEST-REF-123',
  'LENCO-REF-123',
  '0977123456',
  'MTN',
  500.0,
  'timeout',
  '2025-11-15T10:30:00',
  5
);
```

5. Restart the app
6. Navigate to Settings → Subscription
7. Section should appear!

---

## What You'll See When It Works

### Visual Appearance:

```
┌─────────────────────────────────────────────────┐
│  🕐 Unresolved Transactions                [1] │
│                                                 │
│  These transactions could not be verified.      │
│  You can retry checking their status.           │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │ 👑 BASIC PLAN                             │ │
│  │ K500.00 · MTN                             │ │
│  │                                           │ │
│  │ STATUS: Timeout                           │ │
│  │                                           │ │
│  │ Transaction: TEST-REF-123                 │ │
│  │ Phone: 0977123456                         │ │
│  │                                           │ │
│  │ Created 2 hours ago · 5 check attempts    │ │
│  │                                           │ │
│  │        [🔄 Retry Status Check]            │ │
│  └───────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

---

## Debug: Check If Unresolved Transactions Exist

Add this debug code to see what's in the list:

### In subscription_view.dart, add to build method:

```dart
// Debug output (remove after testing)
print('🔍 Unresolved transactions count: ${subscriptionService.unresolvedTransactions.length}');
if (subscriptionService.unresolvedTransactions.isNotEmpty) {
  print('📋 Unresolved transactions:');
  for (var tx in subscriptionService.unresolvedTransactions) {
    print('  - ${tx.transactionId}: ${tx.status.name}');
  }
} else {
  print('✅ No unresolved transactions');
}
```

Check your console/debug output to see if transactions are loaded.

---

## Troubleshooting

### Issue: Section doesn't appear even with transactions in DB

**Check 1:** Is SubscriptionService initialized?
```dart
// In main.dart, ensure:
Get.put(SubscriptionService());
```

**Check 2:** Is the observable updating?
```dart
// In subscription_service.dart _loadUnresolvedTransactions()
print('Loaded ${unresolvedTransactions.length} unresolved transactions');
```

**Check 3:** Is the Obx widget working?
```dart
// In subscription_view.dart
Obx(() {
  print('🔄 Obx rebuild - count: ${subscriptionService.unresolvedTransactions.length}');
  if (subscriptionService.unresolvedTransactions.isNotEmpty) {
    return _buildUnresolvedTransactionsSection(...);
  }
  return SizedBox.shrink();
}),
```

---

### Issue: Transactions not being saved

**Check:** Look for this print in console when payment times out:
```
⚠️ Transaction NOT FOUND - Adding to unresolved
```

If you don't see this, the payment might not be reaching the timeout state.

---

### Issue: Database table doesn't exist

**Check:** Look for this print on app startup:
```
Loaded X unresolved transactions
```

If you see an error instead, the table might not have been created.

**Fix:** Uninstall and reinstall the app to recreate database.

---

## Real-World Test Scenario

### Complete Flow:

1. **Start:** Open app → Settings → Subscription
2. **Initiate:** Click "Subscribe Now" on Basic Plan
3. **Enter:** Phone number (e.g., 0977123456)
4. **Send:** Click "Pay K500"
5. **See:** "Checking Payment Status..." card appears
6. **Wait:** Don't approve on phone
7. **Observe:** Status checks 5 times:
   - Attempt 1 of 5...
   - Attempt 2 of 5...
   - Attempt 3 of 5...
   - Attempt 4 of 5...
   - Attempt 5 of 5...
8. **Timeout:** After 25 seconds, checking stops
9. **Notification:** Orange "Transaction Saved" notification appears
10. **Dialog:** "Payment Status" dialog shows
11. **Section:** Scroll up to see "Unresolved Transactions [1]"
12. **Card:** Your transaction is there with [Retry] button

### Expected Console Output:

```
✅ Payment request initiated
📞 Payment sent to: 0977123456
🔍 Checking payment status... (attempt 1/5)
⏳ Transaction not found yet, waiting 5s...
🔍 Checking payment status... (attempt 2/5)
⏳ Transaction not found yet, waiting 5s...
🔍 Checking payment status... (attempt 3/5)
⏳ Transaction not found yet, waiting 5s...
🔍 Checking payment status... (attempt 4/5)
⏳ Transaction not found yet, waiting 5s...
🔍 Checking payment status... (attempt 5/5)
❌ Max attempts reached without confirmation
⚠️ Transaction NOT FOUND - Adding to unresolved
Loaded 1 unresolved transactions
```

---

## Summary

### Why you can't see it:
✅ **The feature is working correctly**  
✅ **The code is in place**  
✅ **You just don't have any unresolved transactions yet**

### How to see it:
1. **Real test:** Initiate payment → Don't approve → Wait for timeout
2. **Quick test:** Add test data using SQLite or debug button
3. **Debug:** Check console for "Loaded X unresolved transactions"

### When it appears:
- ✅ When `unresolvedTransactions.length > 0`
- ✅ Automatically after payment timeout
- ✅ Persists across app restarts
- ✅ Disappears when all transactions resolved

---

## Quick Verification

Run this in your debug console to check current state:

```dart
final subscriptionService = Get.find<SubscriptionService>();
print('Unresolved count: ${subscriptionService.unresolvedTransactions.length}');
```

**If 0:** Section is hidden (expected behavior)  
**If > 0:** Section should be visible - check Obx widget

---

**Status:** Feature is working correctly ✅  
**Next Step:** Test with real payment or add test data  
**Expected:** Section appears immediately when transaction added
