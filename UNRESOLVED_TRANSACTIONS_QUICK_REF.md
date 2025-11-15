# Unresolved Transactions - Quick Reference

## At a Glance

**Purpose:** Track and retry payment transactions that couldn't be verified immediately

**When Used:** Payment approved by user but system timed out checking status

**User Benefit:** Never lose a payment - retry checking later

---

## Quick Visual

### Before (Problem)
```
Payment → Approve → Check Status → Timeout ❌
                                    ↓
                              User stuck
                           Payment approved
                        But no subscription 😢
```

### After (Solution)
```
Payment → Approve → Check Status → Timeout
                                    ↓
                           Add to Unresolved 📋
                                    ↓
                            User sees list
                                    ↓
                          Click "Retry" button
                                    ↓
                         Found! Subscription ✓
```

---

## User Interface

### Unresolved Section (Appears above current subscription)

```
╔════════════════════════════════════════════════╗
║  🕐  Unresolved Transactions            [2]   ║
║                                                ║
║  These transactions could not be verified.    ║
║  You can retry checking their status.         ║
║                                                ║
║  ┌──────────────────────────────────────────┐ ║
║  │ 💰 1 Month          [Pending Approval]  │ ║
║  │    K500 • MTN                           │ ║
║  │    Ref: 2531808060                      │ ║
║  │    Phone: 0977123456                    │ ║
║  │    🕐 2h ago • 1 attempts                │ ║
║  │    [🔄 Retry Status Check]              │ ║
║  └──────────────────────────────────────────┘ ║
╚════════════════════════════════════════════════╝
```

---

## Status Types

| Status | Color | Meaning | Action |
|--------|-------|---------|--------|
| **Pending** | 🟠 Orange | Waiting for approval | Retry check |
| **Checking** | 🔵 Blue | Currently checking | Wait... |
| **Timeout** | 🔴 Red | API timeout | Retry check |
| **Not Found** | 🟠 Orange | Transaction not in system yet | Retry later |
| **Resolved** | 🟢 Green | Completed/Failed | Hidden |

---

## When Transactions Are Added

1. User initiates payment
2. Payment shows "pay-offline" status
3. System polls 5 times (25 seconds total)
4. If status still not available → **Add to Unresolved**
5. User sees notification: "Transaction Saved"
6. Transaction appears in Unresolved section

---

## How Retry Works

```
User clicks "Retry Status Check"
        ↓
Notification: "Checking Status..."
        ↓
API call to check transaction
        ↓
   ┌────┴────┐
   │ Result? │
   └────┬────┘
        │
   ┌────┴────────────────────┐
   │                          │
Completed ✓             Still Pending ⏱️
   │                          │
Activate                 Keep in
Subscription            Unresolved
   │                          │
Remove from             User retries
Unresolved               later
   │                          │
Success! 🎉            Try again
```

---

## Code Snippets

### Add Transaction
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

### Retry Transaction
```dart
final result = await subscriptionService.retryUnresolvedTransaction(
  transaction,
);
```

### Check Unresolved Count
```dart
subscriptionService.unresolvedTransactions.length
```

---

## Key Benefits

| Before | After |
|--------|-------|
| ❌ Payment approved but lost | ✅ Always tracked |
| ❌ User frustrated | ✅ User can retry |
| ❌ Manual support needed | ✅ Self-service |
| ❌ No visibility | ✅ Clear status |
| ❌ One-time check only | ✅ Retry unlimited |

---

## Common Scenarios

### Scenario 1: Slow Network
- Payment approved
- Network slow → timeout
- Added to unresolved
- Wait 5 minutes
- Retry → Success! ✓

### Scenario 2: Provider Delay
- Payment approved
- Provider system slow
- Not in system yet
- Wait 30 minutes
- Retry → Found! ✓

### Scenario 3: Payment Failed
- Payment approved (user thinks)
- Actually declined (low balance)
- Retry shows: "Failed"
- User knows to try again

---

## Testing Quick Checks

✅ Payment timeout → Transaction added  
✅ Transaction appears in UI  
✅ "Retry" button works  
✅ Success → Subscription activates  
✅ Failed → Removed from unresolved  
✅ Pending → Stays in unresolved  
✅ App restart → Transactions persist  
✅ Multiple transactions display correctly  

---

## Files Changed

| File | Change |
|------|--------|
| `unresolved_transaction_model.dart` | NEW - Data model |
| `subscription_service.dart` | UPDATED - Added methods |
| `subscription_view.dart` | UPDATED - Added UI section |

---

## Quick Stats

- **Polling attempts:** 5 times
- **Poll interval:** 5 seconds each
- **Total wait:** 25 seconds
- **Timeout threshold:** After 5 failed checks
- **Cleanup period:** 30 days (resolved transactions)
- **Retry limit:** Unlimited

---

## Important Notes

⚠️ **Transactions are NOT automatically retried**  
→ User must manually click "Retry Status Check"

⚠️ **Resolved transactions are hidden**  
→ Only pending/timeout/not-found shown

⚠️ **Old resolved transactions auto-deleted**  
→ After 30 days to keep database clean

✅ **Safe to retry multiple times**  
→ Won't create duplicate subscriptions

✅ **Works offline-first**  
→ Transactions saved locally, syncs when online

---

## Summary

**What:** Unresolved Transactions Feature  
**Why:** Track payments that timeout during verification  
**How:** Save → Display → Allow retry → Auto-activate  
**Benefit:** Never lose a payment

**Status:** ✅ Complete and Ready

---

**Need Help?**  
See: `UNRESOLVED_TRANSACTIONS_FEATURE.md` for full documentation
