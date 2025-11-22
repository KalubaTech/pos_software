# Business Registration and Auth Flow Implementation

**Date:** November 19, 2025  
**Status:** 🚧 In Progress  
**Goal:** Implement complete business registration and authentication flow

---

## 🎯 Overview

Implemented a comprehensive business registration system where:
1. **First-time users** must register their business
2. **Business registration** requires admin approval from Dynamos team
3. **Business status** can be: pending, active, inactive, or rejected
4. **Admin users** can add cashiers/staff with roles and permissions

---

## ✅ Completed Work

### 1. Business Model (`lib/models/business_model.dart`)

**Status:** ✅ Complete

Created comprehensive business model with:

```dart
enum BusinessStatus {
  pending,    // Awaiting admin approval
  active,     // Approved and operational
  inactive,   // Suspended or deactivated
  rejected,   // Application rejected
}

class BusinessModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? city;
  final String? country;
  final String? taxId;
  final String? website;
  final String adminId;          // Admin who registered
  final BusinessStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;       // Dynamos admin ID
  final String? rejectionReason;
  final String? logo;
  final Map<String, dynamic>? settings;
  
  // Helper methods
  bool get isActive
  bool get isPending
  bool get isInactive
  bool get isRejected
  String get statusLabel
  String get statusDescription
}
```

**Features:**
- ✅ Complete JSON serialization (fromJson/toJson)
- ✅ Business status tracking
- ✅ Admin approval workflow
- ✅ Comprehensive business information
- ✅ Helper getters for status checks
- ✅ Copy with method for updates

---

### 2. Business Service (`lib/services/business_service.dart`)

**Status:** ✅ Complete

Created service for managing businesses in Firestore:

**Methods:**
```dart
// Registration & Retrieval
Future<BusinessModel?> registerBusiness(...)  // Register new business
Future<BusinessModel?> getBusinessById(String businessId)
Future<BusinessStatus?> checkBusinessStatus()
Future<bool> updateBusiness(BusinessModel business)

// Admin Operations
Future<bool> approveBusiness(String businessId, String adminId)
Future<bool> rejectBusiness(String businessId, String reason)
Future<bool> suspendBusiness(String businessId)
Future<bool> reactivateBusiness(String businessId)
Future<List<BusinessModel>> getPendingBusinesses()

// Local Management
Future<void> clearBusiness()
```

**Features:**
- ✅ Firestore integration
- ✅ Local storage caching
- ✅ Observable state management (GetX)
- ✅ Automatic business loading on init
- ✅ Error handling and logging
- ✅ Admin approval workflow

**Firestore Structure:**
```
business_registrations/          (Top-level collection)
  ├── {businessId}/
      ├── id: string
      ├── name: string
      ├── email: string
      ├── status: "pending"|"active"|"inactive"|"rejected"
      ├── admin_id: string
      ├── created_at: timestamp
      ├── approved_at: timestamp
      └── ... (other fields)

businesses/                       (Created when approved)
  ├── {businessId}/
      ├── id: string
      ├── name: string
      ├── status: "active"
      └── (sub-collections for synced data)
```

---

### 3. Firedart Sync Service Updates (`lib/services/firedart_sync_service.dart`)

**Status:** ✅ Complete

Added methods to support top-level collections:

```dart
// Push to top-level or business sub-collection
Future<void> pushToCloud(
  String collection,
  String documentId,
  Map<String, dynamic> data, {
  bool isTopLevel = false,  // NEW: For collections not under businesses/{id}/
})

// Get single document from top-level collection
Future<Map<String, dynamic>?> getDocument(
  String collection,
  String documentId,
)

// Get document from business sub-collection
Future<Map<String, dynamic>?> getBusinessDocument(
  String collection,
  String documentId,
)
```

**Changes:**
- ✅ Added `isTopLevel` parameter to pushToCloud()
- ✅ Created getDocument() for top-level collections
- ✅ Created getBusinessDocument() for business sub-collections
- ✅ No breaking changes to existing code

---

### 4. Business Registration View (`lib/views/auth/business_registration_view.dart`)

**Status:** 🚧 Created (needs color fixes)

Created comprehensive 3-step registration form:

**Step 1: Business Information**
- Business name (required)
- Email address (required, validated)
- Phone number (required)
- Business address (required)
- City (optional)
- Country (optional)
- Tax ID (optional)
- Website (optional)

**Step 2: Admin Account**
- Full name (required)
- Email address (required, validated)
- PIN (4 digits, required)
- Confirm PIN (must match)
- Info: "You will be the admin of this business"

**Step 3: Review**
- Shows all entered information
- Warning: "Pending approval from Dynamos admin"
- Submit button

**Features:**
- ✅ 3-step wizard with progress indicator
- ✅ Form validation
- ✅ Animated transitions (animate_do)
- ✅ Dark mode support
- ✅ Responsive design
- ✅ Creates admin cashier automatically
- ✅ Success dialog with approval notice
- ⚠️ **Needs color fixes** (textPrimary/textSecondary errors)

---

## 🚧 Pending Work

### 1. Fix Business Registration View Colors

**Issue:** Using non-existent AppColors properties (textPrimary, textSecondary)

**Solution:** Replace with:
- `AppColors.getTextPrimary(isDark)`
- `AppColors.getTextSecondary(isDark)`
- Or use `Colors.black` / `Colors.grey[700]`

**Files to fix:**
- `lib/views/auth/business_registration_view.dart` (~18 occurrences)

---

### 2. Update Auth Controller

**File:** `lib/controllers/auth_controller.dart`

**Changes Needed:**
```dart
class AuthController extends GetxController {
  final BusinessService _businessService = Get.find<BusinessService>();
  
  // Add business-aware login
  Future<bool> loginWithBusinessCheck(String pin) async {
    // Check if business exists and is active
    final business = _businessService.currentBusiness.value;
    
    if (business == null) {
      // No business registered - redirect to registration
      return false;
    }
    
    if (!business.isActive) {
      // Business not active - show status message
      _showBusinessStatusDialog(business);
      return false;
    }
    
    // Business is active - proceed with normal login
    return await login(pin);
  }
  
  void _showBusinessStatusDialog(BusinessModel business) {
    Get.dialog(AlertDialog(
      title: Text('Business ${business.statusLabel}'),
      content: Text(business.statusDescription),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('OK'),
        ),
      ],
    ));
  }
}
```

---

### 3. Update Login View

**File:** `lib/views/auth/login_view.dart`

**Changes Needed:**

```dart
@override
void initState() {
  super.initState();
  _checkBusinessStatus();
}

Future<void> _checkBusinessStatus() async {
  final businessService = Get.find<BusinessService>();
  
  // Check if business exists
  if (businessService.currentBusiness.value == null) {
    // No business - show registration prompt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRegistrationPrompt();
    });
    return;
  }
  
  // Check business status
  final business = businessService.currentBusiness.value!;
  
  if (!business.isActive) {
    // Business not active - show status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showBusinessStatusDialog(business);
    });
  }
}

void _showRegistrationPrompt() {
  Get.dialog(
    AlertDialog(
      title: Row(
        children: [
          Icon(Iconsax.shop, color: AppColors.primary),
          SizedBox(width: 12),
          Text('Welcome to Dynamos POS'),
        ],
      ),
      content: Text(
        'To get started, please register your business. Your registration will be reviewed by our team.',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            Get.to(() => BusinessRegistrationView());
          },
          child: Text('Register Business'),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}
```

---

### 4. Update Cashier Model

**File:** `lib/models/cashier_model.dart`

**Add:**
```dart
class CashierModel {
  final String businessId;  // NEW: Link cashier to business
  // ... existing fields
  
  CashierModel({
    required this.businessId,  // NEW
    // ... existing parameters
  });
}
```

**Update database methods to:**
- Filter cashiers by business ID
- Prevent cross-business access
- Include business ID in queries

---

### 5. Create Admin Approval Dashboard

**New File:** `lib/views/admin/business_approval_view.dart`

**Features:**
- List all pending businesses
- View business details
- Approve with reason
- Reject with reason
- Suspend active businesses
- Reactivate suspended businesses

**Access Control:**
- Only accessible by Dynamos super-admins
- Separate from regular business admins
- Admin credentials stored in environment

---

### 6. Add Business Status Check Middleware

**New File:** `lib/middleware/business_status_middleware.dart`

```dart
class BusinessStatusMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final businessService = Get.find<BusinessService>();
    
    if (businessService.currentBusiness.value == null) {
      return RouteSettings(name: '/business-registration');
    }
    
    if (!businessService.hasActiveBusiness) {
      return RouteSettings(name: '/business-status');
    }
    
    return null; // Allow navigation
  }
}
```

**Apply to routes:**
```dart
GetPage(
  name: '/home',
  page: () => HomeView(),
  middlewares: [BusinessStatusMiddleware()],
),
```

---

### 7. Create Business Status View

**New File:** `lib/views/auth/business_status_view.dart`

Shows current business status with appropriate actions:

**Pending:**
- Orange banner
- "Your business is under review"
- Estimated approval time
- Contact support button

**Rejected:**
- Red banner
- Rejection reason
- Appeal process
- Re-register button

**Inactive:**
- Yellow banner
- "Your business has been suspended"
- Contact support to reactivate
- Support contact info

---

### 8. Add Notifications

**Firebase Cloud Messaging:**
- Notify business when approved
- Notify business when rejected
- Notify business when suspended
- Notify admin when new registration

---

## 📊 Database Schema

### Local SQLite

```sql
-- Update cashiers table
CREATE TABLE cashiers (
  id TEXT PRIMARY KEY,
  business_id TEXT NOT NULL,  -- NEW
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  pin TEXT NOT NULL,
  role TEXT NOT NULL,
  is_active INTEGER DEFAULT 1,
  created_at TEXT,
  last_login TEXT,
  FOREIGN KEY (business_id) REFERENCES businesses(id)
);

-- New businesses table
CREATE TABLE businesses (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT NOT NULL,
  city TEXT,
  country TEXT,
  status TEXT NOT NULL,
  admin_id TEXT NOT NULL,
  created_at TEXT,
  approved_at TEXT
);
```

### Firestore

```
business_registrations/          Top-level collection
  └── {businessId}/              Document per business
      ├── id: string
      ├── name: string
      ├── email: string
      ├── phone: string
      ├── address: string
      ├── city?: string
      ├── country?: string
      ├── tax_id?: string
      ├── website?: string
      ├── admin_id: string       Admin who registered
      ├── status: enum           pending|active|inactive|rejected
      ├── created_at: timestamp
      ├── approved_at?: timestamp
      ├── approved_by?: string   Dynamos admin ID
      ├── rejection_reason?: string
      └── syncMetadata: {}

businesses/                      Created when approved
  └── {businessId}/              Business workspace
      ├── products/              Synced data
      ├── transactions/
      ├── customers/
      ├── wallets/
      ├── subscriptions/
      └── ... (other collections)
```

---

## 🔄 Authentication Flow

### New User Journey

```
1. Open App
   ↓
2. No business found
   ↓
3. Show "Register Business" dialog
   ↓
4. Fill Business Registration Form (3 steps)
   ↓
5. Submit → Status: PENDING
   ↓
6. Wait for Dynamos admin approval
   ↓
7. Receive approval notification
   ↓
8. Login with admin PIN
   ↓
9. Access full POS features
```

### Existing User Journey

```
1. Open App
   ↓
2. Check business status
   ├─→ ACTIVE → Show login PIN screen
   ├─→ PENDING → Show "Under Review" screen
   ├─→ INACTIVE → Show "Suspended" screen
   └─→ REJECTED → Show "Rejected" screen with reason
```

---

## 🎨 UI Components Created

### Business Registration View
- ✅ 3-step wizard
- ✅ Progress indicator
- ✅ Form validation
- ✅ Dark mode support
- ⚠️ Needs color fixes

### Pending Components
- ⏳ Business Status View
- ⏳ Admin Approval Dashboard
- ⏳ Business Status Dialog
- ⏳ Registration Prompt Dialog

---

## 🧪 Testing Checklist

### Business Registration
- [ ] Register new business with all fields
- [ ] Register with minimum required fields
- [ ] Validate email format
- [ ] Validate phone number
- [ ] Validate PIN (4 digits)
- [ ] Validate PIN confirmation match
- [ ] Test form navigation (Next/Back)
- [ ] Test form submission
- [ ] Verify Firestore document created
- [ ] Verify admin cashier created
- [ ] Verify success dialog shown

### Business Status
- [ ] Login with pending business
- [ ] Login with rejected business
- [ ] Login with inactive business
- [ ] Login with active business
- [ ] Test status check on app start
- [ ] Test status refresh

### Admin Approval
- [ ] View pending businesses
- [ ] Approve business
- [ ] Reject business with reason
- [ ] Suspend active business
- [ ] Reactivate suspended business
- [ ] Verify Firestore updates
- [ ] Verify businesses collection created on approval

---

## 📝 Next Steps (Priority Order)

1. **Fix Business Registration View Colors** (Quick fix)
   - Replace AppColors.textPrimary/textSecondary
   - Test form rendering

2. **Update AuthController** (High priority)
   - Add business status checks
   - Add business-aware login
   - Add status dialogs

3. **Update Login View** (High priority)
   - Add business status check on init
   - Add registration prompt
   - Add status dialogs

4. **Update Cashier Model** (Medium priority)
   - Add business_id field
   - Update database schema
   - Update queries

5. **Create Business Status View** (Medium priority)
   - Pending status screen
   - Rejected status screen
   - Inactive status screen

6. **Create Admin Dashboard** (Low priority)
   - Approval interface
   - Business list
   - Admin actions

7. **Add Middleware** (Low priority)
   - Route protection
   - Status-based redirects

8. **Add Notifications** (Future)
   - FCM integration
   - Status change notifications

---

## 🎯 Success Criteria

✅ **Phase 1: Registration** (Current)
- Users can register businesses
- Data saves to Firestore
- Admin accounts created

🚧 **Phase 2: Status Management** (Next)
- Status checks on login
- Appropriate screens for each status
- Clear user communication

⏳ **Phase 3: Admin Approval** (Future)
- Dynamos team can approve/reject
- Notifications sent
- Businesses activated

⏳ **Phase 4: Multi-User** (Future)
- Cashiers linked to businesses
- Role-based permissions
- Business isolation

---

## 📞 Files Modified

### Created Files (4)
1. ✅ `lib/models/business_model.dart`
2. ✅ `lib/services/business_service.dart`
3. 🚧 `lib/views/auth/business_registration_view.dart` (needs fixes)
4. ✅ `BUSINESS_AUTH_FLOW_SUMMARY.md` (this file)

### Modified Files (2)
1. ✅ `lib/services/firedart_sync_service.dart`
   - Added isTopLevel parameter to pushToCloud()
   - Added getDocument() method
   - Added getBusinessDocument() method

2. ⏳ `lib/controllers/auth_controller.dart` (pending)
3. ⏳ `lib/views/auth/login_view.dart` (pending)

---

**Last Updated:** November 19, 2025  
**Version:** 1.0  
**Status:** Phase 1 - 80% Complete
