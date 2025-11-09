import 'dart:math';
import '../models/product_model.dart';
import '../models/client_model.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/cart_item_model.dart';

/// Dummy API Service for simulating backend operations
class DummyApiService {
  static final DummyApiService _instance = DummyApiService._internal();
  factory DummyApiService() => _instance;
  DummyApiService._internal() {
    _generateMockTransactions();
  }

  final Random _random = Random();

  // Simulate network delay
  Future<void> _delay() async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(700)));
  }

  // Mock Categories
  List<CategoryModel> _categories = [
    CategoryModel(
      id: '1',
      name: 'Beverages',
      description: 'Drinks and beverages',
      iconName: 'coffee',
      color: '#FF5722',
    ),
    CategoryModel(
      id: '2',
      name: 'Food',
      description: 'Food items',
      iconName: 'food',
      color: '#4CAF50',
    ),
    CategoryModel(
      id: '3',
      name: 'Electronics',
      description: 'Electronic devices',
      iconName: 'devices',
      color: '#2196F3',
    ),
    CategoryModel(
      id: '4',
      name: 'Clothing',
      description: 'Apparel and accessories',
      iconName: 'shirt',
      color: '#9C27B0',
    ),
    CategoryModel(
      id: '5',
      name: 'Home & Garden',
      description: 'Home improvement',
      iconName: 'home',
      color: '#FF9800',
    ),
  ];

  // Mock Products with enhanced features
  List<ProductModel> _products = [
    // Beverages
    ProductModel(
      id: 'p1',
      storeId: 's1',
      name: 'Espresso',
      description: 'Strong Italian coffee',
      price: 3.50,
      category: 'Beverages',
      imageUrl:
          'https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?w=400',
      type: ProductType.drink,
      isAvailable: true,
      sku: 'BEV-ESP-001',
      barcode: '7501234567890',
      stock: 85,
      minStock: 20,
      unit: 'cups',
      trackInventory: true,
      costPrice: 1.50,
      variants: [
        ProductVariant(
          id: 'v1',
          name: 'Single Shot',
          attributeType: 'Size',
          priceAdjustment: 0.0,
          sku: 'BEV-ESP-001-S',
          stock: 50,
          barcode: '7501234567891',
        ),
        ProductVariant(
          id: 'v2',
          name: 'Double Shot',
          attributeType: 'Size',
          priceAdjustment: 1.50,
          sku: 'BEV-ESP-001-D',
          stock: 35,
          barcode: '7501234567892',
        ),
      ],
    ),
    ProductModel(
      id: 'p2',
      storeId: 's1',
      name: 'Cappuccino',
      description: 'Espresso with steamed milk',
      price: 4.50,
      category: 'Beverages',
      imageUrl:
          'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=400',
      type: ProductType.drink,
      isAvailable: true,
      sku: 'BEV-CAP-002',
      barcode: '7501234567893',
      stock: 120,
      minStock: 25,
      unit: 'cups',
      trackInventory: true,
      costPrice: 2.00,
      variants: [
        ProductVariant(
          id: 'v3',
          name: 'Small',
          attributeType: 'Size',
          priceAdjustment: 0.0,
          sku: 'BEV-CAP-002-S',
          stock: 50,
          barcode: '7501234567894',
        ),
        ProductVariant(
          id: 'v4',
          name: 'Medium',
          attributeType: 'Size',
          priceAdjustment: 1.00,
          sku: 'BEV-CAP-002-M',
          stock: 45,
          barcode: '7501234567895',
        ),
        ProductVariant(
          id: 'v5',
          name: 'Large',
          attributeType: 'Size',
          priceAdjustment: 2.00,
          sku: 'BEV-CAP-002-L',
          stock: 25,
          barcode: '7501234567896',
        ),
      ],
    ),
    ProductModel(
      id: 'p3',
      storeId: 's1',
      name: 'Latte',
      description: 'Smooth coffee with milk',
      price: 4.00,
      category: 'Beverages',
      imageUrl:
          'https://images.unsplash.com/photo-1561047029-3000c68339ca?w=400',
      type: ProductType.drink,
      isAvailable: true,
      sku: 'BEV-LAT-003',
      barcode: '7501234567897',
      stock: 8,
      minStock: 15,
      unit: 'cups',
      trackInventory: true,
      costPrice: 1.80,
    ),
    ProductModel(
      id: 'p4',
      storeId: 's1',
      name: 'Green Tea',
      description: 'Organic green tea',
      price: 2.50,
      category: 'Beverages',
      imageUrl:
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400',
      type: ProductType.drink,
      isAvailable: true,
      sku: 'BEV-TEA-004',
      barcode: '7501234567898',
      stock: 0,
      minStock: 10,
      unit: 'cups',
      trackInventory: true,
      costPrice: 1.00,
    ),
    // Food
    ProductModel(
      id: 'p5',
      storeId: 's1',
      name: 'Croissant',
      description: 'Fresh buttery croissant',
      price: 3.00,
      category: 'Food',
      imageUrl:
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',
      type: ProductType.food,
      isAvailable: true,
      sku: 'FOOD-CRO-005',
      barcode: '7501234567899',
      stock: 45,
      minStock: 20,
      unit: 'pcs',
      trackInventory: true,
      costPrice: 1.50,
    ),
    ProductModel(
      id: 'p6',
      storeId: 's1',
      name: 'Sandwich',
      description: 'Turkey and cheese sandwich',
      price: 6.50,
      category: 'Food',
      imageUrl:
          'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=400',
      type: ProductType.food,
      isAvailable: true,
      sku: 'FOOD-SAN-006',
      barcode: '7501234567900',
      stock: 30,
      minStock: 15,
      unit: 'pcs',
      trackInventory: true,
      costPrice: 3.50,
      variants: [
        ProductVariant(
          id: 'v6',
          name: 'Turkey',
          attributeType: 'Type',
          priceAdjustment: 0.0,
          sku: 'FOOD-SAN-006-TUR',
          stock: 15,
          barcode: '7501234567901',
        ),
        ProductVariant(
          id: 'v7',
          name: 'Chicken',
          attributeType: 'Type',
          priceAdjustment: 0.50,
          sku: 'FOOD-SAN-006-CHK',
          stock: 15,
          barcode: '7501234567902',
        ),
      ],
    ),
    ProductModel(
      id: 'p7',
      storeId: 's1',
      name: 'Salad',
      description: 'Fresh garden salad',
      price: 7.50,
      category: 'Food',
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
      type: ProductType.food,
      isAvailable: true,
      sku: 'FOOD-SAL-007',
      barcode: '7501234567903',
      stock: 5,
      minStock: 10,
      unit: 'pcs',
      trackInventory: true,
      costPrice: 3.00,
    ),
    ProductModel(
      id: 'p8',
      storeId: 's1',
      name: 'Burger',
      description: 'Classic beef burger',
      price: 8.99,
      category: 'Food',
      imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
      type: ProductType.food,
      isAvailable: true,
      sku: 'FOOD-BUR-008',
      barcode: '7501234567904',
      stock: 25,
      minStock: 12,
      unit: 'pcs',
      trackInventory: true,
      costPrice: 4.50,
    ),
    // Electronics
    ProductModel(
      id: 'p9',
      storeId: 's1',
      name: 'Wireless Mouse',
      description: 'Ergonomic wireless mouse',
      price: 24.99,
      category: 'Electronics',
      imageUrl:
          'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400',
      type: ProductType.generic,
      isAvailable: true,
      sku: 'ELEC-MOU-009',
      barcode: '7501234567905',
      stock: 65,
      minStock: 20,
      unit: 'pcs',
      trackInventory: true,
      costPrice: 12.00,
      variants: [
        ProductVariant(
          id: 'v8',
          name: 'Black',
          attributeType: 'Color',
          priceAdjustment: 0.0,
          sku: 'ELEC-MOU-009-BLK',
          stock: 35,
          barcode: '7501234567906',
        ),
        ProductVariant(
          id: 'v9',
          name: 'White',
          attributeType: 'Color',
          priceAdjustment: 2.00,
          sku: 'ELEC-MOU-009-WHT',
          stock: 30,
          barcode: '7501234567907',
        ),
      ],
    ),
    ProductModel(
      id: 'p10',
      storeId: 's1',
      name: 'USB Cable',
      description: 'USB-C charging cable',
      price: 12.99,
      category: 'Electronics',
      imageUrl:
          'https://images.unsplash.com/photo-1591290619762-9e04e6b1c9b6?w=400',
      type: ProductType.generic,
      isAvailable: true,
      sku: 'ELEC-USB-010',
      barcode: '7501234567908',
      stock: 150,
      minStock: 30,
      unit: 'pcs',
      trackInventory: true,
      costPrice: 5.00,
      variants: [
        ProductVariant(
          id: 'v10',
          name: '1 Meter',
          attributeType: 'Length',
          priceAdjustment: 0.0,
          sku: 'ELEC-USB-010-1M',
          stock: 80,
          barcode: '7501234567909',
        ),
        ProductVariant(
          id: 'v11',
          name: '2 Meter',
          attributeType: 'Length',
          priceAdjustment: 3.00,
          sku: 'ELEC-USB-010-2M',
          stock: 70,
          barcode: '7501234567910',
        ),
      ],
    ),
    ProductModel(
      id: 'p11',
      storeId: 's1',
      name: 'Headphones',
      description: 'Noise cancelling headphones',
      price: 79.99,
      category: 'Electronics',
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
      type: ProductType.generic,
      isAvailable: true,
      sku: 'ELEC-HEA-011',
      barcode: '7501234567911',
      stock: 6,
      minStock: 8,
      unit: 'pcs',
      trackInventory: true,
      costPrice: 40.00,
    ),
    ProductModel(
      id: 'p12',
      storeId: 's1',
      name: 'Power Bank',
      description: '10000mAh portable charger',
      price: 29.99,
      category: 'Electronics',
      imageUrl:
          'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400',
      type: ProductType.generic,
      isAvailable: true,
      sku: 'ELEC-POW-012',
      barcode: '7501234567912',
      stock: 40,
      minStock: 15,
      unit: 'pcs',
      trackInventory: true,
      costPrice: 15.00,
      variants: [
        ProductVariant(
          id: 'v12',
          name: '10000mAh',
          attributeType: 'Capacity',
          priceAdjustment: 0.0,
          sku: 'ELEC-POW-012-10K',
          stock: 25,
          barcode: '7501234567913',
        ),
        ProductVariant(
          id: 'v13',
          name: '20000mAh',
          attributeType: 'Capacity',
          priceAdjustment: 15.00,
          sku: 'ELEC-POW-012-20K',
          stock: 15,
          barcode: '7501234567914',
        ),
      ],
    ),
  ];

  // Mock Customers
  List<ClientModel> _customers = [
    ClientModel(
      id: 'c1',
      name: 'John Doe',
      email: 'john.doe@email.com',
      phoneNumber: '+1234567890',
    ),
    ClientModel(
      id: 'c2',
      name: 'Jane Smith',
      email: 'jane.smith@email.com',
      phoneNumber: '+1234567891',
    ),
    ClientModel(
      id: 'c3',
      name: 'Bob Johnson',
      email: 'bob.j@email.com',
      phoneNumber: '+1234567892',
    ),
    ClientModel(
      id: 'c4',
      name: 'Alice Williams',
      email: 'alice.w@email.com',
      phoneNumber: '+1234567893',
    ),
    ClientModel(
      id: 'c5',
      name: 'Charlie Brown',
      email: 'charlie.b@email.com',
      phoneNumber: '+1234567894',
    ),
    ClientModel(
      id: 'c6',
      name: 'Diana Prince',
      email: 'diana.p@email.com',
      phoneNumber: '+1234567895',
    ),
    ClientModel(
      id: 'c7',
      name: 'Edward Norton',
      email: 'edward.n@email.com',
      phoneNumber: '+1234567896',
    ),
    ClientModel(
      id: 'c8',
      name: 'Fiona Green',
      email: 'fiona.g@email.com',
      phoneNumber: '+1234567897',
    ),
  ];

  // Mock Transactions
  List<TransactionModel> _transactions = [];

  void _generateMockTransactions() {
    final now = DateTime.now();
    for (int i = 0; i < 50; i++) {
      final transactionDate = now.subtract(
        Duration(days: _random.nextInt(30), hours: _random.nextInt(24)),
      );
      final numItems = 1 + _random.nextInt(5);
      final items = <CartItemModel>[];

      for (int j = 0; j < numItems; j++) {
        final product = _products[_random.nextInt(_products.length)];
        items.add(
          CartItemModel(product: product, quantity: 1 + _random.nextInt(3)),
        );
      }

      final subtotal = items.fold(0.0, (sum, item) => sum + item.subtotal);
      final tax = subtotal * 0.08;
      final discount = _random.nextDouble() < 0.3 ? subtotal * 0.1 : 0.0;
      final total = subtotal + tax - discount;

      final customer = _random.nextDouble() < 0.7
          ? _customers[_random.nextInt(_customers.length)]
          : null;

      _transactions.add(
        TransactionModel(
          id: 't${i + 1}',
          storeId: 's1',
          transactionDate: transactionDate,
          items: items,
          subtotal: subtotal,
          tax: tax,
          discount: discount,
          total: total,
          status: TransactionStatus.completed,
          paymentMethod: PaymentMethod
              .values[_random.nextInt(PaymentMethod.values.length)],
          customerId: customer?.id,
          customerName: customer?.name,
          cashierId: 'u1',
          cashierName: 'Admin User',
        ),
      );
    }

    _transactions.sort(
      (a, b) => b.transactionDate.compareTo(a.transactionDate),
    );
  }

  // ========== PRODUCTS API ==========
  Future<List<ProductModel>> getProducts({String? category}) async {
    await _delay();
    if (category != null && category.isNotEmpty) {
      return _products
          .where((p) => p.category.toLowerCase() == category.toLowerCase())
          .toList();
    }
    return List.from(_products);
  }

  Future<ProductModel?> getProductById(String id) async {
    await _delay();
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> addProduct(ProductModel product) async {
    await _delay();
    _products.add(product);
    return true;
  }

  Future<bool> updateProduct(ProductModel product) async {
    await _delay();
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      return true;
    }
    return false;
  }

  Future<bool> deleteProduct(String id) async {
    await _delay();
    final initialLength = _products.length;
    _products.removeWhere((p) => p.id == id);
    return _products.length < initialLength;
  }

  // ========== CUSTOMERS API ==========
  Future<List<ClientModel>> getCustomers() async {
    await _delay();
    return List.from(_customers);
  }

  Future<ClientModel?> getCustomerById(String id) async {
    await _delay();
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> addCustomer(ClientModel customer) async {
    await _delay();
    _customers.add(customer);
    return true;
  }

  Future<bool> updateCustomer(ClientModel customer) async {
    await _delay();
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _customers[index] = customer;
      return true;
    }
    return false;
  }

  Future<bool> deleteCustomer(String id) async {
    await _delay();
    final initialLength = _customers.length;
    _customers.removeWhere((c) => c.id == id);
    return _customers.length < initialLength;
  }

  // ========== TRANSACTIONS API ==========
  Future<List<TransactionModel>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _delay();
    var filtered = List<TransactionModel>.from(_transactions);

    if (startDate != null) {
      filtered = filtered
          .where(
            (t) =>
                t.transactionDate.isAfter(startDate) ||
                t.transactionDate.isAtSameMomentAs(startDate),
          )
          .toList();
    }

    if (endDate != null) {
      filtered = filtered
          .where(
            (t) =>
                t.transactionDate.isBefore(endDate) ||
                t.transactionDate.isAtSameMomentAs(endDate),
          )
          .toList();
    }

    return filtered;
  }

  Future<TransactionModel?> getTransactionById(String id) async {
    await _delay();
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<String> createTransaction(TransactionModel transaction) async {
    await _delay();
    _transactions.insert(0, transaction);
    return transaction.id;
  }

  // ========== CATEGORIES API ==========
  Future<List<CategoryModel>> getCategories() async {
    await _delay();
    return List.from(_categories);
  }

  // ========== DASHBOARD STATS ==========
  Future<Map<String, dynamic>> getDashboardStats() async {
    await _delay();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisMonth = DateTime(now.year, now.month, 1);

    final todayTransactions = _transactions
        .where(
          (t) =>
              t.transactionDate.isAfter(today) &&
              t.status == TransactionStatus.completed,
        )
        .toList();

    final monthTransactions = _transactions
        .where(
          (t) =>
              t.transactionDate.isAfter(thisMonth) &&
              t.status == TransactionStatus.completed,
        )
        .toList();

    final todaySales = todayTransactions.fold(0.0, (sum, t) => sum + t.total);
    final monthSales = monthTransactions.fold(0.0, (sum, t) => sum + t.total);

    return {
      'todaySales': todaySales,
      'todayTransactions': todayTransactions.length,
      'monthSales': monthSales,
      'monthTransactions': monthTransactions.length,
      'totalCustomers': _customers.length,
      'totalProducts': _products.length,
      'lowStockItems': _random.nextInt(10) + 5, // Mock low stock count
    };
  }

  // ========== SALES DATA FOR CHARTS ==========
  Future<List<Map<String, dynamic>>> getSalesChartData({int days = 7}) async {
    await _delay();

    final now = DateTime.now();
    final data = <Map<String, dynamic>>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final nextDay = date.add(Duration(days: 1));

      final dayTransactions = _transactions
          .where(
            (t) =>
                t.transactionDate.isAfter(date) &&
                t.transactionDate.isBefore(nextDay) &&
                t.status == TransactionStatus.completed,
          )
          .toList();

      final daySales = dayTransactions.fold(0.0, (sum, t) => sum + t.total);

      data.add({
        'date': date,
        'sales': daySales,
        'transactions': dayTransactions.length,
      });
    }

    return data;
  }

  // ========== TOP SELLING PRODUCTS ==========
  Future<List<Map<String, dynamic>>> getTopSellingProducts({
    int limit = 5,
  }) async {
    await _delay();

    final productSales = <String, Map<String, dynamic>>{};

    for (var transaction in _transactions) {
      if (transaction.status != TransactionStatus.completed) continue;

      for (var item in transaction.items) {
        final productId = item.product.id;
        if (!productSales.containsKey(productId)) {
          productSales[productId] = {
            'product': item.product,
            'quantity': 0,
            'revenue': 0.0,
          };
        }
        productSales[productId]!['quantity'] += item.quantity;
        productSales[productId]!['revenue'] += item.subtotal;
      }
    }

    final sortedProducts = productSales.values.toList()
      ..sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));

    return sortedProducts.take(limit).toList();
  }
}
