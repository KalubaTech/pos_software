# 🎯 CLEAN DATABASE SCHEMA - Final Design

**Status:** ✅ Ready to Implement  
**Date:** November 20, 2025

---

## 🚨 Problems Identified from Your Screenshot

Looking at your Firestore screenshot, I see:

### Business Document (BUS_1763638746767)
```
✅ id: "BUS_1763638746767"
✅ name: "Kaloo Tech"
✅ email: "kalubachakanga@gmail.com"
✅ phone: "0973232553"
✅ status: "active"
✅ online_store_enabled: true
❌ address: MISSING
❌ city: MISSING
❌ country: MISSING
❌ latitude: MISSING
❌ longitude: MISSING
❌ business_type: MISSING
❌ admin_id: MISSING (should be there)
❌ created_at: "2025-11-20T13:39:07..." (wrong format - has extra chars)
```

### Business Settings (Detached Subcollection)
```
✅ onlineStoreEnabled: true (REDUNDANT - already in parent)
✅ currency: "ZMW"
✅ currencySymbol: "K"
✅ openingTime: "09:00"
✅ closingTime: "21:00"
✅ acceptCard: true
✅ acceptCash: true
✅ acceptMobile: true
✅ onlineProductCount: 0
```

### Issues:
1. ❌ **Location data completely missing** (address, city, latitude, longitude)
2. ❌ **Redundant `onlineStoreEnabled` in two places**
3. ❌ **Settings should be IN the business document, not detached**
4. ❌ **Timestamp format inconsistent**
5. ❌ **`admin_id` missing from business document**

---

## ✅ CLEAN SCHEMA - Single Document Design

### Business Document Structure

```typescript
businesses/{businessId}/
{
  // ═══════════════════════════════════════════════════════
  // CORE BUSINESS INFO (Required)
  // ═══════════════════════════════════════════════════════
  id: string,                          // e.g., "BUS_1234567890"
  name: string,                        // e.g., "Kaloo Tech"
  email: string,                       // e.g., "kaloo@example.com"
  phone: string,                       // e.g., "+260973232553"
  admin_id: string,                    // e.g., "USER_123" (owner)
  status: "active" | "inactive",       // Business operational status
  created_at: string (ISO8601),        // e.g., "2025-11-20T13:39:07.000Z"
  updated_at: string (ISO8601),        // Last update timestamp
  
  // ═══════════════════════════════════════════════════════
  // LOCATION (Required - THIS WAS MISSING!)
  // ═══════════════════════════════════════════════════════
  address: string,                     // e.g., "123 Main Street, Lusaka"
  city: string,                        // e.g., "Lusaka"
  country: string,                     // e.g., "Zambia"
  latitude: number,                    // e.g., -15.4167
  longitude: number,                   // e.g., 28.2833
  
  // ═══════════════════════════════════════════════════════
  // BUSINESS DETAILS (Optional)
  // ═══════════════════════════════════════════════════════
  business_type: string,               // e.g., "Retail", "Restaurant"
  tax_id: string,                      // e.g., "TAX123456"
  website: string,                     // e.g., "https://kaloo.com"
  logo: string,                        // e.g., "gs://bucket/logos/kaloo.jpg"
  
  // ═══════════════════════════════════════════════════════
  // ONLINE STORE
  // ═══════════════════════════════════════════════════════
  online_store_enabled: boolean,       // true/false
  online_product_count: number,        // Count of products listed online
  
  // ═══════════════════════════════════════════════════════
  // STORE SETTINGS (Embedded - NO SUBCOLLECTION!)
  // ═══════════════════════════════════════════════════════
  settings: {
    // Currency
    currency: string,                  // "ZMW"
    currency_symbol: string,           // "K"
    currency_position: "before" | "after",
    
    // Tax
    tax_enabled: boolean,
    tax_rate: number,                  // e.g., 16.0 (for 16%)
    tax_name: string,                  // "VAT"
    include_tax_in_price: boolean,
    
    // Operating Hours
    opening_time: string,              // "09:00"
    closing_time: string,              // "21:00"
    
    // Payment Methods
    accept_cash: boolean,
    accept_card: boolean,
    accept_mobile: boolean,
    
    // Receipt Settings
    receipt_header: string,
    receipt_footer: string,
    receipt_show_logo: boolean,
  }
}
```

---

## 📦 Subcollections (Under Each Business)

### products/
```typescript
businesses/{businessId}/products/{productId}/
{
  id: string,
  name: string,
  description: string,
  price: number,
  cost_price: number,
  category: string,
  image_url: string,
  
  // Inventory
  stock: number,
  min_stock: number,
  track_inventory: boolean,
  unit: string,                        // "pcs", "kg", "liters"
  
  // Identifiers
  sku: string,
  barcode: string,
  
  // Online Store
  listed_online: boolean,              // Show on Dynamos Market
  
  // Variants (if any)
  variants: [
    {
      id: string,
      name: string,
      attribute_type: string,          // "Size", "Color"
      price_adjustment: number,
      stock: number,
      sku: string,
      barcode: string
    }
  ],
  
  // Metadata
  created_at: string,
  updated_at: string,
  last_restocked: string
}
```

### cashiers/
```typescript
businesses/{businessId}/cashiers/{cashierId}/
{
  id: string,
  business_id: string,
  name: string,
  email: string,
  pin: string (hashed),
  role: "admin" | "manager" | "cashier",
  is_active: boolean,
  profile_image_url: string,
  created_at: string,
  last_login: string
}
```

### customers/
```typescript
businesses/{businessId}/customers/{customerId}/
{
  id: string,
  business_id: string,
  name: string,
  email: string,
  phone: string,
  address: string,
  loyalty_points: number,
  total_spent: number,
  created_at: string
}
```

### transactions/
```typescript
businesses/{businessId}/transactions/{transactionId}/
{
  id: string,
  business_id: string,
  cashier_id: string,
  customer_id: string,
  
  // Items
  items: [
    {
      product_id: string,
      product_name: string,
      quantity: number,
      unit_price: number,
      total_price: number
    }
  ],
  
  // Totals
  subtotal: number,
  tax_amount: number,
  discount_amount: number,
  total_amount: number,
  
  // Payment
  payment_method: "cash" | "card" | "mobile",
  amount_paid: number,
  change_given: number,
  
  // Status
  status: "completed" | "pending" | "cancelled" | "refunded",
  
  // Metadata
  transaction_date: string,
  created_at: string,
  notes: string
}
```

---

## 🗄️ SQLite Local Schema (Mirror of Firestore)

```sql
-- ════════════════════════════════════════════════════════
-- BUSINESSES TABLE (Complete Mirror)
-- ════════════════════════════════════════════════════════
CREATE TABLE businesses (
    -- Core Info
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    admin_id TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    
    -- Location (THESE WERE MISSING!)
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    country TEXT NOT NULL,
    latitude REAL,
    longitude REAL,
    
    -- Business Details
    business_type TEXT,
    tax_id TEXT,
    website TEXT,
    logo TEXT,
    
    -- Online Store
    online_store_enabled INTEGER NOT NULL DEFAULT 0,
    online_product_count INTEGER NOT NULL DEFAULT 0,
    
    -- Settings (JSON column for flexibility)
    settings TEXT,  -- Stored as JSON string
    
    -- Sync
    last_synced_at TEXT,
    
    CONSTRAINT chk_status CHECK (status IN ('active', 'inactive'))
);

-- ════════════════════════════════════════════════════════
-- PRODUCTS TABLE
-- ════════════════════════════════════════════════════════
CREATE TABLE products (
    id TEXT PRIMARY KEY,
    business_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    price REAL NOT NULL,
    cost_price REAL,
    category TEXT,
    image_url TEXT,
    
    -- Inventory
    stock INTEGER NOT NULL DEFAULT 0,
    min_stock INTEGER NOT NULL DEFAULT 10,
    track_inventory INTEGER NOT NULL DEFAULT 1,
    unit TEXT DEFAULT 'pcs',
    
    -- Identifiers
    sku TEXT,
    barcode TEXT,
    
    -- Online
    listed_online INTEGER NOT NULL DEFAULT 0,
    
    -- Variants (JSON)
    variants TEXT,  -- JSON string
    
    -- Metadata
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    last_restocked TEXT,
    last_synced_at TEXT,
    
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
);

-- ════════════════════════════════════════════════════════
-- CASHIERS TABLE
-- ════════════════════════════════════════════════════════
CREATE TABLE cashiers (
    id TEXT PRIMARY KEY,
    business_id TEXT NOT NULL,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    pin TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'cashier',
    is_active INTEGER NOT NULL DEFAULT 1,
    profile_image_url TEXT,
    created_at TEXT NOT NULL,
    last_login TEXT,
    last_synced_at TEXT,
    
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    CONSTRAINT chk_role CHECK (role IN ('admin', 'manager', 'cashier'))
);

-- ════════════════════════════════════════════════════════
-- CUSTOMERS TABLE
-- ════════════════════════════════════════════════════════
CREATE TABLE customers (
    id TEXT PRIMARY KEY,
    business_id TEXT NOT NULL,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    address TEXT,
    loyalty_points INTEGER DEFAULT 0,
    total_spent REAL DEFAULT 0.0,
    created_at TEXT NOT NULL,
    last_synced_at TEXT,
    
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
);

-- ════════════════════════════════════════════════════════
-- TRANSACTIONS TABLE
-- ════════════════════════════════════════════════════════
CREATE TABLE transactions (
    id TEXT PRIMARY KEY,
    business_id TEXT NOT NULL,
    cashier_id TEXT NOT NULL,
    customer_id TEXT,
    
    -- Items (JSON)
    items TEXT NOT NULL,  -- JSON array of items
    
    -- Totals
    subtotal REAL NOT NULL,
    tax_amount REAL DEFAULT 0.0,
    discount_amount REAL DEFAULT 0.0,
    total_amount REAL NOT NULL,
    
    -- Payment
    payment_method TEXT NOT NULL,
    amount_paid REAL NOT NULL,
    change_given REAL DEFAULT 0.0,
    
    -- Status
    status TEXT NOT NULL DEFAULT 'completed',
    
    -- Metadata
    transaction_date TEXT NOT NULL,
    created_at TEXT NOT NULL,
    notes TEXT,
    last_synced_at TEXT,
    
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    FOREIGN KEY (cashier_id) REFERENCES cashiers(id),
    CONSTRAINT chk_status CHECK (status IN ('completed', 'pending', 'cancelled', 'refunded')),
    CONSTRAINT chk_payment CHECK (payment_method IN ('cash', 'card', 'mobile'))
);

-- ════════════════════════════════════════════════════════
-- INDEXES
-- ════════════════════════════════════════════════════════
CREATE INDEX idx_businesses_online_store ON businesses(online_store_enabled);
CREATE INDEX idx_products_business ON products(business_id);
CREATE INDEX idx_products_listed_online ON products(listed_online);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_cashiers_business ON cashiers(business_id);
CREATE INDEX idx_customers_business ON customers(business_id);
CREATE INDEX idx_transactions_business ON transactions(business_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
```

---

## 🔄 Data Flow - Registration to Sync

### 1. Business Registration

```dart
// User fills registration form
final business = {
  'id': 'BUS_${timestamp}',
  'name': 'Kaloo Tech',
  'email': 'kaloo@example.com',
  'phone': '+260973232553',
  'address': '123 Main Street, Lusaka',  // ✅ MUST CAPTURE
  'city': 'Lusaka',                       // ✅ MUST CAPTURE
  'country': 'Zambia',                    // ✅ MUST CAPTURE
  'latitude': -15.4167,                   // ✅ FROM MAP/GPS
  'longitude': 28.2833,                   // ✅ FROM MAP/GPS
  'business_type': 'Retail',
  'admin_id': adminCashier.id,
  'status': 'active',
  'created_at': DateTime.now().toIso8601String(),
  'updated_at': DateTime.now().toIso8601String(),
  'online_store_enabled': false,
  'online_product_count': 0,
  'settings': {
    'currency': 'ZMW',
    'currency_symbol': 'K',
    'currency_position': 'before',
    'tax_enabled': true,
    'tax_rate': 16.0,
    'tax_name': 'VAT',
    'include_tax_in_price': true,
    'opening_time': '09:00',
    'closing_time': '21:00',
    'accept_cash': true,
    'accept_card': true,
    'accept_mobile': true,
    'receipt_header': 'Thank you for your purchase',
    'receipt_footer': 'Please visit again!',
    'receipt_show_logo': true,
  }
};

// Save to Firestore (ONE PLACE ONLY!)
await firestore.collection('businesses').doc(business['id']).set(business);

// Save to SQLite (local cache)
await db.insert('businesses', {
  ...business,
  'settings': jsonEncode(business['settings']),  // Convert to JSON string
  'last_synced_at': DateTime.now().toIso8601String(),
});
```

### 2. Update Settings (e.g., Online Store Toggle)

```dart
// User toggles online store
await firestore.collection('businesses').doc(businessId).update({
  'online_store_enabled': true,
  'updated_at': DateTime.now().toIso8601String(),
});

// Update local SQLite
await db.update('businesses', 
  {
    'online_store_enabled': 1,
    'updated_at': DateTime.now().toIso8601String(),
    'last_synced_at': DateTime.now().toIso8601String(),
  },
  where: 'id = ?',
  whereArgs: [businessId]
);
```

### 3. Dynamos Market Fetches Businesses

```javascript
// Fetch online businesses
const businesses = await firestore
  .collection('businesses')
  .where('online_store_enabled', '==', true)
  .where('status', '==', 'active')
  .get();

// Each business has EVERYTHING:
businesses.forEach(doc => {
  const business = doc.data();
  console.log(`
    Name: ${business.name}
    Address: ${business.address}        // ✅ Available
    City: ${business.city}              // ✅ Available
    Location: ${business.latitude}, ${business.longitude}  // ✅ Available
    Phone: ${business.phone}
    Opening: ${business.settings.opening_time}
    Currency: ${business.settings.currency}
  `);
});
```

---

## 🎯 Key Rules

### Rule 1: NO DETACHED SUBCOLLECTIONS FOR SETTINGS
❌ **WRONG:**
```
businesses/BUS_123/
businesses/BUS_123/business_settings/default/  ← DON'T DO THIS
```

✅ **CORRECT:**
```
businesses/BUS_123/
  └─ settings: { ... }  ← Embedded in document
```

### Rule 2: ALL LOCATION FIELDS REQUIRED
```dart
// MUST capture during registration:
- address (full street address)
- city
- country
- latitude (from map picker)
- longitude (from map picker)
```

### Rule 3: NO DUAL WRITES
❌ **WRONG:**
```dart
// Don't save to multiple collections
await firestore.collection('business_registrations').doc(id).set(data);
await firestore.collection('businesses').doc(id).set(data);  // Redundant!
```

✅ **CORRECT:**
```dart
// Save to ONE place only
await firestore.collection('businesses').doc(id).set(data);
```

### Rule 4: CONSISTENT TIMESTAMPS
```dart
// Always use ISO 8601 format
DateTime.now().toIso8601String()  // "2025-11-20T13:39:07.000Z"

// NOT:
DateTime.now().toString()  // ❌ Wrong format
```

### Rule 5: SETTINGS AS EMBEDDED OBJECT
```dart
// Store settings IN the business document
{
  'id': 'BUS_123',
  'name': 'Kaloo Tech',
  'settings': {  // ✅ Embedded
    'currency': 'ZMW',
    'tax_rate': 16.0,
    // ... all settings here
  }
}
```

---

## ✅ Implementation Checklist

### Step 1: Clear Firestore
```bash
# Delete all documents (via Firebase Console or script)
firebase firestore:delete businesses --recursive
```

### Step 2: Update Business Model
- [x] Model already has all fields
- [ ] Ensure `settings` is a Map<String, dynamic>
- [ ] Add default settings in constructor

### Step 3: Update Registration Form
- [ ] Add location fields (address, city, country)
- [ ] Add map picker for latitude/longitude
- [ ] Add default settings initialization

### Step 4: Update Business Service
- [ ] Remove dual collection writes
- [ ] Save ALL fields including location
- [ ] Embed settings in business document
- [ ] Remove business_settings subcollection logic

### Step 5: Update SQLite Schema
- [ ] Add missing columns (address, city, country, lat, lng)
- [ ] Add settings column (TEXT, stores JSON)
- [ ] Create indexes

### Step 6: Test
- [ ] Register new business with location
- [ ] Verify all fields in Firestore
- [ ] Test online store toggle
- [ ] Verify Dynamos Market can fetch

---

**Next:** I'll implement these changes in the actual code files.
