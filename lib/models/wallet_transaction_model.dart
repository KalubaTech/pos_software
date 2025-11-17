class WalletTransactionModel {
  final int? id;
  final int walletId;
  final String businessId;
  final String transactionId;
  final String type; // deposit, withdrawal, charge, refund, settlement
  final double amount;
  final double chargeAmount;
  final double netAmount;
  final double balanceBefore;
  final double balanceAfter;
  final String status; // pending, completed, failed, reversed
  final String? paymentMethod; // MTN, Airtel, Vodafone, etc.
  final String? customerPhone;
  final String? customerName;
  final String? referenceId; // Links to sales transaction
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletTransactionModel({
    this.id,
    required this.walletId,
    required this.businessId,
    required this.transactionId,
    required this.type,
    required this.amount,
    this.chargeAmount = 0.0,
    required this.netAmount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.status = 'pending',
    this.paymentMethod,
    this.customerPhone,
    this.customerName,
    this.referenceId,
    this.description,
    this.metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] as int?,
      walletId: json['wallet_id'] as int,
      businessId: json['business_id'] as String,
      transactionId: json['transaction_id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      chargeAmount: (json['charge_amount'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['net_amount'] as num).toDouble(),
      balanceBefore: (json['balance_before'] as num).toDouble(),
      balanceAfter: (json['balance_after'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String?,
      customerPhone: json['customer_phone'] as String?,
      customerName: json['customer_name'] as String?,
      referenceId: json['reference_id'] as String?,
      description: json['description'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'business_id': businessId,
      'transaction_id': transactionId,
      'type': type,
      'amount': amount,
      'charge_amount': chargeAmount,
      'net_amount': netAmount,
      'balance_before': balanceBefore,
      'balance_after': balanceAfter,
      'status': status,
      'payment_method': paymentMethod,
      'customer_phone': customerPhone,
      'customer_name': customerName,
      'reference_id': referenceId,
      'description': description,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isDeposit => type == 'deposit';
  bool get isWithdrawal => type == 'withdrawal';
  bool get isCharge => type == 'charge';
  bool get isRefund => type == 'refund';
  bool get isSettlement => type == 'settlement';
  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
}
