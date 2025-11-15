# Payment Flow Debugging Guide

## Issue: Subscription Activating Immediately

If you're experiencing immediate subscription activation instead of waiting for payment confirmation, follow this debugging guide.

---

## Expected Flow

```
1. User clicks "Pay K500"
2. API call to initiate payment
3. Dialog closes immediately
4. Orange notification: "Approval Required - Check your phone"
5. Background polling starts (5 attempts × 5 seconds)
6. User approves on phone
7. Status check finds payment = "completed"
8. Green notification: "Payment confirmed!"
9. Subscription activates
```

---

## What to Check

### 1. Console Output After Clicking Pay

Look for these messages in your debug console:

```
=== PAYMENT RESULT ===
Status: pay-offline
Transaction ID: SUB-YourBusiness-1234567890
Lenco Reference: 2531807904
====================
Dialog closed - starting background status checking
```

**If you see this:** ✅ Flow is working correctly

**If you DON'T see this or status is different:** 
- Check what status the API is returning
- Payment might be completing instantly (status: 'completed')
- API might be returning unexpected status

### 2. Background Status Checking

Look for these messages:

```
=== STARTING BACKGROUND STATUS CHECK ===
Reference: SUB-YourBusiness-1234567890
Lenco Reference: 2531807904
Will check 5 times with 5-second intervals
========================================
```

**If you see this:** ✅ Background checking started

**If you DON'T see this:**
- `_checkPaymentStatus()` method not being called
- Check if payment status is 'pay-offline'

### 3. Polling Messages

You should see these repeated messages:

```
Payment initiated. Waiting for user approval...
Reference: SUB-YourBusiness-123, Lenco Reference: 2531807904
Checking status... Attempt 1/5
Checking transaction status: lenco_reference=2531807904
Status check response: 200
Status response body: {...}
```

**Expected:** 5 attempts, each 5 seconds apart

**If you DON'T see these:**
- `waitForPaymentConfirmation()` not being called
- Network issues preventing API calls

### 4. Status Check Results

After 5-25 seconds, you should see:

```
=== POLLING COMPLETED ===
Result: {status: completed, ...}
========================
✅ Payment COMPLETED - Activating subscription
```

**OR (if transaction not found):**

```
=== POLLING COMPLETED ===
Result: {status: not-found, ...}
========================
⚠️ Transaction NOT FOUND - Showing manual check button
```

**OR (if payment failed):**

```
=== POLLING COMPLETED ===
Result: {status: failed, error: Insufficient funds, ...}
========================
❌ Payment FAILED
```

---

## Common Issues & Solutions

### Issue 1: Payment Instantly Completes (Status = 'completed')

**Symptom:**
```
Status: completed
```

**Cause:** API is returning 'completed' instead of 'pay-offline'

**Solution:** This is actually correct behavior! Some payments complete instantly without needing phone approval. The code handles this by activating immediately.

**To Verify:** Check the API response - if it says `status: 'completed'`, instant activation is correct.

---

### Issue 2: No Background Checking Logs

**Symptom:** No "STARTING BACKGROUND STATUS CHECK" message

**Possible Causes:**
1. Payment status is NOT 'pay-offline'
2. Dialog not closing properly
3. `_checkPaymentStatus()` not being called

**Debug Steps:**

**Step 1:** Check payment status
```dart
print('Status: $status');  // What does this show?
```

**Step 2:** Check if condition is met
```dart
if (status == 'pay-offline') {
  print('ENTERED pay-offline branch');  // Do you see this?
}
```

**Step 3:** Verify method call
```dart
_checkPaymentStatus(...);  // Is this line reached?
```

---

### Issue 3: Immediate Activation Without Status Check

**Symptom:** Subscription activates without seeing any polling messages

**Cause:** Code is taking the 'completed' branch instead of 'pay-offline' branch

**Check Console For:**
```
Status: completed  ← This means payment already done
```

**OR:**
```
Status: [something else]  ← Unexpected status
```

**Solution:**
- If status is 'completed': This is correct - payment finished instantly
- If status is something else: API behavior changed, needs investigation

---

### Issue 4: Manual Check Button Never Appears

**Symptom:** After 25 seconds, no manual check button

**Possible Causes:**
1. Transaction was found before 5 attempts completed
2. Payment completed or failed (no need for manual check)
3. Polling not running

**Check Console:**
```
Transaction not found yet, continuing...  ← Should see 5 times
⚠️ Transaction NOT FOUND - Showing manual check button  ← Final message
```

---

## Testing Scenarios

### Test 1: Normal Payment Flow

**Steps:**
1. Click Pay button
2. Check console for "PAYMENT RESULT"
3. Verify status = 'pay-offline'
4. Check for "STARTING BACKGROUND STATUS CHECK"
5. Count polling attempts (should be 5)
6. Approve payment on phone
7. Check for "COMPLETED" message
8. Verify subscription activates

**Expected Console Output:**
```
=== PAYMENT RESULT ===
Status: pay-offline
...
Dialog closed - starting background status checking
=== STARTING BACKGROUND STATUS CHECK ===
...
Checking status... Attempt 1/5
...
Checking status... Attempt 2/5
...
Current status: completed
✅ Payment COMPLETED - Activating subscription
```

### Test 2: Instant Completion

**Steps:**
1. Click Pay button
2. Check console for status
3. Should see status = 'completed'
4. No background checking (not needed)
5. Immediate activation

**Expected Console Output:**
```
=== PAYMENT RESULT ===
Status: completed
...
```
*(No background checking - correct behavior)*

### Test 3: Transaction Not Found

**Steps:**
1. Click Pay button
2. Don't approve on phone
3. Wait 25 seconds
4. Check for manual button

**Expected Console Output:**
```
=== PAYMENT RESULT ===
Status: pay-offline
...
=== STARTING BACKGROUND STATUS CHECK ===
...
Checking status... Attempt 1/5
Transaction not found yet, continuing...
Checking status... Attempt 2/5
Transaction not found yet, continuing...
...
Checking status... Attempt 5/5
Transaction not found yet, continuing...
=== POLLING COMPLETED ===
Result: {status: not-found, ...}
⚠️ Transaction NOT FOUND - Showing manual check button
```

---

## API Response Reference

### Payment Initiation Response

**Expected:**
```json
{
  "status": true,
  "data": {
    "status": "pay-offline",
    "lenco_reference": "2531807904",
    "id": 1
  }
}
```

**Key Field:** `data.status` should be `"pay-offline"`

### Status Check Response (Not Found)

```json
{
  "status": false,
  "message": "Transaction not found"
}
```

### Status Check Response (Completed)

```json
{
  "status": true,
  "data": {
    "status": "completed",
    "lenco_reference": "2531807904"
  }
}
```

---

## Quick Debug Checklist

Run through this checklist when testing:

- [ ] Click Pay button
- [ ] Check console for "PAYMENT RESULT"
- [ ] Note the status value
- [ ] If status = 'pay-offline':
  - [ ] Dialog should close
  - [ ] Orange "Approval Required" notification appears
  - [ ] Console shows "STARTING BACKGROUND STATUS CHECK"
  - [ ] See 5 polling attempts
  - [ ] Approve on phone
  - [ ] See "COMPLETED" message
  - [ ] Subscription activates
- [ ] If status = 'completed':
  - [ ] Instant activation is CORRECT
  - [ ] No background checking needed
- [ ] If status = something else:
  - [ ] Note what it is
  - [ ] Check API documentation

---

## How to Share Debug Info

If issues persist, share these console outputs:

1. **Payment Result:**
```
=== PAYMENT RESULT ===
Status: [what status?]
...
```

2. **Background Check Start:**
```
=== STARTING BACKGROUND STATUS CHECK ===
...
```

3. **Polling Attempts:**
```
Checking status... Attempt X/5
Current status: [what status?]
```

4. **Final Result:**
```
=== POLLING COMPLETED ===
Result: [what result?]
```

5. **Any Error Messages**

---

## Next Steps

1. **Run the app in debug mode**
2. **Open debug console**
3. **Click Pay button**
4. **Watch console output**
5. **Compare with expected flow above**
6. **Identify where it diverges**

---

## Important Notes

✅ **Instant activation is CORRECT if:**
- Payment API returns `status: 'completed'`
- Some operators complete payments instantly
- No user approval needed

❌ **Instant activation is WRONG if:**
- Status is 'pay-offline' but activates anyway
- Background checking never starts
- Polling doesn't happen

---

**Created:** November 14, 2025
**Purpose:** Debug immediate subscription activation issue
**Status:** Use this guide to identify where the flow breaks
