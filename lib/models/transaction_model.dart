import 'cart_item_model.dart';

enum TransactionStatus { pending, completed, cancelled, refunded }

enum PaymentMethod { cash, card, mobile, other }

class TransactionModel {
  final String id;
  final String storeId;
  final DateTime transactionDate;
  final List<CartItemModel> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final TransactionStatus status;
  final PaymentMethod paymentMethod;
  final String? customerId;
  final String? customerName;
  final String? notes;
  final String cashierId;
  final String cashierName;

  TransactionModel({
    required this.id,
    required this.storeId,
    required this.transactionDate,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    this.status = TransactionStatus.completed,
    this.paymentMethod = PaymentMethod.cash,
    this.customerId,
    this.customerName,
    this.notes,
    required this.cashierId,
    required this.cashierName,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      storeId: json['storeId'],
      transactionDate: DateTime.parse(json['transactionDate']),
      items: (json['items'] as List)
          .map((item) => CartItemModel.fromJson(item))
          .toList(),
      subtotal: json['subtotal'].toDouble(),
      tax: json['tax'].toDouble(),
      discount: json['discount'].toDouble(),
      total: json['total'].toDouble(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.completed,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      customerId: json['customerId'],
      customerName: json['customerName'],
      notes: json['notes'],
      cashierId: json['cashierId'],
      cashierName: json['cashierName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'transactionDate': transactionDate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      'customerId': customerId,
      'customerName': customerName,
      'notes': notes,
      'cashierId': cashierId,
      'cashierName': cashierName,
    };
  }
}
