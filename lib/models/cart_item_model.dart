import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  final ProductVariant?
  selectedVariant; // Selected variant if product has variants
  int quantity;
  String? notes;

  CartItemModel({
    required this.product,
    this.selectedVariant,
    this.quantity = 1,
    this.notes,
  });

  // Get the final price considering variant
  double get unitPrice {
    if (selectedVariant != null) {
      return product.price + selectedVariant!.priceAdjustment;
    }
    return product.price;
  }

  double get subtotal => unitPrice * quantity;

  // Get display name with variant info
  String get displayName {
    if (selectedVariant != null) {
      return '${product.name} (${selectedVariant!.name})';
    }
    return product.name;
  }

  // Get the SKU (variant SKU or product SKU)
  String? get effectiveSku {
    return selectedVariant?.sku ?? product.sku;
  }

  // Get the barcode (variant barcode or product barcode)
  String? get effectiveBarcode {
    return selectedVariant?.barcode ?? product.barcode;
  }

  // Get available stock
  int get availableStock {
    if (selectedVariant != null) {
      return selectedVariant!.stock;
    }
    return product.stock;
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product']),
      selectedVariant: json['selectedVariant'] != null
          ? ProductVariant.fromJson(json['selectedVariant'])
          : null,
      quantity: json['quantity'] ?? 1,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'selectedVariant': selectedVariant?.toJson(),
      'quantity': quantity,
      'notes': notes,
    };
  }

  CartItemModel copyWith({
    ProductModel? product,
    ProductVariant? selectedVariant,
    int? quantity,
    String? notes,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }
}
