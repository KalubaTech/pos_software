class ReceiptModel {
  final String id;
  final String transactionId;
  final String storeId;
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final DateTime timestamp;
  final String cashierId;
  final String cashierName;
  final List<ReceiptItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String paymentMethod;
  final double amountPaid;
  final double change;
  final String? customerName;
  final String? customerEmail;
  final String receiptNumber;
  final String? notes;

  ReceiptModel({
    required this.id,
    required this.transactionId,
    required this.storeId,
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
    required this.timestamp,
    required this.cashierId,
    required this.cashierName,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.amountPaid,
    required this.change,
    this.customerName,
    this.customerEmail,
    required this.receiptNumber,
    this.notes,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    return ReceiptModel(
      id: json['id'],
      transactionId: json['transactionId'],
      storeId: json['storeId'],
      storeName: json['storeName'],
      storeAddress: json['storeAddress'],
      storePhone: json['storePhone'],
      timestamp: DateTime.parse(json['timestamp']),
      cashierId: json['cashierId'],
      cashierName: json['cashierName'],
      items: (json['items'] as List)
          .map((item) => ReceiptItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal'].toDouble(),
      tax: json['tax'].toDouble(),
      discount: json['discount'].toDouble(),
      total: json['total'].toDouble(),
      paymentMethod: json['paymentMethod'],
      amountPaid: json['amountPaid'].toDouble(),
      change: json['change'].toDouble(),
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      receiptNumber: json['receiptNumber'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'storeId': storeId,
      'storeName': storeName,
      'storeAddress': storeAddress,
      'storePhone': storePhone,
      'timestamp': timestamp.toIso8601String(),
      'cashierId': cashierId,
      'cashierName': cashierName,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'paymentMethod': paymentMethod,
      'amountPaid': amountPaid,
      'change': change,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'receiptNumber': receiptNumber,
      'notes': notes,
    };
  }
}

class ReceiptItem {
  final String name;
  final int quantity;
  final double price;
  final double total;

  ReceiptItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      name: json['name'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      total: json['total'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'quantity': quantity, 'price': price, 'total': total};
  }
}
