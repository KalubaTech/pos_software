# Payment Status Flow - Testing Guide

## Pre-Testing Setup

### 1. Environment Setup
```bash
# Ensure you're on the correct branch
git status

# Make sure all dependencies are installed
flutter pub get

# Run the app in debug mode
flutter run
```

### 2. Test Data Required
- Valid Zambian mobile money numbers:
  - MTN: 096XXXXXXX or 076XXXXXXX
  - Airtel: 097XXXXXXX or 077XXXXXXX
  - Zamtel: 095XXXXXXX or 075XXXXXXX
- Test amounts: K500, K1500, K2400
- Lenco API access (production or sandbox)

### 3. Debugging Tools
- Enable debug logging in subscription_service.dart
- Monitor console output for status check responses
- Use network inspector to verify API calls

---

## Test Cases

### Test 1: Successful Payment Flow ✅

**Objective:** Verify complete successful payment and subscription activation

**Steps:**
1. Open app and navigate to Settings → Subscription tab
2. Click on "Monthly Plan (K500)" card
3. Enter valid phone number (e.g., 0977123456)
4. Select payment method (or let it auto-detect)
5. Click "Pay K500.00"
6. **VERIFY:** Payment dialog closes immediately
7. **VERIFY:** "Approval Required" orange notification appears
8. Approve payment on your mobile device (enter PIN)
9. Wait up to 25 seconds
10. **VERIFY:** "Payment confirmed! Subscription activated" green notification appears
11. **VERIFY:** Subscription status shows "Active"
12. **VERIFY:** Sync tab is now accessible (no premium gate)

**Expected Results:**
- Dialog closes right after clicking Pay
- Background polling happens automatically
- Subscription activates only when status = 'completed'
- No manual intervention needed

**Debug Checks:**
```
Console should show:
✓ "Checking status... Attempt 1/5"
✓ "Checking status... Attempt 2/5"
✓ "Current status: completed"
✓ "Payment completed successfully!"
```

---

### Test 2: Failed Payment (Wrong PIN) ❌

**Objective:** Verify failed payment handling

**Steps:**
1. Navigate to Settings → Subscription
2. Click any plan card
3. Enter valid phone number
4. Click Pay
5. **VERIFY:** Dialog closes immediately
6. **VERIFY:** "Approval Required" notification appears
7. On mobile device, enter WRONG PIN 3 times
8. Wait for status check
9. **VERIFY:** "Payment Failed: Incorrect Pin" red notification appears
10. **VERIFY:** Subscription NOT activated
11. **VERIFY:** Can retry with same or different method

**Expected Results:**
- Error message shows reason for failure
- Subscription remains inactive
- User can try again

**Debug Checks:**
```
Console should show:
✓ "Current status: failed"
✓ "Payment failed: Incorrect Pin"
```

---

### Test 3: Transaction Not Found (Manual Check) 🔄

**Objective:** Verify manual status check button appears

**Steps:**
1. Navigate to Settings → Subscription
2. Click any plan card
3. Enter valid phone number
4. Click Pay
5. **VERIFY:** Dialog closes immediately
6. **VERIFY:** "Approval Required" notification appears
7. DO NOT approve payment on phone yet
8. Wait 25 seconds (5 attempts × 5 seconds)
9. **VERIFY:** "Transaction not found yet. You can check manually" orange notification with [Check Status] button appears
10. Now approve payment on your phone
11. Click "Check Status" button in the notification
12. **VERIFY:** "Payment confirmed! Subscription activated" appears
13. **VERIFY:** Subscription is now active

**Expected Results:**
- After 5 failed attempts, manual button appears
- Manual check works correctly
- Subscription activates when user manually checks

**Debug Checks:**
```
Console should show:
✓ "Checking status... Attempt 5/5"
✓ "Transaction not found yet, continuing..."
✓ "Payment confirmation timeout after 25 seconds"
(After manual check)
✓ "Current status: completed"
```

---

### Test 4: Instant Completion (Fast Approval) ⚡

**Objective:** Verify quick approval detection

**Steps:**
1. Navigate to Settings → Subscription
2. Click any plan card
3. Enter valid phone number
4. Click Pay
5. **VERIFY:** Dialog closes immediately
6. IMMEDIATELY approve payment on phone (within 5 seconds)
7. **VERIFY:** "Payment confirmed!" appears within 5-10 seconds
8. **VERIFY:** Subscription activates quickly

**Expected Results:**
- First status check (5 seconds) finds completed transaction
- Subscription activates on first attempt
- Total time: ~5-10 seconds

---

### Test 5: Multiple Plan Selections 💰

**Objective:** Verify different subscription plans work correctly

**Test 5a: Monthly Plan (K500)**
1. Select Monthly Plan
2. Complete payment
3. Verify: Amount = K500, Duration = 1 month

**Test 5b: Yearly Plan (K1500)**
1. Select Yearly Plan
2. Complete payment
3. Verify: Amount = K1500, Duration = 12 months, "Save K4,500" badge visible

**Test 5c: 2-Year Plan (K2400)**
1. Select 2-Year Plan
2. Complete payment
3. Verify: Amount = K2400, Duration = 24 months, "Save K9,600" badge visible

---

### Test 6: Operator Detection 📱

**Objective:** Verify auto-detection of mobile operators

**Test 6a: MTN Detection**
- Phone: 0967123456 → Operator: mtn ✅
- Phone: 0767123456 → Operator: mtn ✅

**Test 6b: Airtel Detection**
- Phone: 0977123456 → Operator: airtel ✅
- Phone: 0777123456 → Operator: airtel ✅

**Test 6c: Zamtel Detection**
- Phone: 0957123456 → Operator: zamtel ✅
- Phone: 0757123456 → Operator: zamtel ✅

**Test 6d: Manual Override**
1. Enter phone: 0977123456
2. Select "MTN Mobile Money" from dropdown
3. Verify: Uses MTN despite Airtel prefix

---

### Test 7: Phone Number Formatting 📞

**Objective:** Verify phone number formatting works

| Input | Expected Output |
|-------|----------------|
| 0977123456 | 0977123456 ✅ |
| +260977123456 | 0977123456 ✅ |
| 260977123456 | 0977123456 ✅ |
| 977123456 | 0977123456 ✅ |

---

### Test 8: Network Failure Handling 🌐

**Objective:** Verify error handling for network issues

**Test 8a: No Internet (During Initiation)**
1. Disable internet connection
2. Try to initiate payment
3. **VERIFY:** Error message displayed
4. **VERIFY:** Can retry after reconnecting

**Test 8b: Internet Loss (During Polling)**
1. Initiate payment with internet
2. Disable internet after dialog closes
3. **VERIFY:** Status checks fail gracefully
4. Re-enable internet
5. **VERIFY:** Manual check button works

---

### Test 9: Concurrent Payments 🚫

**Objective:** Prevent duplicate subscriptions

**Steps:**
1. Initiate payment for Monthly plan
2. While first payment is polling, try to initiate another payment
3. **VERIFY:** Second payment attempt is prevented OR handled correctly
4. **VERIFY:** Only one subscription activates

---

### Test 10: Business ID Tracking 🏢

**Objective:** Verify transactions include business ID

**Steps:**
1. Set business name in Settings → Business
2. Initiate payment
3. **VERIFY:** Transaction reference includes business name
   - Format: `SUB-{BusinessName}-{timestamp}`
   - Example: `SUB-Kalutech Stores-1763137403872`
4. Check database entry
5. **VERIFY:** Subscription linked to correct business ID

---

### Test 11: Subscription Status Display 📊

**Objective:** Verify subscription info is displayed correctly

**After successful activation, verify:**
- Current Plan badge (Monthly/Yearly/2-Year)
- Status badge (Active - green)
- Expiry date is correct
- Days remaining calculation is accurate
- Amount paid is displayed
- Transaction reference is shown

---

### Test 12: Premium Feature Gate 🔒

**Objective:** Verify sync features are properly gated

**Before Subscription:**
1. Navigate to Settings → Sync
2. **VERIFY:** Premium gate displayed
3. **VERIFY:** "View Plans" button redirects to Subscription tab

**After Subscription:**
1. Activate any subscription
2. Navigate to Settings → Sync
3. **VERIFY:** Full sync configuration visible
4. **VERIFY:** No premium gate shown

---

## Performance Tests

### Test P1: API Response Time ⏱️
**Expected:** Status check completes within 2 seconds
**Measure:** Time from request to response
**Tool:** Network inspector or console logs

### Test P2: Polling Overhead 💻
**Expected:** No UI freezing during background polling
**Measure:** App remains responsive
**Tool:** Flutter DevTools performance tab

### Test P3: Memory Usage 🧠
**Expected:** No memory leaks from polling
**Measure:** Memory stays stable after multiple payments
**Tool:** Flutter DevTools memory profiler

---

## Edge Cases

### Edge Case 1: Rapid Clicking
1. Click "Pay" button rapidly multiple times
2. **VERIFY:** Only one payment initiated
3. **VERIFY:** Button disabled during processing

### Edge Case 2: App Backgrounding
1. Initiate payment
2. Background the app immediately
3. Approve payment on phone
4. Return to app
5. **VERIFY:** Status check continues or resumes

### Edge Case 3: Very Long Delay
1. Initiate payment
2. Don't approve for 5 minutes
3. Click manual "Check Status"
4. Approve payment
5. Click "Check Status" again
6. **VERIFY:** Works correctly

### Edge Case 4: Invalid Phone Numbers
| Input | Expected Behavior |
|-------|------------------|
| 12345 | Show error before payment |
| 0887123456 | Show invalid operator error |
| empty | Show "Please enter phone number" |

---

## Security Tests

### Security Test 1: Transaction Reference Uniqueness
1. Initiate multiple payments
2. **VERIFY:** Each has unique reference
3. **VERIFY:** Format: `SUB-{business}-{timestamp}`

### Security Test 2: Activation Validation
1. Manually check API response
2. **VERIFY:** Status must be 'completed' for activation
3. **VERIFY:** 'pay-offline' alone does NOT activate

### Security Test 3: Amount Verification
1. Check payment request
2. **VERIFY:** Amount matches selected plan
3. **VERIFY:** No amount manipulation possible

---

## Regression Tests

### Regression 1: Existing Subscriptions
1. User with active subscription
2. Try to purchase another
3. **VERIFY:** Appropriate message or upgrade flow

### Regression 2: Expired Subscriptions
1. User with expired subscription
2. Try to access sync features
3. **VERIFY:** Premium gate appears
4. Purchase new subscription
5. **VERIFY:** Access restored

---

## API Testing

### API Test 1: Status Endpoint Structure
**Endpoint:** `GET https://kalootech.com/pay/lenco/transaction.php?reference={ref}`

**Expected Response (Found):**
```json
{
  "status": true,
  "message": "Transaction found",
  "data": {
    "id": 1,
    "event": "collection.completed",
    "reference": "SUB-XXX-123",
    "lencoReference": "2531807380",
    "amount": "500.00",
    "status": "completed",
    "reasonForFailure": null,
    "created_at": "2025-11-14 16:27:06"
  }
}
```

**Expected Response (Not Found):**
```json
{
  "status": false,
  "message": "Transaction not found",
  "reference": "UNKNOWN"
}
```

### API Test 2: Payment Initiation
**Endpoint:** `POST https://kalootech.com/pay/lenco/mobile-money/collection.php`

**Test valid request:**
```json
{
  "amount": "500",
  "reference": "SUB-Business-1763137403872",
  "phone": "0977123456",
  "operator": "airtel",
  "country": "zm",
  "bearer": "merchant"
}
```

---

## Automated Testing (Future)

### Unit Tests to Write
```dart
// subscription_service_test.dart
test('checkTransactionStatus returns found:true for valid transaction')
test('checkTransactionStatus returns found:false when missing')
test('waitForPaymentConfirmation polls 5 times')
test('waitForPaymentConfirmation stops on completed')
test('formatPhoneNumber handles all formats')
test('detectOperator identifies all networks')
```

### Integration Tests to Write
```dart
// subscription_flow_test.dart
testWidgets('Complete payment flow activates subscription')
testWidgets('Failed payment shows error message')
testWidgets('Manual check button appears after timeout')
testWidgets('Dialog closes immediately after payment')
```

---

## Test Results Template

```
## Test Run: [Date]
Tester: [Name]
Environment: [Production/Staging]
App Version: [X.X.X]

| Test Case | Status | Notes |
|-----------|--------|-------|
| Test 1: Successful Payment | ✅ PASS | Activated in 12s |
| Test 2: Failed Payment | ✅ PASS | Showed "Incorrect Pin" |
| Test 3: Manual Check | ✅ PASS | Button appeared at 25s |
| Test 4: Fast Approval | ✅ PASS | Completed in 7s |
| Test 5a: Monthly Plan | ✅ PASS | K500 charged correctly |
| Test 5b: Yearly Plan | ✅ PASS | K1500, 12 months |
| Test 5c: 2-Year Plan | ✅ PASS | K2400, 24 months |
| Test 6: Operator Detection | ✅ PASS | All operators detected |
| Test 7: Phone Formatting | ✅ PASS | All formats work |
| Test 8: Network Failure | ✅ PASS | Graceful error handling |
| Test 9: Concurrent Payments | ⚠️ SKIP | Need to implement |
| Test 10: Business ID | ✅ PASS | Reference includes ID |
| Test 11: Status Display | ✅ PASS | All fields correct |
| Test 12: Premium Gate | ✅ PASS | Blocks/unblocks correctly |

Issues Found:
- [Issue 1 description]
- [Issue 2 description]

Overall: ✅ READY FOR PRODUCTION
```

---

## Quick Smoke Test (5 Minutes)

For rapid testing before releases:

1. **Payment Initiation** (1 min)
   - Click Pay → Dialog closes ✅
   
2. **Status Checking** (1 min)
   - Approve payment → Success message ✅
   
3. **Subscription Display** (1 min)
   - Check status card → Shows active ✅
   
4. **Sync Access** (1 min)
   - Open Sync tab → No gate ✅
   
5. **Failed Payment** (1 min)
   - Wrong PIN → Error shown ✅

---

## Debugging Tips

### Console Output to Monitor
```
✓ "Initiating payment to 0977123456..."
✓ "Payment initiated. Waiting for user approval..."
✓ "Checking status... Attempt 1/5"
✓ "Status response body: {...}"
✓ "Current status: completed"
✓ "Payment completed successfully!"
```

### Common Issues and Solutions

**Issue:** Status check never finds transaction
**Solution:** Check transaction reference format, verify API is accessible

**Issue:** Dialog doesn't close
**Solution:** Check if `Get.back()` is called after payment initiation

**Issue:** Subscription activates too early
**Solution:** Verify activation only happens on `status: 'completed'`

**Issue:** Manual button doesn't appear
**Solution:** Check polling completes all 5 attempts, verify `status: 'not-found'` returned

---

## Sign-off Checklist

Before marking as complete:

- [ ] All critical test cases pass (Tests 1-4)
- [ ] All subscription plans work (Test 5)
- [ ] Operator detection works (Test 6)
- [ ] Phone formatting works (Test 7)
- [ ] Error handling is graceful (Test 8)
- [ ] Premium gate functions correctly (Test 12)
- [ ] No console errors during normal flow
- [ ] API responses match expected format
- [ ] Documentation is complete
- [ ] Code review completed
- [ ] Performance is acceptable
- [ ] Security checks pass

---

**Testing Status:** ⏳ Ready for Testing
**Last Updated:** November 14, 2025
**Next:** Execute test plan with real mobile money
