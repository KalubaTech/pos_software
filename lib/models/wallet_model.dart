class WalletModel {
  final int? id;
  final String businessId;
  final String businessName;
  final double balance;
  final String currency;
  final String status; // active, suspended, closed
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletModel({
    this.id,
    required this.businessId,
    required this.businessName,
    this.balance = 0.0,
    this.currency = 'USD',
    this.status = 'active',
    this.isEnabled = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    // Handle both snake_case (from database) and camelCase (from Firestore)
    final businessId =
        (json['business_id'] ?? json['businessId'] ?? '') as String;
    final businessName =
        (json['business_name'] ?? json['businessName'] ?? '') as String;

    return WalletModel(
      id: json['id'] as int?,
      businessId: businessId,
      businessName: businessName,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] as String?) ?? 'USD',
      status: (json['status'] as String?) ?? 'active',
      isEnabled:
          json['is_enabled'] == 1 ||
          json['is_enabled'] == true ||
          json['isEnabled'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : (json['createdAt'] != null
                ? DateTime.parse(json['createdAt'] as String)
                : DateTime.now()),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : (json['updatedAt'] != null
                ? DateTime.parse(json['updatedAt'] as String)
                : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'business_name': businessName,
      'balance': balance,
      'currency': currency,
      'status': status,
      'is_enabled': isEnabled ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  WalletModel copyWith({
    int? id,
    String? businessId,
    String? businessName,
    double? balance,
    String? currency,
    String? status,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      businessName: businessName ?? this.businessName,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == 'active' && isEnabled;
  bool get isSuspended => status == 'suspended';
  bool get isClosed => status == 'closed';
}
