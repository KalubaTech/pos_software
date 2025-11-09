enum ProductType { generic, food, drink, grocery, service }

// Product Variant for size, color, etc.
class ProductVariant {
  final String id;
  final String name; // e.g., "Small", "Red", "128GB"
  final String attributeType; // e.g., "Size", "Color", "Storage"
  final double priceAdjustment; // Additional price for this variant
  final String? sku; // Variant-specific SKU
  final int stock;
  final String? barcode; // Variant-specific barcode
  final String? imageUrl; // Variant-specific image

  ProductVariant({
    required this.id,
    required this.name,
    required this.attributeType,
    this.priceAdjustment = 0.0,
    this.sku,
    this.stock = 0,
    this.barcode,
    this.imageUrl,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'],
      name: json['name'],
      attributeType: json['attributeType'],
      priceAdjustment: (json['priceAdjustment'] ?? 0.0).toDouble(),
      sku: json['sku'],
      stock: json['stock'] ?? 0,
      barcode: json['barcode'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'attributeType': attributeType,
      'priceAdjustment': priceAdjustment,
      'sku': sku,
      'stock': stock,
      'barcode': barcode,
      'imageUrl': imageUrl,
    };
  }

  ProductVariant copyWith({
    String? id,
    String? name,
    String? attributeType,
    double? priceAdjustment,
    String? sku,
    int? stock,
    String? barcode,
    String? imageUrl,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      name: name ?? this.name,
      attributeType: attributeType ?? this.attributeType,
      priceAdjustment: priceAdjustment ?? this.priceAdjustment,
      sku: sku ?? this.sku,
      stock: stock ?? this.stock,
      barcode: barcode ?? this.barcode,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  double get finalPrice => priceAdjustment;
}

class ProductModel {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final double price; // Base price
  final String category;
  final String imageUrl;
  final ProductType type;
  final Map<String, dynamic>? attributes;
  final bool isAvailable;

  // New fields
  final String? sku; // Stock Keeping Unit
  final String? barcode; // Product barcode
  final int stock; // Current stock quantity
  final int minStock; // Minimum stock level for alerts
  final List<ProductVariant>? variants; // Product variations
  final String? unit; // Unit of measurement (pcs, kg, liters, etc.)
  final bool trackInventory; // Whether to track inventory for this product
  final DateTime? lastRestocked; // Last time inventory was updated
  final double? costPrice; // Cost price for profit calculation

  ProductModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.type = ProductType.generic,
    this.attributes,
    this.isAvailable = true,
    this.sku,
    this.barcode,
    this.stock = 0,
    this.minStock = 10,
    this.variants,
    this.unit = 'pcs',
    this.trackInventory = true,
    this.lastRestocked,
    this.costPrice,
  });

  // Check if product is low on stock
  bool get isLowStock => trackInventory && stock <= minStock && stock > 0;

  // Check if product is out of stock
  bool get isOutOfStock => trackInventory && stock <= 0;

  // Get stock status
  String get stockStatus {
    if (!trackInventory) return 'Not Tracked';
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }

  // Calculate profit margin
  double get profitMargin {
    if (costPrice == null || costPrice! <= 0) return 0.0;
    return ((price - costPrice!) / price) * 100;
  }

  // Get total stock including variants
  int get totalStock {
    if (variants == null || variants!.isEmpty) return stock;
    return variants!.fold(0, (sum, variant) => sum + variant.stock);
  }

  // Check if any variant is low on stock
  bool get hasLowStockVariants {
    if (variants == null || variants!.isEmpty) return false;
    return variants!.any((v) => v.stock <= minStock && v.stock > 0);
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      storeId: json['storeId'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      category: json['category'],
      imageUrl: json['imageUrl'],
      type: ProductType.values.firstWhere(
        (e) => e.toString() == 'ProductType.${json['type']}',
        orElse: () => ProductType.generic,
      ),
      attributes: json['attributes'] != null
          ? Map<String, dynamic>.from(json['attributes'])
          : null,
      isAvailable: json['isAvailable'] ?? true,
      sku: json['sku'],
      barcode: json['barcode'],
      stock: json['stock'] ?? 0,
      minStock: json['minStock'] ?? 10,
      variants: json['variants'] != null
          ? (json['variants'] as List)
                .map((v) => ProductVariant.fromJson(v))
                .toList()
          : null,
      unit: json['unit'] ?? 'pcs',
      trackInventory: json['trackInventory'] ?? true,
      lastRestocked: json['lastRestocked'] != null
          ? DateTime.parse(json['lastRestocked'])
          : null,
      costPrice: json['costPrice']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'type': type.name,
      'attributes': attributes,
      'isAvailable': isAvailable,
      'sku': sku,
      'barcode': barcode,
      'stock': stock,
      'minStock': minStock,
      'variants': variants?.map((v) => v.toJson()).toList(),
      'unit': unit,
      'trackInventory': trackInventory,
      'lastRestocked': lastRestocked?.toIso8601String(),
      'costPrice': costPrice,
    };
  }

  ProductModel copyWith({
    String? id,
    String? storeId,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    ProductType? type,
    Map<String, dynamic>? attributes,
    bool? isAvailable,
    String? sku,
    String? barcode,
    int? stock,
    int? minStock,
    List<ProductVariant>? variants,
    String? unit,
    bool? trackInventory,
    DateTime? lastRestocked,
    double? costPrice,
  }) {
    return ProductModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      attributes: attributes ?? this.attributes,
      isAvailable: isAvailable ?? this.isAvailable,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      variants: variants ?? this.variants,
      unit: unit ?? this.unit,
      trackInventory: trackInventory ?? this.trackInventory,
      lastRestocked: lastRestocked ?? this.lastRestocked,
      costPrice: costPrice ?? this.costPrice,
    );
  }
}
