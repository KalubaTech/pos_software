# 🧪 Online Store Feature - Testing Guide

## Quick Test Checklist

### ✅ Test 1: Database Persistence (5 minutes)

**What to Test**: Product `listedOnline` field saves and loads correctly

**Steps**:
1. Open POS app
2. Go to Products → Add Product or Edit existing product
3. Scroll to "Online Store" section
4. Toggle "List Online" to **ON**
5. Click "Save"
6. **Close the dialog**
7. **Reopen the same product** (click Edit)
8. ✅ **VERIFY**: Toggle should still show **ON**

**Expected Result**: 
- Toggle stays ON after reopening
- Console shows: `☁️ Product [name] synced`

**If it fails**:
- Check console for database errors
- Check database version (should be 3)
- Run: `flutter clean && flutter pub get`

---

### ✅ Test 2: Firestore Sync (5 minutes)

**What to Test**: Product data syncs to Firestore immediately

**Steps**:
1. Open Firebase Console in browser
2. Navigate to: Firestore Database
3. In POS app, edit a product
4. Toggle "List Online" to **ON**
5. Click "Save"
6. **Immediately check Firebase Console**
7. Navigate to: `businesses/default_business_001/products`
8. Click on your product document
9. ✅ **VERIFY**: `listedOnline: true` field exists

**Expected Result**:
```json
{
  "id": "product_123",
  "name": "Test Product",
  "price": 100.0,
  "listedOnline": true,  ← Should be true!
  "lastModified": "2025-11-20T10:30:00Z"
}
```

**If it fails**:
- Check internet connection
- Check console for sync errors
- Verify Firebase project ID in `firebase_options.dart`
- Check Firestore rules (should allow write)

---

### ✅ Test 3: Business Settings Sync (3 minutes)

**What to Test**: Online Store toggle syncs to Firestore

**Steps**:
1. Go to Settings → Business Settings
2. Scroll to "Online Store" section
3. Toggle "Enable Online Store" to **ON**
4. Open Firebase Console
5. Navigate to: `businesses/default_business_001/business_settings`
6. Click on document
7. ✅ **VERIFY**: `onlineStoreEnabled: true` field exists

**Expected Result**:
```json
{
  "storeName": "My Store",
  "taxEnabled": true,
  "onlineStoreEnabled": true,  ← Should be true!
  "onlineProductCount": 5,
  "lastUpdated": "2025-11-20T10:30:00Z"
}
```

---

### ✅ Test 4: Product Count Update (2 minutes)

**What to Test**: Online product count updates correctly

**Steps**:
1. Enable Online Store in settings
2. List 3 products online
3. Go back to Business Settings
4. ✅ **VERIFY**: Shows "3 products listed online"
5. Unlist 1 product
6. Go back to Business Settings
7. ✅ **VERIFY**: Shows "2 products listed online"

---

### ✅ Test 5: Offline Behavior (5 minutes)

**What to Test**: Changes queue when offline, sync when online

**Steps**:
1. **Disconnect internet** (turn off WiFi)
2. Edit a product
3. Toggle "List Online" to ON
4. Save product
5. Console should show: "Added to sync queue"
6. **Reconnect internet**
7. Wait 5-10 seconds
8. Check Firebase Console
9. ✅ **VERIFY**: Product updated in Firestore

---

### ✅ Test 6: Multi-Product Sync (3 minutes)

**What to Test**: Multiple products sync correctly

**Steps**:
1. Create 5 new products
2. List all 5 online
3. Check Firebase Console
4. ✅ **VERIFY**: All 5 products have `listedOnline: true`
5. Unlist 2 products
6. Refresh Firebase Console
7. ✅ **VERIFY**: 2 products now have `listedOnline: false`

---

## Console Output Reference

### ✅ Successful Product Sync:
```
☁️ Product Test Product synced
✅ Pushed products/product_abc123 to cloud
```

### ✅ Successful Business Settings Sync:
```
⚙️ Syncing business settings...
☁️ Business settings synced for: default_business_001
✅ Business settings sync complete
✅ Online store setting synced to cloud: true
```

### ❌ Error - No Internet:
```
⚠️ Offline - added to sync queue
📤 Queued operation: UPDATE products/product_123
```

### ✅ Queue Processing (when back online):
```
✅ Online
📤 Processing sync queue (3 items)
☁️ Product A synced
☁️ Product B synced
☁️ Product C synced
✅ Sync queue cleared
```

---

## Troubleshooting

### Problem: Toggle doesn't persist (shows OFF after reopening)

**Solution**:
1. Check database version: Should be 3
2. Run migration:
   ```bash
   flutter clean
   flutter pub get
   flutter run -d windows
   ```
3. Database will auto-migrate on first run
4. Check console for: `ALTER TABLE products ADD COLUMN listedOnline`

---

### Problem: Not syncing to Firestore

**Check**:
1. Internet connection (green cloud icon in AppBar)
2. Firebase project ID correct
3. Firestore rules allow write:
   ```javascript
   allow read, write: if true; // For development
   ```
4. Console shows sync messages

**Fix**:
1. Open Firebase Console
2. Go to Firestore → Rules
3. Update rules to allow write
4. Publish changes

---

### Problem: Console shows "Business ID not set"

**Solution**:
```dart
// In main.dart, verify:
await syncController.initialize('default_business_001');
```

---

### Problem: Products show in Firestore but not in app

**Solution**:
1. Check real-time listener is active
2. Console should show: `👂 Listening to cloud products`
3. If not, restart app
4. Check for errors in console

---

## Firebase Console Navigation

### To View Products:
1. Open Firebase Console
2. Select your project
3. Click "Firestore Database" in left menu
4. Navigate to: `businesses` → `default_business_001` → `products`
5. Click any product to see fields

### To View Business Settings:
1. Navigate to: `businesses` → `default_business_001` → `business_settings`
2. Click document ID (same as business ID)
3. View all settings including `onlineStoreEnabled`

---

## Performance Benchmarks

### Expected Sync Times:
- **Product Update**: < 2 seconds
- **Business Settings**: < 1 second
- **Initial Sync (10 products)**: < 5 seconds
- **Initial Sync (100 products)**: < 30 seconds

### Network Usage:
- **Product Update**: ~1-2 KB
- **Business Settings**: ~2-3 KB
- **Initial Sync (10 products)**: ~10-15 KB

---

## Next Steps After Testing

### If All Tests Pass ✅:
1. **Done!** Online store feature working perfectly
2. Ready for production use
3. Can start building Dynamos Market customer app

### If Tests Fail ❌:
1. Check console output for specific errors
2. Verify Firebase configuration
3. Check internet connection
4. Review this guide's troubleshooting section
5. Check `ONLINE_STORE_FIRESTORE_SYNC.md` for technical details

---

## Support

**Documentation**:
- `ONLINE_STORE_FIRESTORE_SYNC.md` - Technical implementation
- `ONLINE_STORE_FEATURE.md` - Feature overview
- `DYNAMOS_MARKET_SETUP_GUIDE.md` - Customer app setup

**Console Commands**:
```bash
# Clean build
flutter clean

# Reinstall dependencies
flutter pub get

# Run app with verbose logging
flutter run -d windows -v

# Check Flutter doctor
flutter doctor
```

---

## 🎯 Success Criteria

Your online store feature is working correctly if:

1. ✅ Toggle "List Online" and it stays ON after reopening
2. ✅ Product appears in Firebase Console with `listedOnline: true`
3. ✅ Console shows sync messages
4. ✅ Product count updates in Business Settings
5. ✅ Business settings sync to Firestore
6. ✅ Works offline (queues sync operations)
7. ✅ No errors in console

**When all 7 criteria pass → Feature is production-ready!** 🚀
