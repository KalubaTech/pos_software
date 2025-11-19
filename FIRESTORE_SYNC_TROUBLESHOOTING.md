# 🔥 Firestore Sync Troubleshooting Guide

## 🚨 Current Issues Identified

### Issue 1: PERMISSION_DENIED Error ⚠️

**Error Message:**
```
❌ Failed to push to cloud: gRPC Error (code: 7, codeName: PERMISSION_DENIED, 
message: Missing or insufficient permissions.
```

**Cause:** Firestore security rules are blocking write operations.

**Solution:** Update Firestore security rules to allow access.

---

## ✅ Step-by-Step Fix

### Step 1: Open Firebase Console

1. Go to: **https://console.firebase.google.com/project/dynamos-pos**
2. Click on **"Firestore Database"** in the left sidebar
3. Click on the **"Rules"** tab at the top

### Step 2: Update Security Rules

**Current Rules (Blocking):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false; // ❌ BLOCKS ALL ACCESS
    }
  }
}
```

**Updated Rules (Development Mode):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Open access for development
    match /{document=**} {
      allow read, write: if true; // ✅ ALLOWS ALL ACCESS
    }
  }
}
```

### Step 3: Publish Rules

1. Copy the updated rules above
2. Paste into the Firestore Rules editor
3. Click **"Publish"** button
4. Wait **1-2 minutes** for rules to propagate globally

### Step 4: Test Sync

1. Close your app completely
2. Restart the app
3. Try adding a new product
4. Check console for success messages:
   ```
   ☁️ Product TestProduct synced to cloud
   ```
5. Go to Firestore Database and verify data appears

---

## 🔒 Production-Ready Rules (For Later)

Once you implement authentication, use these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Business data - scoped by businessId
    match /businesses/{businessId}/{collection}/{document} {
      // Allow authenticated users to access their business data
      allow read, write: if request.auth != null 
                          && request.auth.token.businessId == businessId;
    }
    
    // Alternative: Allow any authenticated user (less secure)
    match /businesses/{businessId}/{collection}/{document} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 📊 Verifying Data in Firestore

### Step 1: Open Firestore Database

1. Go to: https://console.firebase.google.com/project/dynamos-pos/firestore/data
2. You should see the following structure:

```
📁 businesses/
  📁 default_business_001/
    📁 products/
      📄 1763372316727
        - id: "1763372316727"
        - name: "Product Name"
        - price: 10.0
        - stock: 100
        - category: "Beverages"
        - syncMetadata
          - lastModified: "2025-11-17T..."
          - modifiedBy: "windows_YOUR-PC_..."
          - deviceId: "windows_YOUR-PC_..."
          
    📁 customers/
      📄 c1763376719924
        - id: "c1763376719924"
        - name: "Customer Name"
        - email: "email@example.com"
        - phoneNumber: "1234567890"
        - syncMetadata
          
    📁 transactions/
      📄 [transaction-id]
        - id: "..."
        - items: [...]
        - total: 100.0
```

### Step 2: Check Sync Metadata

Every synced document should have a `syncMetadata` field:
- `lastModified`: Timestamp of last change
- `modifiedBy`: Device ID that made the change
- `deviceId`: Unique device identifier

---

## 🐛 Common Errors & Solutions

### Error 1: "PERMISSION_DENIED"

**Cause:** Firestore rules blocking access

**Fix:**
1. Update rules to allow access (see Step 2 above)
2. Publish rules
3. Wait 1-2 minutes
4. Restart app

### Error 2: "type 'String' is not a subtype of type 'List<dynamic>'"

**Cause:** Data type mismatch when syncing templates

**Status:** Currently being investigated

**Workaround:** Templates may not sync immediately but products and customers should work

### Error 3: "Offline queue building up"

**Cause:** No internet connection OR permission denied

**Fix:**
1. Check internet connection
2. Verify Firestore rules are published
3. Check console for specific error messages

### Error 4: "Data not appearing in Firestore"

**Possible Causes:**
1. Rules not published yet (wait 2 minutes)
2. App not connected to internet
3. Wrong project ID in code
4. Data queued in offline queue

**Fix:**
1. Check `FiredartSyncService` is initialized:
   ```
   ✅ Firedart sync service initialized
   🏢 Sync initialized for business: default_business_001
   ```
2. Check for "Pushed X items to cloud" messages
3. Verify Project ID matches: `dynamos-pos`

---

## 🔍 Debugging Checklist

Run through this checklist if sync isn't working:

### App Side:
- [ ] Console shows: "🔥 Using Firedart for cloud sync"
- [ ] Console shows: "✅ Firedart sync service initialized"
- [ ] Console shows: "🏢 Sync initialized for business: default_business_001"
- [ ] Console shows: "🌍 Universal sync controller initialized"
- [ ] No "PERMISSION_DENIED" errors
- [ ] Internet connection active
- [ ] Products added successfully (visible in app)

### Firebase Side:
- [ ] Correct project selected: **dynamos-pos**
- [ ] Firestore Database enabled
- [ ] Security rules allow read/write
- [ ] Rules published (not in draft)
- [ ] No usage quota exceeded

### Data Verification:
- [ ] Open Firestore Database tab
- [ ] Navigate to: `businesses/default_business_001/products`
- [ ] At least 1 document visible
- [ ] Document has all expected fields
- [ ] `syncMetadata` field present

---

## 📝 Console Output Interpretation

### ✅ Successful Sync:
```
📦 Syncing products...
📱 Local products: 1
☁️ Pushed 1 products to cloud
✅ Full sync completed!
```

### ❌ Failed Sync (Permission Denied):
```
📦 Syncing products...
📱 Local products: 1
❌ Failed to push to cloud: PERMISSION_DENIED
📝 Added to offline queue: create products/123
☁️ Pushed 1 products to cloud  ⚠️ (Actually queued, not pushed)
```

### 🔄 Offline Queue Working:
```
📝 Added to offline queue: create products/123
⚠️ Offline - queuing operation
🔄 Will retry when online
```

---

## 🧪 Test Procedure

### Test 1: Add Product

1. Open app
2. Go to Inventory
3. Click "Add Product"
4. Fill details:
   - Name: "Test Sync Product"
   - Price: 99.99
   - Stock: 50
5. Save
6. Check console for: `☁️ Product Test Sync Product synced`
7. Open Firestore Console
8. Navigate to: `businesses/default_business_001/products`
9. Verify new document appears

### Test 2: Add Customer

1. Go to Customers
2. Click "Add Customer"
3. Fill details:
   - Name: "Test Customer"
   - Email: "test@example.com"
   - Phone: "1234567890"
4. Save
5. Check console for: `☁️ Customer Test Customer synced`
6. Open Firestore Console
7. Navigate to: `businesses/default_business_001/customers`
8. Verify new document appears

### Test 3: Real-time Sync (If you have Android/another device)

1. Add product on Windows
2. Open Android app
3. Product should appear automatically (within 1-2 seconds)
4. Edit product on Android
5. Changes appear on Windows

---

## 🚀 Quick Fix Summary

**If Firestore is empty and you see PERMISSION_DENIED:**

1. **Go to:** https://console.firebase.google.com/project/dynamos-pos/firestore/rules

2. **Paste this:**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true;
       }
     }
   }
   ```

3. **Click:** Publish

4. **Wait:** 2 minutes

5. **Restart:** Your app

6. **Test:** Add a product

7. **Verify:** Check Firestore Database tab

---

## 📞 Still Not Working?

### Check These:

1. **Firebase Project ID:**
   - Code uses: `dynamos-pos`
   - Verify in: `lib/services/firedart_sync_service.dart`
   - Line: `Firestore.initialize('dynamos-pos');`

2. **Internet Connection:**
   - Firestore requires internet
   - Check WiFi/Ethernet
   - Try opening https://firebase.google.com

3. **Firestore Enabled:**
   - Go to: https://console.firebase.google.com/project/dynamos-pos/firestore
   - Should show database, not "Get Started"
   - If "Get Started" shows, Firestore not enabled

4. **Business ID:**
   - Default: `default_business_001`
   - Check in: `lib/main.dart`
   - Look for: `final businessId = GetStorage().read('business_id')`

---

## 🎯 Expected Behavior After Fix

### On App Startup:
```
🔥 Using Firedart for cloud sync
✅ Firedart sync service initialized
🏢 Sync initialized for business: default_business_001
🌍 Universal sync controller initialized
👂 Listening to cloud products
👂 Listening to cloud transactions
👂 Listening to cloud customers
🔄 Starting full sync...
📦 Syncing products...
📱 Local products: 5
☁️ Pushed 5 products to cloud
✅ Full sync completed!
```

### When Adding Product:
```
☁️ Product Test Product synced to cloud
```

### When Another Device Adds Product:
```
📥 Received 6 products from cloud
➕ Added new product from cloud: Remote Product
```

---

## ✅ Success Indicators

You'll know sync is working when:

1. ✅ No "PERMISSION_DENIED" errors in console
2. ✅ Console shows "☁️ Pushed X items to cloud"
3. ✅ Firestore Database shows documents
4. ✅ Adding product shows in Firestore within 1-2 seconds
5. ✅ Changes on one device appear on another device

---

## 📚 Additional Resources

- **Firebase Console:** https://console.firebase.google.com/project/dynamos-pos
- **Firestore Documentation:** https://firebase.google.com/docs/firestore
- **Security Rules Guide:** https://firebase.google.com/docs/firestore/security/get-started
- **Firedart Package:** https://pub.dev/packages/firedart

---

**Last Updated:** November 17, 2025  
**App Version:** 1.0.1  
**Sync System:** Firedart (Pure Dart)
