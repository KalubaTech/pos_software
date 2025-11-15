# Payment Flow - Quick Summary

## What Changed?

### Before
- Payment dialog stayed open during confirmation
- Subscription activated immediately on `pay-offline` status
- No automatic status verification
- User had to wait in dialog

### After
- ✅ Dialog closes immediately after payment initiation
- ✅ Automatic status checking (5 intervals of 5 seconds)
- ✅ Subscription only activates when status is `completed`
- ✅ Manual "Check Status" button if transaction not found
- ✅ Better user experience and security

## Flow Summary

```
1. User clicks "Pay K500"
   ↓
2. Payment API called → Dialog CLOSES immediately
   ↓
3. User sees: "Approval Required - Check your phone"
   ↓
4. Background: Checking status every 5 seconds (5 times)
   ↓
5a. FOUND → Status = "completed" → ✅ Subscription activated
5b. FOUND → Status = "failed" → ❌ Show error reason
5c. NOT FOUND → Show "Check Status" button for manual verification
```

## Key API Responses

### Status Check Endpoint
```
GET https://kalootech.com/pay/lenco/transaction.php?reference={reference}
```

### Response: Transaction Found (Success)
```json
{
  "status": true,
  "message": "Transaction found",
  "data": {
    "status": "completed",
    "lencoReference": "2531807380",
    "amount": "500.00"
  }
}
```

### Response: Transaction Found (Failed)
```json
{
  "status": true,
  "message": "Transaction found",
  "data": {
    "status": "failed",
    "reasonForFailure": "Incorrect Pin"
  }
}
```

### Response: Transaction Not Found
```json
{
  "status": false,
  "message": "Transaction not found",
  "reference": "UNKNOWN"
}
```

## Updated Methods

### 1. `checkTransactionStatus()` - subscription_service.dart
- Returns `found: true/false` field
- Handles "Transaction not found" case properly
- Includes `event` field (collection.completed/failed)

### 2. `waitForPaymentConfirmation()` - subscription_service.dart
- Changed to 5 attempts × 5 seconds (was 30 × 2)
- Returns `status: 'not-found'` if transaction missing
- Only returns success on `status: 'completed'`

### 3. `_showPaymentDialog()` - subscription_view.dart
- Closes dialog immediately after payment initiation
- Calls `_checkPaymentStatus()` in background
- No longer activates subscription on `pay-offline`

### 4. `_checkPaymentStatus()` - subscription_view.dart (NEW)
- Runs automatic polling
- Activates subscription only on `completed` status
- Shows manual check button if `not-found`

### 5. `_manualStatusCheck()` - subscription_view.dart (NEW)
- Allows user to manually check payment status
- Triggered by "Check Status" button
- Same validation as automatic check

## User Experience

### Successful Payment (Happy Path)
```
1. User clicks Pay
2. Dialog closes
3. "Approval Required - Check your phone" (orange notification)
4. User approves on phone
5. (5-25 seconds later)
6. "Payment confirmed! Subscription activated" (green notification)
```

### Failed Payment
```
1. User clicks Pay
2. Dialog closes
3. "Approval Required - Check your phone"
4. User enters wrong PIN
5. "Payment Failed: Incorrect Pin" (red notification)
```

### Transaction Not Found
```
1. User clicks Pay
2. Dialog closes
3. "Approval Required - Check your phone"
4. (After 25 seconds)
5. "Transaction not found yet. You can check manually" with [Check Status] button
6. User clicks "Check Status" when ready
7. Either: Success, Failed, or "Still not found"
```

## Configuration

**Default Settings:**
- Polling Attempts: 5
- Polling Interval: 5 seconds
- Total Wait: 25 seconds

**To Change:**
```dart
// In subscription_service.dart, line ~498
int maxAttempts = 5;
Duration pollInterval = const Duration(seconds: 5);
```

## Security

### ✅ Secure Practices Implemented
- Subscription only activates on `status: 'completed'`
- Never activates on just `pay-offline` status
- Verifies transaction exists before processing
- Validates amount matches expected value
- Checks `event` field for confirmation type

### ⚠️ What NOT to Do
- ❌ Don't activate on `pay-offline` alone
- ❌ Don't skip status verification
- ❌ Don't trust client-side confirmation only

## Testing Checklist

- [ ] Test successful payment → subscription activates
- [ ] Test failed payment → error message shown
- [ ] Test delayed transaction → manual check works
- [ ] Test with wrong PIN → shows "Incorrect Pin"
- [ ] Test with insufficient funds → shows reason
- [ ] Test with no internet → error handling works
- [ ] Test manual check button appears after 25s
- [ ] Verify dialog closes immediately
- [ ] Verify background polling works
- [ ] Verify no double-activations

## Files Modified

1. **lib/services/subscription_service.dart**
   - `checkTransactionStatus()`: Added `found` field
   - `waitForPaymentConfirmation()`: Updated to 5×5s polling

2. **lib/views/settings/subscription_view.dart**
   - `_showPaymentDialog()`: Close dialog immediately
   - `_checkPaymentStatus()`: NEW - Background polling
   - `_manualStatusCheck()`: NEW - Manual verification

3. **Documentation**
   - `PAYMENT_STATUS_FLOW.md`: Complete flow documentation
   - `PAYMENT_FLOW_SUMMARY.md`: This file

## Quick Reference

| Scenario | Status | Action |
|----------|--------|--------|
| Payment approved on phone | `completed` | ✅ Activate subscription |
| Payment declined | `failed` | ❌ Show error |
| Transaction processing | `pay-offline` | ⏳ Keep checking |
| Transaction not in system yet | `not-found` | 🔄 Manual check button |

## Support

If payment issues occur:
1. Check transaction reference format: `SUB-{businessId}-{timestamp}`
2. Verify API endpoint is accessible
3. Check internet connection
4. Review logs for error messages
5. Use manual check button to verify status
6. Contact Lenco support with `lencoReference` if needed

---

**Status:** ✅ Implementation Complete
**Last Updated:** November 14, 2025
**Next Steps:** Testing with real mobile money transactions
