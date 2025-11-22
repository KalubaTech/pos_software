# 🚨 CRITICAL: Business Document Corrupted in Firestore

**Date:** November 20, 2025  
**Business Affected:** BUS_1763633194048 (Kaloo Stores)  
**Severity:** CRITICAL - Business cannot be loaded by Dynamos Market  
**Cause:** Document overwrite instead of partial update

---

## ❌ The Problem

The business document in Firestore was **overwritten** instead of **updated**, losing all required fields:

### Current State (BROKEN):
```json
businesses/BUS_1763633194048/
{
  "id": "BUS_1763633194048",
  "online_store_enabled": true,
  "syncMetadata": { ... }
}
```

### Missing Fields:
- ❌ `name` - Required
- ❌ `email` - Required
- ❌ `phone` - Required  
- ❌ `address` - Required
- ❌ `status` - Required
- ❌ `admin_id` - Required
- ❌ `created_at` - Required

**Result:** BusinessModel.fromJson() fails because required fields are missing!

---

## ✅ IMMEDIATE FIX (Firebase Console - 2 minutes)

### Step 1: Get Full Business Data
1. Go to Firebase Console
2. Navigate to: `business_registrations/BUS_1763633194048`
3. Copy ALL the data (you'll need it)

### Step 2: Restore Business Document
1. Navigate to: `businesses/BUS_1763633194048`
2. Delete the current document (it's corrupted)
3. Create a new document with ID: `BUS_1763633194048`
4. Add these fields:

```json
{
  "id": "BUS_1763633194048",
  "name": "Kaloo Stores",
  "email": "kalubachakanga@gmail.com",
  "phone": "0973232553",
  "address": "54, Sable Rd, Kabulonga.",
  "status": "active",
  "admin_id": "ADMIN_1763633194048",
  "created_at": "2025-11-20T12:06:36.000000",
  "online_store_enabled": true
}
```

**Important:** Copy the exact values from `business_registrations`, don't make them up!

---

## 🔧 Code Fixes Applied

### Fix 1: Added `updateCloud()` Method
**File:** `lib/services/firedart_sync_service.dart`

New method that uses `.update()` instead of `.set()` to preserve existing fields:

```dart
Future<void> updateCloud(
  String collection,
  String documentId,
  Map<String, dynamic> fields, {
  bool isTopLevel = false,
}) async {
  // Uses Firestore update() to modify specific fields only
  await _firestore.collection(path).document(documentId).update(fields);
}
```

### Fix 2: Updated Business Settings Controller
**File:** `lib/controllers/business_settings_controller.dart`

Changed from `pushToCloud()` (overwrites) to `updateCloud()` (partial update):

```dart
// OLD (WRONG - overwrites entire document):
await syncService.pushToCloud('businesses', syncService.businessId!, {
  'online_store_enabled': value,
}, isTopLevel: true);

// NEW (CORRECT - updates only specific field):
await syncService.updateCloud(
  'businesses',
  syncService.businessId!,
  {'online_store_enabled': value},
  isTopLevel: true,
);
```

---

## 🧪 Verify the Fix Works

After restoring the business document:

### Test 1: Check Firestore
```
businesses/BUS_1763633194048/ should have:
✅ id
✅ name
✅ email
✅ phone
✅ address
✅ status
✅ admin_id
✅ created_at
✅ online_store_enabled
```

### Test 2: Check Dynamos Market Logs
```
I/flutter: ✅ Fetched 1 documents from businesses
I/flutter: ✅ Successfully converted 1 online businesses  ← Should be 1!
```

### Test 3: Toggle Online Store
1. Open POS app
2. Go to Settings → Business Settings
3. Toggle "Online Store" OFF
4. Check Firestore - all fields should still exist
5. Toggle "Online Store" ON
6. Check Firestore - only `online_store_enabled` should change

---

## 🛡️ Prevention

The code is now fixed to prevent this from happening again. All future toggles will use `updateCloud()` which preserves existing fields.

**What Changed:**
- ✅ New `updateCloud()` method for partial updates
- ✅ Business settings controller uses `updateCloud()`
- ✅ Business registration creates complete documents
- ✅ Future toggles won't corrupt documents

---

## 📋 Quick Summary

**Problem:** Used `.set()` which replaced entire document  
**Solution:** Use `.update()` which modifies specific fields  
**Status:** Code fixed ✅, document needs manual restore ⏳  
**Impact:** Kaloo Stores (and any business that toggled online store)  
**Time to Fix:** 2 minutes in Firebase Console

---

## 🆘 If You Can't Access Firebase Console

Run this query in your POS app (Developer Console):

```dart
// Restore business document from business_registrations
final syncService = Get.find<FiredartSyncService>();

// Get full data from business_registrations
final registrationData = await syncService.getDocument(
  'business_registrations',
  'BUS_1763633194048'
);

if (registrationData != null) {
  // Create complete business document
  final completeData = {
    'id': registrationData['id'],
    'name': registrationData['name'],
    'email': registrationData['email'],
    'phone': registrationData['phone'],
    'address': registrationData['address'],
    'status': registrationData['status'] ?? 'active',
    'admin_id': registrationData['admin_id'],
    'created_at': registrationData['created_at'],
    'online_store_enabled': true, // Set to true since they enabled it
  };
  
  // Replace corrupted document
  await syncService.pushToCloud(
    'businesses',
    'BUS_1763633194048',
    completeData,
    isTopLevel: true,
  );
  
  print('✅ Business document restored!');
}
```

---

**Priority:** 🔴 URGENT - Fix immediately to unblock Dynamos Market  
**Affected Users:** 1 confirmed (Kaloo Stores)  
**Estimated Impact:** Any business that toggled online store after initial fix
