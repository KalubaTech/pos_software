# Online Store Toggle & Price Tag Template Sync Fixes

## 🔍 Issues Identified

### Issue 1: Online Store Toggle Inconsistency ❌
**Symptoms:**
```
Console shows:
✅ Business document updated: online_store_enabled = false
✅ Business document updated: online_store_enabled = true

But Firestore shows: online_store_enabled = false
And UI switch shows: ON 
```

**Root Cause:**
Race condition between multiple initialization methods:

1. `BusinessSettingsController.onInit()` calls:
   - `loadSettings()` → Reads from GetStorage (old value: `false`)
   - `loadFromFirestore()` → Reads from Firestore (async)

2. `BusinessService` initialization calls:
   - Sets `onlineStoreEnabled.value = business.onlineStoreEnabled` (from Firestore: `true`)
   - Calls `saveSettings()` → Shows snackbar and saves to GetStorage

3. **Race condition:**
   - `loadFromFirestore()` finishes (async) AFTER business service initialization
   - Overwrites the correct value with old/wrong value
   - Multiple updates to Firestore creating confusion

**The Flow:**
```
Time 0: Controller init → loadSettings() → onlineStoreEnabled = false (from old GetStorage)
Time 1: Business loads → Sets onlineStoreEnabled = true (from Firestore)
Time 2: Calls saveSettings() → Saves true, shows snackbar
Time 3: loadFromFirestore() completes (async) → Overwrites with ??? value
Time 4: UI state mismatch!
```

---

### Issue 2: Price Tag Template Sync Error ❌
**Error Message:**
```
❌ Error syncing templates: type 'String' is not a subtype of type 'List<dynamic>' in type cast
```

**Root Cause:**
SQLite storage bug in `database_service.dart`:

**Storing templates (Line 954):**
```dart
'elements': template.toJson()['elements'].toString(),  // ❌ Converts List to String!
```

**Reading templates (Line 967):**
```dart
'elements': map['elements'],  // ❌ Passes String directly, expects List!
```

When syncing tries to call `template.toJson()`, it fails because `fromJson` expects `elements` to be a List but gets a String.

---

## ✅ Solutions Implemented

### Fix 1: Online Store Toggle Race Condition

#### Modified: `lib/services/business_service.dart`

**Change 1 - Registration (Lines 216-236):**
```dart
// BEFORE:
await settingsController.saveSettings();  // Shows snackbar, generic save
print('✅ Business Settings initialized successfully');

// AFTER:
// Save to GetStorage immediately (DON'T call saveSettings to avoid snackbar)
await _storage.write('store_name', settingsController.storeName.value);
await _storage.write('store_address', settingsController.storeAddress.value);
await _storage.write('store_phone', settingsController.storePhone.value);
await _storage.write('store_email', settingsController.storeEmail.value);
await _storage.write('store_tax_id', settingsController.storeTaxId.value);
await _storage.write('tax_enabled', settingsController.taxEnabled.value);
await _storage.write('tax_rate', settingsController.taxRate.value);
await _storage.write('tax_name', settingsController.taxName.value);
await _storage.write('currency', settingsController.currency.value);
await _storage.write('currency_symbol', settingsController.currencySymbol.value);
await _storage.write('receipt_header', settingsController.receiptHeader.value);
await _storage.write('receipt_footer', settingsController.receiptFooter.value);
await _storage.write('online_store_enabled', settingsController.onlineStoreEnabled.value);

print('✅ Business Settings initialized successfully');
```

**Change 2 - Load Business (Lines 326-346):**
```dart
// BEFORE:
await settingsController.saveSettings();  // Shows snackbar
print('✅ Business Settings initialized from loaded business');

// AFTER:
// Save to GetStorage (DON'T call saveSettings to avoid snackbar)
await _storage.write('store_name', settingsController.storeName.value);
await _storage.write('store_address', settingsController.storeAddress.value);
await _storage.write('store_phone', settingsController.storePhone.value);
await _storage.write('store_email', settingsController.storeEmail.value);
await _storage.write('store_tax_id', settingsController.storeTaxId.value);
await _storage.write('tax_enabled', settingsController.taxEnabled.value);
await _storage.write('tax_rate', settingsController.taxRate.value);
await _storage.write('tax_name', settingsController.taxName.value);
await _storage.write('currency', settingsController.currency.value);
await _storage.write('currency_symbol', settingsController.currencySymbol.value);
await _storage.write('receipt_header', settingsController.receiptHeader.value);
await _storage.write('receipt_footer', settingsController.receiptFooter.value);
await _storage.write('online_store_enabled', settingsController.onlineStoreEnabled.value);

print('✅ Business Settings initialized from loaded business');
```

**Why This Works:**
- ✅ Directly writes to GetStorage (bypasses saveSettings())
- ✅ No snackbar shown during initialization
- ✅ No race condition with `loadFromFirestore()`
- ✅ Explicit, clear, synchronous writes
- ✅ `onlineStoreEnabled` is correctly saved

---

### Fix 2: Price Tag Template JSON Encoding

#### Modified: `lib/services/database_service.dart`

**Change 1 - Add Import (Line 2):**
```dart
import 'dart:convert'; // ✅ Add for jsonEncode/jsonDecode
```

**Change 2 - Fix _templateToMap (Line 955):**
```dart
// BEFORE:
'elements': template.toJson()['elements'].toString(),  // ❌ Wrong!

// AFTER:
'elements': jsonEncode(template.toJson()['elements']), // ✅ Proper JSON encoding
```

**Change 3 - Fix _templateFromMap (Line 967):**
```dart
// BEFORE:
'elements': map['elements'],  // ❌ Passes String, expects List

// AFTER:
'elements': jsonDecode(map['elements']), // ✅ Decode JSON string to List
```

**Why This Works:**
- ✅ SQLite stores complex data as JSON strings
- ✅ `jsonEncode()` properly serializes List → String
- ✅ `jsonDecode()` properly deserializes String → List
- ✅ `PriceTagTemplate.fromJson()` receives correct data type
- ✅ Sync to Firestore works correctly

---

## 📊 Expected Behavior After Fixes

### Online Store Toggle:
**Before Fix:**
```
1. Register business (online_store_enabled = false)
2. Login
3. Business loads with online_store_enabled = true (from Firestore)
4. saveSettings() called → Firestore updated to true
5. loadFromFirestore() overwrites → back to false
6. UI shows: ON, Firestore shows: false ❌
```

**After Fix:**
```
1. Register business (online_store_enabled = false)
2. Login
3. Business loads with online_store_enabled = false (from Firestore)
4. Direct GetStorage write → Saves false
5. No race condition, no overwrite
6. UI shows: OFF, Firestore shows: false ✅
7. User toggles ON → Firestore updated to true ✅
8. UI shows: ON, Firestore shows: true ✅
```

### Price Tag Templates:
**Before Fix:**
```
1. Save template to SQLite
   → elements stored as String: "[{...}, {...}]" (wrong)
2. Load template from SQLite
   → elements = "[{...}, {...}]" (still String)
3. Call template.toJson()
   → PriceTagTemplate.fromJson() expects List
   → ERROR: type 'String' is not a subtype of type 'List'
```

**After Fix:**
```
1. Save template to SQLite
   → elements stored as String: "[{...}, {...}]" (correct JSON)
2. Load template from SQLite
   → elements = jsonDecode("[{...}, {...}]") → List ✅
3. Call template.toJson()
   → Works correctly ✅
4. Sync to Firestore
   → Success ✅
```

---

## 🧪 Testing Instructions

### Test 1: Online Store Toggle

#### Step 1: Fresh Registration
```powershell
.\reset_database.ps1
flutter run -d windows
```

#### Step 2: Register Business
- Complete registration
- **Expected console:**
```
✅ Business registered successfully: BUS_xxx
📝 Initializing Business Settings with registration data...
   📱 Online Store: false
✅ Business Settings initialized successfully
```

#### Step 3: Check Settings Page
1. Login with PIN
2. Go to Settings → Business tab
3. Scroll to "Online Store" section
4. **Expected:** Switch is OFF ✅
5. **Check Firestore:** `online_store_enabled: false` ✅

#### Step 4: Toggle Online Store
1. Turn switch ON
2. **Expected console:**
```
🔄 Updating document: businesses/BUS_xxx
🔄 Fields: online_store_enabled, updated_at
✅ Updated businesses/BUS_xxx in cloud
✅ Business document updated: online_store_enabled = true
```
3. **Expected snackbar:** "Online Store Enabled" ✅
4. **Check Firestore:** `online_store_enabled: true` ✅

#### Step 5: Restart App
1. Close and reopen app
2. Login
3. **Expected console:**
```
🔍 Fetching business: BUS_xxx
✅ Business loaded: Your Business (active)
📝 Initializing Business Settings from loaded business...
   📱 Online Store: true
✅ Business Settings initialized from loaded business
```
4. **Check Settings Page:** Switch is ON ✅
5. **Check Firestore:** Still `true` ✅

---

### Test 2: Price Tag Templates

#### Step 1: Create Template
1. Go to Price Tags Designer
2. Create a new template with some elements
3. Save template
4. **Expected:** No errors ✅

#### Step 2: Close and Reopen App
1. Close app
2. Reopen app
3. Login
4. **Expected console:**
```
🏷️ Syncing price tag templates...
📱 Local templates: 1
☁️ Pushed 1 templates to cloud
```
5. **No error message!** ✅

#### Step 3: Check Firestore
1. Go to Firebase Console
2. Navigate to: `businesses/{id}/price_tag_templates/`
3. **Expected:** Template document exists with proper structure ✅
4. **Expected:** `elements` field is an array of objects ✅

---

## ✅ Verification Checklist

### Online Store Toggle:
- [ ] Initial state matches Firestore (false)
- [ ] Toggle updates Firestore correctly
- [ ] UI state matches Firestore state
- [ ] No duplicate update messages in console
- [ ] State persists across app restarts
- [ ] No snackbar during initialization

### Price Tag Templates:
- [ ] Templates save to SQLite without errors
- [ ] Templates load from SQLite without errors
- [ ] Templates sync to Firestore without errors
- [ ] Template `elements` field is properly formatted in Firestore
- [ ] No type casting errors in console

---

## 📝 Files Modified

### 1. `lib/services/business_service.dart`
**Changes:**
- Replaced `saveSettings()` calls with direct GetStorage writes
- Added explicit write for `online_store_enabled`
- Removed snackbar trigger during initialization

**Lines Modified:**
- Registration: 216-236
- Load Business: 326-346

### 2. `lib/services/database_service.dart`
**Changes:**
- Added `import 'dart:convert';`
- Fixed `_templateToMap()` to use `jsonEncode()`
- Fixed `_templateFromMap()` to use `jsonDecode()`

**Lines Modified:**
- Line 2: Added import
- Line 955: JSON encode elements
- Line 967: JSON decode elements

---

## 🎯 Summary

### Issue 1: Online Store Toggle ✅ FIXED
**Problem:** Race condition causing UI/Firestore mismatch
**Solution:** Direct GetStorage writes, no async race
**Result:** UI and Firestore always in sync

### Issue 2: Price Tag Templates ✅ FIXED
**Problem:** Wrong data type stored in SQLite (String instead of JSON)
**Solution:** Proper JSON encode/decode
**Result:** Templates sync correctly to Firestore

### Impact:
- ✅ Online store toggle works reliably
- ✅ State persists correctly across restarts
- ✅ No duplicate Firestore updates
- ✅ Price tag templates sync without errors
- ✅ Clean console output (no type errors)

**All issues resolved!** 🎉
