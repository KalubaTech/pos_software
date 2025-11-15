# Troubleshooting: Unresolved Transactions Not Showing

## Problem
Transaction is saved (you see "Transaction Saved" notification), but the "Unresolved Transactions" section doesn't appear in the UI.

---

## Debug Tools Added

I've added a **DEBUG PANEL** to your Subscription tab that will help us diagnose the issue. 

### How to Access Debug Tools:

1. **Stop the app** if it's running
2. **Hot restart** (not hot reload): `r` in terminal or Ctrl+Shift+F5
3. **Navigate to**: Settings → Subscription tab
4. **You'll see a RED DEBUG PANEL** at the top with buttons:
   - 🔵 **Check Status** - Shows current state of unresolved transactions
   - 🟢 **Add Test** - Adds a test unresolved transaction
   - 🟠 **Reload** - Reloads from database
   - 🔴 **Clear All** - Removes all unresolved transactions
   - 🟣 **Full Diagnostics** - Runs complete diagnostic suite

---

## Diagnostic Steps

### Step 1: Check Console Output

When you navigate to the Subscription tab, you should see debug output in your console:

```
🔷 [Service] Initializing unresolved transactions table...
✅ [Service] Table created/verified
✅ [Service] Indexes created/verified
📊 [Service] Table verified: X records exist
🔄 [Service] _loadUnresolvedTransactions called
💾 [Service] Querying database...
📊 [Service] Query returned X records
📋 [Service] Parsed X transactions
🔧 [Service] Setting observable value...
🔧 [Service] Before: unresolvedTransactions.length = 0
🔧 [Service] After: unresolvedTransactions.length = X
✅ [Service] Loaded X unresolved transactions
🔔 [Service] Called refresh() on observable
```

### Step 2: Click "Check Status" Button

This will show you the current state:

**Expected Output:**
```
========================================
🔍 UNRESOLVED TRANSACTIONS DEBUG CHECK
========================================

📊 Observable Status:
  - Type: RxList<UnresolvedTransactionModel>
  - Length: X
  - isEmpty: false
  - isNotEmpty: true

📋 Transactions List:
  1. TEST-123456789
     Status: pending
     Phone: 0977123456
     Amount: K500.0
     Created: 2025-11-15 10:30:00
     Attempts: 0

========================================
```

**If Length is 0**, then transactions aren't being saved to database.

### Step 3: Click "Add Test" Button

This will:
1. Create a test transaction
2. Save it to database
3. Reload from database
4. Show the updated status

**Watch the console** for detailed logging of each step.

### Step 4: Check Obx Rebuild

When the Obx widget rebuilds, you should see:

```
🔍 [Obx] Unresolved transactions rebuild triggered
📊 [Obx] Count: X
📋 [Obx] isEmpty: false
📋 [Obx] isNotEmpty: true
✅ [Obx] Showing unresolved section
📝 [Obx] Transactions: [TEST-123456789, ...]
```

**If you see this but still no UI**, the problem is in the widget rendering.

---

## Common Issues & Fixes

### Issue 1: Database Table Doesn't Exist

**Symptoms:**
- Console shows: "❌ [Service] Error loading unresolved transactions"
- No records returned from query

**Fix:**
```
1. Uninstall the app completely
2. Delete app data
3. Reinstall and run
4. Check console for: "✅ [Service] Table created/verified"
```

### Issue 2: Transactions Saved But Not Loaded

**Symptoms:**
- You see "Transaction Saved" notification
- Console shows: "✅ [Service] Database insert successful"
- But: "📊 [Service] Query returned 0 records"

**Fix:**
Check the status field. The query filters out 'resolved' status:
```sql
-- Current query:
SELECT * FROM unresolved_transactions WHERE status != 'resolved'
```

If transactions are accidentally saved with status='resolved', they won't show.

**Temporary Fix:** Click "Add Test" button - it creates with status='pending'

### Issue 3: Observable Not Triggering Obx

**Symptoms:**
- Console shows transactions loaded
- Length > 0
- But Obx never rebuilds (no "🔍 [Obx] Unresolved transactions rebuild triggered")

**Fix:**
```dart
// This is already implemented in the code:
unresolvedTransactions.refresh();
```

If this still doesn't work, check if Get.put(SubscriptionService()) is called in main.dart

### Issue 4: Obx Rebuilds But Nothing Shows

**Symptoms:**
- Obx rebuilds (see console log)
- Count > 0
- isNotEmpty = true
- Console shows: "✅ [Obx] Showing unresolved section"
- But UI still empty

**Fix:**
This means the widget is rendering but invisible. Check:

1. **Widget height** - Might be collapsed
2. **Scroll position** - Might be off-screen
3. **Z-index/Stack** - Might be behind something

Try scrolling to the very top of the page.

### Issue 5: Build Context Issues

**Symptoms:**
- Everything works in console
- Widget should render
- But crashes or shows blank

**Fix:**
Check for build context errors in console. The Obx might be outside valid context.

---

## Testing Procedure

### Test 1: Fresh Start
1. Clear all transactions: Click "Clear All"
2. Check status: Click "Check Status" (should show 0)
3. Add test transaction: Click "Add Test"
4. Wait 1 second
5. **Expected:** Orange section appears with test transaction
6. **Check console** for all debug logs

### Test 2: Real Payment Timeout
1. Clear all test transactions: Click "Clear All"
2. Initiate real payment: Choose plan → Subscribe → Pay
3. Don't approve on phone
4. Wait for timeout (25 seconds)
5. Check console for: "⚠️ Transaction NOT FOUND - Adding to unresolved"
6. Check status: Click "Check Status"
7. **Expected:** Section appears with real transaction

### Test 3: Database Persistence
1. Add test transaction: Click "Add Test"
2. Verify it shows in UI
3. Close app completely
4. Reopen app
5. Navigate to Settings → Subscription
6. **Expected:** Transaction still there
7. Check console for: "📊 [Service] Table verified: 1 records exist"

---

## What to Look For in Console

### On App Startup:
```
🔷 [Service] Initializing unresolved transactions table...
✅ [Service] Table created/verified
✅ [Service] Indexes created/verified
📊 [Service] Table verified: X records exist
🔄 [Service] _loadUnresolvedTransactions called
✅ [Service] Loaded X unresolved transactions
```

### When Payment Times Out:
```
❌ Max attempts reached without confirmation
⚠️ Transaction NOT FOUND - Adding to unresolved
🔷 [Service] Adding unresolved transaction...
📝 [Service] Transaction ID: XXX
💾 [Service] Inserting into database...
✅ [Service] Database insert successful
🔄 [Service] Reloading unresolved transactions...
✅ [Service] Added unresolved transaction: XXX
📊 [Service] Current count: 1
```

### When Obx Rebuilds:
```
🔍 [Obx] Unresolved transactions rebuild triggered
📊 [Obx] Count: 1
📋 [Obx] isEmpty: false
📋 [Obx] isNotEmpty: true
✅ [Obx] Showing unresolved section
📝 [Obx] Transactions: [TEST-123456789]
```

---

## Quick Diagnostic Commands

### Check Database Directly (if you have SQLite browser):

```sql
-- Check if table exists
SELECT name FROM sqlite_master WHERE type='table' AND name='unresolved_transactions';

-- Check record count
SELECT COUNT(*) FROM unresolved_transactions;

-- View all records
SELECT * FROM unresolved_transactions;

-- View only unresolved (what UI shows)
SELECT * FROM unresolved_transactions WHERE status != 'resolved';
```

---

## Expected Behavior

### When Working Correctly:

1. **Payment times out**
   - Console: "⚠️ Transaction NOT FOUND - Adding to unresolved"
   - Orange notification appears: "Transaction Saved"
   - Dialog shows: "Payment Status"

2. **UI updates immediately**
   - Orange section appears at top of Subscription tab
   - Header: "🕐 Unresolved Transactions [1]"
   - Card shows transaction details
   - "Retry Status Check" button appears

3. **Persists across restarts**
   - Close and reopen app
   - Navigate to Subscription tab
   - Section still there with same transaction

4. **Observable updates**
   - subscriptionService.unresolvedTransactions.length > 0
   - Obx widget rebuilds
   - UI reflects current state

---

## Next Steps

1. **Hot restart the app** (Ctrl+Shift+F5 or `r` in terminal)
2. **Navigate to** Settings → Subscription tab
3. **You'll see the red DEBUG PANEL** at the top
4. **Click "Check Status"** to see current state
5. **Click "Add Test"** to add a test transaction
6. **Watch the console** for debug output
7. **Report back** what you see:
   - Did the test transaction appear in UI?
   - What does console show?
   - Any errors?

---

## If Still Not Working

If after running diagnostics it still doesn't work, please provide:

1. **Console output** from clicking "Full Diagnostics"
2. **Screenshot** of the Subscription tab
3. **Any error messages** in console
4. **Database record count** from "Check Status"

This will help identify exactly where the problem is:
- Database not saving? (Issue with addUnresolvedTransaction)
- Database not loading? (Issue with _loadUnresolvedTransactions)
- Observable not updating? (Issue with RxList)
- Obx not rebuilding? (Issue with GetX reactivity)
- Widget not rendering? (Issue with UI code)

---

## Removing Debug Tools

Once the issue is fixed, remove the debug panel:

1. **Remove import:** `import '../../debug_unresolved_test.dart';`
2. **Remove debug panel** (the `if (kDebugMode) Card(...)` block)
3. **Optional:** Keep debug logging in console or remove print statements

---

**Status:** Debug tools active  
**Action:** Hot restart and use debug buttons  
**Goal:** Identify why UI not showing despite "saved" message
