# Unresolved Transactions Feature

## Overview
A comprehensive system to track and retry payment transactions that could not be verified immediately. Users can retry checking the status later when the transaction becomes available in the system.

**Implemented:** November 15, 2025  
**Status:** ✅ Complete and Ready for Testing

---

## Problem Solved

### The Issue
When a user initiates a mobile money payment:
1. Payment request is sent to user's phone
2. User approves the payment
3. System polls for status (5 attempts × 5 seconds = 25 seconds)
4. **Problem:** If transaction status isn't available yet, the system times out
5. **Result:** User approved payment but subscription not activated
6. **User frustration:** Payment went through but no subscription!

### The Solution
✅ Save "unresolved" transactions to a persistent list  
✅ Allow users to retry checking status later  
✅ Automatically activate subscription when payment is found  
✅ Keep transaction history for reference  
✅ Clean up old resolved transactions

---

## How It Works

### Flow Diagram

```
User Initiates Payment
        ↓
Payment Request Sent
        ↓
User Approves on Phone ✓
        ↓
System Checks Status (5×5s)
        ↓
   ┌────┴────┐
   │ Found? │
   └────┬────┘
        │
    ┌───┴───┐
    │  YES  │──→ Activate Subscription ✓
    └───────┘
        │
    ┌───┴───┐
    │   NO  │──→ Add to Unresolved Transactions 📋
    └───────┘
        │
    User sees "Unresolved Transactions" section
        │
    User clicks "Retry Status Check"
        │
        ↓
    ┌────────────┐
    │ Found now? │
    └────┬───────┘
         │
    ┌────┴────┐
    │  YES    │──→ Activate Subscription ✓
    │         │    Remove from Unresolved
    └─────────┘
         │
    ┌────┴────┐
    │   NO    │──→ Keep in Unresolved
    │         │    Try again later
    └─────────┘
```

---

## Database Schema

### Unresolved Transactions Table

```sql
CREATE TABLE unresolved_transactions (
  id TEXT PRIMARY KEY,
  businessId TEXT NOT NULL,
  plan TEXT NOT NULL,
  transactionId TEXT NOT NULL,
  lencoReference TEXT,
  phone TEXT NOT NULL,
  operator TEXT NOT NULL,
  amount REAL NOT NULL,
  status TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  lastCheckedAt TEXT,
  checkAttempts INTEGER DEFAULT 0,
  lastError TEXT
)
```

**Indexes:**
- `idx_unresolved_business` on `businessId`
- `idx_unresolved_status` on `status`

---

## Transaction States

### 1. `pending` (Orange)
- **Meaning:** Waiting for payment approval or processing
- **User Action:** Retry check
- **Display:** "Pending Approval"

### 2. `checking` (Blue)
- **Meaning:** Currently checking transaction status
- **User Action:** Wait for result
- **Display:** "Checking Status..."

### 3. `timeout` (Red)
- **Meaning:** API call timed out or failed
- **User Action:** Retry check
- **Display:** "Check Timeout"

### 4. `notFound` (Orange)
- **Meaning:** Transaction not found in system yet
- **User Action:** Retry check later
- **Display:** "Not Found"

### 5. `resolved` (Green)
- **Meaning:** Transaction completed or failed (removed from list)
- **User Action:** None (hidden from unresolved list)
- **Display:** Not shown in unresolved section

---

## UI Components

### Unresolved Transactions Section

```
┌─────────────────────────────────────────────────────┐
│  🕐  Unresolved Transactions                    [2] │
│                                                      │
│  These transactions could not be verified. You can  │
│  retry checking their status.                       │
│  ┌────────────────────────────────────────────────┐│
│  │ 💰  1 Month                   [Pending Approval]││
│  │     K500.00 • MTN                              ││
│  │     ──────────────────────────────────────────  ││
│  │     Transaction Reference    Phone Number      ││
│  │     2531808060              0977123456         ││
│  │                                                ││
│  │     🕐 2h ago • 1 attempts                      ││
│  │                                                ││
│  │     [🔄 Retry Status Check]                    ││
│  └────────────────────────────────────────────────┘│
│  ┌────────────────────────────────────────────────┐│
│  │ 💰  1 Year                         [Not Found] ││
│  │     K1,500.00 • Airtel                        ││
│  │     ──────────────────────────────────────────  ││
│  │     Transaction Reference    Phone Number      ││
│  │     2531808061              0965987654         ││
│  │                                                ││
│  │     🕐 5h ago • 3 attempts                      ││
│  │                                                ││
│  │     [🔄 Retry Status Check]                    ││
│  └────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────┘
```

### Transaction Card Details

**Header:**
- Icon: Wallet icon in orange background
- Plan name: "1 Month", "1 Year", "24 Months"
- Amount & Operator: "K500.00 • MTN"
- Status badge: Color-coded status

**Body:**
- Transaction reference (lencoReference or transactionId)
- Phone number
- Time since created
- Number of check attempts

**Footer:**
- Retry button (if `canRetry` is true)

---

## API Methods

### 1. `addUnresolvedTransaction()`
```dart
await subscriptionService.addUnresolvedTransaction(
  businessId: 'store_123',
  plan: SubscriptionPlan.monthly,
  transactionId: '2531808060',
  lencoReference: 'LEN12345',
  phone: '0977123456',
  operator: 'mtn',
  amount: 500.00,
);
```

**When to use:** After payment timeout (status check failed 5 times)

---

### 2. `updateUnresolvedTransaction()`
```dart
await subscriptionService.updateUnresolvedTransaction(
  transactionId,
  status: TransactionStatus.checking,
  lastCheckedAt: DateTime.now(),
  checkAttempts: 2,
  lastError: null,
);
```

**When to use:** Update transaction state during retry

---

### 3. `removeUnresolvedTransaction()`
```dart
await subscriptionService.removeUnresolvedTransaction(transactionId);
```

**When to use:** Transaction resolved (completed or failed)

---

### 4. `retryUnresolvedTransaction()`
```dart
final result = await subscriptionService.retryUnresolvedTransaction(
  transaction,
);

if (result != null) {
  if (result['success'] == true) {
    // Payment successful - subscription activated
  } else if (result['status'] == 'failed') {
    // Payment failed
  } else {
    // Still pending or not found
  }
}
```

**When to use:** User clicks "Retry Status Check" button

**Returns:**
```dart
{
  'success': true/false,
  'status': 'completed'|'failed'|'pending'|'not-found'|'error',
  'message': 'Human-readable message',
  'mmAccountName': 'John Doe',  // if available
  'mmOperatorTxnId': 'MTN123',  // if available
}
```

---

### 5. `cleanupOldTransactions()`
```dart
await subscriptionService.cleanupOldTransactions();
```

**When to use:** Periodically (e.g., app startup)  
**Purpose:** Remove resolved transactions older than 30 days

---

## User Scenarios

### Scenario 1: Timeout During Initial Check

```
1. User clicks "Pay K500"
   ↓
2. Enters phone: 0977123456
   ↓
3. Clicks "Pay" button
   ↓
4. Payment initiated: "pay-offline"
   ↓
5. Notification: "Approval Required 📱"
   ↓
6. User picks up phone and approves ✓
   ↓
7. System polls for 25 seconds...
   ↓
8. Status not available yet ⏱️
   ↓
9. Transaction added to "Unresolved"
   ↓
10. Notification: "Transaction Saved"
    ↓
11. User sees unresolved section
    ↓
12. User waits 5 minutes (transaction processes)
    ↓
13. User clicks "Retry Status Check"
    ↓
14. Status found: "completed" ✓
    ↓
15. Subscription activated!
    ↓
16. Transaction removed from unresolved
    ↓
17. Notification: "Payment Successful! 🎉"
```

---

### Scenario 2: Multiple Retries

```
1. Transaction in unresolved list
   ↓
2. User clicks "Retry" (Attempt 1)
   ↓
3. Status: "Not Found"
   ↓
4. Wait 10 minutes...
   ↓
5. User clicks "Retry" (Attempt 2)
   ↓
6. Status: "Not Found"
   ↓
7. Wait 30 minutes...
   ↓
8. User clicks "Retry" (Attempt 3)
   ↓
9. Status: "Completed" ✓
   ↓
10. Subscription activated!
    ↓
11. Removed from unresolved
```

---

### Scenario 3: Payment Actually Failed

```
1. Transaction in unresolved list
   ↓
2. User clicks "Retry"
   ↓
3. Status: "Failed" ❌
   ↓
4. Reason: "Insufficient funds"
   ↓
5. Notification: "Payment Failed"
   ↓
6. Transaction removed from unresolved
   ↓
7. User can try again with new payment
```

---

## Integration Points

### When Transaction is Added

**File:** `subscription_view.dart`  
**Line:** ~1089 (in `_checkPaymentStatus` method)

```dart
} else if (confirmed['status'] == 'not-found') {
  // Add to unresolved
  await subscriptionService.addUnresolvedTransaction(
    businessId: ...,
    plan: plan.plan,
    transactionId: reference,
    lencoReference: lencoReference,
    phone: paymentResult['phone'] ?? '',
    operator: operator,
    amount: plan.price,
  );
  
  _showResultNotification(
    title: 'Transaction Saved',
    message: 'The transaction has been saved to "Unresolved Transactions"...',
    type: 'warning',
  );
}
```

---

### Where Unresolved Section Appears

**File:** `subscription_view.dart`  
**Line:** ~108 (in `build` method)

```dart
// Unresolved transactions section
Obx(() {
  if (subscriptionService.unresolvedTransactions.isNotEmpty) {
    return _buildUnresolvedTransactionsSection(...);
  }
  return SizedBox.shrink();
}),
```

**Position:** Between status checking card and current subscription card

---

## Benefits

### 1. No Lost Payments ✅
- User approves payment → Always tracked
- Even if system times out → Transaction saved
- Can retry later → Eventually activates

### 2. User Control 🎯
- See all pending transactions
- Retry at their convenience  
- Clear status for each transaction

### 3. Better UX 😊
- No frustration from "lost" payments
- Transparent process
- Always know what's happening

### 4. Data Persistence 💾
- Survives app restarts
- Transaction history maintained
- Can reference later

### 5. Automatic Cleanup 🧹
- Old resolved transactions removed
- Keeps database lean
- No manual maintenance needed

---

## Testing Checklist

### Test 1: Add Unresolved Transaction
- [ ] Initiate payment
- [ ] Wait for timeout (25 seconds)
- [ ] Verify transaction added to unresolved
- [ ] Verify notification shown
- [ ] Verify transaction appears in UI

### Test 2: Retry Success
- [ ] Have unresolved transaction
- [ ] Click "Retry Status Check"
- [ ] Mock payment as completed
- [ ] Verify subscription activated
- [ ] Verify transaction removed from unresolved
- [ ] Verify success notification

### Test 3: Retry Still Pending
- [ ] Have unresolved transaction
- [ ] Click "Retry Status Check"
- [ ] Mock status still "pay-offline"
- [ ] Verify transaction stays in unresolved
- [ ] Verify pending notification
- [ ] Verify checkAttempts incremented

### Test 4: Retry Failed
- [ ] Have unresolved transaction
- [ ] Click "Retry Status Check"
- [ ] Mock payment as failed
- [ ] Verify error notification
- [ ] Verify transaction removed
- [ ] Verify subscription not activated

### Test 5: Multiple Unresolved
- [ ] Add 3 unresolved transactions
- [ ] Verify all 3 display
- [ ] Verify count badge shows "3"
- [ ] Retry one transaction
- [ ] Verify it resolves correctly
- [ ] Verify count updates to "2"

### Test 6: Persistence
- [ ] Add unresolved transaction
- [ ] Close app completely
- [ ] Reopen app
- [ ] Verify transaction still in unresolved
- [ ] Verify all details preserved

### Test 7: Status Colors
- [ ] Verify pending = orange
- [ ] Verify checking = blue
- [ ] Verify timeout = red
- [ ] Verify not-found = orange

### Test 8: Cleanup
- [ ] Add resolved transaction (mock old date)
- [ ] Call cleanupOldTransactions()
- [ ] Verify old resolved transactions deleted
- [ ] Verify recent transactions kept

---

## Configuration

### Automatic Cleanup Schedule
Old resolved transactions are cleaned up after **30 days**.

**To change:**
```dart
// In subscription_service.dart
final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
// Change to: Duration(days: 60) for 60 days
```

### Retry Button Visibility
Transaction must be in one of these states:
- `pending`
- `timeout`
- `notFound`

**Check:**
```dart
bool get canRetry {
  return status == TransactionStatus.timeout || 
         status == TransactionStatus.notFound ||
         status == TransactionStatus.pending;
}
```

---

## Error Handling

### Scenario: API Error During Retry
```dart
try {
  final result = await retryUnresolvedTransaction(transaction);
} catch (e) {
  // Transaction marked as timeout
  // lastError field updated
  // User notified with error message
}
```

### Scenario: Database Error
```dart
try {
  await addUnresolvedTransaction(...);
} catch (e) {
  print('Error adding unresolved transaction: $e');
  // Silent fail - doesn't block payment flow
}
```

---

## Summary

### What Was Built ✅
1. **UnresolvedTransactionModel** - Data model for transactions
2. **Database table** - Persistent storage
3. **Service methods** - Add, update, remove, retry
4. **UI section** - Display unresolved transactions
5. **Transaction cards** - Show details and retry button
6. **Integration** - Auto-add on timeout
7. **Cleanup** - Remove old resolved transactions

### How It Helps Users 🎯
- ✅ Never lose a payment
- ✅ Retry checking anytime
- ✅ See all pending transactions
- ✅ Automatic activation when found
- ✅ Clear status for each transaction

### Files Modified 📁
- `lib/models/unresolved_transaction_model.dart` (NEW)
- `lib/services/subscription_service.dart` (UPDATED)
- `lib/views/settings/subscription_view.dart` (UPDATED)

---

**Status:** ✅ Feature Complete and Ready for Testing  
**Compilation:** ✅ No errors  
**Documentation:** ✅ Complete
