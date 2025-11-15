enum SubscriptionPlan { free, monthly, yearly, twoYears }

enum SubscriptionStatus { active, expired, cancelled, trial }

class SubscriptionModel {
  final String id;
  final String businessId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final String currency;
  final String? transactionId;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SubscriptionModel({
    required this.id,
    required this.businessId,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.amount,
    this.currency = 'ZMW',
    this.transactionId,
    this.paymentMethod,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isActive {
    return status == SubscriptionStatus.active &&
        DateTime.now().isBefore(endDate);
  }

  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  bool get hasAccessToSync {
    return isActive && plan != SubscriptionPlan.free;
  }

  int get daysRemaining {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  String get planName {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.monthly:
        return '1 Month';
      case SubscriptionPlan.yearly:
        return '1 Year';
      case SubscriptionPlan.twoYears:
        return '24 Months';
    }
  }

  String get planDescription {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'All offline features';
      case SubscriptionPlan.monthly:
        return 'Cloud sync + All offline features';
      case SubscriptionPlan.yearly:
        return 'Cloud sync + All offline features';
      case SubscriptionPlan.twoYears:
        return 'Cloud sync + All offline features';
    }
  }

  static double getPlanPrice(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 0;
      case SubscriptionPlan.monthly:
        return 500;
      case SubscriptionPlan.yearly:
        return 1500;
      case SubscriptionPlan.twoYears:
        return 2400;
    }
  }

  static int getPlanDurationInDays(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 0;
      case SubscriptionPlan.monthly:
        return 30;
      case SubscriptionPlan.yearly:
        return 365;
      case SubscriptionPlan.twoYears:
        return 730;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'plan': plan.name,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'amount': amount,
      'currency': currency,
      'transactionId': transactionId,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      businessId: json['businessId'],
      plan: SubscriptionPlan.values.firstWhere(
        (e) => e.name == json['plan'],
        orElse: () => SubscriptionPlan.free,
      ),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.expired,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      amount: json['amount'].toDouble(),
      currency: json['currency'] ?? 'ZMW',
      transactionId: json['transactionId'],
      paymentMethod: json['paymentMethod'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  SubscriptionModel copyWith({
    String? id,
    String? businessId,
    SubscriptionPlan? plan,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? amount,
    String? currency,
    String? transactionId,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      transactionId: transactionId ?? this.transactionId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SubscriptionPlanOption {
  final SubscriptionPlan plan;
  final String title;
  final String subtitle;
  final double price;
  final String currency;
  final int durationInDays;
  final List<String> features;
  final bool isPopular;
  final double? savings;

  SubscriptionPlanOption({
    required this.plan,
    required this.title,
    required this.subtitle,
    required this.price,
    this.currency = 'ZMW',
    required this.durationInDays,
    required this.features,
    this.isPopular = false,
    this.savings,
  });

  String get pricePerMonth {
    if (durationInDays == 0) return '0';
    final months = durationInDays / 30;
    final pricePerMonth = price / months;
    return 'K${pricePerMonth.toStringAsFixed(0)}/month';
  }

  static List<SubscriptionPlanOption> getAllPlans() {
    return [
      SubscriptionPlanOption(
        plan: SubscriptionPlan.monthly,
        title: '1 Month',
        subtitle: 'Perfect for trying out',
        price: 500,
        durationInDays: 30,
        features: [
          'Cloud sync enabled',
          'All offline features',
          'Multi-device support',
          'Real-time sync',
          'Cancel anytime',
        ],
      ),
      SubscriptionPlanOption(
        plan: SubscriptionPlan.yearly,
        title: '1 Year',
        subtitle: 'Best value for money',
        price: 1500,
        durationInDays: 365,
        isPopular: true,
        savings: 4500, // Save K4,500 (12 months * K500 = K6,000 - K1,500)
        features: [
          'Cloud sync enabled',
          'All offline features',
          'Multi-device support',
          'Real-time sync',
          'Priority support',
          'Save K4,500',
        ],
      ),
      SubscriptionPlanOption(
        plan: SubscriptionPlan.twoYears,
        title: '24 Months',
        subtitle: 'Maximum savings',
        price: 2400,
        durationInDays: 730,
        savings: 9600, // Save K9,600 (24 months * K500 = K12,000 - K2,400)
        features: [
          'Cloud sync enabled',
          'All offline features',
          'Multi-device support',
          'Real-time sync',
          'Priority support',
          'Extended support',
          'Save K9,600',
        ],
      ),
    ];
  }
}
