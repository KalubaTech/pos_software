enum UserRole { admin, cashier, manager }

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.cashier:
        return 'Cashier';
      case UserRole.manager:
        return 'Manager';
    }
  }
}

class CashierModel {
  final String id;
  final String name;
  final String email;
  final String pin; // 4-digit PIN for quick login
  final UserRole role;
  final String? profileImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String? businessId; // Business this cashier belongs to

  CashierModel({
    required this.id,
    required this.name,
    required this.email,
    required this.pin,
    this.role = UserRole.cashier,
    this.profileImageUrl,
    this.isActive = true,
    required this.createdAt,
    this.lastLogin,
    this.businessId,
  });

  factory CashierModel.fromJson(Map<String, dynamic> json) {
    return CashierModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      pin: json['pin'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.cashier,
      ),
      profileImageUrl: json['profileImageUrl'],
      isActive: json['isActive'] == 1 || json['isActive'] == true,
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : null,
      businessId: json['businessId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'pin': pin,
      'role': role.name,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'businessId': businessId,
    };
  }

  /// Convert to SQLite-compatible format (bool -> int)
  Map<String, dynamic> toSQLite() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'pin': pin,
      'role': role.name,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive ? 1 : 0, // SQLite: bool -> int
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'businessId': businessId,
    };
  }

  CashierModel copyWith({
    String? id,
    String? name,
    String? email,
    String? pin,
    UserRole? role,
    String? profileImageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
    String? businessId,
  }) {
    return CashierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      pin: pin ?? this.pin,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      businessId: businessId ?? this.businessId,
    );
  }
}
