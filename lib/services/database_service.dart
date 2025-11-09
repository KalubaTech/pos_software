import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../models/client_model.dart';
import '../models/cart_item_model.dart';

class DatabaseService extends GetxController {
  static Database? _database;
  static const String _databaseName = 'pos_software.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String productsTable = 'products';
  static const String variantsTable = 'product_variants';
  static const String transactionsTable = 'transactions';
  static const String transactionItemsTable = 'transaction_items';
  static const String customersTable = 'customers';
  static const String settingsTable = 'settings';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI for desktop platforms (Windows, Linux, macOS)
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE $productsTable (
        id TEXT PRIMARY KEY,
        storeId TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        imageUrl TEXT,
        type TEXT,
        attributes TEXT,
        isAvailable INTEGER DEFAULT 1,
        sku TEXT,
        barcode TEXT,
        stock INTEGER DEFAULT 0,
        minStock INTEGER DEFAULT 10,
        unit TEXT DEFAULT 'pcs',
        trackInventory INTEGER DEFAULT 1,
        lastRestocked TEXT,
        costPrice REAL,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    // Product Variants table
    await db.execute('''
      CREATE TABLE $variantsTable (
        id TEXT PRIMARY KEY,
        productId TEXT NOT NULL,
        name TEXT NOT NULL,
        attributeType TEXT NOT NULL,
        priceAdjustment REAL DEFAULT 0,
        sku TEXT,
        stock INTEGER DEFAULT 0,
        barcode TEXT,
        imageUrl TEXT,
        FOREIGN KEY (productId) REFERENCES $productsTable (id) ON DELETE CASCADE
      )
    ''');

    // Transactions table
    await db.execute('''
      CREATE TABLE $transactionsTable (
        id TEXT PRIMARY KEY,
        storeId TEXT NOT NULL,
        transactionDate TEXT NOT NULL,
        subtotal REAL NOT NULL,
        tax REAL NOT NULL,
        discount REAL DEFAULT 0,
        total REAL NOT NULL,
        status TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        customerId TEXT,
        customerName TEXT,
        cashierId TEXT NOT NULL,
        cashierName TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    // Transaction Items table
    await db.execute('''
      CREATE TABLE $transactionItemsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transactionId TEXT NOT NULL,
        productId TEXT NOT NULL,
        productName TEXT NOT NULL,
        variantId TEXT,
        variantName TEXT,
        quantity INTEGER NOT NULL,
        unitPrice REAL NOT NULL,
        subtotal REAL NOT NULL,
        notes TEXT,
        FOREIGN KEY (transactionId) REFERENCES $transactionsTable (id) ON DELETE CASCADE
      )
    ''');

    // Customers table
    await db.execute('''
      CREATE TABLE $customersTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        address TEXT,
        loyaltyPoints INTEGER DEFAULT 0,
        totalSpent REAL DEFAULT 0,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    // Settings table (key-value store for app settings)
    await db.execute('''
      CREATE TABLE $settingsTable (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        type TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX idx_products_category ON $productsTable(category)',
    );
    await db.execute(
      'CREATE INDEX idx_products_barcode ON $productsTable(barcode)',
    );
    await db.execute('CREATE INDEX idx_products_sku ON $productsTable(sku)');
    await db.execute(
      'CREATE INDEX idx_variants_product ON $variantsTable(productId)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_date ON $transactionsTable(transactionDate)',
    );
    await db.execute(
      'CREATE INDEX idx_transaction_items_transaction ON $transactionItemsTable(transactionId)',
    );
    await db.execute(
      'CREATE INDEX idx_customers_phone ON $customersTable(phone)',
    );
    await db.execute(
      'CREATE INDEX idx_customers_email ON $customersTable(email)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < 2) {
      // Example migration for version 2
      // await db.execute('ALTER TABLE $productsTable ADD COLUMN newColumn TEXT');
    }
  }

  // ==================== PRODUCTS ====================

  Future<int> insertProduct(ProductModel product) async {
    final db = await database;
    try {
      await db.insert(
        productsTable,
        _productToMap(product),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert variants if any
      if (product.variants != null && product.variants!.isNotEmpty) {
        for (var variant in product.variants!) {
          await db.insert(
            variantsTable,
            _variantToMap(variant, product.id),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      return 1;
    } catch (e) {
      print('Error inserting product: $e');
      return 0;
    }
  }

  Future<List<ProductModel>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> products = await db.query(productsTable);

    List<ProductModel> productList = [];
    for (var productMap in products) {
      // Get variants for this product
      final variants = await db.query(
        variantsTable,
        where: 'productId = ?',
        whereArgs: [productMap['id']],
      );

      productList.add(
        _productFromMap(
          productMap,
          variants.map((v) => _variantFromMap(v)).toList(),
        ),
      );
    }

    return productList;
  }

  Future<ProductModel?> getProductById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> products = await db.query(
      productsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (products.isEmpty) return null;

    // Get variants
    final variants = await db.query(
      variantsTable,
      where: 'productId = ?',
      whereArgs: [id],
    );

    return _productFromMap(
      products.first,
      variants.map((v) => _variantFromMap(v)).toList(),
    );
  }

  Future<ProductModel?> getProductByBarcode(String barcode) async {
    final db = await database;
    final List<Map<String, dynamic>> products = await db.query(
      productsTable,
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (products.isEmpty) {
      // Check variants
      final variants = await db.query(
        variantsTable,
        where: 'barcode = ?',
        whereArgs: [barcode],
      );

      if (variants.isNotEmpty) {
        // Get the product for this variant
        return await getProductById(variants.first['productId'] as String);
      }
      return null;
    }

    final variants = await db.query(
      variantsTable,
      where: 'productId = ?',
      whereArgs: [products.first['id']],
    );

    return _productFromMap(
      products.first,
      variants.map((v) => _variantFromMap(v)).toList(),
    );
  }

  Future<int> updateProduct(ProductModel product) async {
    final db = await database;
    try {
      // Update product
      await db.update(
        productsTable,
        _productToMap(product),
        where: 'id = ?',
        whereArgs: [product.id],
      );

      // Delete old variants
      await db.delete(
        variantsTable,
        where: 'productId = ?',
        whereArgs: [product.id],
      );

      // Insert new variants
      if (product.variants != null && product.variants!.isNotEmpty) {
        for (var variant in product.variants!) {
          await db.insert(
            variantsTable,
            _variantToMap(variant, product.id),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      return 1;
    } catch (e) {
      print('Error updating product: $e');
      return 0;
    }
  }

  Future<int> deleteProduct(String id) async {
    final db = await database;
    return await db.delete(productsTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateStock(
    String productId,
    int stock, {
    String? variantId,
  }) async {
    final db = await database;
    if (variantId != null) {
      // Update variant stock
      return await db.update(
        variantsTable,
        {'stock': stock},
        where: 'id = ?',
        whereArgs: [variantId],
      );
    } else {
      // Update product stock
      return await db.update(
        productsTable,
        {'stock': stock, 'lastRestocked': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [productId],
      );
    }
  }

  // ==================== TRANSACTIONS ====================

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    try {
      await db.insert(
        transactionsTable,
        _transactionToMap(transaction),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert transaction items
      for (var item in transaction.items) {
        await db.insert(
          transactionItemsTable,
          _transactionItemToMap(item, transaction.id),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Update stock
        if (item.product.trackInventory) {
          if (item.selectedVariant != null) {
            final variant = await db.query(
              variantsTable,
              where: 'id = ?',
              whereArgs: [item.selectedVariant!.id],
            );
            if (variant.isNotEmpty) {
              final currentStock = variant.first['stock'] as int;
              await updateStock(
                item.product.id,
                currentStock - item.quantity,
                variantId: item.selectedVariant!.id,
              );
            }
          } else {
            final product = await db.query(
              productsTable,
              where: 'id = ?',
              whereArgs: [item.product.id],
            );
            if (product.isNotEmpty) {
              final currentStock = product.first['stock'] as int;
              await updateStock(item.product.id, currentStock - item.quantity);
            }
          }
        }
      }

      return 1;
    } catch (e) {
      print('Error inserting transaction: $e');
      return 0;
    }
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> transactions = await db.query(
      transactionsTable,
      orderBy: 'transactionDate DESC',
    );

    List<TransactionModel> transactionList = [];
    for (var transactionMap in transactions) {
      final items = await db.query(
        transactionItemsTable,
        where: 'transactionId = ?',
        whereArgs: [transactionMap['id']],
      );

      transactionList.add(await _transactionFromMap(transactionMap, items));
    }

    return transactionList;
  }

  Future<List<TransactionModel>> getTransactionsByDate(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> transactions = await db.query(
      transactionsTable,
      where: 'transactionDate BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'transactionDate DESC',
    );

    List<TransactionModel> transactionList = [];
    for (var transactionMap in transactions) {
      final items = await db.query(
        transactionItemsTable,
        where: 'transactionId = ?',
        whereArgs: [transactionMap['id']],
      );

      transactionList.add(await _transactionFromMap(transactionMap, items));
    }

    return transactionList;
  }

  Future<TransactionModel?> getTransactionById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> transactions = await db.query(
      transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (transactions.isEmpty) return null;

    final items = await db.query(
      transactionItemsTable,
      where: 'transactionId = ?',
      whereArgs: [id],
    );

    return await _transactionFromMap(transactions.first, items);
  }

  // ==================== CUSTOMERS ====================

  Future<int> insertCustomer(ClientModel customer) async {
    final db = await database;
    return await db.insert(
      customersTable,
      _customerToMap(customer),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ClientModel>> getAllCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> customers = await db.query(customersTable);
    return customers.map((c) => _customerFromMap(c)).toList();
  }

  Future<int> updateCustomer(ClientModel customer) async {
    final db = await database;
    return await db.update(
      customersTable,
      _customerToMap(customer),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(String id) async {
    final db = await database;
    return await db.delete(customersTable, where: 'id = ?', whereArgs: [id]);
  }

  // ==================== SETTINGS ====================

  Future<int> saveSetting(String key, dynamic value, String type) async {
    final db = await database;
    return await db.insert(settingsTable, {
      'key': key,
      'value': value.toString(),
      'type': type,
      'updatedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<dynamic> getSetting(String key, String type) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      settingsTable,
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isEmpty) return null;

    final value = result.first['value'];
    switch (type) {
      case 'int':
        return int.tryParse(value);
      case 'double':
        return double.tryParse(value);
      case 'bool':
        return value.toLowerCase() == 'true';
      default:
        return value;
    }
  }

  Future<Map<String, dynamic>> getAllSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> settings = await db.query(settingsTable);
    Map<String, dynamic> settingsMap = {};
    for (var setting in settings) {
      settingsMap[setting['key']] = setting['value'];
    }
    return settingsMap;
  }

  // ==================== HELPER METHODS ====================

  Map<String, dynamic> _productToMap(ProductModel product) {
    return {
      'id': product.id,
      'storeId': product.storeId,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'category': product.category,
      'imageUrl': product.imageUrl,
      'type': product.type.name,
      'attributes': product.attributes?.toString(),
      'isAvailable': product.isAvailable ? 1 : 0,
      'sku': product.sku,
      'barcode': product.barcode,
      'stock': product.stock,
      'minStock': product.minStock,
      'unit': product.unit,
      'trackInventory': product.trackInventory ? 1 : 0,
      'lastRestocked': product.lastRestocked?.toIso8601String(),
      'costPrice': product.costPrice,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  ProductModel _productFromMap(
    Map<String, dynamic> map,
    List<ProductVariant> variants,
  ) {
    return ProductModel(
      id: map['id'],
      storeId: map['storeId'],
      name: map['name'],
      description: map['description'] ?? '',
      price: map['price'],
      category: map['category'],
      imageUrl: map['imageUrl'] ?? '',
      type: ProductType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ProductType.generic,
      ),
      isAvailable: map['isAvailable'] == 1,
      sku: map['sku'],
      barcode: map['barcode'],
      stock: map['stock'] ?? 0,
      minStock: map['minStock'] ?? 10,
      variants: variants.isEmpty ? null : variants,
      unit: map['unit'] ?? 'pcs',
      trackInventory: map['trackInventory'] == 1,
      lastRestocked: map['lastRestocked'] != null
          ? DateTime.parse(map['lastRestocked'])
          : null,
      costPrice: map['costPrice'],
    );
  }

  Map<String, dynamic> _variantToMap(ProductVariant variant, String productId) {
    return {
      'id': variant.id,
      'productId': productId,
      'name': variant.name,
      'attributeType': variant.attributeType,
      'priceAdjustment': variant.priceAdjustment,
      'sku': variant.sku,
      'stock': variant.stock,
      'barcode': variant.barcode,
      'imageUrl': variant.imageUrl,
    };
  }

  ProductVariant _variantFromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['id'],
      name: map['name'],
      attributeType: map['attributeType'],
      priceAdjustment: map['priceAdjustment'] ?? 0.0,
      sku: map['sku'],
      stock: map['stock'] ?? 0,
      barcode: map['barcode'],
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> _transactionToMap(TransactionModel transaction) {
    return {
      'id': transaction.id,
      'storeId': transaction.storeId,
      'transactionDate': transaction.transactionDate.toIso8601String(),
      'subtotal': transaction.subtotal,
      'tax': transaction.tax,
      'discount': transaction.discount,
      'total': transaction.total,
      'status': transaction.status.name,
      'paymentMethod': transaction.paymentMethod.name,
      'customerId': transaction.customerId,
      'customerName': transaction.customerName,
      'cashierId': transaction.cashierId,
      'cashierName': transaction.cashierName,
      'notes': transaction.notes,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  Future<TransactionModel> _transactionFromMap(
    Map<String, dynamic> map,
    List<Map<String, dynamic>> itemMaps,
  ) async {
    // Reconstruct cart items from transaction items
    List<CartItemModel> items = [];
    for (var itemMap in itemMaps) {
      final product = await getProductById(itemMap['productId']);
      if (product != null) {
        ProductVariant? variant;
        if (itemMap['variantId'] != null) {
          variant = product.variants?.firstWhere(
            (v) => v.id == itemMap['variantId'],
          );
        }
        items.add(
          CartItemModel(
            product: product,
            selectedVariant: variant,
            quantity: itemMap['quantity'],
            notes: itemMap['notes'],
          ),
        );
      }
    }

    return TransactionModel(
      id: map['id'],
      storeId: map['storeId'],
      transactionDate: DateTime.parse(map['transactionDate']),
      items: items,
      subtotal: map['subtotal'],
      tax: map['tax'],
      discount: map['discount'],
      total: map['total'],
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == map['status'],
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['paymentMethod'],
      ),
      customerId: map['customerId'],
      customerName: map['customerName'],
      cashierId: map['cashierId'],
      cashierName: map['cashierName'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> _transactionItemToMap(
    dynamic item,
    String transactionId,
  ) {
    return {
      'transactionId': transactionId,
      'productId': item.product.id,
      'productName': item.product.name,
      'variantId': item.selectedVariant?.id,
      'variantName': item.selectedVariant?.name,
      'quantity': item.quantity,
      'unitPrice': item.unitPrice,
      'subtotal': item.subtotal,
      'notes': item.notes,
    };
  }

  Map<String, dynamic> _customerToMap(ClientModel customer) {
    return {
      'id': customer.id,
      'name': customer.name,
      'email': customer.email,
      'phone': customer.phoneNumber,
      'address': '', // Not in ClientModel
      'loyaltyPoints': 0, // Not in ClientModel
      'totalSpent': 0.0, // Not in ClientModel
      'isActive': 1, // Not in ClientModel
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  ClientModel _customerFromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'],
      name: map['name'],
      email: map['email'] ?? '',
      phoneNumber: map['phone'] ?? '',
    );
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(productsTable);
    await db.delete(variantsTable);
    await db.delete(transactionsTable);
    await db.delete(transactionItemsTable);
    await db.delete(customersTable);
    await db.delete(settingsTable);
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
