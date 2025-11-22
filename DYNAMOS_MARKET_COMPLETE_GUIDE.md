# 🏪 Dynamos Market - Complete Integration Guide

**Target Audience:** Dynamos Market Client Application Developers  
**Version:** 2.0  
**Last Updated:** November 20, 2025  
**Status:** Production Ready

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Database Architecture](#database-architecture)
3. [Fetching Online Businesses](#fetching-online-businesses)
4. [Fetching Products](#fetching-products)
5. [Business Details](#business-details)
6. [Product Details](#product-details)
7. [Search & Filtering](#search--filtering)
8. [Real-time Updates](#real-time-updates)
9. [Error Handling](#error-handling)
10. [Best Practices](#best-practices)
11. [Complete Code Examples](#complete-code-examples)
12. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

### What is Dynamos Market?

Dynamos Market is the **consumer-facing marketplace app** where customers can:
- Browse online stores registered in the POS system
- View products from businesses with `online_store_enabled: true`
- Place orders
- Track deliveries
- Leave reviews

### Data Source

**All data comes from Firestore Cloud Database:**
- Collection: `businesses/`
- Sub-collection: `businesses/{businessId}/products/`
- Real-time sync from POS desktop app

### Key Concepts

1. **Online Store Flag**: Only businesses with `online_store_enabled: true` appear in Dynamos Market
2. **Listed Products**: Only products with `listedOnline: true` are visible
3. **Single Source of Truth**: Read from `businesses/` collection (NOT `business_registrations`)
4. **Required Fields**: All businesses MUST have complete data (see schema below)

---

## 🏗️ Database Architecture

### Firestore Structure

```
firestore/
└── businesses/                          ← READ FROM HERE
    └── {businessId}/                    
        ├── [Business Document Fields]
        │   ├── id: string
        │   ├── name: string
        │   ├── email: string
        │   ├── phone: string
        │   ├── address: string
        │   ├── city: string
        │   ├── country: string
        │   ├── status: "active" | "inactive" | "suspended"
        │   ├── online_store_enabled: boolean  ← CRITICAL FIELD
        │   ├── latitude: number
        │   ├── longitude: number
        │   ├── website: string
        │   ├── logo: string
        │   ├── created_at: timestamp
        │   └── updated_at: timestamp
        │
        ├── products/                    ← READ PRODUCTS FROM HERE
        │   └── {productId}/
        │       ├── id: string
        │       ├── name: string
        │       ├── price: number
        │       ├── stock: number
        │       ├── category: string
        │       ├── listedOnline: boolean  ← CRITICAL FIELD
        │       ├── description: string
        │       ├── image: string
        │       ├── barcode: string
        │       ├── sku: string
        │       ├── created_at: timestamp
        │       └── updated_at: timestamp
        │
        └── business_settings/           ← OPTIONAL (for extra details)
            └── default/
                ├── storeName: string
                ├── storeAddress: string
                ├── storePhone: string
                ├── onlineStoreEnabled: boolean
                ├── onlineProductCount: number
```

### Business Document Schema

**Required Fields:**
```json
{
  "id": "BUS_1234567890",
  "name": "Kaloo Stores",
  "email": "kaloo@example.com",
  "phone": "+260-123-456-789",
  "address": "123 Main Street",
  "status": "active",
  "admin_id": "ADMIN_123",
  "created_at": "2024-11-20T10:30:00Z",
  "updated_at": "2024-11-20T10:30:00Z",
  "online_store_enabled": true
}
```

**Optional Fields:**
```json
{
  "city": "Lusaka",
  "country": "Zambia",
  "business_type": "retail",
  "latitude": -15.3875,
  "longitude": 28.3228,
  "tax_id": "TAX123456",
  "website": "https://kaloo.com",
  "logo": "gs://bucket/logo.jpg"
}
```

### Product Document Schema

**Required Fields:**
```json
{
  "id": "PROD_1234567890",
  "name": "Coca Cola 500ml",
  "price": 15.00,
  "stock": 50,
  "listedOnline": true,
  "created_at": "2024-11-20T10:30:00Z",
  "updated_at": "2024-11-20T10:30:00Z"
}
```

**Optional Fields:**
```json
{
  "category": "Beverages",
  "description": "Refreshing soft drink",
  "image": "gs://bucket/products/cocacola.jpg",
  "barcode": "5449000000996",
  "sku": "CC-500ML",
  "cost": 10.00
}
```

---

## 🔍 Fetching Online Businesses

### Method 1: Query with Filter (Recommended)

**Firebase Query (JavaScript):**
```javascript
import { collection, query, where, getDocs } from 'firebase/firestore';

const fetchOnlineBusinesses = async () => {
  const businessesRef = collection(db, 'businesses');
  const q = query(
    businessesRef,
    where('online_store_enabled', '==', true),
    where('status', '==', 'active')
  );
  
  const snapshot = await getDocs(q);
  const businesses = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));
  
  console.log(`✅ Fetched ${businesses.length} online businesses`);
  return businesses;
};
```

**Dart (Flutter - Firedart):**
```dart
import 'package:firedart/firedart.dart';

Future<List<Map<String, dynamic>>> fetchOnlineBusinesses() async {
  final firestore = Firestore.instance;
  
  final snapshot = await firestore
      .collection('businesses')
      .where('online_store_enabled', isEqualTo: true)
      .where('status', isEqualTo: 'active')
      .get();
  
  final businesses = snapshot.map((doc) => {
    'id': doc.id,
    ...doc.map,
  }).toList();
  
  print('✅ Fetched ${businesses.length} online businesses');
  return businesses;
}
```

**Python (Firebase Admin SDK):**
```python
import firebase_admin
from firebase_admin import firestore

def fetch_online_businesses():
    db = firestore.client()
    
    # Query businesses collection
    businesses_ref = db.collection('businesses')
    query = businesses_ref.where('online_store_enabled', '==', True) \
                          .where('status', '==', 'active')
    
    docs = query.stream()
    businesses = []
    
    for doc in docs:
        business_data = doc.to_dict()
        business_data['id'] = doc.id
        businesses.append(business_data)
    
    print(f'✅ Fetched {len(businesses)} online businesses')
    return businesses
```

### Method 2: Real-time Listener (Recommended for Live Updates)

```javascript
import { onSnapshot } from 'firebase/firestore';

const subscribeToOnlineBusinesses = (callback) => {
  const q = query(
    collection(db, 'businesses'),
    where('online_store_enabled', '==', true),
    where('status', '==', 'active')
  );
  
  const unsubscribe = onSnapshot(q, (snapshot) => {
    const businesses = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    callback(businesses);
  });
  
  return unsubscribe; // Call this to stop listening
};

// Usage
const unsubscribe = subscribeToOnlineBusinesses((businesses) => {
  console.log('Updated businesses:', businesses.length);
  // Update UI
});

// When done:
// unsubscribe();
```

---

## 📦 Fetching Products

### Fetch Products for Specific Business

```javascript
const fetchBusinessProducts = async (businessId) => {
  const productsRef = collection(db, `businesses/${businessId}/products`);
  const q = query(
    productsRef,
    where('listedOnline', '==', true),
    where('stock', '>', 0)  // Only in-stock products
  );
  
  const snapshot = await getDocs(q);
  const products = snapshot.docs.map(doc => ({
    id: doc.id,
    businessId: businessId,
    ...doc.data()
  }));
  
  console.log(`✅ Fetched ${products.length} products for ${businessId}`);
  return products;
};
```

### Fetch All Products from All Online Businesses

```javascript
const fetchAllOnlineProducts = async () => {
  // Step 1: Get all online businesses
  const businesses = await fetchOnlineBusinesses();
  
  // Step 2: Fetch products for each business
  const allProducts = [];
  
  for (const business of businesses) {
    const products = await fetchBusinessProducts(business.id);
    
    // Add business info to each product
    const productsWithBusiness = products.map(product => ({
      ...product,
      businessName: business.name,
      businessPhone: business.phone,
      businessAddress: business.address,
      businessLogo: business.logo
    }));
    
    allProducts.push(...productsWithBusiness);
  }
  
  console.log(`✅ Total online products: ${allProducts.length}`);
  return allProducts;
};
```

---

## 🔎 Business Details

### Get Single Business

```javascript
const getBusinessDetails = async (businessId) => {
  const docRef = doc(db, 'businesses', businessId);
  const docSnap = await getDoc(docRef);
  
  if (!docSnap.exists()) {
    throw new Error(`Business ${businessId} not found`);
  }
  
  const businessData = {
    id: docSnap.id,
    ...docSnap.data()
  };
  
  // Check if online store is enabled
  if (!businessData.online_store_enabled) {
    throw new Error(`Business ${businessId} is not available online`);
  }
  
  return businessData;
};
```

### Get Business with Settings

```javascript
const getBusinessWithSettings = async (businessId) => {
  // Get business document
  const business = await getBusinessDetails(businessId);
  
  // Get settings
  const settingsRef = doc(db, `businesses/${businessId}/business_settings/default`);
  const settingsSnap = await getDoc(settingsRef);
  
  if (settingsSnap.exists()) {
    business.settings = settingsSnap.data();
  }
  
  return business;
};
```

---

## 🔍 Search & Filtering

### Search Businesses by Name

```javascript
const searchBusinesses = async (searchTerm) => {
  // Note: Firestore doesn't support full-text search natively
  // This is a simple prefix search
  
  const lowerSearch = searchTerm.toLowerCase();
  const businesses = await fetchOnlineBusinesses();
  
  return businesses.filter(business =>
    business.name.toLowerCase().includes(lowerSearch) ||
    (business.city && business.city.toLowerCase().includes(lowerSearch))
  );
};
```

### Filter Products by Price Range

```javascript
const filterProductsByPrice = async (minPrice, maxPrice) => {
  const allProducts = await fetchAllOnlineProducts();
  
  return allProducts.filter(product =>
    product.price >= minPrice && product.price <= maxPrice
  );
};
```

### Get Businesses by Location (Nearby)

```javascript
const getNearbyBusinesses = async (userLat, userLng, radiusKm = 10) => {
  const businesses = await fetchOnlineBusinesses();
  
  // Filter businesses with coordinates
  const businessesWithCoords = businesses.filter(b => b.latitude && b.longitude);
  
  // Calculate distance and filter
  const nearby = businessesWithCoords
    .map(business => {
      const distance = calculateDistance(
        userLat, userLng,
        business.latitude, business.longitude
      );
      return { ...business, distance };
    })
    .filter(business => business.distance <= radiusKm)
    .sort((a, b) => a.distance - b.distance);
  
  return nearby;
};

// Haversine formula for distance calculation
const calculateDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371; // Earth's radius in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
};
```

---

## 🔴 Real-time Updates

### Listen to Business Changes

```javascript
const subscribeToBusinessChanges = (businessId, callback) => {
  const docRef = doc(db, 'businesses', businessId);
  
  const unsubscribe = onSnapshot(docRef, (doc) => {
    if (doc.exists()) {
      const business = { id: doc.id, ...doc.data() };
      callback(business);
    } else {
      callback(null); // Business deleted or offline
    }
  });
  
  return unsubscribe;
};

// Usage
const unsubscribe = subscribeToBusinessChanges('BUS_123', (business) => {
  if (!business || !business.online_store_enabled) {
    // Business went offline
    console.log('Business is no longer online');
  } else {
    console.log('Business updated:', business.name);
  }
});
```

### Listen to Product Stock Changes

```javascript
const subscribeToProductStock = (businessId, productId, callback) => {
  const docRef = doc(db, `businesses/${businessId}/products`, productId);
  
  const unsubscribe = onSnapshot(docRef, (doc) => {
    if (doc.exists()) {
      const product = { id: doc.id, ...doc.data() };
      callback(product);
    } else {
      callback(null); // Product deleted
    }
  });
  
  return unsubscribe;
};
```

---

## ❌ Error Handling

### Common Errors & Solutions

#### 1. Business Not Found
```javascript
try {
  const business = await getBusinessDetails('INVALID_ID');
} catch (error) {
  if (error.message.includes('not found')) {
    // Show "Business not available" message
    console.error('Business does not exist');
  }
}
```

#### 2. Missing Required Fields
```javascript
const validateBusiness = (business) => {
  const required = ['id', 'name', 'email', 'phone', 'address', 'status'];
  const missing = required.filter(field => !business[field]);
  
  if (missing.length > 0) {
    throw new Error(`Business missing required fields: ${missing.join(', ')}`);
  }
  
  return true;
};

// Use in fetch
const businesses = await fetchOnlineBusinesses();
const validBusinesses = businesses.filter(business => {
  try {
    return validateBusiness(business);
  } catch (error) {
    console.error(`Invalid business ${business.id}:`, error.message);
    return false;
  }
});
```

#### 3. Network Errors with Retry
```javascript
const fetchWithRetry = async (fetchFn, maxRetries = 3) => {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fetchFn();
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      
      // Wait before retry (exponential backoff)
      await new Promise(resolve => setTimeout(resolve, Math.pow(2, i) * 1000));
      console.log(`Retry ${i + 1}/${maxRetries}...`);
    }
  }
};

// Usage
const businesses = await fetchWithRetry(() => fetchOnlineBusinesses());
```

---

## ✅ Best Practices

### 1. Cache Data Locally

```javascript
class DataCache {
  constructor(ttl = 5 * 60 * 1000) { // 5 minutes default
    this.cache = new Map();
    this.ttl = ttl;
  }
  
  set(key, value) {
    this.cache.set(key, {
      value,
      timestamp: Date.now()
    });
  }
  
  get(key) {
    const item = this.cache.get(key);
    if (!item) return null;
    
    const age = Date.now() - item.timestamp;
    if (age > this.ttl) {
      this.cache.delete(key);
      return null;
    }
    
    return item.value;
  }
}

const businessCache = new DataCache();

const getCachedBusinesses = async () => {
  const cached = businessCache.get('online_businesses');
  if (cached) {
    console.log('✅ Using cached data');
    return cached;
  }
  
  const businesses = await fetchOnlineBusinesses();
  businessCache.set('online_businesses', businesses);
  return businesses;
};
```

### 2. Paginate Large Results

```javascript
const fetchBusinessesPaginated = async (pageSize = 20, lastDoc = null) => {
  let q = query(
    collection(db, 'businesses'),
    where('online_store_enabled', '==', true),
    where('status', '==', 'active'),
    limit(pageSize)
  );
  
  if (lastDoc) {
    q = query(q, startAfter(lastDoc));
  }
  
  const snapshot = await getDocs(q);
  const businesses = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));
  
  return {
    businesses,
    lastDoc: snapshot.docs[snapshot.docs.length - 1],
    hasMore: snapshot.docs.length === pageSize
  };
};
```

### 3. Handle Offline Mode

```javascript
import { enableIndexedDbPersistence } from 'firebase/firestore';

// Enable offline persistence
try {
  await enableIndexedDbPersistence(db);
  console.log('✅ Offline persistence enabled');
} catch (error) {
  if (error.code === 'failed-precondition') {
    console.warn('Offline persistence failed: multiple tabs open');
  } else if (error.code === 'unimplemented') {
    console.warn('Offline persistence not supported by browser');
  }
}
```

---

## 💻 Complete Code Examples

### Example 1: Marketplace Homepage

```javascript
import { collection, query, where, getDocs, limit } from 'firebase/firestore';
import { db } from './firebase-config';

class MarketplaceService {
  async getHomepageData() {
    try {
      // Fetch featured businesses (up to 10)
      const businesses = await this.fetchFeaturedBusinesses(10);
      
      // Fetch featured products from each business (5 per business)
      const featuredProducts = [];
      
      for (const business of businesses) {
        const products = await this.fetchBusinessProducts(business.id, 5);
        
        const productsWithBusiness = products.map(product => ({
          ...product,
          businessName: business.name,
          businessLogo: business.logo,
          businessPhone: business.phone
        }));
        
        featuredProducts.push(...productsWithBusiness);
      }
      
      return {
        businesses,
        featuredProducts,
        totalBusinesses: businesses.length,
        totalProducts: featuredProducts.length
      };
    } catch (error) {
      console.error('Error loading homepage:', error);
      throw error;
    }
  }
  
  async fetchFeaturedBusinesses(maxCount = 10) {
    const businessesRef = collection(db, 'businesses');
    const q = query(
      businessesRef,
      where('online_store_enabled', '==', true),
      where('status', '==', 'active'),
      limit(maxCount)
    );
    
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }
  
  async fetchBusinessProducts(businessId, maxCount = 5) {
    const productsRef = collection(db, `businesses/${businessId}/products`);
    const q = query(
      productsRef,
      where('listedOnline', '==', true),
      where('stock', '>', 0),
      limit(maxCount)
    );
    
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({ 
      id: doc.id, 
      businessId,
      ...doc.data() 
    }));
  }
}

// Usage
const marketplace = new MarketplaceService();
const homepage = await marketplace.getHomepageData();

console.log(`Loaded ${homepage.totalBusinesses} businesses`);
console.log(`Loaded ${homepage.totalProducts} products`);
```

### Example 2: Product Search

```javascript
class ProductSearchService {
  async searchProducts(searchTerm, filters = {}) {
    try {
      // Get all online businesses
      const businesses = await this.fetchOnlineBusinesses();
      
      // Fetch products from all businesses
      const allProducts = [];
      
      for (const business of businesses) {
        const products = await this.fetchBusinessProducts(business.id);
        
        const productsWithBusiness = products.map(product => ({
          ...product,
          businessName: business.name,
          businessPhone: business.phone,
          businessAddress: business.address,
          businessCity: business.city,
          businessLogo: business.logo
        }));
        
        allProducts.push(...productsWithBusiness);
      }
      
      // Apply search and filters
      let results = this.filterProducts(allProducts, searchTerm, filters);
      
      // Sort results
      results = this.sortProducts(results, filters.sortBy || 'relevance');
      
      return {
        results,
        totalResults: results.length,
        searchTerm
      };
    } catch (error) {
      console.error('Search error:', error);
      throw error;
    }
  }
  
  async fetchOnlineBusinesses() {
    const businessesRef = collection(db, 'businesses');
    const q = query(
      businessesRef,
      where('online_store_enabled', '==', true),
      where('status', '==', 'active')
    );
    
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }
  
  async fetchBusinessProducts(businessId) {
    const productsRef = collection(db, `businesses/${businessId}/products`);
    const q = query(
      productsRef,
      where('listedOnline', '==', true),
      where('stock', '>', 0)
    );
    
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({ 
      id: doc.id, 
      businessId,
      ...doc.data() 
    }));
  }
  
  filterProducts(products, searchTerm, filters) {
    let filtered = products;
    
    // Search by name or description
    if (searchTerm) {
      const lower = searchTerm.toLowerCase();
      filtered = filtered.filter(p =>
        p.name.toLowerCase().includes(lower) ||
        (p.description && p.description.toLowerCase().includes(lower))
      );
    }
    
    // Filter by category
    if (filters.category) {
      filtered = filtered.filter(p => p.category === filters.category);
    }
    
    // Filter by price range
    if (filters.minPrice !== undefined) {
      filtered = filtered.filter(p => p.price >= filters.minPrice);
    }
    if (filters.maxPrice !== undefined) {
      filtered = filtered.filter(p => p.price <= filters.maxPrice);
    }
    
    return filtered;
  }
  
  sortProducts(products, sortBy) {
    switch (sortBy) {
      case 'price_asc':
        return products.sort((a, b) => a.price - b.price);
      case 'price_desc':
        return products.sort((a, b) => b.price - a.price);
      case 'name_asc':
        return products.sort((a, b) => a.name.localeCompare(b.name));
      default:
        return products;
    }
  }
}

// Usage
const searchService = new ProductSearchService();
const results = await searchService.searchProducts('coca cola', {
  category: 'Beverages',
  minPrice: 10,
  maxPrice: 50,
  sortBy: 'price_asc'
});

console.log(`Found ${results.totalResults} products`);
```

---

## 🔧 Troubleshooting

### Problem 1: "Fetched 0 online businesses"

**Causes:**
1. No businesses have `online_store_enabled: true`
2. Reading from wrong collection
3. Field name mismatch

**Solutions:**
```javascript
// Check if any businesses exist
const allBusinesses = await getDocs(collection(db, 'businesses'));
console.log(`Total businesses: ${allBusinesses.size}`);

// Check fields
allBusinesses.forEach(doc => {
  const data = doc.data();
  console.log(`${doc.id}: online_store_enabled = ${data.online_store_enabled}`);
});
```

### Problem 2: "Business missing required fields"

**Cause:** Corrupted business document

**Solution:**
```javascript
const checkBusinessIntegrity = async (businessId) => {
  const docRef = doc(db, 'businesses', businessId);
  const docSnap = await getDoc(docRef);
  
  if (!docSnap.exists()) {
    console.error('Business not found');
    return;
  }
  
  const data = docSnap.data();
  const required = ['id', 'name', 'email', 'phone', 'address', 'status'];
  const missing = required.filter(field => !data[field]);
  
  if (missing.length > 0) {
    console.error(`❌ Missing fields: ${missing.join(', ')}`);
  } else {
    console.log('✅ Business document is complete');
  }
};
```

---

## 🎯 Quick Reference Card

```javascript
// ═══════════════════════════════════════════════════════
// DYNAMOS MARKET - QUICK REFERENCE
// ═══════════════════════════════════════════════════════

// 1. FETCH ONLINE BUSINESSES
const businesses = await getDocs(
  query(
    collection(db, 'businesses'),
    where('online_store_enabled', '==', true),
    where('status', '==', 'active')
  )
);

// 2. FETCH PRODUCTS FOR BUSINESS
const products = await getDocs(
  query(
    collection(db, `businesses/${businessId}/products`),
    where('listedOnline', '==', true),
    where('stock', '>', 0)
  )
);

// 3. GET SINGLE BUSINESS
const business = await getDoc(doc(db, 'businesses', businessId));

// 4. LISTEN TO CHANGES (Real-time)
onSnapshot(doc(db, 'businesses', businessId), (doc) => {
  console.log('Updated:', doc.data());
});
```

---

**End of Guide** • Version 2.0 • November 20, 2025
