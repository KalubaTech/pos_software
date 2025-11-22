# 🌐 Dynamos Market Agent - Online Business & Product Management Guide

## 📋 Overview

This guide provides step-by-step instructions for Dynamos Market agents on how to verify, configure, and manage online business features and products within the Dynamos POS system.

**Document Version**: 1.0  
**Last Updated**: November 20, 2025  
**Target Audience**: Dynamos Market Support Agents

---

## 🎯 What's New: Online Store Features

### Summary of Changes

The Dynamos POS system now includes **Online Store integration** that allows businesses to:

1. ✅ Enable/disable their online presence with a single toggle
2. ✅ Choose which products to list on the online marketplace
3. ✅ Track the number of products available online in real-time
4. ✅ Sync online store settings across all devices
5. ✅ Manage online visibility at the individual product level

### Key Components

- **Business Settings → Online Store Section**: Master toggle to enable/disable online presence
- **Product Dialog → List Online Toggle**: Per-product control for online visibility
- **Real-time Sync**: All settings sync to Firestore for multi-device consistency

---

## 📖 Agent Instructions

### Part 1: Verify Business Registration & Settings

#### Step 1: Confirm Business is Registered

**What to Check**:
```
1. Business exists in Firestore:
   - Collection: businesses/{BUSINESS_ID}/
   - Document should contain:
     ├─ id: "BUS_XXXXX"
     ├─ name: "[Business Name]"
     ├─ email: "[Business Email]"
     ├─ status: "active"
     └─ created_at: "[Timestamp]"

2. Business settings exist:
   - Collection: businesses/{BUSINESS_ID}/business_settings/
   - Document ID: "default"
   - Should contain: storeName, storeAddress, storePhone, etc.
```

**Verification Steps**:

1. Open **Firebase Console** → Firestore Database
2. Navigate to `businesses` collection
3. Find business by ID (format: `BUS_` followed by timestamp)
4. Verify:
   - ✅ Business document exists
   - ✅ Status is "active"
   - ✅ Business name matches registration
5. Check sub-collection: `business_settings/default`
6. Verify settings document contains correct business information

**Expected Console Output** (from POS app):
```
🔄 Loading business settings from Firestore...
✅ Found settings in Firestore
✅ Business settings loaded from Firestore and synced to local storage
```

**If Business Missing**:
- Business may only exist in `business_registrations` (pending approval)
- Check: `business_registrations/{BUSINESS_ID}/`
- Solution: Re-register business (new registration creates in both collections)

---

#### Step 2: Verify Business Settings Load Correctly

**What Merchant Should See**:

1. Open POS Application
2. Navigate: **Settings** → **Business** tab
3. Check "Store Information" section displays:
   - ✅ Correct store name (not "My Store")
   - ✅ Correct address
   - ✅ Correct phone number
   - ✅ Correct email

**If Showing Default Values**:

**Problem**: Settings showing "My Store" instead of registered business name

**Solution**:
1. Check Firestore has settings (see Step 1)
2. Restart the POS application
3. Monitor console for:
   ```
   🔄 Loading business settings from Firestore...
   ✅ Found settings in Firestore
   ```
4. If still showing defaults, clear local storage and re-login

**Technical Note**: 
- Settings controller loads from Firestore on initialization
- Fallback to GetStorage if Firestore unavailable
- Background sync ensures consistency

---

### Part 2: Enable Online Store

#### Step 3: Navigate to Online Store Settings

**Instructions for Merchant**:

1. Open **Dynamos POS** application
2. Click **Settings** in the left sidebar
3. Select **Business** tab at the top
4. Scroll down to **"Online Store"** section (near the bottom)

**Visual Indicators**:
- 🌐 Globe icon with "Online Store" heading
- Toggle switch labeled "Enable Online Store"
- Status badge (Orange = Disabled, Green = Enabled)

---

#### Step 4: Enable Online Store Toggle

**Before Enabling** (Default State):
```
┌─────────────────────────────────────────────┐
│ 🌐 Online Store                             │
│                                             │
│ [Toggle OFF] Enable Online Store            │
│ Activate to make products available online  │
│                                             │
│ Status: Disabled (Orange badge)             │
└─────────────────────────────────────────────┘
```

**How to Enable**:

1. Click the **toggle switch** to turn it ON
2. Watch for confirmation snackbar:
   ```
   ✅ Online Store Enabled
   Your products can now be listed online
   ```
3. Verify toggle turns GREEN

**After Enabling** (Active State):
```
┌─────────────────────────────────────────────┐
│ 🌐 Online Store                             │
│                                             │
│ [Toggle ON] Enable Online Store             │
│ Your store is online. Customers can browse │
│ and order products.                         │
│                                             │
│ Status: Active (Green badge)                │
│                                             │
│ ℹ️ Online Store Active                      │
│ You can now manage which products appear    │
│ online in the Products section. Look for    │
│ the "List Online" toggle on each product.  │
│                                             │
│ Statistics:                                 │
│ ┌─────────────────┬─────────────────┐       │
│ │ Products Online │ Store Status    │       │
│ │      0         │     Active      │       │
│ └─────────────────┴─────────────────┘       │
└─────────────────────────────────────────────┘
```

**Console Output** (Technical Verification):
```
✅ Online store setting synced to cloud: true
```

**Firestore Update**:
```
businesses/{BUSINESS_ID}/business_settings/default
├─ onlineStoreEnabled: true
└─ lastUpdated: "2025-11-20T..."
```

---

#### Step 5: Verify Sync Across Devices

**Multi-Device Test**:

1. **Device A**: Enable online store
2. **Device B**: Restart POS app and login
3. **Verify**: Device B shows online store enabled
4. **Confirm**: Real-time sync working

**Expected Behavior**:
- Settings sync to Firestore immediately
- Other devices pull settings on startup
- Real-time listener updates if devices online simultaneously

**Troubleshooting**:
- If not syncing: Check internet connection
- Monitor console for: `☁️ Business settings synced to cloud`
- Verify Firestore rules allow read/write

---

### Part 3: List Products Online

#### Step 6: Navigate to Products Section

**Instructions for Merchant**:

1. From main dashboard, click **"Products"** in left sidebar
2. Choose one of these actions:
   - **Add New Product**: Click "+ New Product" button
   - **Edit Existing Product**: Click pencil icon on any product card

---

#### Step 7: Understanding the "List Online" Toggle

**Location in Product Dialog**:
```
Add/Edit Product Dialog
├─ Step 1: Basic Information
│   ├─ Product Name
│   ├─ Category
│   ├─ Price
│   ├─ Description
│   └─ Image
│
├─ Step 2: Inventory & Pricing
│   ├─ Track Inventory (Toggle)
│   ├─ [LIST ONLINE TOGGLE] ⭐ HERE!
│   ├─ Initial Stock
│   └─ Minimum Stock Level
│
└─ Step 3: Variants (Optional)
```

**Toggle States**:

**State 1: Online Store Disabled** (Locked)
```
┌─────────────────────────────────────────────┐
│ 🔒 List on Online Store                     │
│ Enable online store in Business Settings    │
│ first                                       │
│                                             │
│ [TOGGLE DISABLED - GREYED OUT]              │
└─────────────────────────────────────────────┘
```
**Action**: Merchant must enable online store first (see Step 4)

---

**State 2: Online Store Enabled** (Available)
```
┌─────────────────────────────────────────────┐
│ 🌍 List on Online Store                     │
│ Make this product available in your online  │
│ store                                       │
│                                             │
│ [TOGGLE AVAILABLE - CAN TURN ON/OFF]        │
└─────────────────────────────────────────────┘
```
**Action**: Merchant can now toggle individual products

---

#### Step 8: List a Product Online

**How to List Product**:

1. Open product dialog (add or edit)
2. Scroll to **"Inventory & Pricing"** section
3. Find **"List on Online Store"** toggle
4. **Turn toggle ON** (switch to right, turns green)
5. Complete product information
6. Click **"Save Product"** or **"Add Product"**

**Visual Confirmation**:
```
┌─────────────────────────────────────────────┐
│ ✅ List on Online Store                     │
│ Make this product available in your online  │
│ store                                       │
│                                             │
│ [TOGGLE ON - GREEN]                         │
└─────────────────────────────────────────────┘
```

**Console Output**:
```
✅ Product saved: [Product Name]
📤 Preparing to push: [Product Name]
   - Product ID: PROD_XXXXX
   - Listed Online: true
☁️ Product synced to cloud
```

**Firestore Update**:
```
businesses/{BUSINESS_ID}/products/{PRODUCT_ID}
├─ name: "Product Name"
├─ price: 100.00
├─ listedOnline: true ⭐
└─ ... other fields
```

---

#### Step 9: Verify Online Product Count Updates

**What Happens Automatically**:

1. When product with `listedOnline: true` is saved
2. ProductController updates online product count
3. BusinessSettingsController receives update
4. Statistics update in Online Store settings section

**Where to Check**:

Navigate back to: **Settings** → **Business** → **Online Store** section

**Updated Display**:
```
Statistics:
┌─────────────────┬─────────────────┐
│ Products Online │ Store Status    │
│      1         │     Active      │  ⬅️ Count increased!
└─────────────────┴─────────────────┘
```

**Console Output**:
```
⚠️ ProductController: Could not update online product count
```
*Note: This warning is normal if controller not initialized yet*

---

### Part 4: Managing Online Products

#### Step 10: View All Online Products

**Current Implementation**:
- Products marked as `listedOnline: true` are synced to Firestore
- No dedicated "Online Products" view yet (future enhancement)
- Agents can verify in Firestore Console

**Firestore Query** (for agents):
```javascript
// Firebase Console → Firestore → Query
businesses/{BUSINESS_ID}/products
WHERE listedOnline == true
```

**Expected Results**:
- List of all products with online visibility enabled
- Each product shows full details (name, price, description, stock, etc.)

---

#### Step 11: Remove Product from Online Store

**How to Un-list a Product**:

1. Go to **Products** section
2. Click **pencil icon** on the product to edit
3. Find **"List on Online Store"** toggle
4. **Turn toggle OFF** (switch to left, turns grey)
5. Click **"Save Product"**

**Result**:
```
listedOnline: false
```

**Online Product Count**: Automatically decreases by 1

**Console Output**:
```
✅ Product updated: [Product Name]
☁️ Product synced to cloud
   - Listed Online: false
```

---

#### Step 12: Disable Online Store Completely

**When to Disable**:
- Merchant wants to temporarily close online presence
- Maintenance or inventory update
- Testing purposes

**How to Disable**:

1. Navigate: **Settings** → **Business** → **Online Store**
2. Click toggle to turn OFF
3. Confirm with snackbar:
   ```
   ⚠️ Online Store Disabled
   Online store has been disabled
   ```

**Effect on Products**:
- ✅ Products retain their `listedOnline: true/false` status
- ✅ Settings saved, ready to re-enable later
- ❌ Products NOT visible to customers (online store inactive)
- ✅ "List Online" toggle in product dialog becomes locked (greyed out)

**Console Output**:
```
✅ Online store setting synced to cloud: false
```

---

## 🔍 Verification Checklist

### For Agents to Complete with Merchant

**Business Setup** ✅
```
☐ Business registered and active in Firestore
☐ Business settings load correctly (not showing defaults)
☐ Business name, address, phone, email all correct
☐ Sync service initialized with correct business ID
```

**Online Store Configuration** ✅
```
☐ Online Store toggle visible in Business Settings
☐ Toggle can be turned ON successfully
☐ Snackbar confirmation appears
☐ Online Store statistics section appears when enabled
☐ "Products Online" count shows 0 initially
☐ "Store Status" shows "Active" with green indicator
```

**Product Online Listing** ✅
```
☐ "List Online" toggle visible in product dialog
☐ Toggle is LOCKED when online store disabled
☐ Toggle becomes AVAILABLE when online store enabled
☐ Can successfully list a product online
☐ Product syncs to Firestore with listedOnline: true
☐ Online product count increases after listing product
```

**Multi-Device Sync** ✅
```
☐ Online store settings sync across devices
☐ Product online status syncs across devices
☐ Console shows successful sync messages
☐ Firestore reflects current state
```

---

## 🐛 Troubleshooting Guide

### Issue 1: Online Store Toggle Not Visible

**Symptoms**:
- Business Settings page loads but no "Online Store" section

**Possible Causes**:
1. Old app version (update required)
2. Controller not initialized
3. UI not scrolled to bottom

**Solution**:
1. Verify app version (should be latest)
2. Scroll to bottom of Business Settings page
3. Restart app if needed
4. Check console for errors

---

### Issue 2: "List Online" Toggle Always Locked

**Symptoms**:
- Product dialog shows toggle but it's greyed out
- Message says "Enable online store in Business Settings first"

**Cause**:
- Online Store not enabled in Business Settings

**Solution**:
1. Navigate to Settings → Business → Online Store
2. Enable online store toggle (see Step 4)
3. Return to product dialog
4. Toggle should now be available

---

### Issue 3: Online Product Count Shows 0

**Symptoms**:
- Products marked as online
- Count still shows 0 in statistics

**Possible Causes**:
1. ProductController not initialized yet
2. Products not saved properly
3. Sync delay

**Solution**:
1. Restart the app
2. Verify products in Firestore:
   ```
   businesses/{BUSINESS_ID}/products
   Check: listedOnline: true
   ```
3. Re-save a product with online toggle ON
4. Check console:
   ```
   ✅ Product synced to cloud
   ```

---

### Issue 4: Settings Not Syncing Across Devices

**Symptoms**:
- Enable online store on Device A
- Device B doesn't show it enabled

**Possible Causes**:
1. No internet connection
2. Firestore rules blocking sync
3. Different business IDs (logged into different businesses)

**Solution**:
1. Verify internet connection (check cloud icon in app)
2. Check console on both devices:
   ```
   Device A: ✅ Online store setting synced to cloud: true
   Device B: 🔄 Loading business settings from Firestore...
            ✅ Found settings in Firestore
   ```
3. Verify both devices logged into same business:
   ```
   Check Settings → Business → Store Name
   ```
4. Restart Device B and re-login
5. Check Firestore directly for `onlineStoreEnabled` field

---

### Issue 5: Product Doesn't Appear in Firestore

**Symptoms**:
- Product saved successfully in app
- Not showing in Firestore Console

**Possible Causes**:
1. Offline mode (queued for sync)
2. Sync error
3. Wrong collection path

**Solution**:
1. Check internet connection
2. Look for console error:
   ```
   ❌ Error syncing products: [error details]
   ```
3. Verify Firestore path:
   ```
   businesses/{BUSINESS_ID}/products/{PRODUCT_ID}
   NOT: businesses/products/{PRODUCT_ID}
   ```
4. Check offline queue:
   ```
   🔄 Device online, processing queue...
   ```
5. Force sync (if available):
   ```dart
   final syncController = Get.find<UniversalSyncController>();
   await syncController.performFullSync();
   ```

---

## 📊 Firestore Data Structure Reference

### For Agent Verification

**Complete Structure**:
```
firestore/
├── businesses/
│   └── {BUSINESS_ID}/                         ← Business document
│       ├── id: "BUS_1763630850073"
│       ├── name: "Kaloo Technologies"
│       ├── email: "business@example.com"
│       ├── status: "active"
│       ├── created_at: "2025-11-20T..."
│       │
│       ├── business_settings/                 ← Settings sub-collection
│       │   └── default/                       ← Settings document
│       │       ├── storeName: "Kaloo Technologies"
│       │       ├── storeAddress: "45hjd, Lusaka"
│       │       ├── storePhone: "0973232553"
│       │       ├── storeEmail: "kaluba@gmail.com"
│       │       ├── currency: "ZMW"
│       │       ├── taxEnabled: false
│       │       ├── onlineStoreEnabled: true  ⭐ Key field!
│       │       ├── onlineProductCount: 5     ⭐ Auto-updated
│       │       └── lastUpdated: "2025-11-20T..."
│       │
│       ├── products/                          ← Products sub-collection
│       │   ├── PROD_1234567890/               ← Product document
│       │   │   ├── id: "PROD_1234567890"
│       │   │   ├── name: "Coca Cola 500ml"
│       │   │   ├── price: 10.00
│       │   │   ├── category: "Beverages"
│       │   │   ├── stock: 100
│       │   │   ├── listedOnline: true        ⭐ Product visibility!
│       │   │   └── ... other fields
│       │   │
│       │   └── PROD_9876543210/
│       │       ├── id: "PROD_9876543210"
│       │       ├── name: "Bread"
│       │       ├── price: 15.00
│       │       ├── listedOnline: false       ⭐ Not listed online
│       │       └── ...
│       │
│       ├── customers/                         ← Other sub-collections
│       ├── transactions/
│       └── cashiers/
│
└── business_registrations/                    ← Registration records
    └── {BUSINESS_ID}/
        └── ... registration data
```

---

## 📝 Agent Scripts

### Script 1: Initial Online Store Setup

**Use When**: First-time setup for merchant wanting online presence

```
"Let me help you set up your online store. I'll guide you through 
enabling the feature and listing your first product.

Step 1: Enable Online Store
1. Open Dynamos POS
2. Go to Settings → Business tab
3. Scroll to 'Online Store' section
4. Turn ON the toggle
5. You should see 'Online Store Enabled' message

Step 2: List Your First Product
1. Go to Products section
2. Click on a product to edit (or add new one)
3. Find 'List on Online Store' toggle
4. Turn it ON (green checkmark)
5. Save the product

Step 3: Verify
1. Return to Settings → Business → Online Store
2. Check 'Products Online' count - should show 1
3. Your product is now visible in the Dynamos marketplace!

Would you like to list more products online?"
```

---

### Script 2: Troubleshooting Not Syncing

**Use When**: Merchant reports settings not syncing

```
"I understand the settings aren't syncing. Let's verify a few things:

1. First, check your internet connection
   - Look for the cloud icon in the top right
   - Should be green/blue (not grey)

2. Let me check your business registration
   - What's your business name showing in Settings?
   - Is it '[Registered Name]' or 'My Store'?

3. If showing 'My Store':
   - Please restart the application
   - Log in again
   - Settings should load from cloud
   - Check if correct name appears now

4. If still not syncing:
   - I'll verify your Firestore data
   - May need to clear local cache
   - Contact technical support if needed

Can you check the cloud icon status for me?"
```

---

### Script 3: Explaining Product Online Status

**Use When**: Merchant asks why some products don't show online

```
"Great question! Here's how product visibility works:

For a product to appear in the online marketplace:

1. ✅ Online Store must be ENABLED
   (Settings → Business → Online Store toggle ON)

2. ✅ Individual product must be marked 'List Online'
   (Edit product → Turn on 'List Online' toggle)

3. ✅ Product must have valid information
   (Name, price, image, stock if tracking)

If your online store is enabled but product not showing:
- Edit the product
- Look for 'List on Online Store' toggle
- Make sure it's turned ON (green)
- Save the product

The system gives you control over WHICH products appear online.
You can sell some items in-store only if you prefer.

Would you like me to help you list specific products?"
```

---

## 🎓 Training Resources

### For New Agents

**Required Knowledge**:
1. Basic understanding of Dynamos POS navigation
2. Firestore Console access and navigation
3. Reading console logs for troubleshooting
4. Business registration process

**Recommended Training Flow**:
1. Complete standard POS training (1-2 days)
2. Review this guide (30 minutes)
3. Shadow experienced agent handling online store setup (2-3 calls)
4. Practice setup in test environment (1 hour)
5. Handle supervised calls (2-3 calls)
6. Independent support (with escalation path)

**Test Environment Setup**:
```
1. Create test business: "Agent Training Store"
2. Enable online store
3. Add 5 test products
4. List 3 products online
5. Verify count shows 3
6. Un-list 1 product
7. Verify count shows 2
8. Disable online store
9. Verify products can't be listed
10. Re-enable and verify functionality restored
```

---

## 📞 Escalation Criteria

### When to Escalate to Technical Support

**Escalate if**:
1. ❌ Firestore data missing or corrupted
2. ❌ Sync completely broken (console shows errors)
3. ❌ Multiple merchants reporting same issue (potential bug)
4. ❌ Settings not loading after multiple restarts
5. ❌ Products syncing but count not updating after 24 hours
6. ❌ Online store toggle not visible in latest app version

**Don't Escalate if**:
1. ✅ Merchant forgot to enable online store (guide them)
2. ✅ Product toggle locked (remind to enable online store first)
3. ✅ Count shows 0 (check if products actually marked online)
4. ✅ Settings showing defaults (restart app, re-login)
5. ✅ Merchant confusion about feature (provide education)

**Escalation Template**:
```
Subject: Online Store Issue - [Business Name] - [BUSINESS_ID]

Business Details:
- Business ID: BUS_XXXXX
- Business Name: [Name]
- Contact: [Email/Phone]

Issue Description:
[Detailed description of problem]

Troubleshooting Steps Completed:
☐ Verified internet connection
☐ Checked Firestore data structure
☐ Reviewed console logs
☐ Restarted application
☐ Cleared cache and re-logged in
☐ [Other steps taken]

Console Errors (if any):
[Paste relevant error messages]

Firestore Status:
- Business exists: Yes/No
- Settings exist: Yes/No
- onlineStoreEnabled: true/false
- Products with listedOnline=true: [count]

Screenshots/Logs:
[Attach relevant files]

Priority: Low/Medium/High
```

---

## 🔄 Version History & Updates

### Version 1.0 (November 20, 2025)
- Initial release
- Online store toggle feature documentation
- Product listing online feature documentation
- Sync behavior documentation
- Troubleshooting guide
- Agent scripts and training materials

### Future Enhancements (Planned)

**Coming Soon**:
1. **Dedicated Online Products View**: Filter to show only online products
2. **Bulk Online Listing**: Select multiple products to list online at once
3. **Online Store Analytics**: Views, clicks, orders from online marketplace
4. **Product Categories for Online**: Choose which categories appear online
5. **Visibility Scheduling**: Schedule products to go online/offline automatically
6. **Online Pricing**: Different pricing for online vs in-store
7. **Inventory Sync Rules**: Auto-remove from online when out of stock

**Notify Agents When Released**:
- Updated documentation will be provided
- Training sessions for new features
- Update agent scripts accordingly

---

## 📚 Quick Reference

### Key File Locations (for technical support)

```
lib/controllers/business_settings_controller.dart
├─ onlineStoreEnabled (observable)
├─ onlineProductCount (observable)
├─ toggleOnlineStore() (method)
└─ loadFromFirestore() (sync method)

lib/models/product_model.dart
├─ listedOnline (boolean field)
└─ fromJson/toJson (serialization)

lib/views/settings/business_settings_view.dart
├─ _buildOnlineStoreSettings() (UI section)
└─ Online store toggle and statistics

lib/components/dialogs/add_product_dialog.dart
├─ _buildListOnlineToggle() (product toggle)
└─ _listOnline (state variable)

lib/controllers/universal_sync_controller.dart
├─ _syncBusinessSettings() (sync method)
└─ Bidirectional sync with Firestore
```

### Console Commands (for debugging)

```dart
// Check online store status
final settings = Get.find<BusinessSettingsController>();
print('Online Store: ${settings.onlineStoreEnabled.value}');
print('Products Online: ${settings.onlineProductCount.value}');

// Force sync
final sync = Get.find<UniversalSyncController>();
await sync.performFullSync();

// Check specific product
final products = Get.find<ProductController>();
final onlineProducts = products.products.where((p) => p.listedOnline);
print('Online Products: ${onlineProducts.length}');
```

---

## ✅ Summary

This guide covers:
- ✅ Complete online store setup process
- ✅ Product listing management
- ✅ Verification steps for agents
- ✅ Troubleshooting common issues
- ✅ Firestore data structure reference
- ✅ Agent scripts for customer support
- ✅ Training materials and escalation criteria

**Key Takeaways for Agents**:
1. Online store must be **enabled first** in Business Settings
2. Individual products are **opt-in** for online visibility
3. **Count updates automatically** when products are listed/unlisted
4. Settings **sync to Firestore** for multi-device consistency
5. **Console logs** are your friend for troubleshooting

**For Questions or Updates**:
Contact Technical Support Team  
Email: support@dynamospos.com  
Internal Slack: #dynamos-pos-support

---

**Document End** - Version 1.0 - November 20, 2025
