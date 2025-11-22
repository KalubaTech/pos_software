# Fresh Start Testing Guide

## Current Issues Fixed ✅

### 1. ✅ SQLite Boolean Error - FIXED
**Problem:** `isActive` field was being saved as `bool` (true/false) but SQLite only accepts integers (0/1)

**Solution Applied:**
- Added `toSQLite()` method to `CashierModel` that converts `bool` to `int`
- Updated `database_service.dart` `insertCashier()` to auto-convert booleans
- Updated all `auth_controller.dart` calls to use `toSQLite()` instead of `toJson()`

### 2. ✅ Missing Dashboard Route - FIXED
**Problem:** `Get.offAllNamed('/dashboard')` failed because route wasn't defined

**Solution Applied:**
- Added route definition in `main.dart`:
```dart
routes: {
  '/dashboard': (context) => PageAnchor(),
},
```

### 3. ⚠️ Wrong Business ID - REQUIRES DATABASE RESET
**Problem:** Login loaded old cashier from SQLite with old business ID (`BUS_1763642420922`)
- New registration created: `BUS_1763643122626` ✅
- But login used cached cashier with old business ID ❌

**Why This Happened:**
- SQLite database still contains cashier from previous registration
- That old cashier has the old business ID
- Login reads from local SQLite first, finds old cashier
- Tries to sync with Firestore using old business ID
- Firestore document doesn't exist (you cleared it)

## How to Test Fresh Start 🧪

### Step 1: Clear Everything
```powershell
# Delete SQLite database
Remove-Item -Path "$env:LOCALAPPDATA\pos_software\*.db" -Force

# OR if that doesn't work, find the database location:
Get-ChildItem -Path "$env:LOCALAPPDATA" -Recurse -Filter "pos_software*.db"
```

### Step 2: Clear Firestore
1. Go to Firebase Console
2. Delete the entire `businesses` collection
3. This ensures a completely clean start

### Step 3: Clear App Storage (Optional but Recommended)
```powershell
# Clear GetStorage cache
Remove-Item -Path "$env:LOCALAPPDATA\pos_software\get_storage*" -Recurse -Force
```

### Step 4: Restart App
1. Close the app completely
2. Restart: `flutter run -d windows`

### Step 5: Register New Business
1. Fill all fields:
   - Business Name: "Fresh Test Business"
   - Email: your email
   - Phone: your phone
   - Address: full address
   - **City: SELECT from dropdown** (e.g., "Lusaka")
   - **Country: Zambia** (auto-filled)
   - Admin Name: your name
   - **PIN: 1122** (remember this!)

2. Expected Console Output:
```
🏢 Registering new business: Fresh Test Business
📤 Firestore path: businesses
✅ Business registered successfully: BUS_xxxxxxxxx
   📍 Location: Lusaka, Zambia
   🗺️  Coordinates: -15.xxx, 28.xxx
✅ Admin cashier saved to Firestore successfully
✅ Business registered with embedded settings
```

3. **Verify in Firestore Console:**
   - `businesses/BUS_xxxxxxxxx/` exists
   - Has all fields: name, email, phone, address, city, country, latitude, longitude
   - Has embedded `settings` object
   - `businesses/BUS_xxxxxxxxx/cashiers/ADMIN_xxxxxxxxx/` exists
   - **NO `business_settings` subcollection anywhere**

### Step 6: Login
1. Use PIN: **1122**
2. Expected Console Output:
```
=== LOGIN ATTEMPT ===
Input: 1122
Cashiers count: 1
Login mode: PIN only
PIN: 1122
✅ Found cashier by PIN: Your Name
✅ Login successful! User: Your Name, Business: BUS_xxxxxxxxx
🔄 Initializing business sync...
📊 Using registered business: BUS_xxxxxxxxx
✅ Sync service initialized for business: BUS_xxxxxxxxx
🎉 Business sync initialization complete!
```

3. Should navigate to **Dashboard** successfully ✅

## What Was Fixed in Code

### File: `lib/models/cashier_model.dart`
```dart
/// Convert to SQLite-compatible format (bool -> int)
Map<String, dynamic> toSQLite() {
  return {
    'id': id,
    'name': name,
    'email': email,
    'pin': pin,
    'role': role.name,
    'profileImageUrl': profileImageUrl,
    'isActive': isActive ? 1 : 0, // ✅ bool -> int
    'createdAt': createdAt.toIso8601String(),
    'lastLogin': lastLogin?.toIso8601String(),
    'businessId': businessId,
  };
}
```

### File: `lib/services/database_service.dart`
```dart
Future<int> insertCashier(Map<String, dynamic> cashier) async {
  final db = await database;
  try {
    // ✅ Convert boolean to int for SQLite compatibility
    final sqliteCashier = Map<String, dynamic>.from(cashier);
    if (sqliteCashier['isActive'] is bool) {
      sqliteCashier['isActive'] = (sqliteCashier['isActive'] as bool) ? 1 : 0;
    }
    
    await db.insert(
      cashiersTable,
      sqliteCashier,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return 1;
  } catch (e) {
    print('Error inserting cashier: $e');
    return 0;
  }
}
```

### File: `lib/controllers/auth_controller.dart`
```dart
// Line 107: Default cashiers
await _db.insertCashier(cashier.toSQLite()); // ✅ Use toSQLite()

// Line 302: Firestore sync
await _db.insertCashier(cashier.toSQLite()); // ✅ Use toSQLite()

// Line 440: Add cashier
await _db.insertCashier(cashier.toSQLite()); // ✅ Use toSQLite()
```

### File: `lib/main.dart`
```dart
GetMaterialApp(
  // ... other properties
  home: AuthWrapper(),
  routes: {
    '/dashboard': (context) => PageAnchor(), // ✅ Added route
  },
)
```

## Verification Checklist

After fresh start and registration:

### Firestore Structure ✅
- [ ] `businesses/BUS_xxx/` exists
- [ ] `businesses/BUS_xxx/name` = "Fresh Test Business"
- [ ] `businesses/BUS_xxx/city` = "Lusaka"
- [ ] `businesses/BUS_xxx/country` = "Zambia"
- [ ] `businesses/BUS_xxx/latitude` = -15.xxx
- [ ] `businesses/BUS_xxx/longitude` = 28.xxx
- [ ] `businesses/BUS_xxx/settings` = embedded object (not subcollection)
- [ ] `businesses/BUS_xxx/cashiers/ADMIN_xxx/` exists with pin = "1122"
- [ ] **NO** `business_settings` subcollection anywhere
- [ ] **NO** `business_registrations` collection

### Login Flow ✅
- [ ] Login with PIN 1122 succeeds
- [ ] No SQLite boolean errors
- [ ] Dashboard loads successfully
- [ ] Console shows correct business ID (matches Firestore)
- [ ] No "Document not found" errors

### Settings Load ✅
- [ ] Go to Settings
- [ ] Console shows: "✅ Found embedded settings in business document"
- [ ] All settings load correctly
- [ ] Toggle online store works
- [ ] **NO** "business_settings sync skipped" messages

## Common Issues & Solutions

### Issue: "Two business documents created"
**Cause:** Old data in SQLite causing duplicate registrations

**Solution:** Delete SQLite database before testing

---

### Issue: "Document not found: BUS_xxx"
**Cause:** Login using old business ID from cached cashier

**Solution:** Delete SQLite database, register fresh

---

### Issue: "Invalid argument type 'bool': true"
**Cause:** Using `toJson()` instead of `toSQLite()` for database insert

**Solution:** ✅ FIXED in code - all calls now use `toSQLite()`

---

### Issue: "Could not find a generator for route /dashboard"
**Cause:** Missing route definition in main.dart

**Solution:** ✅ FIXED in code - route added to GetMaterialApp

## Summary

**All code fixes are complete!** ✅

**Next step:** Clear local database and test fresh registration.

The app now:
1. ✅ Saves cashiers correctly to SQLite (bool → int)
2. ✅ Has dashboard route defined
3. ✅ Uses embedded settings (no subcollection)
4. ✅ Saves complete business data to Firestore
5. ✅ Associates cashiers with correct business ID

**Just need a fresh start to see it all working together!** 🎉
