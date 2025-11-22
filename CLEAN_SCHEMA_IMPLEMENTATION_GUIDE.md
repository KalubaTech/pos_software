# 🎯 CLEAN SCHEMA IMPLEMENTATION GUIDE

**Date:** November 20, 2025  
**Status:** ✅ Code Updated - Ready to Test

---

## ✅ What Was Fixed

### 1. Business Registration (`lib/services/business_service.dart`)

**Before (Chaotic):**
- Saved to TWO collections with DIFFERENT data
- Location fields MISSING from main document
- Only 9 fields in businesses collection

**After (Clean):**
- Saves to ONE collection with COMPLETE data
- All 20+ fields including location
- Embedded settings object

**Changes Made:**
- ✅ Now requires `city` and `country` (previously optional)
- ✅ Captures `latitude` and `longitude`
- ✅ Includes embedded `settings` object
- ✅ Saves `online_product_count`
- ✅ Single write to `businesses` collection only

### 2. Business Updates (`lib/services/business_service.dart`)

**Changes:**
- ✅ Uses `updateCloud()` for partial updates
- ✅ Updates single `businesses` collection
- ✅ Adds `updated_at` timestamp
- ✅ No more data loss

### 3. Online Store Toggle (`lib/controllers/business_settings_controller.dart`)

**Changes:**
- ✅ No more subcollection writes
- ✅ Single update to business document
- ✅ Includes timestamp
- ✅ Uses safe `updateCloud()` method

---

## 📋 What You Need to Do Now

### Step 1: Clear Firestore (IMPORTANT!)

Your current Firestore has incomplete data. Start fresh:

**Via Firebase Console:**
1. Go to Firebase Console → Firestore Database
2. Select "businesses" collection
3. Click "..." → Delete collection
4. Confirm deletion

**Via Firebase CLI:**
```bash
firebase firestore:delete businesses --recursive --force
```

### Step 2: Update Registration View

Add location fields to your registration form:

**File:** `lib/views/auth/business_registration_view.dart` (or similar)

```dart
// Add these fields to the form:

TextFormField(
  decoration: InputDecoration(
    labelText: 'Street Address *',
    hintText: 'e.g., 123 Main Street, Woodlands',
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    return null;
  },
  onSaved: (value) => address = value!,
),

TextFormField(
  decoration: InputDecoration(
    labelText: 'City *',
    hintText: 'e.g., Lusaka',
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'City is required';
    }
    return null;
  },
  onSaved: (value) => city = value!,
),

TextFormField(
  decoration: InputDecoration(
    labelText: 'Country *',
    hintText: 'e.g., Zambia',
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Country is required';
    }
    return null;
  },
  onSaved: (value) => country = value!,
),

// Optional: Location picker button
ElevatedButton.icon(
  icon: Icon(Icons.location_on),
  label: Text('Pick Location on Map'),
  onPressed: () async {
    // Use google_maps_flutter or similar to pick location
    final position = await pickLocationOnMap();
    if (position != null) {
      latitude = position.latitude;
      longitude = position.longitude;
    }
  },
),
```

**Update the registration call:**

```dart
final business = await businessService.registerBusiness(
  name: name,
  businessType: businessType,
  email: email,
  phone: phone,
  address: address,          // ✅ Now required
  city: city,                // ✅ Now required
  country: country,          // ✅ Now required
  latitude: latitude,        // ✅ From map picker
  longitude: longitude,      // ✅ From map picker
  taxId: taxId,
  website: website,
  adminId: adminCashier.id,
  adminCashierData: {
    'id': adminCashier.id,
    'name': adminCashier.name,
    'email': adminCashier.email,
    'pin': adminCashier.pin,
    'role': 'admin',
    'businessId': businessId,
    'isActive': true,
    'createdAt': DateTime.now().toIso8601String(),
  },
);
```

### Step 3: Update SQLite Schema

Your local database needs matching structure.

**File:** `lib/services/database_service.dart`

**Add missing columns:**

```dart
Future<void> _upgradeDatabaseToV6(Database db, int oldVersion, int newVersion) async {
  print('🔄 Upgrading database from v$oldVersion to v$newVersion');
  
  if (oldVersion < 6) {
    // Add missing location columns
    await db.execute('ALTER TABLE businesses ADD COLUMN city TEXT');
    await db.execute('ALTER TABLE businesses ADD COLUMN country TEXT');
    await db.execute('ALTER TABLE businesses ADD COLUMN latitude REAL');
    await db.execute('ALTER TABLE businesses ADD COLUMN longitude REAL');
    
    // Add settings column (stores JSON)
    await db.execute('ALTER TABLE businesses ADD COLUMN settings TEXT');
    
    // Add online_product_count
    await db.execute('ALTER TABLE businesses ADD COLUMN online_product_count INTEGER DEFAULT 0');
    
    // Add updated_at
    await db.execute('ALTER TABLE businesses ADD COLUMN updated_at TEXT');
    
    print('✅ Database upgraded to v6');
  }
}

// Update version constant
static const int _databaseVersion = 6;
```

### Step 4: Test Registration

1. **Run the app:**
```bash
flutter run -d windows
```

2. **Register a new business:**
   - Fill ALL fields including address, city, country
   - Optionally pick location on map
   - Complete registration

3. **Verify in Firebase Console:**
   - Go to Firestore → `businesses` collection
   - Check your new business has:
     ```
     ✅ id
     ✅ name
     ✅ email
     ✅ phone
     ✅ address (NOW THERE!)
     ✅ city (NOW THERE!)
     ✅ country (NOW THERE!)
     ✅ latitude (if picked)
     ✅ longitude (if picked)
     ✅ admin_id
     ✅ status
     ✅ created_at
     ✅ updated_at
     ✅ online_store_enabled
     ✅ online_product_count
     ✅ settings (embedded object)
     ```

### Step 5: Test Online Store Toggle

1. Toggle online store ON
2. Check Firebase Console
3. Verify `online_store_enabled: true`
4. **Verify NO fields were lost!**

### Step 6: Test Dynamos Market

```javascript
// Fetch online businesses
const businesses = await db
  .collection('businesses')
  .where('online_store_enabled', '==', true)
  .get();

businesses.forEach(doc => {
  const b = doc.data();
  console.log(`${b.name} - ${b.city}, ${b.country}`);
  // Address and location should be there now!
});
```

---

## ✅ Verification Checklist

### Business Document
- [ ] `address` exists (WAS MISSING!)
- [ ] `city` exists (WAS MISSING!)
- [ ] `country` exists (WAS MISSING!)
- [ ] `latitude` exists (optional)
- [ ] `longitude` exists (optional)
- [ ] `settings` is embedded object
- [ ] `online_product_count` exists
- [ ] `updated_at` exists

### No Redundancy
- [ ] NO `business_registrations` collection
- [ ] NO `business_settings` subcollection
- [ ] Settings embedded in business document

### Functionality
- [ ] Can register business
- [ ] All fields save correctly
- [ ] Can toggle online store
- [ ] No data loss on updates
- [ ] Dynamos Market fetches businesses

---

## 📊 Before & After

### Before (Your Screenshot) 🔴
```
BUS_1763638746767/
  ✅ name: "Kaloo Tech"
  ✅ phone: "0973232553"
  ❌ address: MISSING
  ❌ city: MISSING
  ❌ country: MISSING
  ❌ settings: NOT EMBEDDED

BUS_1763638746767/business_settings/default/
  ❌ DETACHED SUBCOLLECTION
```

### After (Clean) ✅
```
BUS_1763638746767/
  ✅ name: "Kaloo Tech"
  ✅ phone: "+260973232553"
  ✅ address: "123 Main Street"     ← NOW THERE
  ✅ city: "Lusaka"                 ← NOW THERE
  ✅ country: "Zambia"              ← NOW THERE
  ✅ latitude: -15.4167             ← NOW THERE
  ✅ longitude: 28.2833             ← NOW THERE
  ✅ settings: { ... }              ← EMBEDDED

NO detached subcollections! ✅
```

---

## 🚀 Next Steps

1. ✅ Code is updated (business_service.dart, business_settings_controller.dart)
2. ⏳ Update registration view (add location fields)
3. ⏳ Update SQLite schema (add columns)
4. ⏳ Clear Firestore
5. ⏳ Test registration
6. ⏳ Test Dynamos Market

**The code is clean - now update the UI and test!** 🎉
