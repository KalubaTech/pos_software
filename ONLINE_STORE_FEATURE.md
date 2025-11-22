# Online Store Feature

## Overview
The online store feature allows businesses to activate/deactivate their online presence and control which products are listed online. This lays the foundation for future e-commerce capabilities.

## Implementation Summary

### 1. Data Models Updated

#### BusinessModel (`lib/models/business_model.dart`)
Added new field:
```dart
final bool onlineStoreEnabled; // Defaults to false
```

This field controls whether the business's online store is active.

#### ProductModel (`lib/models/product_model.dart`)
Added new field:
```dart
final bool listedOnline; // Defaults to false
```

This field controls whether individual products appear in the online store.

### 2. Controller Logic

#### BusinessSettingsController (`lib/controllers/business_settings_controller.dart`)
Added properties and methods:

**Properties:**
- `onlineStoreEnabled` - Observable boolean for store status
- `onlineProductCount` - Observable integer for counting online products

**Methods:**
- `toggleOnlineStore(bool value)` - Toggle online store status
- `updateOnlineProductCount(int count)` - Update the count of online products
- `_updateOnlineProductCount()` - Internal helper to refresh count

**Persistence:**
- Stores setting in GetStorage as `'online_store_enabled'`
- Loads on controller initialization
- Saves when toggled

### 3. User Interface

#### Business Settings View (`lib/views/settings/business_settings_view.dart`)
Added new section: `_buildOnlineStoreSettings()`

**Features:**
- **Toggle Switch**: Enable/disable online store with visual feedback
  - Green indicator when enabled
  - Orange indicator when disabled
- **Info Card**: Shows when enabled, explains how to list products
- **Statistics Cards**: 
  - Products Online count (will be updated when products are listed)
  - Store Status (Active/Inactive)

**Layout:**
```
Business Settings
  ├── Store Information
  ├── Tax Configuration
  ├── Currency Settings
  ├── Receipt Settings
  ├── Operating Hours
  ├── Payment Methods
  └── Online Store Settings (NEW)
      ├── Toggle Switch
      ├── Info Card (when enabled)
      └── Statistics (Products Online, Store Status)
```

## Usage Guide

### For Business Owners

#### Activating Online Store:
1. Open **Business Settings**
2. Scroll to **Online Store Settings**
3. Toggle the switch to **ON**
4. You'll see a confirmation message
5. Info card appears explaining next steps

#### Listing Products Online:
(Coming in next phase)
- Go to product management
- Edit a product
- Toggle "List Online" switch
- Product will appear in online store

#### Deactivating Online Store:
1. Open **Business Settings**
2. Toggle the switch to **OFF**
3. Confirmation message appears
4. All products are automatically unlisted

### For Developers

#### Checking Online Store Status:
```dart
final settingsController = Get.find<BusinessSettingsController>();
bool isOnline = settingsController.onlineStoreEnabled.value;
```

#### Reacting to Status Changes:
```dart
Obx(() {
  if (settingsController.onlineStoreEnabled.value) {
    // Store is online
  } else {
    // Store is offline
  }
})
```

#### Updating Product Count:
```dart
// When products are listed/unlisted
final count = products.where((p) => p.listedOnline).length;
settingsController.updateOnlineProductCount(count);
```

## Next Steps

### Phase 1: Product UI (In Progress)
- [ ] Add "List Online" toggle in product detail view
- [ ] Add "List Online" toggle in product edit view
- [ ] Show online status badge in product list
- [ ] Disable toggle when online store is disabled
- [ ] Update online product count when toggled

### Phase 2: Product Controller Integration
- [ ] Add `toggleProductOnlineStatus()` method
- [ ] Integrate with BusinessSettingsController
- [ ] Bulk unlist products when store is disabled
- [ ] Sync online status to Firestore

### Phase 3: Online Store Configuration
- [ ] Store URL/subdomain settings
- [ ] Online store branding (logo, colors, banner)
- [ ] Shipping/delivery options
- [ ] Online payment methods configuration

### Phase 4: Public Online Store
- [ ] Customer-facing web interface
- [ ] Product browsing and search
- [ ] Shopping cart functionality
- [ ] Order placement system
- [ ] Customer accounts

## Technical Notes

### Database Structure
```
businesses/{businessId}/
  - onlineStoreEnabled: bool
  - ... other fields
  
  products/{productId}/
    - listedOnline: bool
    - ... other fields
```

### Storage Keys
- `online_store_enabled` - Boolean in GetStorage

### Dependencies
- GetX for state management
- GetStorage for persistence
- Existing BusinessModel and ProductModel

### Business Logic
1. **Default State**: Online store is disabled for new businesses
2. **Product Listing**: Products default to not listed online
3. **Cascading Disable**: When store is disabled, all products should be unlisted (to be implemented)
4. **Permission**: Only admins/managers can toggle online store

## Benefits

### For Businesses:
- ✅ Expand reach beyond physical location
- ✅ 24/7 availability for customers
- ✅ Control over online presence
- ✅ Easy product listing management
- ✅ Future-ready for e-commerce growth

### For Customers:
- ✅ Browse products from home
- ✅ Check availability before visiting
- ✅ Future: Order online for pickup/delivery
- ✅ Better shopping experience

## Testing Checklist

- [ ] Toggle online store ON → Confirmation appears
- [ ] Toggle online store OFF → Confirmation appears
- [ ] Settings persist after app restart
- [ ] Statistics show correct values
- [ ] Dark mode displays correctly
- [ ] Info card shows when enabled
- [ ] Info card hides when disabled
- [ ] Reset to defaults clears online store setting

## Related Files

### Core Implementation:
- `lib/models/business_model.dart` - Business entity with onlineStoreEnabled
- `lib/models/product_model.dart` - Product entity with listedOnline
- `lib/controllers/business_settings_controller.dart` - Online store state management
- `lib/views/settings/business_settings_view.dart` - Online store UI

### Documentation:
- `ONLINE_STORE_FEATURE.md` (this file) - Complete feature guide

## Version History

### v1.0 (Current)
- ✅ Business-level online store toggle
- ✅ Data models updated (BusinessModel, ProductModel)
- ✅ Controller logic with persistence
- ✅ Settings UI with statistics
- ⏳ Product UI for listing online (next phase)

---

**Status**: Foundation Complete ✅  
**Next Phase**: Product Listing UI  
**Last Updated**: Current Session
