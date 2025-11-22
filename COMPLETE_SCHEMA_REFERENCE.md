# 🗂️ COMPLETE FIRESTORE SCHEMA REFERENCE

**Date:** November 20, 2025  
**Status:** Definitive Schema Design

---

## 📊 Firestore Structure

### 1. **businesses/** (Top-Level Collection)

**Purpose:** Store all business information in a single document per business.

**Document ID:** `BUS_<timestamp>`

**Fields:**
```
businesses/{businessId}/
  ├── id: string
  ├── name: string
  ├── business_type: string
  ├── email: string
  ├── phone: string
  ├── address: string
  ├── city: string                    ✅ NOW REQUIRED
  ├── country: string                 ✅ NOW REQUIRED
  ├── latitude: number (optional)
  ├── longitude: number (optional)
  ├── tax_id: string (optional)
  ├── website: string (optional)
  ├── logo: string (optional)
  ├── admin_id: string
  ├── status: string                  // 'active', 'pending', 'suspended', 'rejected'
  ├── created_at: timestamp
  ├── updated_at: timestamp
  ├── approved_at: timestamp (optional)
  ├── approved_by: string (optional)
  ├── rejection_reason: string (optional)
  ├── online_store_enabled: boolean
  ├── online_product_count: number
  └── settings: object {              ✅ EMBEDDED SETTINGS
      ├── currency: string
      ├── currency_symbol: string
      ├── currency_position: string
      ├── tax_enabled: boolean
      ├── tax_rate: number
      ├── tax_name: string
      ├── include_tax_in_price: boolean
      ├── opening_time: string
      ├── closing_time: string
      ├── accept_cash: boolean
      ├── accept_card: boolean
      ├── accept_mobile: boolean
      ├── receipt_header: string
      ├── receipt_footer: string
      └── receipt_show_logo: boolean
  }
```

### 2. **businesses/{businessId}/cashiers/** (Subcollection)

**Purpose:** Store all cashiers for a specific business.

**Document ID:** `ADMIN_<timestamp>` or `CASHIER_<timestamp>`

**Fields:**
```
businesses/{businessId}/cashiers/{cashierId}/
  ├── id: string
  ├── name: string
  ├── email: string
  ├── pin: string                     // 4-6 digit PIN
  ├── role: string                    // 'admin', 'manager', 'cashier'
  ├── business_id: string
  ├── is_active: boolean
  ├── created_at: timestamp
  ├── last_login: timestamp (optional)
  ├── permissions: array (optional)
  └── photo: string (optional)
```

### 3. **businesses/{businessId}/products/** (Subcollection)

**Purpose:** Store all products for a specific business.

**Document ID:** `PROD_<timestamp>`

**Fields:**
```
businesses/{businessId}/products/{productId}/
  ├── id: string
  ├── name: string
  ├── description: string
  ├── category: string
  ├── price: number
  ├── cost: number
  ├── sku: string
  ├── barcode: string
  ├── stock: number
  ├── stock_unit: string
  ├── min_stock: number
  ├── image: string (optional)
  ├── is_active: boolean
  ├── listed_online: boolean          ✅ For Dynamos Market
  ├── business_id: string
  ├── created_at: timestamp
  ├── updated_at: timestamp
  ├── variants: array (optional) [
  │   {
  │     id: string
  │     name: string
  │     price: number
  │     stock: number
  │     sku: string
  │   }
  │ ]
  └── tax_rate: number (optional)
```

### 4. **businesses/{businessId}/sales/** (Subcollection)

**Purpose:** Store all sales transactions.

**Document ID:** `SALE_<timestamp>`

**Fields:**
```
businesses/{businessId}/sales/{saleId}/
  ├── id: string
  ├── sale_number: string
  ├── business_id: string
  ├── cashier_id: string
  ├── cashier_name: string
  ├── customer_name: string (optional)
  ├── customer_phone: string (optional)
  ├── items: array [
  │   {
  │     product_id: string
  │     product_name: string
  │     quantity: number
  │     price: number
  │     total: number
  │   }
  │ ]
  ├── subtotal: number
  ├── tax: number
  ├── discount: number
  ├── total: number
  ├── payment_method: string          // 'cash', 'card', 'mobile'
  ├── amount_paid: number
  ├── change_given: number
  ├── status: string                  // 'completed', 'refunded', 'cancelled'
  ├── created_at: timestamp
  └── updated_at: timestamp
```

### 5. **businesses/{businessId}/expenses/** (Subcollection)

**Purpose:** Track business expenses.

**Document ID:** `EXP_<timestamp>`

**Fields:**
```
businesses/{businessId}/expenses/{expenseId}/
  ├── id: string
  ├── business_id: string
  ├── category: string
  ├── description: string
  ├── amount: number
  ├── payment_method: string
  ├── recorded_by: string             // cashier_id
  ├── receipt_image: string (optional)
  ├── created_at: timestamp
  └── updated_at: timestamp
```

### 6. **businesses/{businessId}/customers/** (Subcollection)

**Purpose:** Store customer information.

**Document ID:** `CUST_<timestamp>`

**Fields:**
```
businesses/{businessId}/customers/{customerId}/
  ├── id: string
  ├── name: string
  ├── phone: string
  ├── email: string (optional)
  ├── address: string (optional)
  ├── business_id: string
  ├── total_purchases: number
  ├── total_spent: number
  ├── loyalty_points: number (optional)
  ├── created_at: timestamp
  └── last_purchase: timestamp (optional)
```

---

## 🚫 What NOT to Do

### ❌ REMOVED Collections:
1. **`business_registrations/`** - NO LONGER USED
   - All business data now in `businesses/` collection
   - No separate registration collection

2. **`business_settings/{default}/`** - NO LONGER USED
   - Settings now embedded in business document
   - No detached subcollection

### ❌ AVOID:
- Duplicate data in multiple collections
- Settings in separate subcollection
- Redundant fields (e.g., `onlineStoreEnabled` in multiple places)

---

## 🔄 Data Flow

### Registration Flow:
```
1. User fills registration form
2. Create admin cashier (CashierModel)
3. Create business (BusinessModel) with embedded settings
4. Save business to: businesses/{businessId}
5. Save admin cashier to: businesses/{businessId}/cashiers/{cashierId}
6. Save both to SQLite locally
```

### Login Flow:
```
1. User enters PIN
2. Check SQLite local database
3. If not found, check Firestore:
   - Query all businesses/{businessId}/cashiers subcollections
   - Match by PIN
4. If found in Firestore:
   - Sync to SQLite
   - Allow login
5. If not found:
   - Login failed
```

### Product Sync Flow:
```
1. Product created locally (SQLite)
2. Sync to: businesses/{businessId}/products/{productId}
3. If listed_online = true:
   - Increment businesses/{businessId}.online_product_count
   - Dynamos Market can fetch from businesses collection
```

### Sales Flow:
```
1. Sale created locally (SQLite)
2. Sync to: businesses/{businessId}/sales/{saleId}
3. Update product stock in both SQLite and Firestore
```

---

## 📱 SQLite Schema (Local Database)

### **businesses** table:
```sql
CREATE TABLE businesses (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  business_type TEXT,
  email TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT NOT NULL,
  city TEXT NOT NULL,              -- ✅ Add this column
  country TEXT NOT NULL,           -- ✅ Add this column
  latitude REAL,                   -- ✅ Add this column
  longitude REAL,                  -- ✅ Add this column
  tax_id TEXT,
  website TEXT,
  logo TEXT,
  admin_id TEXT,
  status TEXT,
  created_at TEXT,
  updated_at TEXT,
  approved_at TEXT,
  approved_by TEXT,
  rejection_reason TEXT,
  online_store_enabled INTEGER DEFAULT 0,
  online_product_count INTEGER DEFAULT 0,
  settings TEXT                    -- ✅ Add this column (JSON string)
);
```

### **cashiers** table:
```sql
CREATE TABLE cashiers (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  pin TEXT NOT NULL,
  role TEXT NOT NULL,
  business_id TEXT NOT NULL,
  is_active INTEGER DEFAULT 1,
  created_at TEXT,
  last_login TEXT,
  permissions TEXT,
  photo TEXT,
  FOREIGN KEY (business_id) REFERENCES businesses(id)
);

-- ✅ IMPORTANT INDEX for PIN login
CREATE INDEX idx_cashiers_pin ON cashiers(pin);
CREATE INDEX idx_cashiers_business ON cashiers(business_id);
```

### **products** table:
```sql
CREATE TABLE products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT,
  price REAL NOT NULL,
  cost REAL,
  sku TEXT,
  barcode TEXT,
  stock REAL DEFAULT 0,
  stock_unit TEXT,
  min_stock REAL,
  image TEXT,
  is_active INTEGER DEFAULT 1,
  listed_online INTEGER DEFAULT 0,  -- ✅ For Dynamos Market
  business_id TEXT NOT NULL,
  created_at TEXT,
  updated_at TEXT,
  variants TEXT,                     -- JSON array
  tax_rate REAL,
  FOREIGN KEY (business_id) REFERENCES businesses(id)
);

CREATE INDEX idx_products_business ON products(business_id);
CREATE INDEX idx_products_listed_online ON products(listed_online);
```

### **sales** table:
```sql
CREATE TABLE sales (
  id TEXT PRIMARY KEY,
  sale_number TEXT NOT NULL,
  business_id TEXT NOT NULL,
  cashier_id TEXT NOT NULL,
  cashier_name TEXT,
  customer_name TEXT,
  customer_phone TEXT,
  items TEXT NOT NULL,              -- JSON array
  subtotal REAL,
  tax REAL,
  discount REAL,
  total REAL NOT NULL,
  payment_method TEXT,
  amount_paid REAL,
  change_given REAL,
  status TEXT DEFAULT 'completed',
  created_at TEXT,
  updated_at TEXT,
  FOREIGN KEY (business_id) REFERENCES businesses(id),
  FOREIGN KEY (cashier_id) REFERENCES cashiers(id)
);

CREATE INDEX idx_sales_business ON sales(business_id);
CREATE INDEX idx_sales_date ON sales(created_at);
```

---

## ✅ Implementation Checklist

### Phase 1: Database Schema ✅
- [x] Update business document structure
- [x] Embed settings in business document
- [x] Remove business_registrations collection
- [x] Remove business_settings subcollection
- [ ] Update SQLite schema (add missing columns)

### Phase 2: Business Service ✅
- [x] Fix registerBusiness() to save complete data
- [x] Make city/country required fields
- [x] Save cashier to subcollection
- [x] Single collection write (businesses only)
- [x] Fix updateBusiness() to use updateCloud()

### Phase 3: Login Service ⏳
- [ ] Update _fetchCashierFromFirestore() to query cashiers subcollection
- [ ] Remove business_registrations query
- [ ] Add proper indexing for PIN lookup

### Phase 4: Product Service ⏳
- [ ] Ensure products sync to businesses/{id}/products/
- [ ] Update online_product_count when listed_online changes
- [ ] Implement product.listed_online field

### Phase 5: Sales Service ⏳
- [ ] Ensure sales sync to businesses/{id}/sales/
- [ ] Update product stock after sale

### Phase 6: Testing ⏳
- [ ] Test registration (business + cashier)
- [ ] Test login with PIN
- [ ] Test product CRUD
- [ ] Test sales creation
- [ ] Verify Firestore structure

---

## 🎯 Summary

**Single Source of Truth:**
- All business data in ONE document: `businesses/{businessId}`
- All related data in subcollections: `businesses/{businessId}/cashiers`, `/products`, `/sales`, etc.
- Settings EMBEDDED in business document (no separate collection)
- No duplicate collections (no business_registrations)

**Clean Structure:**
```
businesses/
  └── BUS_1763638746767/
      ├── (all business fields + embedded settings)
      ├── cashiers/
      │   └── ADMIN_123456/
      ├── products/
      │   └── PROD_789012/
      ├── sales/
      │   └── SALE_345678/
      └── customers/
          └── CUST_901234/
```

**This is the definitive schema - follow it strictly!**
