# 🚀 Sync Update - Quick Guide

## What's New

Three new data types now sync automatically across all your devices:

### 💰 Wallets
Your business wallet balance and status sync in real-time.

### 👑 Subscriptions  
Your active subscription plan stays updated everywhere.

### ⚙️ Business Settings
All your store settings (name, address, tax, receipts, etc.) sync automatically.

---

## How It Works

### Automatic Sync ✨

Everything syncs automatically:

1. **Make a change** on any device
2. **Change syncs** to cloud instantly
3. **Other devices update** automatically

No manual intervention needed!

### What Syncs

**Wallet:**
- Balance
- Status (active/suspended)
- Currency
- Business info

**Subscription:**
- Current plan
- Expiry date
- Payment status
- Transaction details

**Business Settings:**
- Store information
- Tax configuration
- Currency settings
- Receipt preferences
- Printer setup
- Operating hours
- Payment methods

---

## Using the New Sync

### Trigger Full Sync

Go to **Settings → Sync** and tap **"Sync Now"**

This syncs everything including:
- Products ✓
- Transactions ✓
- Customers ✓
- Templates ✓
- Cashiers ✓
- **Wallets** ✨ NEW
- **Subscriptions** ✨ NEW  
- **Settings** ✨ NEW

### Check Sync Status

Look at the top bar:
- 🟢 **Green:** Online and synced
- 🟡 **Yellow:** Syncing...
- 🔴 **Red:** Offline (will sync when online)

### Last Sync Time

See when data was last synced in the Sync settings page.

---

## Real-World Scenarios

### Scenario 1: Update Store Address

**On Windows PC:**
1. Go to Settings → Business
2. Update store address
3. Tap "Save Settings"
4. ✅ Synced automatically

**On Android/iOS:**
- Address updates instantly
- Receipt shows new address
- No action needed

### Scenario 2: Wallet Top-Up

**On Any Device:**
1. Customer pays
2. Wallet balance updates
3. ✅ Balance syncs to cloud

**On All Devices:**
- New balance appears instantly
- Transaction history updated
- Consistent across devices

### Scenario 3: Buy Subscription

**On Windows PC:**
1. Go to Settings → Subscription
2. Choose plan and pay
3. ✅ Subscription activates

**On Mobile:**
- Subscription status updates
- Sync features enabled
- All devices can now sync

---

## Benefits

✅ **No Manual Work**
- Everything syncs automatically
- No buttons to press
- No data to copy

✅ **Always Up-to-Date**
- Real-time updates
- Instant synchronization
- No delays

✅ **Works Offline**
- Changes queued when offline
- Syncs when connection returns
- No data loss

✅ **Multi-Device Ready**
- Use Windows + Android + iOS
- All devices stay in sync
- Seamless experience

---

## Requirements

### For Sync to Work:

1. **Active Subscription** (Monthly/Yearly/2-Year)
   - Free plan: No sync
   - Paid plans: Full sync enabled

2. **Internet Connection**
   - Online: Syncs instantly
   - Offline: Queues for later

3. **Same Business ID**
   - All devices must use same business account
   - Set during initial setup

---

## Troubleshooting

### Settings Not Updating on Other Devices

1. Check internet connection
2. Verify subscription is active
3. Tap "Sync Now" manually
4. Wait 5-10 seconds for cloud update

### Wallet Balance Different on Devices

1. Pull to refresh on each device
2. Trigger full sync
3. Check last sync time
4. Verify internet connectivity

### Subscription Status Not Syncing

1. Restart app on all devices
2. Check subscription in Firebase Console
3. Trigger manual sync
4. Contact support if issue persists

---

## Firebase Console

### Check Your Data

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select "dynamos-pos" project
3. Click "Firestore Database"
4. Navigate to your business folder:
   ```
   businesses → {your_business_id} → 
     - wallets
     - subscriptions
     - business_settings
   ```

### What You'll See

**Wallets Collection:**
- Document ID: Your business ID
- Fields: balance, status, currency, etc.

**Subscriptions Collection:**
- Document ID: Subscription ID
- Fields: plan, status, startDate, endDate, etc.

**Business Settings Collection:**
- Document ID: Your business ID
- Fields: All your store settings

---

## Support

### Need Help?

**Contact:**
- Email: support@dynamospos.com
- In-App: Settings → Help & Support

**Before Contacting:**
1. Check internet connection
2. Verify subscription active
3. Try manual sync
4. Note any error messages

---

## Statistics

**Data Added to Sync:**
- 3 new collections
- ~300 lines of code
- 12 new sync methods
- 4 files enhanced

**Performance:**
- Wallet sync: ~500 bytes
- Subscription sync: ~800 bytes
- Settings sync: ~2-3 KB
- Total: ~4-5 KB per full sync

**Reliability:**
- ✅ Offline queue support
- ✅ Real-time listeners
- ✅ Automatic retry
- ✅ Error handling

---

**Updated:** November 19, 2025  
**Version:** 2.0  
**Status:** ✅ Live
