/// Business status enum
enum BusinessStatus {
  pending, // Awaiting admin approval
  active, // Approved and operational
  inactive, // Suspended or deactivated
  rejected, // Application rejected
}

/// Business model representing a registered business/store
class BusinessModel {
  final String id;
  final String name;
  final String? businessType; // Type of business (Retail, Restaurant, etc.)
  final String email;
  final String phone;
  final String address;
  final String? city;
  final String? country;
  final double? latitude; // Business location latitude
  final double? longitude; // Business location longitude
  final String? taxId; // Tax identification number
  final String? website;
  final String adminId; // ID of the admin user who registered
  final BusinessStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy; // Admin ID who approved
  final String? rejectionReason;
  final String? logo; // URL or path to business logo
  final Map<String, dynamic>? settings; // Additional business settings
  final bool onlineStoreEnabled; // Whether online store is active

  BusinessModel({
    required this.id,
    required this.name,
    this.businessType,
    required this.email,
    required this.phone,
    required this.address,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.taxId,
    this.website,
    required this.adminId,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
    this.rejectionReason,
    this.logo,
    this.settings,
    this.onlineStoreEnabled = false,
  });

  /// Create from JSON
  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as String,
      name: json['name'] as String,
      businessType: json['business_type'] as String?,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      city: json['city'] as String?,
      country: json['country'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      taxId: json['tax_id'] as String?,
      website: json['website'] as String?,
      adminId: json['admin_id'] as String,
      status: _parseStatus(json['status']),
      createdAt: DateTime.parse(json['created_at'] as String),
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      approvedBy: json['approved_by'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      logo: json['logo'] as String?,
      settings: json['settings'] as Map<String, dynamic>?,
      onlineStoreEnabled: json['online_store_enabled'] ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'business_type': businessType,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'tax_id': taxId,
      'website': website,
      'admin_id': adminId,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'approved_by': approvedBy,
      'rejection_reason': rejectionReason,
      'logo': logo,
      'settings': settings,
      'online_store_enabled': onlineStoreEnabled,
    };
  }

  /// Parse status from string
  static BusinessStatus _parseStatus(dynamic status) {
    if (status is BusinessStatus) return status;
    if (status is String) {
      switch (status.toLowerCase()) {
        case 'pending':
          return BusinessStatus.pending;
        case 'active':
          return BusinessStatus.active;
        case 'inactive':
          return BusinessStatus.inactive;
        case 'rejected':
          return BusinessStatus.rejected;
        default:
          return BusinessStatus.pending;
      }
    }
    return BusinessStatus.pending;
  }

  /// Copy with method
  BusinessModel copyWith({
    String? id,
    String? name,
    String? businessType,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? taxId,
    String? website,
    String? adminId,
    BusinessStatus? status,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? approvedBy,
    String? rejectionReason,
    String? logo,
    Map<String, dynamic>? settings,
    bool? onlineStoreEnabled,
  }) {
    return BusinessModel(
      id: id ?? this.id,
      name: name ?? this.name,
      businessType: businessType ?? this.businessType,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      taxId: taxId ?? this.taxId,
      website: website ?? this.website,
      adminId: adminId ?? this.adminId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      logo: logo ?? this.logo,
      settings: settings ?? this.settings,
      onlineStoreEnabled: onlineStoreEnabled ?? this.onlineStoreEnabled,
    );
  }

  /// Helper getters
  bool get isActive => status == BusinessStatus.active;
  bool get isPending => status == BusinessStatus.pending;
  bool get isInactive => status == BusinessStatus.inactive;
  bool get isRejected => status == BusinessStatus.rejected;

  String get statusLabel {
    switch (status) {
      case BusinessStatus.pending:
        return 'Pending Approval';
      case BusinessStatus.active:
        return 'Active';
      case BusinessStatus.inactive:
        return 'Inactive';
      case BusinessStatus.rejected:
        return 'Rejected';
    }
  }

  String get statusDescription {
    switch (status) {
      case BusinessStatus.pending:
        return 'Your business registration is under review. You will be notified once approved.';
      case BusinessStatus.active:
        return 'Your business is active and operational.';
      case BusinessStatus.inactive:
        return 'Your business account has been suspended. Please contact support.';
      case BusinessStatus.rejected:
        return rejectionReason ??
            'Your business registration was not approved. Please contact support.';
    }
  }

  @override
  String toString() {
    return 'BusinessModel(id: $id, name: $name, status: ${status.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BusinessModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
