# Dynamos Market - E-Commerce App Setup Guide

## 🎯 Project Overview

**Dynamos Market** is the customer-facing e-commerce mobile app that complements the Dynamos POS system. Customers can browse businesses, search products, and make purchases from businesses that have enabled their online stores.

---

## 📋 Prerequisites

- Flutter SDK (3.32.8 or higher)
- Dart SDK (3.8.1 or higher)
- VS Code with Flutter extension
- Firebase account (use same project as Dynamos POS)
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)

---

## 🚀 Step-by-Step Setup

### Step 1: Create New Flutter Project

```powershell
# Navigate to your projects directory
cd C:\

# Create new Flutter project
flutter create dynamos_market

# Navigate into project
cd dynamos_market

# Open in VS Code
code .
```

### Step 2: Update pubspec.yaml

Replace the dependencies section with:

```yaml
name: dynamos_market
description: E-commerce app for Dynamos POS customers
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.8.1 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  get: ^4.6.6
  get_storage: ^2.1.1
  
  # Firebase & Cloud
  firedart: ^0.9.8
  
  # UI Components
  cupertino_icons: ^1.0.8
  iconsax: ^0.0.8
  google_fonts: ^6.1.0
  shimmer: ^3.0.0
  cached_network_image: ^3.3.0
  
  # Location Services
  geolocator: ^14.0.2
  geocoding: ^4.0.0
  google_maps_flutter: ^2.10.0
  
  # Image Handling
  image_picker: ^1.0.7
  
  # Payment
  flutter_paystack: ^1.0.7
  
  # Utils
  intl: ^0.19.0
  uuid: ^4.3.3
  url_launcher: ^6.2.4
  share_plus: ^7.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

flutter:
  uses-material-design: true
  
  assets:
    - assets/
    - assets/icons/
    - assets/images/
```

### Step 3: Install Dependencies

```powershell
flutter pub get
```

### Step 4: Create Project Structure

Create the following folder structure:

```
lib/
├── main.dart
├── constants/
│   ├── app_colors.dart
│   ├── app_constants.dart
│   └── zambia_locations.dart (copy from POS)
├── models/
│   ├── business_model.dart (copy from POS)
│   ├── product_model.dart (copy from POS)
│   ├── customer_model.dart (NEW)
│   ├── order_model.dart (NEW)
│   ├── cart_item_model.dart (NEW)
│   └── address_model.dart (NEW)
├── services/
│   ├── firebase_service.dart
│   ├── auth_service.dart
│   ├── business_service.dart
│   ├── product_service.dart
│   ├── order_service.dart
│   └── location_service.dart
├── controllers/
│   ├── auth_controller.dart
│   ├── business_controller.dart
│   ├── product_controller.dart
│   ├── cart_controller.dart
│   ├── order_controller.dart
│   └── theme_controller.dart
├── views/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── phone_verification_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── business_detail_screen.dart
│   │   └── product_detail_screen.dart
│   ├── search/
│   │   └── search_screen.dart
│   ├── cart/
│   │   ├── cart_screen.dart
│   │   └── checkout_screen.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   ├── orders_screen.dart
│   │   ├── order_detail_screen.dart
│   │   └── settings_screen.dart
│   └── main_navigation.dart
├── widgets/
│   ├── business_card.dart
│   ├── product_card.dart
│   ├── cart_item_widget.dart
│   ├── order_item_widget.dart
│   └── custom_app_bar.dart
└── utils/
    ├── currency_formatter.dart
    ├── date_formatter.dart
    └── validators.dart
```

---

## 🔥 Firebase Configuration

### Shared Database with POS

Use the **same Firebase project** as Dynamos POS to access:
- Businesses with `onlineStoreEnabled: true`
- Products with `listedOnline: true`

### Firestore Collections Structure

```
businesses/
  └── {businessId}/
      ├── onlineStoreEnabled: bool
      ├── name: string
      ├── email: string
      ├── phone: string
      ├── address: string
      ├── province: string
      ├── district: string
      ├── latitude: double
      ├── longitude: double
      ├── businessType: string
      └── products/ (subcollection)
          └── {productId}/
              ├── listedOnline: bool ← FILTER BY THIS
              ├── name: string
              ├── description: string
              ├── price: double
              ├── category: string
              ├── imageUrl: string
              ├── stock: int
              └── variants: array

customers/ (NEW - Create this collection)
  └── {customerId}/
      ├── name: string
      ├── email: string
      ├── phone: string
      ├── createdAt: timestamp
      ├── addresses: array
      └── photoUrl: string

orders/ (NEW - Create this collection)
  └── {orderId}/
      ├── customerId: string
      ├── businessId: string
      ├── businessName: string
      ├── items: array
      │   ├── productId: string
      │   ├── name: string
      │   ├── price: double
      │   ├── quantity: int
      │   └── variant: object
      ├── subtotal: double
      ├── deliveryFee: double
      ├── total: double
      ├── status: string (pending/confirmed/preparing/out_for_delivery/delivered/cancelled)
      ├── deliveryAddress: object
      ├── paymentMethod: string
      ├── paymentStatus: string (pending/paid/failed)
      ├── createdAt: timestamp
      └── updatedAt: timestamp
```

---

## 🎨 Key Features to Implement

### 1. Home Screen (Discovery)
- **Featured Businesses**: Carousel of popular businesses
- **Nearby Businesses**: Using GPS location
- **Categories**: Browse by business type
- **Search Bar**: Quick product/business search
- **Recent Orders**: Quick reorder

### 2. Search Screen
- **Product Search**: Search across all businesses
- **Filters**: Price range, category, location, rating
- **Sort Options**: Price, popularity, distance
- **Business Filter**: Filter by specific business

### 3. Business Detail
- **Business Info**: Name, address, phone, hours
- **Products Grid**: All online products
- **Get Directions**: Integration with maps
- **Call Business**: Phone integration
- **Business Rating**: Customer reviews

### 4. Product Detail
- **Image Gallery**: Product images
- **Description**: Full product details
- **Variants**: Size, color, etc.
- **Stock Status**: Real-time availability
- **Add to Cart**: With quantity selector
- **Business Info**: Where it's sold

### 5. Shopping Cart
- **Cart Items**: Products from multiple businesses
- **Quantity Adjust**: Increase/decrease
- **Remove Items**: Delete from cart
- **Price Breakdown**: Subtotal, delivery, total
- **Checkout Button**: Proceed to payment

### 6. Checkout
- **Delivery Address**: Saved or new address
- **Payment Method**: Card, mobile money, cash on delivery
- **Order Summary**: Review before placing
- **Place Order**: Create order in Firestore

### 7. Profile & Orders
- **Customer Profile**: Edit name, phone, photo
- **Order History**: All past orders
- **Track Order**: Real-time status
- **Saved Addresses**: Manage delivery addresses
- **Settings**: Dark mode, notifications

---

## 💳 Payment Integration

### Supported Payment Methods

1. **Mobile Money** (Priority for Zambia)
   - MTN Mobile Money
   - Airtel Money
   - Zamtel Kwacha

2. **Cards**
   - Visa
   - Mastercard
   - Via Paystack

3. **Cash on Delivery**
   - Pay when order is delivered

### Payment Flow

```
User clicks "Place Order"
    ↓
Select Payment Method
    ↓
If Card/Mobile Money:
  - Process payment via Paystack
  - Update paymentStatus: "paid"
If Cash on Delivery:
  - Set paymentStatus: "pending"
    ↓
Create order in Firestore
    ↓
Notify business (POS receives notification)
    ↓
Show order confirmation to customer
```

---

## 📱 UI/UX Guidelines

### Design Principles
- **Mobile-First**: Optimized for phones
- **Touch-Friendly**: Large tap targets (48x48dp minimum)
- **Fast Loading**: Cached images, lazy loading
- **Clear Navigation**: Bottom navigation + back button
- **Visual Feedback**: Loading states, animations
- **Error Handling**: Friendly error messages

### Color Scheme
```dart
Primary: #2196F3 (Blue)
Secondary: #4CAF50 (Green)
Accent: #FF9800 (Orange)
Error: #F44336 (Red)
Background Light: #FFFFFF
Background Dark: #121212
```

### Bottom Navigation
1. **Home** (🏠) - Business discovery
2. **Search** (🔍) - Product search
3. **Cart** (🛒) - Shopping cart (with badge)
4. **Profile** (👤) - User profile & orders

---

## 🔐 Authentication Flow

### Customer Registration
```dart
1. Enter phone number
2. Send OTP via SMS
3. Verify OTP
4. Enter name and email
5. Create customer account
6. Save to Firestore customers/
```

### Customer Login
```dart
1. Enter phone number
2. Send OTP
3. Verify OTP
4. Fetch customer data
5. Navigate to home
```

---

## 🚀 Development Phases

### Phase 1: Foundation (Week 1)
- [ ] Project setup
- [ ] Firebase integration
- [ ] Authentication system
- [ ] Basic navigation
- [ ] Theme controller (dark mode)

### Phase 2: Business & Product Discovery (Week 2)
- [ ] Home screen with business listing
- [ ] Business detail screen
- [ ] Product detail screen
- [ ] Search functionality
- [ ] Filters and sorting

### Phase 3: Shopping Cart (Week 3)
- [ ] Cart controller
- [ ] Add to cart functionality
- [ ] Cart screen with items
- [ ] Quantity management
- [ ] Cart persistence

### Phase 4: Checkout & Orders (Week 4)
- [ ] Checkout screen
- [ ] Address management
- [ ] Payment integration
- [ ] Order creation
- [ ] Order confirmation

### Phase 5: User Profile (Week 5)
- [ ] Profile screen
- [ ] Order history
- [ ] Order tracking
- [ ] Settings screen
- [ ] Edit profile

### Phase 6: Polish & Testing (Week 6)
- [ ] Loading states
- [ ] Error handling
- [ ] Animations
- [ ] Performance optimization
- [ ] Testing

---

## 📊 Real-Time Sync with POS

### How It Works

**Scenario 1: Stock Updates**
```
Customer views product (stock: 10)
    ↓
Business sells 3 in POS
    ↓
POS updates Firestore (stock: 7)
    ↓
Market app listens to Firestore
    ↓
Market app updates product (stock: 7)
    ↓
Customer sees updated stock
```

**Scenario 2: Product Unlisted**
```
Customer adds product to cart
    ↓
Business unlists product in POS
    ↓
POS updates Firestore (listedOnline: false)
    ↓
Market app detects change
    ↓
Product removed from listings
    ↓
Cart shows "Product unavailable"
```

**Scenario 3: Order Notification**
```
Customer places order
    ↓
Order created in Firestore orders/
    ↓
POS listens to new orders
    ↓
POS shows notification
    ↓
Business accepts/prepares order
    ↓
Status updated in Firestore
    ↓
Customer sees status update in real-time
```

---

## 🛠️ Utilities to Copy from POS

### From pos_software/lib/constants/
- `zambia_locations.dart` - Province and district data

### From pos_software/lib/models/
- `business_model.dart` - Business entity
- `product_model.dart` - Product entity

### From pos_software/lib/utils/
- `colors.dart` - App colors (adapt for Market)
- `currency_formatter.dart` - ZMW formatting

### Create New Models

**customer_model.dart**
```dart
class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<Address> addresses;
  final String? photoUrl;
  final DateTime createdAt;
  
  // fromJson, toJson, copyWith
}
```

**order_model.dart**
```dart
class OrderModel {
  final String id;
  final String customerId;
  final String businessId;
  final String businessName;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status;
  final Address deliveryAddress;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime createdAt;
  
  // fromJson, toJson, copyWith
}
```

**cart_item_model.dart**
```dart
class CartItem {
  final ProductModel product;
  final int quantity;
  final ProductVariant? selectedVariant;
  
  double get totalPrice => 
    (product.price + (selectedVariant?.priceAdjustment ?? 0)) * quantity;
}
```

---

## 📱 Sample Screens Code Structure

### Home Screen Structure
```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Dynamos Market'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            SearchBar(),
            
            // Featured Businesses Carousel
            FeaturedBusinesses(),
            
            // Categories
            CategoryChips(),
            
            // Nearby Businesses
            NearbyBusinesses(),
            
            // Popular Products
            PopularProducts(),
          ],
        ),
      ),
    );
  }
}
```

### Search Screen Structure
```dart
class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SearchTextField(),
        actions: [FilterButton()],
      ),
      body: Column(
        children: [
          // Filter Chips
          FilterChips(),
          
          // Results Count
          ResultsCount(),
          
          // Product Grid
          Expanded(
            child: ProductGrid(),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔔 Push Notifications

### Setup Firebase Cloud Messaging

```yaml
# Add to pubspec.yaml
firebase_messaging: ^14.7.10
```

### Notification Types
1. **Order Status Updates**
   - Order confirmed
   - Order preparing
   - Out for delivery
   - Delivered

2. **Promotional**
   - New businesses
   - Special offers
   - Flash sales

---

## 🗺️ Location Features

### GPS-Based Business Discovery

```dart
// Get current location
Position position = await Geolocator.getCurrentPosition();

// Calculate distance to businesses
double distance = Geolocator.distanceBetween(
  position.latitude,
  position.longitude,
  business.latitude!,
  business.longitude!,
);

// Sort by distance
businesses.sort((a, b) => 
  getDistance(userLocation, a) - getDistance(userLocation, b)
);
```

### Get Directions Integration

```dart
void openMapsForDirections(double lat, double lng) async {
  final url = Platform.isIOS
    ? 'maps://?q=$lat,$lng'
    : 'geo:$lat,$lng';
  
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  }
}
```

---

## 🎯 Success Metrics

### Key Performance Indicators
- **App Launch Time**: < 3 seconds
- **Search Response**: < 500ms
- **Cart Load Time**: < 200ms
- **Order Placement**: < 2 seconds
- **Crash Rate**: < 0.1%
- **User Retention**: > 40% (30 days)

---

## 📝 Next Steps

1. **Create the project**: `flutter create dynamos_market`
2. **Copy this guide** into the new project
3. **Set up Firebase** with same project as POS
4. **Start with Phase 1**: Authentication and navigation
5. **Iterate**: Build feature by feature
6. **Test**: On real devices with real data
7. **Deploy**: To Play Store and App Store

---

## 🆘 Getting Help

When setting up in a new folder, use this prompt with Copilot:

```
I'm building Dynamos Market, an e-commerce app for the Dynamos POS system.

Context:
- Customer-facing mobile app
- Connects to same Firestore as Dynamos POS
- Shows businesses with onlineStoreEnabled=true
- Shows products with listedOnline=true
- Features: browsing, search, cart, checkout, orders
- Using Flutter + GetX + Firestore
- Target: Zambian market

Current task: [Describe what you need help with]

Reference: See DYNAMOS_MARKET_SETUP_GUIDE.md for full architecture
```

---

## 📚 Additional Resources

- **Dynamos POS Repo**: Reference for models and services
- **Flutter Docs**: https://flutter.dev/docs
- **GetX Docs**: https://pub.dev/packages/get
- **Firestore Docs**: https://firebase.google.com/docs/firestore
- **Paystack Docs**: https://paystack.com/docs

---

**Created**: Current Session  
**Last Updated**: Current Session  
**Version**: 1.0.0  
**Status**: Ready for Implementation 🚀
