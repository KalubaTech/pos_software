import 'package:pos_software/models/product_model.dart';

/// Represents a customer's delivery address
class DeliveryAddress {
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

  DeliveryAddress({
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

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
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

/// Represents an item in an online order
class OnlineOrderItem {
  final String productId;
  final String productName;
  final String? imageUrl;
  final double price;
  final int quantity;
  final ProductVariant? variant;
  final double total;

  OnlineOrderItem({
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.price,
    required this.quantity,
    this.variant,
    required this.total,
  });

  factory OnlineOrderItem.fromJson(Map<String, dynamic> json) {
    return OnlineOrderItem(
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

/// Order status enum
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled,
  refunded
}

/// Payment status enum
enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded
}

/// Extension to get display text for OrderStatus
extension OrderStatusExtension on OrderStatus {
  String get displayText {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  String get icon {
    switch (this) {
      case OrderStatus.pending:
        return '⏳';
      case OrderStatus.confirmed:
        return '✅';
      case OrderStatus.preparing:
        return '👨‍🍳';
      case OrderStatus.outForDelivery:
        return '🚚';
      case OrderStatus.delivered:
        return '📦';
      case OrderStatus.cancelled:
        return '❌';
      case OrderStatus.refunded:
        return '💰';
    }
  }
}

/// Extension to get display text for PaymentStatus
extension PaymentStatusExtension on PaymentStatus {
  String get displayText {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
}

/// Represents an online order from a customer
class OnlineOrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String businessId;
  final String businessName;
  final String businessPhone;
  final List<OnlineOrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final DeliveryAddress deliveryAddress;
  final String paymentMethod;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? confirmedAt;
  final DateTime? deliveredAt;
  final String? notes;
  final String? cancellationReason;
  final String? trackingNumber;

  OnlineOrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
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
    this.confirmedAt,
    this.deliveredAt,
    this.notes,
    this.cancellationReason,
    this.trackingNumber,
  });
  
  static DateTime _parseDateTime(dynamic val) {
    if (val is DateTime) return val;
    if (val is String) return DateTime.parse(val);
    return DateTime.now();
  }

  static DateTime? _parseDateTimeNullable(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    if (val is String) return DateTime.parse(val);
    return null;
  }

  factory OnlineOrderModel.fromJson(Map<String, dynamic> json) {
    return OnlineOrderModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      customerEmail: json['customerEmail'] as String? ?? '',
      businessId: json['businessId'] as String,
      businessName: json['businessName'] as String,
      businessPhone: json['businessPhone'] as String? ?? '',
      items: (json['items'] as List)
          .map((e) => OnlineOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: DeliveryAddress.fromJson(
        json['deliveryAddress'] as Map<String, dynamic>,
      ),
      paymentMethod: json['paymentMethod'] as String,
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTimeNullable(json['updatedAt']),
      confirmedAt: _parseDateTimeNullable(json['confirmedAt']),
      deliveredAt: _parseDateTimeNullable(json['deliveredAt']),
      notes: json['notes'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      trackingNumber: json['trackingNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
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
      'confirmedAt': confirmedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'notes': notes,
      'cancellationReason': cancellationReason,
      'trackingNumber': trackingNumber,
    };
  }

  OnlineOrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? businessId,
    String? businessName,
    String? businessPhone,
    List<OnlineOrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    OrderStatus? status,
    DeliveryAddress? deliveryAddress,
    String? paymentMethod,
    PaymentStatus? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? confirmedAt,
    DateTime? deliveredAt,
    String? notes,
    String? cancellationReason,
    String? trackingNumber,
  }) {
    return OnlineOrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      businessId: businessId ?? this.businessId,
      businessName: businessName ?? this.businessName,
      businessPhone: businessPhone ?? this.businessPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      trackingNumber: trackingNumber ?? this.trackingNumber,
    );
  }

  /// Get total number of items in the order
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Check if order can be cancelled
  bool get canBeCancelled =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;

  /// Check if order can be confirmed
  bool get canBeConfirmed => status == OrderStatus.pending;

  /// Check if order is active (not completed or cancelled)
  bool get isActive =>
      status != OrderStatus.delivered &&
      status != OrderStatus.cancelled &&
      status != OrderStatus.refunded;
}
