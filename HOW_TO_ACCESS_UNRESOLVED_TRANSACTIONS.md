# How to Access Unresolved Transactions

## Quick Answer

**Unresolved Transactions** appear in the **Subscription tab** of Settings, right below any payment status notifications and above your current subscription.

---

## Step-by-Step Access

### From Main Menu

```
1. Open App
   ↓
2. Navigate to Settings (⚙️ icon)
   ↓
3. Click on "Subscription" tab (👑 Crown icon) 
   ↓
4. Scroll down (if needed)
   ↓
5. See "Unresolved Transactions" section
   (Only appears if you have unresolved transactions)
```

---

## Visual Navigation

### Settings View Structure

```
┌─────────────────────────────────────────────────┐
│  Settings                                       │
│  Manage your POS system configuration          │
│  ┌───────────────────────────────────────────┐ │
│  │ [System] [Business] [Appearance]          │ │
│  │     [Subscription] [Sync]   ← Click here │ │
│  └───────────────────────────────────────────┘ │
├─────────────────────────────────────────────────┤
│                                                 │
│  [Result Notification - if any]                │
│                                                 │
│  [Payment Checking Status - if checking]       │
│                                                 │
│  ╔═══════════════════════════════════════════╗ │
│  ║ 🕐 Unresolved Transactions          [2]  ║ │ ← HERE!
│  ║                                           ║ │
│  ║ These transactions could not be verified ║ │
│  ║ You can retry checking their status.     ║ │
│  ║                                           ║ │
│  ║ [Transaction Card 1]                      ║ │
│  ║ [Transaction Card 2]                      ║ │
│  ╚═══════════════════════════════════════════╝ │
│                                                 │
│  [Current Subscription Card - if any]          │
│                                                 │
│  [Choose Your Plan Section]                    │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## Tab Bar Position

The Subscription tab is the **4th tab** (counting from left):

```
┌────────┬──────────┬────────────┬──────────────┬──────┐
│ System │ Business │ Appearance │ Subscription │ Sync │
│   ⚙️   │    🏪    │     🎨     │      👑      │  ☁️  │
│        │          │            │   ← HERE!    │      │
└────────┴──────────┴────────────┴──────────────┴──────┘
```

---

## When Does It Appear?

The **Unresolved Transactions** section is **conditionally displayed**:

### ✅ Shows When:
- You have at least 1 unresolved transaction
- Transaction status is: `pending`, `timeout`, or `notFound`
- Automatically appears after a payment times out

### ❌ Hidden When:
- No unresolved transactions exist
- All transactions have been resolved (completed/failed)
- Clean state (no payment issues)

---

## Real-World Example

### Scenario: You just initiated a payment that timed out

**Step 1:** Payment initiated
```
Payment Dialog → Enter phone → Click "Pay K500"
                                      ↓
                          Payment status checking...
                                      ↓
                          Status not found (25s timeout)
                                      ↓
                  Transaction saved to "Unresolved"
```

**Step 2:** Access unresolved transactions
```
You're automatically in Settings → Subscription tab
                ↓
Scroll up slightly (notification might push it down)
                ↓
See "Unresolved Transactions" section
                ↓
Your transaction is there with [Retry] button
```

---

## UI Hierarchy (Top to Bottom)

```
Settings Header
   ↓
Tab Bar (5 tabs)
   ↓
Tab Content (Subscription):
   ├─ Result Notification (top, if active)
   ├─ Payment Checking Status (if checking)
   ├─ Unresolved Transactions ← YOUR TARGET
   ├─ Current Subscription Card
   ├─ Choose Your Plan
   └─ Features Comparison
```

---

## Code Location

**File:** `lib/views/settings/subscription_view.dart`  
**Lines:** ~112-127

```dart
// Unresolved transactions section
Obx(() {
  if (subscriptionService.unresolvedTransactions.isNotEmpty) {
    return FadeInUp(
      duration: Duration(milliseconds: 300),
      child: Column(
        children: [
          _buildUnresolvedTransactionsSection(
            subscriptionService,
            businessController,
            isDark,
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
  return SizedBox.shrink(); // Hidden if no unresolved
}),
```

---

## Quick Access Path

### Desktop/Tablet:
```
Main App → Settings (sidebar) → Subscription Tab → Scroll to Unresolved
```

### Mobile:
```
Main App → Menu → Settings → Subscription Tab → Scroll to Unresolved
```

---

## How to Know If You Have Unresolved Transactions?

### Indicators:

1. **Badge Counter:** 
   - If visible in future updates: "Unresolved Transactions [2]"
   - Shows count of pending transactions

2. **After Payment Timeout:**
   - You'll see notification: "Transaction Saved"
   - Message says: "saved to 'Unresolved Transactions'"
   - Section automatically appears

3. **Observable in Code:**
   ```dart
   subscriptionService.unresolvedTransactions.length > 0
   ```

---

## Testing Access

### To test if you can access it:

1. Go to Settings
2. Click "Subscription" tab (4th tab, crown icon 👑)
3. Look for orange section with clock icon 🕐
4. Should say "Unresolved Transactions" at top

### If you don't see it:
- ✅ Good! You have no unresolved transactions
- Everything is working normally
- Section only appears when needed

### To create a test unresolved transaction:
1. Initiate a payment
2. Let it timeout (don't approve on phone)
3. Wait 25 seconds for polling to complete
4. Section will appear automatically

---

## Position Summary

| Element | Position | Always Visible? |
|---------|----------|-----------------|
| Result Notification | Top | No (when active) |
| Payment Checking | Below notification | No (when checking) |
| **Unresolved Transactions** | **Below checking** | **No (when exist)** |
| Current Subscription | Below unresolved | Yes (if subscribed) |
| Choose Your Plan | Below subscription | Yes |
| Features Comparison | Bottom | Yes |

---

## Important Notes

⚠️ **Section is dynamic** - Only appears when you have unresolved transactions

✅ **Auto-appears** - When payment times out, section automatically shows

✅ **Auto-hides** - When all transactions resolved, section disappears

✅ **Persistent** - Survives app restarts (saved in database)

✅ **Real-time** - Updates immediately when transactions added/removed

---

## Alternative Access (Future Enhancement)

### Could be added:
- Dashboard notification badge
- Quick access button in header
- Push notification when transaction ready
- Shortcut from payment failure dialog

### Currently:
- Only accessible through Settings → Subscription tab

---

## Summary

**Where:** Settings → Subscription Tab  
**Position:** Below status cards, above current subscription  
**Visibility:** Only when unresolved transactions exist  
**Icon:** 🕐 Clock icon  
**Badge:** Shows count [X]  

**Path:** `Main App → Settings → Subscription Tab → Unresolved Transactions`

---

## Quick Reference

```
┌─────────────────────────────────────┐
│         Settings                    │
├─────────────────────────────────────┤
│ [System][Business][Appearance]      │
│     [Subscription ← HERE][Sync]     │
├─────────────────────────────────────┤
│                                     │
│ 🕐 Unresolved Transactions [2] ←────┤ YOU ARE HERE
│    Retry checking these...          │
│                                     │
│    [Transaction 1 with Retry]       │
│    [Transaction 2 with Retry]       │
│                                     │
└─────────────────────────────────────┘
```

---

**Created:** November 15, 2025  
**Status:** ✅ Feature Active and Accessible
