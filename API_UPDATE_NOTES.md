# API Update Notes - November 14, 2025

## 🔄 Status Check API Changes

### What Changed

The Lenco transaction status API response structure has been updated with more detailed fields and different naming conventions.

---

## API Endpoint Updates

### Status Check Endpoint

**Old Query Parameter:**
```
GET https://kalootech.com/pay/lenco/transaction.php?reference={reference}
```

**New Query Parameter (Updated):**
```
GET https://kalootech.com/pay/lenco/transaction.php?lenco_reference={lencoReference}
```

**OR (Also works):**
```
GET https://kalootech.com/pay/lenco/transaction.php?reference={reference}
```

**Note:** The implementation now supports both methods. It will use `lenco_reference` if available (more reliable), otherwise falls back to `reference`.

---

## Response Structure Changes

### Old Response Structure
```json
{
  "status": true,
  "data": {
    "status": "completed",
    "lencoReference": "2531807380",
    "amount": "500.00",
    "completedAt": "2025-11-14 16:27:06",
    "initiatedAt": "2025-11-14 16:27:06",
    "reasonForFailure": null
  }
}
```

### New Response Structure (Current)
```json
{
  "status": true,
  "data": {
    "id": 1,
    "event": "collection.failed",
    "lenco_id": "3c123bf1-583f-4519-b628-1a8a65aaf409",
    "reference": "SUB-Kalutech Stores-1763140542369",
    "lenco_reference": "2531807904",
    "amount": "500.00",
    "fee": null,
    "bearer": "merchant",
    "currency": "ZMW",
    "status": "failed",
    "type": "mobile-money",
    "reason_for_failure": "Insufficient funds",
    "settlement_status": null,
    "initiated_at": "2025-11-14 17:15:44",
    "completed_at": "2025-11-14 17:16:02",
    "mm_country": "zm",
    "mm_phone": "0973232553",
    "mm_operator": "airtel",
    "mm_account_name": "kaluba chakanga",
    "mm_operator_txn_id": "MP251114.1916.P58489",
    "bank_account_details": null,
    "card_details": null,
    "account_number": null,
    "narration": null,
    "raw_payload": "{...}",
    "created_at": "2025-11-14 17:16:02",
    "updated_at": "2025-11-14 17:16:02"
  }
}
```

---

## Field Name Changes

### Core Fields

| Old Field Name | New Field Name | Notes |
|----------------|----------------|-------|
| `lencoReference` | `lenco_reference` | Changed to snake_case |
| `reasonForFailure` | `reason_for_failure` | Changed to snake_case |
| `completedAt` | `completed_at` | Changed to snake_case |
| `initiatedAt` | `initiated_at` | Changed to snake_case |

### New Fields Added

| Field Name | Type | Description | Example |
|------------|------|-------------|---------|
| `id` | integer | Database record ID | `1` |
| `event` | string | Event type | `collection.completed`, `collection.failed` |
| `lenco_id` | string (UUID) | Lenco's internal UUID | `3c123bf1-583f-4519-b628-1a8a65aaf409` |
| `fee` | string/null | Transaction fee | `null` or `"10.00"` |
| `bearer` | string | Who pays fees | `merchant` |
| `currency` | string | Currency code | `ZMW` |
| `type` | string | Payment type | `mobile-money` |
| `settlement_status` | string/null | Settlement state | `null` |
| `mm_country` | string | Mobile money country | `zm` |
| `mm_phone` | string | Phone number used | `0973232553` |
| `mm_operator` | string | Operator used | `airtel`, `mtn`, `zamtel` |
| `mm_account_name` | string | Account holder name | `kaluba chakanga` |
| `mm_operator_txn_id` | string | Operator's transaction ID | `MP251114.1916.P58489` |
| `bank_account_details` | object/null | Bank details if applicable | `null` |
| `card_details` | object/null | Card details if applicable | `null` |
| `account_number` | string/null | Account number | `null` |
| `narration` | string/null | Transaction description | `null` |
| `raw_payload` | string | Complete API payload | `{...json...}` |
| `created_at` | datetime | Record creation time | `2025-11-14 17:16:02` |
| `updated_at` | datetime | Record update time | `2025-11-14 17:16:02` |

---

## Code Changes Made

### 1. Updated `checkTransactionStatus()` Method

**File:** `lib/services/subscription_service.dart`

**Changes:**
- Added optional `lencoReference` parameter
- Uses `lenco_reference` query param if provided
- Updated field parsing to use snake_case
- Added all new fields to response

```dart
Future<Map<String, dynamic>?> checkTransactionStatus(
  String reference, {
  String? lencoReference,  // NEW PARAMETER
}) async {
  // Use lenco_reference if provided (more reliable)
  final queryParam = lencoReference != null 
      ? 'lenco_reference=$lencoReference'
      : 'reference=$reference';
      
  final url = Uri.parse(
    'https://kalootech.com/pay/lenco/transaction.php?$queryParam',
  );
  
  // ... parse with snake_case fields
  return {
    'lencoReference': data['lenco_reference'],  // Updated
    'reasonForFailure': data['reason_for_failure'],  // Updated
    'completedAt': data['completed_at'],  // Updated
    'initiatedAt': data['initiated_at'],  // Updated
    'mmAccountName': data['mm_account_name'],  // NEW
    'mmOperatorTxnId': data['mm_operator_txn_id'],  // NEW
    // ... more fields
  };
}
```

### 2. Updated `waitForPaymentConfirmation()` Method

**File:** `lib/services/subscription_service.dart`

**Changes:**
- Extracts `lencoReference` from payment result
- Passes it to `checkTransactionStatus()`
- Includes mobile money details in response

```dart
Future<Map<String, dynamic>?> waitForPaymentConfirmation({
  required Map<String, dynamic> paymentResult,
  // ...
}) async {
  final lencoReference = paymentResult['lencoReference'];  // EXTRACT
  
  // Pass to status check
  final statusCheck = await checkTransactionStatus(
    reference,
    lencoReference: lencoReference,  // PASS IT
  );
  
  // Include MM details in response
  if (currentStatus == 'completed') {
    return {
      ...paymentResult,
      'mmAccountName': statusCheck['mmAccountName'],  // NEW
      'mmOperatorTxnId': statusCheck['mmOperatorTxnId'],  // NEW
    };
  }
}
```

### 3. Updated UI Messages

**File:** `lib/views/settings/subscription_view.dart`

**Changes:**
- Shows `lencoReference` in notifications
- Displays `mmAccountName` in success/failure messages
- Includes Lenco reference in manual check prompts

```dart
// Success message
Get.snackbar(
  'Success',
  'Payment confirmed!\nAccount: ${confirmed['mmAccountName']}',  // NEW
);

// Failed message
Get.snackbar(
  'Payment Failed',
  '${error}\nAccount: ${confirmed['mmAccountName']}',  // NEW
);

// Not found message
Get.snackbar(
  'Status Check',
  'Transaction not found.\nLenco Ref: $lencoReference',  // NEW
);
```

---

## Benefits of New Fields

### 1. Better User Feedback
- **Account Name Display:** Users can verify the correct account was charged
- **Operator Transaction ID:** Useful for customer support queries
- **Detailed Failure Reasons:** Clear error messages (e.g., "Insufficient funds")

### 2. Enhanced Tracking
- **Lenco ID (UUID):** Unique identifier for Lenco's system
- **Event Field:** Clear event type for logging
- **Raw Payload:** Complete transaction data for debugging

### 3. Better Support
- **MM Operator Txn ID:** Can trace transaction with mobile operator
- **Account Name:** Verify correct account was used
- **Timestamps:** Precise timing information

---

## Example Scenarios

### Scenario 1: Successful Payment

**Status Check Response:**
```json
{
  "status": true,
  "data": {
    "event": "collection.completed",
    "status": "completed",
    "mm_account_name": "John Doe",
    "mm_operator_txn_id": "MP251114.1916.P58489",
    "amount": "500.00"
  }
}
```

**User Sees:**
```
✅ Payment confirmed! Your subscription is now active.
   Account: John Doe
```

### Scenario 2: Failed Payment (Insufficient Funds)

**Status Check Response:**
```json
{
  "status": true,
  "data": {
    "event": "collection.failed",
    "status": "failed",
    "reason_for_failure": "Insufficient funds",
    "mm_account_name": "Jane Smith"
  }
}
```

**User Sees:**
```
❌ Payment Failed
   Insufficient funds
   Account: Jane Smith
```

### Scenario 3: Failed Payment (Wrong PIN)

**Status Check Response:**
```json
{
  "status": true,
  "data": {
    "event": "collection.failed",
    "status": "failed",
    "reason_for_failure": "Incorrect Pin",
    "mm_account_name": "Mike Johnson"
  }
}
```

**User Sees:**
```
❌ Payment Failed
   Incorrect Pin
   Account: Mike Johnson
```

### Scenario 4: Transaction Not Found

**Status Check Response:**
```json
{
  "status": false,
  "message": "Transaction not found"
}
```

**User Sees:**
```
⚠️ Status Check
   Transaction not found yet. You can check manually.
   Lenco Ref: 2531807904
   [Check Status]
```

---

## Backward Compatibility

The implementation maintains backward compatibility:

1. **Dual Query Support:** Works with both `reference` and `lenco_reference` parameters
2. **Fallback Parsing:** Handles both camelCase and snake_case field names
3. **Graceful Degradation:** Missing fields don't break functionality
4. **Optional Display:** Shows account name only if available

---

## Testing Considerations

### Test Cases to Verify

1. **✅ Status Check with lenco_reference**
   - Verify API returns correct data
   - Check all fields are parsed correctly

2. **✅ Status Check with reference**
   - Verify fallback works
   - Ensure same data is returned

3. **✅ Account Name Display**
   - Successful payment shows account name
   - Failed payment shows account name
   - Handles null account name gracefully

4. **✅ Operator Transaction ID**
   - Stored in response
   - Available for support queries

5. **✅ Detailed Error Messages**
   - "Insufficient funds" displayed correctly
   - "Incorrect Pin" displayed correctly
   - Other error reasons handled

6. **✅ Lenco Reference in Notifications**
   - Shows in "not found" message
   - Shows in manual check prompt
   - Copyable for support tickets

---

## Migration Notes

### For Developers

**No breaking changes** - The update is backward compatible. However:

1. **Update API calls:** Use `lenco_reference` when available for better reliability
2. **Update UI:** Display `mm_account_name` where helpful for user verification
3. **Update logging:** Include `lenco_id` and `event` fields for better tracking
4. **Update support tools:** Use `mm_operator_txn_id` for operator queries

### For Support Team

**New information available:**
- Account name of payer
- Operator transaction ID (for queries with MTN/Airtel/Zamtel)
- Lenco UUID for Lenco support queries
- Detailed failure reasons (not just generic errors)

---

## API Documentation

### Query Transaction Status

**Endpoint:** `GET https://kalootech.com/pay/lenco/transaction.php`

**Query Parameters:**
- `reference` (string) - Your transaction reference (e.g., `SUB-Business-123`)
- `lenco_reference` (string) - Lenco's reference (e.g., `2531807904`)

**Note:** Use `lenco_reference` for more reliable lookups.

**Response (Success):**
```json
{
  "status": true,
  "data": {
    "id": 1,
    "event": "collection.completed|collection.failed",
    "lenco_id": "uuid",
    "reference": "your-reference",
    "lenco_reference": "lenco-ref",
    "amount": "500.00",
    "status": "completed|failed|pay-offline",
    "reason_for_failure": "error message or null",
    "mm_account_name": "account holder name",
    "mm_operator_txn_id": "operator transaction id",
    "initiated_at": "datetime",
    "completed_at": "datetime"
  }
}
```

**Response (Not Found):**
```json
{
  "status": false,
  "message": "Transaction not found"
}
```

---

## Summary

### Key Changes
✅ Updated to snake_case field names
✅ Added 15+ new fields for better tracking
✅ Support for both query parameter types
✅ Enhanced user feedback with account names
✅ Better error messages with detailed reasons
✅ Operator transaction IDs for support

### Impact
- ✅ Better user experience (shows who paid)
- ✅ Better error clarity (specific reasons)
- ✅ Better support tools (operator IDs)
- ✅ Better debugging (raw payloads)
- ✅ Backward compatible (no breaking changes)

---

**Updated:** November 14, 2025
**Status:** ✅ Implementation Complete
**Breaking Changes:** None
**Testing Required:** ✅ Verify all new fields display correctly
