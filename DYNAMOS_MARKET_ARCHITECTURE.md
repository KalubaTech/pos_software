# Dynamos Market - Complete Architecture Document

## 🏗️ System Architecture

### Overview
Dynamos Market is a customer-facing e-commerce mobile application that integrates with the Dynamos POS system through a shared Firestore database.

```
┌─────────────────────────────────────────────────────────────┐
│                     DYNAMOS ECOSYSTEM                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────┐           ┌────────────────────┐     │
│  │  Dynamos POS     │           │  Dynamos Market    │     │
│  │  (Desktop/Mobile)│           │  (Mobile App)      │     │
│  │                  │           │                    │     │
│  │  • Inventory     │           │  • Browse          │     │
│  │  • Sales         │◄─────────►│  • Search          │     │
│  │  • Customers     │  Firestore │  • Cart           │     │
│  │  • Reports       │   Sync    │  • Checkout        │     │
│  │  • Settings      │           │  • Orders          │     │
│  └──────────────────┘           └────────────────────┘     │
│         │                                  │                │
│         └──────────────┬───────────────────┘                │
│                        │                                    │
│                ┌───────▼──────┐                            │
│                │   Firebase    │                            │
│                │   Firestore   │                            │
│                │               │                            │
│                │  • businesses │                            │
│                │  • products   │                            │
│                │  • customers  │                            │
│                │  • orders     │                            │
│                └───────────────┘                            │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Data Models (Complete Definitions)

### 1. CustomerModel (NEW)

```dart
class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<AddressModel> addresses;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool emailVerified;
  final bool phoneVerified;
  
  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.addresses = const [],
    this.photoUrl,
    required this.createdAt,
    this.updatedAt,
    this.emailVerified = false,
    this.phoneVerified = false,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      addresses: (json['addresses'] as List?)
          ?.map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      emailVerified: json['emailVerified'] as bool? ?? false,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'addresses': addresses.map((e) => e.toJson()).toList(),
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    List<AddressModel>? addresses,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? emailVerified,
    bool? phoneVerified,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      addresses: addresses ?? this.addresses,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
    );
  }
}
```

### 2. AddressModel (NEW)

```dart
class AddressModel {
  final String id;
  final String label; // Home, Work, Other
  final String fullAddress;
  final String? province;
  final String? district;
  final double? latitude;
  final double? longitude;
  final String? phoneNumber;
  final String? instructions; // Delivery instructions
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.fullAddress,
    this.province,
    this.district,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.instructions,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      label: json['label'] as String,
      fullAddress: json['fullAddress'] as String,
      province: json['province'] as String?,
      district: json['district'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      phoneNumber: json['phoneNumber'] as String?,
      instructions: json['instructions'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'fullAddress': fullAddress,
      'province': province,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'instructions': instructions,
      'isDefault': isDefault,
    };
  }
}
```

### 3. OrderModel (NEW)

```dart
class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String businessId;
  final String businessName;
  final String businessPhone;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final AddressModel deliveryAddress;
  final String paymentMethod;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;
  final String? cancellationReason;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.businessId,
    required this.businessName,
    required this.businessPhone,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    this.cancellationReason,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      businessId: json['businessId'] as String,
      businessName: json['businessName'] as String,
      businessPhone: json['businessPhone'] as String,
      items: (json['items'] as List)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: OrderStatus.values.byName(json['status'] as String),
      deliveryAddress: AddressModel.fromJson(
        json['deliveryAddress'] as Map<String, dynamic>,
      ),
      paymentMethod: json['paymentMethod'] as String,
      paymentStatus: PaymentStatus.values.byName(
        json['paymentStatus'] as String,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      notes: json['notes'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'businessId': businessId,
      'businessName': businessName,
      'businessPhone': businessPhone,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status.name,
      'deliveryAddress': deliveryAddress.toJson(),
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notes': notes,
      'cancellationReason': cancellationReason,
    };
  }
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled,
  refunded
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded
}
```

### 4. OrderItem

```dart
class OrderItem {
  final String productId;
  final String productName;
  final String? imageUrl;
  final double price;
  final int quantity;
  final ProductVariant? variant;
  final double total;

  OrderItem({
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.price,
    required this.quantity,
    this.variant,
    required this.total,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      imageUrl: json['imageUrl'] as String?,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      variant: json['variant'] != null
          ? ProductVariant.fromJson(json['variant'] as Map<String, dynamic>)
          : null,
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'variant': variant?.toJson(),
      'total': total,
    };
  }
}
```

### 5. CartItemModel (NEW)

```dart
class CartItemModel {
  final String id;
  final ProductModel product;
  final int quantity;
  final ProductVariant? selectedVariant;
  final String businessId;
  final String businessName;

  CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    this.selectedVariant,
    required this.businessId,
    required this.businessName,
  });

  double get unitPrice =>
      product.price + (selectedVariant?.priceAdjustment ?? 0);

  double get totalPrice => unitPrice * quantity;

  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
    ProductVariant? selectedVariant,
    String? businessId,
    String? businessName,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      businessId: businessId ?? this.businessId,
      businessName: businessName ?? this.businessName,
    );
  }
}
```

---

## 🎛️ Controllers Architecture

### 1. AuthController

```dart
class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final Rx<CustomerModel?> currentCustomer = Rx<CustomerModel?>(null);
  final isAuthenticated = false.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Check if user is logged in
    final customerId = GetStorage().read('customerId');
    if (customerId != null) {
      await fetchCustomerData(customerId);
    }
  }

  Future<bool> loginWithPhone(String phone, String otp) async {
    // Verify OTP and login
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
  }) async {
    // Create customer account
  }

  Future<void> logout() async {
    // Clear session
  }

  Future<void> fetchCustomerData(String customerId) async {
    // Fetch from Firestore
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    // Update customer data
  }
}
```

### 2. BusinessController

```dart
class BusinessController extends GetxController {
  final BusinessService _businessService = Get.find<BusinessService>();
  
  final businesses = <BusinessModel>[].obs;
  final featuredBusinesses = <BusinessModel>[].obs;
  final nearbyBusinesses = <BusinessModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOnlineBusinesses();
  }

  Future<void> fetchOnlineBusinesses() async {
    // Fetch businesses where onlineStoreEnabled = true
    isLoading.value = true;
    try {
      final result = await _businessService.getOnlineBusinesses();
      businesses.value = result;
      _categorizeBusinesses();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load businesses');
    } finally {
      isLoading.value = false;
    }
  }

  void _categorizeBusinesses() {
    // Separate featured and nearby businesses
  }

  Future<BusinessModel?> getBusinessById(String businessId) async {
    // Fetch single business
  }

  List<BusinessModel> searchBusinesses(String query) {
    // Search by name, category, location
  }

  List<BusinessModel> filterByCategory(String category) {
    // Filter by business type
  }

  List<BusinessModel> sortByDistance(double userLat, double userLng) {
    // Sort businesses by distance from user
  }
}
```

### 3. ProductController

```dart
class ProductController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();
  
  final products = <ProductModel>[].obs;
  final featuredProducts = <ProductModel>[].obs;
  final isLoading = false.obs;

  Future<void> fetchOnlineProducts() async {
    // Fetch all products where listedOnline = true
    isLoading.value = true;
    try {
      final result = await _productService.getOnlineProducts();
      products.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ProductModel>> fetchBusinessProducts(String businessId) async {
    // Fetch products for specific business
    return await _productService.getBusinessProducts(businessId);
  }

  List<ProductModel> searchProducts(String query) {
    // Search by name, description, category
    return products
        .where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<ProductModel> filterByCategory(String category) {
    // Filter by category
  }

  List<ProductModel> filterByPriceRange(double min, double max) {
    // Filter by price
  }
}
```

### 4. CartController

```dart
class CartController extends GetxController {
  final cartItems = <CartItemModel>[].obs;
  
  double get subtotal =>
      cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  double get deliveryFee => 50.0; // Fixed for now

  double get total => subtotal + deliveryFee;

  int get itemCount => cartItems.length;

  void addToCart(
    ProductModel product,
    String businessId,
    String businessName, {
    int quantity = 1,
    ProductVariant? variant,
  }) {
    // Check if item already in cart
    final existingIndex = cartItems.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedVariant?.id == variant?.id,
    );

    if (existingIndex != -1) {
      // Increase quantity
      final existing = cartItems[existingIndex];
      cartItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      // Add new item
      cartItems.add(CartItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
        quantity: quantity,
        selectedVariant: variant,
        businessId: businessId,
        businessName: businessName,
      ));
    }

    Get.snackbar('Added to Cart', '${product.name} added to cart');
    _saveCart();
  }

  void removeFromCart(String itemId) {
    cartItems.removeWhere((item) => item.id == itemId);
    _saveCart();
  }

  void updateQuantity(String itemId, int newQuantity) {
    final index = cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      if (newQuantity <= 0) {
        removeFromCart(itemId);
      } else {
        cartItems[index] = cartItems[index].copyWith(quantity: newQuantity);
        _saveCart();
      }
    }
  }

  void clearCart() {
    cartItems.clear();
    _saveCart();
  }

  void _saveCart() {
    // Save to GetStorage for persistence
  }

  void _loadCart() {
    // Load from GetStorage
  }

  Map<String, List<CartItemModel>> groupByBusiness() {
    // Group cart items by business
    final grouped = <String, List<CartItemModel>>{};
    for (var item in cartItems) {
      if (!grouped.containsKey(item.businessId)) {
        grouped[item.businessId] = [];
      }
      grouped[item.businessId]!.add(item);
    }
    return grouped;
  }
}
```

### 5. OrderController

```dart
class OrderController extends GetxController {
  final OrderService _orderService = Get.find<OrderService>();
  
  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;

  Future<void> fetchCustomerOrders(String customerId) async {
    // Fetch all orders for customer
    isLoading.value = true;
    try {
      final result = await _orderService.getCustomerOrders(customerId);
      orders.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load orders');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> placeOrder({
    required List<CartItemModel> items,
    required AddressModel deliveryAddress,
    required String paymentMethod,
    String? notes,
  }) async {
    // Create order in Firestore
    try {
      final authController = Get.find<AuthController>();
      final customer = authController.currentCustomer.value!;

      // Group items by business (one order per business)
      final grouped = _groupItemsByBusiness(items);

      final orderIds = <String>[];

      for (var entry in grouped.entries) {
        final businessId = entry.key;
        final businessItems = entry.value;
        
        final order = OrderModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          customerId: customer.id,
          customerName: customer.name,
          customerPhone: customer.phone,
          businessId: businessId,
          businessName: businessItems.first.businessName,
          businessPhone: '', // Fetch from business
          items: businessItems.map((item) => OrderItem(
            productId: item.product.id,
            productName: item.product.name,
            imageUrl: item.product.imageUrl,
            price: item.unitPrice,
            quantity: item.quantity,
            variant: item.selectedVariant,
            total: item.totalPrice,
          )).toList(),
          subtotal: businessItems.fold(
            0,
            (sum, item) => sum + item.totalPrice,
          ),
          deliveryFee: 50.0,
          total: businessItems.fold(
            50.0,
            (sum, item) => sum + item.totalPrice,
          ),
          status: OrderStatus.pending,
          deliveryAddress: deliveryAddress,
          paymentMethod: paymentMethod,
          paymentStatus: paymentMethod == 'cash_on_delivery'
              ? PaymentStatus.pending
              : PaymentStatus.paid,
          createdAt: DateTime.now(),
          notes: notes,
        );

        final orderId = await _orderService.createOrder(order);
        if (orderId != null) {
          orderIds.add(orderId);
        }
      }

      if (orderIds.isNotEmpty) {
        Get.find<CartController>().clearCart();
        return orderIds.first;
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to place order: $e');
      return null;
    }
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    // Cancel order
  }

  Stream<OrderModel> trackOrder(String orderId) {
    // Real-time order tracking
    return _orderService.trackOrder(orderId);
  }

  Map<String, List<CartItemModel>> _groupItemsByBusiness(
    List<CartItemModel> items,
  ) {
    // Group by businessId
    final grouped = <String, List<CartItemModel>>{};
    for (var item in items) {
      if (!grouped.containsKey(item.businessId)) {
        grouped[item.businessId] = [];
      }
      grouped[item.businessId]!.add(item);
    }
    return grouped;
  }
}
```

---

## 🔥 Firestore Service Architecture

### BusinessService

```dart
class BusinessService {
  Future<List<BusinessModel>> getOnlineBusinesses() async {
    // Query businesses where onlineStoreEnabled = true
    final snapshot = await Firestore.instance
        .collection('businesses')
        .where('onlineStoreEnabled', isEqualTo: true)
        .get();
    
    return snapshot.map((doc) => 
      BusinessModel.fromJson(doc.map)
    ).toList();
  }

  Future<BusinessModel?> getBusinessById(String id) async {
    // Fetch single business
  }

  Stream<List<BusinessModel>> streamOnlineBusinesses() {
    // Real-time updates
    return Firestore.instance
        .collection('businesses')
        .where('onlineStoreEnabled', isEqualTo: true)
        .stream
        .map((snapshot) => snapshot.map((doc) =>
            BusinessModel.fromJson(doc.map)).toList());
  }
}
```

### ProductService

```dart
class ProductService {
  Future<List<ProductModel>> getOnlineProducts() async {
    // Get all businesses first
    final businesses = await Get.find<BusinessService>()
        .getOnlineBusinesses();
    
    final allProducts = <ProductModel>[];
    
    for (var business in businesses) {
      final products = await getBusinessProducts(business.id);
      allProducts.addAll(products);
    }
    
    return allProducts;
  }

  Future<List<ProductModel>> getBusinessProducts(String businessId) async {
    // Query products subcollection
    final snapshot = await Firestore.instance
        .collection('businesses')
        .document(businessId)
        .collection('products')
        .where('listedOnline', isEqualTo: true)
        .where('isAvailable', isEqualTo: true)
        .get();
    
    return snapshot.map((doc) =>
      ProductModel.fromJson(doc.map)
    ).toList();
  }

  Future<ProductModel?> getProductById(
    String businessId,
    String productId,
  ) async {
    // Fetch single product
  }

  Stream<ProductModel> streamProduct(
    String businessId,
    String productId,
  ) {
    // Real-time product updates (stock, price, availability)
    return Firestore.instance
        .collection('businesses')
        .document(businessId)
        .collection('products')
        .document(productId)
        .stream
        .map((doc) => ProductModel.fromJson(doc.map));
  }
}
```

### OrderService

```dart
class OrderService {
  Future<String?> createOrder(OrderModel order) async {
    try {
      await Firestore.instance
          .collection('orders')
          .document(order.id)
          .set(order.toJson());
      return order.id;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  Future<List<OrderModel>> getCustomerOrders(String customerId) async {
    final snapshot = await Firestore.instance
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.map((doc) =>
      OrderModel.fromJson(doc.map)
    ).toList();
  }

  Stream<OrderModel> trackOrder(String orderId) {
    return Firestore.instance
        .collection('orders')
        .document(orderId)
        .stream
        .map((doc) => OrderModel.fromJson(doc.map));
  }

  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    await Firestore.instance
        .collection('orders')
        .document(orderId)
        .update({'status': status.name, 'updatedAt': DateTime.now().toIso8601String()});
  }
}
```

---

## 🎨 UI Component Examples

### BusinessCard Widget

```dart
class BusinessCard extends StatelessWidget {
  final BusinessModel business;
  final VoidCallback onTap;

  const BusinessCard({
    required this.business,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business image or placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: business.logo != null
                    ? DecorationImage(
                        image: NetworkImage(business.logo!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: business.logo == null
                  ? Icon(Icons.store, size: 48)
                  : null,
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    business.businessType ?? 'Business',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${business.district}, ${business.province}',
                          style: TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### ProductCard Widget

```dart
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'K${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stock: ${product.stock}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_shopping_cart, size: 20),
                      onPressed: onAddToCart,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 📱 Screen Navigation Flow

```
Splash Screen
    ↓
Auth Check
    ↓
┌───────────────────────────────────────┐
│  Not Authenticated  │  Authenticated  │
├───────────────────────────────────────┤
│ Login/Register      │  Main App       │
│     ↓               │      ↓          │
│  Phone Number       │  Bottom Nav     │
│     ↓               │  ┌──────────┐   │
│  OTP Verification   │  │  Home    │   │
│     ↓               │  │  Search  │   │
│  Name & Email       │  │  Cart    │   │
│     ↓               │  │  Profile │   │
│  Main App           │  └──────────┘   │
└───────────────────────────────────────┘
```

---

## 🔐 Security Considerations

### Data Access Rules (Firestore Security Rules)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Businesses - Read only for customers
    match /businesses/{businessId} {
      allow read: if resource.data.onlineStoreEnabled == true;
      allow write: if false; // Only POS can write
      
      // Products - Read only online products
      match /products/{productId} {
        allow read: if resource.data.listedOnline == true 
                    && resource.data.isAvailable == true;
        allow write: if false; // Only POS can write
      }
    }
    
    // Customers - Users can only access their own data
    match /customers/{customerId} {
      allow read, write: if request.auth.uid == customerId;
    }
    
    // Orders - Users can read their own, businesses can read theirs
    match /orders/{orderId} {
      allow read: if request.auth.uid == resource.data.customerId
                  || request.auth.uid == resource.data.businessId;
      allow create: if request.auth.uid == request.resource.data.customerId;
      allow update: if request.auth.uid == resource.data.businessId;
    }
  }
}
```

---

## 🚀 Performance Optimization

### 1. Image Caching
```dart
// Use cached_network_image
CachedNetworkImage(
  imageUrl: product.imageUrl,
  placeholder: (context, url) => Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(color: Colors.white),
  ),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### 2. Lazy Loading
```dart
// Load products as user scrolls
ListView.builder(
  controller: _scrollController,
  itemBuilder: (context, index) {
    if (index == products.length - 1) {
      _loadMoreProducts();
    }
    return ProductCard(product: products[index]);
  },
)
```

### 3. Search Optimization
```dart
// Debounce search input
Timer? _debounce;

void onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(Duration(milliseconds: 500), () {
    _performSearch(query);
  });
}
```

---

## 📊 Analytics & Monitoring

### Track Key Events
```dart
// Using Firebase Analytics
class AnalyticsService {
  void logProductView(String productId, String productName) {
    // Track product views
  }
  
  void logAddToCart(String productId, double price) {
    // Track cart additions
  }
  
  void logPurchase(String orderId, double amount) {
    // Track completed purchases
  }
  
  void logSearch(String searchTerm) {
    // Track search queries
  }
}
```

---

## 🎯 Success Metrics

### Key Metrics to Track
1. **User Acquisition**: Daily/Monthly active users
2. **Engagement**: Session duration, screens per session
3. **Conversion**: Add-to-cart rate, purchase rate
4. **Revenue**: Total orders, average order value
5. **Performance**: App load time, crash rate
6. **Retention**: Day 1, Day 7, Day 30 retention

---

**Document Version**: 1.0.0  
**Created**: Current Session  
**Last Updated**: Current Session  
**Status**: Ready for Implementation 🚀
