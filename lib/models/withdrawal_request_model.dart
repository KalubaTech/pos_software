class WithdrawalRequestModel {
  final int? id;
  final int walletId;
  final String businessId;
  final String requestId;
  final double amount;
  final String withdrawalMethod; // bank_transfer, mobile_money, cash
  final Map<String, dynamic> accountDetails;
  final String
  status; // pending, approved, processing, completed, rejected, cancelled
  final String? requestedBy;
  final DateTime requestedAt;
  final String? processedBy;
  final DateTime? processedAt;
  final String? rejectionReason;
  final int? transactionId;
  final String? notes;

  WithdrawalRequestModel({
    this.id,
    required this.walletId,
    required this.businessId,
    required this.requestId,
    required this.amount,
    required this.withdrawalMethod,
    required this.accountDetails,
    this.status = 'pending',
    this.requestedBy,
    DateTime? requestedAt,
    this.processedBy,
    this.processedAt,
    this.rejectionReason,
    this.transactionId,
    this.notes,
  }) : requestedAt = requestedAt ?? DateTime.now();

  factory WithdrawalRequestModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequestModel(
      id: json['id'] as int?,
      walletId: json['wallet_id'] as int,
      businessId: json['business_id'] as String,
      requestId: json['request_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      withdrawalMethod: json['withdrawal_method'] as String,
      accountDetails: Map<String, dynamic>.from(json['account_details']),
      status: json['status'] as String? ?? 'pending',
      requestedBy: json['requested_by'] as String?,
      requestedAt: json['requested_at'] != null
          ? DateTime.parse(json['requested_at'] as String)
          : DateTime.now(),
      processedBy: json['processed_by'] as String?,
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      transactionId: json['transaction_id'] as int?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'business_id': businessId,
      'request_id': requestId,
      'amount': amount,
      'withdrawal_method': withdrawalMethod,
      'account_details': accountDetails,
      'status': status,
      'requested_by': requestedBy,
      'requested_at': requestedAt.toIso8601String(),
      'processed_by': processedBy,
      'processed_at': processedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'transaction_id': transactionId,
      'notes': notes,
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';
}
