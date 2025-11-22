# 🗄️ Database Structure Overhaul - Professional Architecture

**Date:** November 20, 2025  
**Version:** 2.0  
**Status:** Complete Restructuring Plan

---

## 📋 Table of Contents

1. [Current Problems](#current-problems)
2. [New Architecture](#new-architecture)
3. [Firestore Structure](#firestore-structure)
4. [SQLite Structure](#sqlite-structure)
5. [Implementation Steps](#implementation-steps)
6. [Migration Guide](#migration-guide)
7. [Data Integrity Rules](#data-integrity-rules)

---

## 🚨 Current Problems

### Issue 1: Dual Collection Chaos
- **Problem:** Businesses exist in BOTH `business_registrations` AND `businesses` collections
- **Impact:** Confusion about source of truth, sync issues, data inconsistency
- **Cause:** Approval workflow remnants in self-service system

### Issue 2: Incomplete Documents
- **Problem:** Business documents missing required fields (name, email, phone, etc.)
- **Impact:** BusinessModel.fromJson() fails, Dynamos Market can't load businesses
- **Cause:** Using `.set()` instead of `.update()` for partial updates

### Issue 3: No Clear Data Flow
- **Problem:** Unclear when to read from which collection
- **Impact:** Multiple data sources, inconsistent business info
- **Cause:** Lack of defined data architecture

### Issue 4: No Validation
- **Problem:** No schema validation before writing to Firestore
- **Impact:** Corrupt documents can be written
- **Cause:** No validation layer

---

## ✅ New Architecture

### Core Principles

1. **Single Source of Truth** - One active collection per entity type
2. **Complete Documents** - All documents must have required fields
3. **Audit Trail** - Separate collection for historical records
4. **Validation Layer** - Schema validation before writes
5. **Clear Data Flow** - Defined read/write patterns

---

## 🏗️ Firestore Structure

### Primary Collections (Operational Data)

```
firestore/
│
├── businesses/                          ← SINGLE SOURCE OF TRUTH
│   └── {businessId}/                    (Complete business documents)
│       ├── id: string (required)
│       ├── name: string (required)
│       ├── email: string (required)
│       ├── phone: string (required)
│       ├── address: string (required)
│       ├── city: string (optional)
│       ├── country: string (optional)
│       ├── business_type: string (optional)
│       ├── status: "active" | "inactive" | "suspended" (required)
│       ├── admin_id: string (required)
│       ├── created_at: timestamp (required)
│       ├── updated_at: timestamp (required)
│       ├── online_store_enabled: boolean (required, default: false)
│       ├── latitude: number (optional)
│       ├── longitude: number (optional)
│       ├── tax_id: string (optional)
│       ├── website: string (optional)
│       ├── logo: string (optional)
│       │
│       ├── business_settings/           ← Settings subcollection
│       │   └── default/
│       │       ├── storeName: string
│       │       ├── storeAddress: string
│       │       ├── storePhone: string
│       │       ├── storeEmail: string
│       │       ├── taxEnabled: boolean
│       │       ├── taxRate: number
│       │       ├── currency: string
│       │       ├── onlineStoreEnabled: boolean
│       │       ├── onlineProductCount: number
│       │       ├── receiptHeader: string
│       │       ├── receiptFooter: string
│       │       ├── updated_at: timestamp
│       │
│       ├── products/                    ← Products subcollection
│       │   └── {productId}/
│       │       ├── id: string (required)
│       │       ├── name: string (required)
│       │       ├── price: number (required)
│       │       ├── stock: number (required)
│       │       ├── category: string (optional)
│       │       ├── listedOnline: boolean (required, default: false)
│       │       ├── description: string (optional)
│       │       ├── image: string (optional)
│       │       ├── barcode: string (optional)
│       │       ├── sku: string (optional)
│       │       ├── created_at: timestamp (required)
│       │       ├── updated_at: timestamp (required)
│       │
│       ├── cashiers/                    ← Staff subcollection
│       │   └── {cashierId}/
│       │       ├── id: string (required)
│       │       ├── name: string (required)
│       │       ├── email: string (required)
│       │       ├── phone: string (optional)
│       │       ├── pin: string (required, hashed)
│       │       ├── role: "admin" | "manager" | "cashier" (required)
│       │       ├── businessId: string (required)
│       │       ├── isActive: boolean (required)
│       │       ├── created_at: timestamp (required)
│       │
│       ├── customers/                   ← Customers subcollection
│       │   └── {customerId}/
│       │
│       ├── transactions/                ← Sales subcollection
│       │   └── {transactionId}/
│       │
│       ├── categories/                  ← Product categories
│       │   └── {categoryId}/
│       │
│       └── inventory_logs/              ← Stock changes
│           └── {logId}/
│
├── business_audit/                      ← AUDIT TRAIL ONLY
│   └── {businessId}/
│       ├── registrations/               ← Registration history
│       │   └── {timestamp}/
│       │       ├── business_data: {...}
│       │       ├── admin_cashier: {...}
│       │       ├── registered_at: timestamp
│       │       ├── registered_from: device_id
│       │
│       ├── status_changes/              ← Status change history
│       │   └── {timestamp}/
│       │       ├── old_status: string
│       │       ├── new_status: string
│       │       ├── changed_by: string
│       │       ├── reason: string
│       │       ├── changed_at: timestamp
│       │
│       └── modifications/               ← Document change history
│           └── {timestamp}/
│               ├── field_name: string
│               ├── old_value: any
│               ├── new_value: any
│               ├── modified_by: string
│               ├── modified_at: timestamp
│
└── system_metadata/                     ← System-level data
    ├── schema_versions/
    │   └── current/
    │       ├── firestore_version: number
    │       ├── sqlite_version: number
    │       ├── last_updated: timestamp
    │
    └── sync_status/
        └── {deviceId}/
            ├── last_sync: timestamp
            ├── business_id: string
            ├── sync_errors: array
```

---

## 📱 SQLite Structure (Local Database)

### Schema Version 5 - Complete Restructuring

```sql
-- ============================================
-- CORE TABLES
-- ============================================

-- Businesses (local cache of Firestore data)
CREATE TABLE businesses (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    address TEXT NOT NULL,
    city TEXT,
    country TEXT,
    business_type TEXT,
    status TEXT NOT NULL DEFAULT 'active',
    admin_id TEXT NOT NULL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    online_store_enabled INTEGER NOT NULL DEFAULT 0,
    latitude REAL,
    longitude REAL,
    tax_id TEXT,
    website TEXT,
    logo TEXT,
    last_synced_at TEXT,
    CONSTRAINT chk_status CHECK (status IN ('active', 'inactive', 'suspended')),
    CONSTRAINT chk_online_store CHECK (online_store_enabled IN (0, 1))
);

-- Business Settings (local cache)
CREATE TABLE business_settings (
    business_id TEXT PRIMARY KEY,
    store_name TEXT NOT NULL,
    store_address TEXT,
    store_phone TEXT,
    store_email TEXT,
    tax_enabled INTEGER NOT NULL DEFAULT 1,
    tax_rate REAL NOT NULL DEFAULT 0.0,
    tax_name TEXT DEFAULT 'VAT',
    currency TEXT NOT NULL DEFAULT 'ZMW',
    currency_symbol TEXT NOT NULL DEFAULT 'K',
    online_store_enabled INTEGER NOT NULL DEFAULT 0,
    online_product_count INTEGER NOT NULL DEFAULT 0,
    receipt_header TEXT,
    receipt_footer TEXT,
    updated_at TEXT NOT NULL,
    last_synced_at TEXT,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    CONSTRAINT chk_tax_enabled CHECK (tax_enabled IN (0, 1)),
    CONSTRAINT chk_online_store CHECK (online_store_enabled IN (0, 1))
);

-- Cashiers (local cache + auth)
CREATE TABLE cashiers (
    id TEXT PRIMARY KEY,
    business_id TEXT NOT NULL,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    pin TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'cashier',
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    last_synced_at TEXT,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    CONSTRAINT chk_role CHECK (role IN ('admin', 'manager', 'cashier')),
    CONSTRAINT chk_is_active CHECK (is_active IN (0, 1))
);

-- Products (local cache)
CREATE TABLE products (
    id TEXT PRIMARY KEY,
    business_id TEXT NOT NULL,
    name TEXT NOT NULL,
    price REAL NOT NULL,
    cost REAL DEFAULT 0.0,
    stock INTEGER NOT NULL DEFAULT 0,
    category TEXT,
    barcode TEXT,
    sku TEXT,
    description TEXT,
    image TEXT,
    listed_online INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    last_synced_at TEXT,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    CONSTRAINT chk_price CHECK (price >= 0),
    CONSTRAINT chk_stock CHECK (stock >= 0),
    CONSTRAINT chk_listed_online CHECK (listed_online IN (0, 1))
);

-- ============================================
-- OPERATIONAL TABLES
-- ============================================

-- Customers
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

-- Transactions
CREATE TABLE transactions (
    id TEXT PRIMARY KEY,
    business_id TEXT NOT NULL,
    cashier_id TEXT NOT NULL,
    customer_id TEXT,
    transaction_date TEXT NOT NULL,
    total_amount REAL NOT NULL,
    tax_amount REAL DEFAULT 0.0,
    discount_amount REAL DEFAULT 0.0,
    payment_method TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'completed',
    notes TEXT,
    created_at TEXT NOT NULL,
    last_synced_at TEXT,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    FOREIGN KEY (cashier_id) REFERENCES cashiers(id),
    CONSTRAINT chk_status CHECK (status IN ('pending', 'completed', 'cancelled', 'refunded'))
);

-- Transaction Items
CREATE TABLE transaction_items (
    id TEXT PRIMARY KEY,
    transaction_id TEXT NOT NULL,
    product_id TEXT NOT NULL,
    product_name TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price REAL NOT NULL,
    total_price REAL NOT NULL,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Categories
CREATE TABLE categories (
    id TEXT PRIMARY KEY,
    business_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    created_at TEXT NOT NULL,
    last_synced_at TEXT,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    UNIQUE(business_id, name)
);

-- ============================================
-- SYNC & QUEUE TABLES
-- ============================================

-- Sync Queue (offline operations)
CREATE TABLE sync_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id TEXT NOT NULL,
    collection TEXT NOT NULL,
    document_id TEXT NOT NULL,
    operation TEXT NOT NULL,
    data TEXT NOT NULL,
    created_at TEXT NOT NULL,
    retry_count INTEGER DEFAULT 0,
    last_error TEXT,
    CONSTRAINT chk_operation CHECK (operation IN ('create', 'update', 'delete'))
);

-- Sync Status
CREATE TABLE sync_status (
    business_id TEXT PRIMARY KEY,
    last_full_sync TEXT,
    last_products_sync TEXT,
    last_customers_sync TEXT,
    last_transactions_sync TEXT,
    pending_operations INTEGER DEFAULT 0,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX idx_businesses_status ON businesses(status);
CREATE INDEX idx_businesses_online_store ON businesses(online_store_enabled);
CREATE INDEX idx_cashiers_business_id ON cashiers(business_id);
CREATE INDEX idx_cashiers_email ON cashiers(email);
CREATE INDEX idx_products_business_id ON products(business_id);
CREATE INDEX idx_products_listed_online ON products(listed_online);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_customers_business_id ON customers(business_id);
CREATE INDEX idx_transactions_business_id ON transactions(business_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_sync_queue_business_id ON sync_queue(business_id);
```

---

## 🔄 Data Flow Rules

### Rule 1: Business Registration
```
1. Create complete business document
2. Write to Firestore: businesses/{id}
3. Write audit record: business_audit/{id}/registrations/{timestamp}
4. Write to local SQLite: businesses table
5. Create default settings in both Firestore and SQLite
6. Return business object
```

### Rule 2: Business Updates
```
1. Validate update data (must not remove required fields)
2. Use updateCloud() for partial updates (NOT pushToCloud)
3. Update Firestore: businesses/{id}
4. Write audit record: business_audit/{id}/modifications/{timestamp}
5. Update local SQLite
6. Return success
```

### Rule 3: Online Store Toggle
```
1. Update business_settings/default/onlineStoreEnabled
2. Update businesses/{id}/online_store_enabled (PARTIAL UPDATE)
3. Update local SQLite: business_settings table
4. Trigger product count update
5. Return success
```

### Rule 4: Data Reading
```
Source Priority:
1. Local SQLite (if recent < 5 minutes)
2. Firestore businesses/{id} (if stale or missing)
3. Never read from business_audit (audit only)
```

---

## 🛠️ Implementation Steps

### Phase 1: Create Validation Layer

**File:** `lib/services/data_validator.dart`

```dart
class DataValidator {
  /// Validate business document before write
  static ValidationResult validateBusiness(Map<String, dynamic> data) {
    final required = ['id', 'name', 'email', 'phone', 'address', 'status', 'admin_id', 'created_at'];
    final missing = required.where((field) => !data.containsKey(field) || data[field] == null).toList();
    
    if (missing.isNotEmpty) {
      return ValidationResult(
        isValid: false,
        errors: ['Missing required fields: ${missing.join(', ')}'],
      );
    }
    
    // Validate email format
    if (!_isValidEmail(data['email'])) {
      return ValidationResult(
        isValid: false,
        errors: ['Invalid email format'],
      );
    }
    
    // Validate status
    if (!['active', 'inactive', 'suspended'].contains(data['status'])) {
      return ValidationResult(
        isValid: false,
        errors: ['Invalid status: ${data['status']}'],
      );
    }
    
    return ValidationResult(isValid: true);
  }
  
  /// Validate product document
  static ValidationResult validateProduct(Map<String, dynamic> data) {
    final required = ['id', 'name', 'price', 'stock', 'created_at'];
    final missing = required.where((field) => !data.containsKey(field)).toList();
    
    if (missing.isNotEmpty) {
      return ValidationResult(
        isValid: false,
        errors: ['Missing required fields: ${missing.join(', ')}'],
      );
    }
    
    // Validate price
    if (data['price'] < 0) {
      return ValidationResult(
        isValid: false,
        errors: ['Price cannot be negative'],
      );
    }
    
    return ValidationResult(isValid: true);
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  
  ValidationResult({required this.isValid, this.errors = const []});
}
```

### Phase 2: Update Business Service

**File:** `lib/services/business_service.dart` (Modified)

```dart
/// Register business with complete data
Future<BusinessModel?> registerBusiness({...}) async {
  // Build complete business document
  final businessDoc = {
    'id': businessId,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'city': city,
    'country': country,
    'business_type': businessType,
    'status': 'active',
    'admin_id': adminId,
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
    'online_store_enabled': false,
    'latitude': latitude,
    'longitude': longitude,
    'tax_id': taxId,
    'website': website,
  };
  
  // Validate before write
  final validation = DataValidator.validateBusiness(businessDoc);
  if (!validation.isValid) {
    throw Exception('Validation failed: ${validation.errors.join(', ')}');
  }
  
  // Write to Firestore: businesses/{id}
  await _syncService.pushToCloud('businesses', businessId, businessDoc, isTopLevel: true);
  
  // Write audit record
  await _syncService.pushToCloud('business_audit/$businessId/registrations', 
    DateTime.now().millisecondsSinceEpoch.toString(), {
      'business_data': businessDoc,
      'admin_cashier': adminCashierData,
      'registered_at': DateTime.now().toIso8601String(),
      'registered_from': _syncService.deviceId,
    }, isTopLevel: true);
  
  // Write to local SQLite
  await _db.insertBusiness(businessDoc);
  
  return BusinessModel.fromJson(businessDoc);
}
```

### Phase 3: Migration Script

**File:** `scripts/migrate_database_v2.dart`

```dart
Future<void> migrateToV2() async {
  print('🔄 Starting database migration to V2...\n');
  
  // Step 1: Backup current data
  await backupCurrentData();
  
  // Step 2: Scan all businesses in Firestore
  final businesses = await firestore.collection('businesses').get();
  
  for (var doc in businesses) {
    final businessId = doc.id;
    final data = doc.map;
    
    // Check if complete
    final validation = DataValidator.validateBusiness(data);
    
    if (!validation.isValid) {
      print('❌ Incomplete business: $businessId');
      print('   Missing: ${validation.errors}');
      
      // Try to restore from business_registrations
      await restoreFromAudit(businessId);
    } else {
      print('✅ Valid business: $businessId');
    }
  }
  
  // Step 3: Move business_registrations to business_audit
  await migrateRegistrationsToAudit();
  
  // Step 4: Upgrade SQLite schema to version 5
  await upgradeSQLiteSchema();
  
  print('\n✅ Migration complete!');
}
```

---

## 📖 Migration Guide

### For Developers

1. **Backup Everything**
   ```bash
   # Export Firestore data
   firebase firestore:export gs://your-backup-bucket
   
   # Backup SQLite
   cp pos_software.db pos_software.db.backup
   ```

2. **Run Migration Script**
   ```bash
   dart run scripts/migrate_database_v2.dart
   ```

3. **Verify Data Integrity**
   ```bash
   dart run scripts/verify_database_integrity.dart
   ```

4. **Update App Code**
   - Replace all `pushToCloud` calls with `updateCloud` for updates
   - Add validation before all writes
   - Update business fetching to read from `businesses` only

5. **Test Thoroughly**
   - Test business registration
   - Test online store toggle
   - Test product listing
   - Test sync operations

### For Existing Businesses

**No Action Required** - Migration script handles everything automatically!

---

## 🔒 Data Integrity Rules

### Rule 1: Required Fields
Every business document MUST have:
- `id`, `name`, `email`, `phone`, `address`, `status`, `admin_id`, `created_at`, `updated_at`, `online_store_enabled`

### Rule 2: Validation Before Write
All writes must pass validation:
```dart
final validation = DataValidator.validateBusiness(data);
if (!validation.isValid) {
  throw Exception('Validation failed');
}
```

### Rule 3: Partial Updates Only
Use `updateCloud()` for updates, never `pushToCloud()`:
```dart
// ❌ WRONG
await syncService.pushToCloud('businesses', id, {'online_store_enabled': true});

// ✅ CORRECT
await syncService.updateCloud('businesses', id, {'online_store_enabled': true});
```

### Rule 4: Audit Everything
All changes must be logged to `business_audit`:
```dart
await logAuditTrail(businessId, 'status_change', {
  'old_status': 'inactive',
  'new_status': 'active',
  'changed_by': userId,
  'changed_at': DateTime.now(),
});
```

### Rule 5: Single Source of Truth
- **Read from:** `businesses/{id}` (NOT business_registrations)
- **Write to:** `businesses/{id}` (AND audit trail)
- **Audit:** `business_audit/{id}/`

---

## 📊 Before vs After

### Before (Chaotic)
```
business_registrations/BUS_123/  ← Has full data
businesses/BUS_123/              ← Missing fields!
```

### After (Clean)
```
businesses/BUS_123/              ← COMPLETE data (single source)
business_audit/BUS_123/          ← History only
  ├── registrations/
  ├── status_changes/
  └── modifications/
```

---

## ✅ Success Criteria

- [ ] All businesses have complete documents
- [ ] No dual-collection confusion
- [ ] Validation prevents corrupt data
- [ ] Clear audit trail
- [ ] Dynamos Market loads all businesses
- [ ] No more "missing required fields" errors
- [ ] SQLite schema version 5
- [ ] All indexes created
- [ ] Migration script tested
- [ ] Documentation complete

---

**End of Architecture Document** • Version 2.0 • November 20, 2025
