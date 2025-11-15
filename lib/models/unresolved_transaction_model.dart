import 'subscription_model.dart';

enum TransactionStatus {
  pending, // Waiting for payment approval
  checking, // Currently checking status
  timeout, // Query timeout - needs retry
  notFound, // Transaction not found yet
  resolved, // Completed or failed (removed from unresolved)
}

class UnresolvedTransactionModel {
  final String id;
  final String businessId;
  final SubscriptionPlan plan;
  final String transactionId;
  final String? lencoReference;
  final String phone;
  final String operator;
  final double amount;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? lastCheckedAt;
  final int checkAttempts;
  final String? lastError;

  UnresolvedTransactionModel({
    required this.id,
    required this.businessId,
    required this.plan,
    required this.transactionId,
    this.lencoReference,
    required this.phone,
    required this.operator,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.lastCheckedAt,
    this.checkAttempts = 0,
    this.lastError,
  });

  String get planName {
    switch (plan) {
      case SubscriptionPlan.monthly:
        return '1 Month';
      case SubscriptionPlan.yearly:
        return '1 Year';
      case SubscriptionPlan.twoYears:
        return '24 Months';
      default:
        return 'Unknown';
    }
  }

  String get operatorName {
    switch (operator.toLowerCase()) {
      case 'mtn':
        return 'MTN';
      case 'airtel':
        return 'Airtel';
      case 'zamtel':
        return 'Zamtel';
      default:
        return operator.toUpperCase();
    }
  }

  String get statusText {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending Approval';
      case TransactionStatus.checking:
        return 'Checking Status...';
      case TransactionStatus.timeout:
        return 'Check Timeout';
      case TransactionStatus.notFound:
        return 'Not Found';
      case TransactionStatus.resolved:
        return 'Resolved';
    }
  }

  bool get canRetry {
    return status == TransactionStatus.timeout ||
        status == TransactionStatus.notFound ||
        status == TransactionStatus.pending;
  }

  int get hoursSinceCreated {
    return DateTime.now().difference(createdAt).inHours;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'plan': plan.name,
      'transactionId': transactionId,
      'lencoReference': lencoReference,
      'phone': phone,
      'operator': operator,
      'amount': amount,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'lastCheckedAt': lastCheckedAt?.toIso8601String(),
      'checkAttempts': checkAttempts,
      'lastError': lastError,
    };
  }

  factory UnresolvedTransactionModel.fromJson(Map<String, dynamic> json) {
    return UnresolvedTransactionModel(
      id: json['id'],
      businessId: json['businessId'],
      plan: SubscriptionPlan.values.firstWhere(
        (e) => e.name == json['plan'],
        orElse: () => SubscriptionPlan.monthly,
      ),
      transactionId: json['transactionId'],
      lencoReference: json['lencoReference'],
      phone: json['phone'],
      operator: json['operator'],
      amount: json['amount'].toDouble(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      lastCheckedAt: json['lastCheckedAt'] != null
          ? DateTime.parse(json['lastCheckedAt'])
          : null,
      checkAttempts: json['checkAttempts'] ?? 0,
      lastError: json['lastError'],
    );
  }

  UnresolvedTransactionModel copyWith({
    String? id,
    String? businessId,
    SubscriptionPlan? plan,
    String? transactionId,
    String? lencoReference,
    String? phone,
    String? operator,
    double? amount,
    TransactionStatus? status,
    DateTime? createdAt,
    DateTime? lastCheckedAt,
    int? checkAttempts,
    String? lastError,
  }) {
    return UnresolvedTransactionModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      plan: plan ?? this.plan,
      transactionId: transactionId ?? this.transactionId,
      lencoReference: lencoReference ?? this.lencoReference,
      phone: phone ?? this.phone,
      operator: operator ?? this.operator,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      checkAttempts: checkAttempts ?? this.checkAttempts,
      lastError: lastError ?? this.lastError,
    );
  }
}
