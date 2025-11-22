# 🚀 Dynamos Market Agent - Quick Reference Card

## 📋 Online Store Setup (30 Seconds)

### Step 1: Enable Online Store
```
Settings → Business → Online Store Section → Toggle ON
✅ Snackbar: "Online Store Enabled"
```

### Step 2: List Product Online
```
Products → Edit Product → "List Online" toggle ON → Save
✅ Product syncs with listedOnline: true
```

### Step 3: Verify
```
Settings → Business → Online Store
✅ "Products Online" count increases
```

---

## 🔍 Quick Troubleshooting

### ❌ Toggle Greyed Out?
**Fix**: Enable online store first (Settings → Business → Online Store)

### ❌ Count Shows 0?
**Check**: 
1. Are products actually marked as online?
2. Restart app
3. Verify in Firestore: `businesses/{ID}/products/` → `listedOnline: true`

### ❌ Settings Show "My Store"?
**Fix**: 
1. Restart app
2. Re-login
3. Monitor console: `✅ Found settings in Firestore`

### ❌ Not Syncing Across Devices?
**Check**:
1. Internet connection (cloud icon)
2. Same business logged in
3. Restart second device

---

## 🎯 Agent Scripts

### Enabling Online Store
```
"Let's enable your online store:
1. Go to Settings → Business
2. Scroll to 'Online Store'
3. Turn the toggle ON
4. You'll see 'Online Store Enabled'
5. Now you can list products!"
```

### Listing Products
```
"To list a product online:
1. Go to Products
2. Click the product to edit
3. Find 'List on Online Store'
4. Turn it ON (green)
5. Save - done!"
```

### Why Product Not Online
```
"For products to appear online:
✅ Online Store must be enabled
✅ Product 'List Online' must be ON
✅ Product must have valid info

Check both settings!"
```

---

## 📊 Firestore Quick Check

```
businesses/{BUSINESS_ID}/
├── business_settings/default/
│   ├── onlineStoreEnabled: true ⭐
│   └── onlineProductCount: 5 ⭐
└── products/{PRODUCT_ID}/
    └── listedOnline: true ⭐
```

---

## ⚠️ Escalate When

- ❌ Firestore data missing
- ❌ Console shows errors
- ❌ Multiple merchants same issue
- ❌ Settings not loading after restarts
- ❌ Toggle not visible in latest version

---

## ✅ Don't Escalate When

- ✅ Toggle locked (tell them to enable store)
- ✅ Count shows 0 (guide them to mark products)
- ✅ Defaults showing (restart/re-login)
- ✅ Merchant confusion (educate)

---

## 📞 Support Contact

**Technical Support**: support@dynamospos.com  
**Internal Slack**: #dynamos-pos-support  
**Full Guide**: DYNAMOS_MARKET_AGENT_GUIDE.md

---

**Print this card and keep at your desk!** 📌
