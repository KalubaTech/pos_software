# Payment Status Flow Implementation

## Overview
This document describes the complete payment confirmation flow for the subscription system, including status checking, automatic polling, and manual verification.

## Payment Flow Sequence

### 1. Payment Initiation
```dart
// User enters phone number and selects payment method
final paymentResult = await subscriptionService.processPayment(
  plan: plan.plan,
  businessId: businessId,
  phoneNumber: formattedPhone,
  operator: operator,
);
```

**Response Example (Success):**
```json
{
  "success": true,
  "status": "pay-offline",
  "transactionId": "SUB-Kalutech Stores-1763137403872",
  "lencoReference": "2531807380",
  "amount": 500.0,
  "phone": "0977123456"
}
```

### 2. Dialog Closure
- Dialog closes immediately after payment initiation
- User sees "Approval Required" snackbar
- Background status checking begins automatically

### 3. Automatic Status Checking
- **Intervals:** 5 attempts × 5 seconds = 25 seconds total
- **Endpoint:** `https://kalootech.com/pay/lenco/transaction.php?reference={reference}`
- **Method:** GET

**Response Example (Transaction Found - Completed):**
```json
{
  "status": true,
  "message": "Transaction found",
  "data": {
    "id": 1,
    "event": "collection.completed",
    "reference": "SUB-Kalutech Stores-1763137403872",
    "lencoReference": "2531807380",
    "amount": "500.00",
    "status": "completed",
    "reasonForFailure": null,
    "raw_payload": "{ ...json... }",
    "created_at": "2025-11-14 16:27:06"
  }
}
```

**Response Example (Transaction Found - Failed):**
```json
{
  "status": true,
  "message": "Transaction found",
  "data": {
    "id": 1,
    "event": "collection.failed",
    "reference": "SUB-Kalutech Stores-1763137403872",
    "lencoReference": "2531807380",
    "amount": "500.00",
    "status": "failed",
    "reasonForFailure": "Incorrect Pin",
    "raw_payload": "{ ...json... }",
    "created_at": "2025-11-14 16:27:06"
  }
}
```

**Response Example (Transaction Not Found):**
```json
{
  "status": false,
  "message": "Transaction not found",
  "reference": "UNKNOWN"
}
```

### 4. Status Check Logic

```dart
Future<Map<String, dynamic>?> checkTransactionStatus(String reference) async {
  final response = await http.get(url);
  final responseData = json.decode(response.body);
  
  if (responseData['status'] == true) {
    // Transaction found
    return {
      'success': true,
      'found': true,
      'status': data['status'], // completed, failed, pay-offline
      'event': data['event'],
      'reasonForFailure': data['reasonForFailure'],
      // ... more fields
    };
  } else {
    // Transaction not found yet
    return {
      'success': true,
      'found': false,
      'message': responseData['message'],
    };
  }
}
```

### 5. Polling Mechanism

```dart
Future<Map<String, dynamic>?> waitForPaymentConfirmation({
  required Map<String, dynamic> paymentResult,
  int maxAttempts = 5,
  Duration pollInterval = const Duration(seconds: 5),
}) async {
  for (int i = 0; i < maxAttempts; i++) {
    await Future.delayed(pollInterval);
    
    final statusCheck = await checkTransactionStatus(reference);
    
    if (statusCheck['found'] == true) {
      if (statusCheck['status'] == 'completed') {
        return {...paymentResult, status: 'completed'};
      } else if (statusCheck['status'] == 'failed') {
        return {success: false, status: 'failed', error: reasonForFailure};
      }
    }
    // Continue polling if not found or still pay-offline
  }
  
  // Not found after 5 attempts
  return {status: 'not-found', error: 'Transaction not found'};
}
```

### 6. Outcome Handling

#### A. Payment Completed
```dart
if (confirmed['status'] == 'completed') {
  await subscriptionService.activateSubscription(
    businessId: businessId,
    plan: plan.plan,
    transactionId: confirmed['transactionId'],
    paymentMethod: operator,
  );
  
  // Show success message
  Get.snackbar('Success', 'Subscription activated!');
}
```

#### B. Payment Failed
```dart
if (confirmed['status'] == 'failed') {
  Get.snackbar(
    'Payment Failed',
    confirmed['error'] ?? 'Payment was declined',
    backgroundColor: Colors.red,
  );
}
```

#### C. Transaction Not Found
```dart
if (confirmed['status'] == 'not-found') {
  // Show manual check button
  Get.snackbar(
    'Status Check',
    'Transaction not found yet. You can check manually.',
    mainButton: TextButton(
      onPressed: () => _manualStatusCheck(),
      child: Text('Check Status'),
    ),
  );
}
```

### 7. Manual Status Check

User can manually trigger status check by clicking the "Check Status" button:

```dart
Future<void> _manualStatusCheck() async {
  final statusCheck = await subscriptionService.checkTransactionStatus(reference);
  
  if (statusCheck['found'] == true) {
    if (statusCheck['status'] == 'completed') {
      // Activate subscription
    } else if (statusCheck['status'] == 'failed') {
      // Show error
    } else {
      // Still pending
    }
  } else {
    // Still not found
  }
}
```

## Complete Flow Diagram

```
User Initiates Payment
         ↓
Payment API Called (Lenco)
         ↓
Dialog Closes Immediately
         ↓
Background Polling Starts (5×5s)
         ↓
   ┌──────┴──────┐
   ↓             ↓
Found         Not Found (after 5 attempts)
   ↓             ↓
Status?      Manual Check Button
   ↓
┌──┴──┐
↓     ↓
Completed  Failed
   ↓        ↓
Activate  Show Error
Subscription
```

## Key Features

### 1. Immediate Feedback
- Dialog closes right after payment initiation
- User isn't blocked waiting for confirmation
- Clear messaging about what's happening

### 2. Automatic Polling
- 5 attempts with 5-second intervals
- Checks transaction status in background
- No user intervention needed if successful

### 3. Transaction States
- **pay-offline:** Payment initiated, waiting for user approval on phone
- **completed:** Payment successful and confirmed
- **failed:** Payment declined (incorrect PIN, insufficient funds, etc.)
- **not-found:** Transaction not yet registered in system

### 4. Manual Recovery
- If automatic polling doesn't find transaction
- User gets "Check Status" button
- Can manually verify at any time
- Useful for network delays or API lag

### 5. Error Handling
- Network failures caught and reported
- API errors displayed to user
- Failed payments show reason (e.g., "Incorrect Pin")
- User can retry or try different payment method

## Response Field Mappings

| API Field | Internal Field | Description |
|-----------|---------------|-------------|
| `data.status` | `status` | Payment state (completed/failed/pay-offline) |
| `data.event` | `event` | Event type (collection.completed/failed) |
| `data.reference` | `transactionId` | Our transaction reference |
| `data.lencoReference` | `lencoReference` | Lenco's internal reference |
| `data.amount` | `amount` | Payment amount |
| `data.reasonForFailure` | `reasonForFailure` | Why payment failed |
| `data.created_at` | `initiatedAt` | When transaction started |

## User Experience

### Happy Path (Success)
1. User enters phone number and clicks Pay
2. Dialog closes
3. "Approval Required" notification appears
4. User approves on phone
5. Within 5-25 seconds: "Payment confirmed!" appears
6. Subscription activates automatically

### Failed Payment
1. User enters phone number and clicks Pay
2. Dialog closes
3. "Approval Required" notification appears
4. User enters wrong PIN on phone
5. "Payment Failed: Incorrect Pin" appears
6. User can try again

### Delayed Transaction
1. User enters phone number and clicks Pay
2. Dialog closes
3. "Approval Required" notification appears
4. After 25 seconds: "Transaction not found yet" appears with "Check Status" button
5. User clicks "Check Status" when ready
6. If completed: Subscription activates
7. If still pending: User can check again later

## Testing Scenarios

### Test 1: Successful Payment
```
1. Initiate payment with valid phone number
2. Verify dialog closes immediately
3. Approve payment on mobile device
4. Verify subscription activates within 25 seconds
5. Check subscription status is "active"
```

### Test 2: Failed Payment
```
1. Initiate payment with valid phone number
2. Enter incorrect PIN on mobile device
3. Verify "Payment Failed: Incorrect Pin" message
4. Verify subscription not activated
```

### Test 3: Delayed Transaction
```
1. Initiate payment but don't approve on phone
2. Wait 25 seconds
3. Verify "Check Status" button appears
4. Approve payment on phone
5. Click "Check Status"
6. Verify subscription activates
```

### Test 4: Network Issues
```
1. Initiate payment with no internet
2. Verify error message displayed
3. Restore internet
4. Verify user can retry
```

## Configuration

```dart
// Adjust polling behavior in subscription_service.dart
Future<Map<String, dynamic>?> waitForPaymentConfirmation({
  required Map<String, dynamic> paymentResult,
  int maxAttempts = 5,        // Number of attempts
  Duration pollInterval = const Duration(seconds: 5), // Time between attempts
})
```

**Default Settings:**
- Max Attempts: 5
- Poll Interval: 5 seconds
- Total Wait Time: 25 seconds

**Recommended Settings:**
- Fast networks: 5 attempts × 3 seconds = 15 seconds
- Slow networks: 7 attempts × 5 seconds = 35 seconds
- Very slow: 10 attempts × 5 seconds = 50 seconds

## Security Considerations

1. **Transaction Reference Format:** `SUB-{businessId}-{timestamp}`
   - Unique per transaction
   - Includes timestamp to prevent collisions
   - Business ID for tracking

2. **Status Verification:**
   - Always verify `status: true` before processing
   - Check `event` field for confirmation type
   - Validate `amount` matches expected value

3. **Activation Guard:**
   - Only activate on `status == 'completed'`
   - Never activate on `pay-offline` alone
   - Verify `event == 'collection.completed'`

## Future Enhancements

1. **Webhook Support:**
   - Instant notifications from Lenco
   - No polling needed
   - Immediate activation

2. **SMS Notifications:**
   - Send SMS when payment completes
   - Include subscription details
   - Receipt generation

3. **Transaction History:**
   - Store all payment attempts
   - Show in subscription view
   - Export for accounting

4. **Retry Logic:**
   - Automatic retry on network failures
   - Exponential backoff
   - Maximum retry limit

## Troubleshooting

### Problem: Transaction Never Found
**Cause:** API delay or network issues
**Solution:** Use manual check button or wait longer

### Problem: Multiple Activations
**Cause:** Rapid clicking or duplicate requests
**Solution:** Disable button during processing, check existing subscriptions

### Problem: Wrong Amount Charged
**Cause:** Price mismatch between app and API
**Solution:** Validate amount in response, log discrepancies

### Problem: Subscription Not Activating
**Cause:** Database error or business ID mismatch
**Solution:** Check logs, verify business ID exists, test database connection

## Summary

This implementation provides a robust, user-friendly payment confirmation flow that:
- ✅ Closes dialog immediately after payment initiation
- ✅ Polls status automatically every 5 seconds for 5 attempts
- ✅ Shows manual check button if transaction not found
- ✅ Only activates subscription when status is "completed"
- ✅ Handles all transaction states (completed, failed, pay-offline, not-found)
- ✅ Provides clear user feedback at every stage
- ✅ Supports manual retry and verification
- ✅ Includes comprehensive error handling

The system ensures payments are verified before activating subscriptions while maintaining a smooth user experience.
