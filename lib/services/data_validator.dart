import 'package:firedart/firedart.dart';

/// Data Validation Service
///
/// Provides validation methods for all Firestore documents before write operations.
/// Ensures data integrity and prevents corrupt documents.

class DataValidator {
  /// Validate business document before write
  static ValidationResult validateBusiness(Map<String, dynamic> data) {
    final errors = <String>[];

    // Check required fields
    final requiredFields = [
      'id',
      'name',
      'email',
      'phone',
      'address',
      'status',
      'admin_id',
      'created_at',
      'online_store_enabled',
    ];

    for (final field in requiredFields) {
      if (!data.containsKey(field) ||
          data[field] == null ||
          data[field] == '') {
        errors.add('Missing required field: $field');
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult(isValid: false, errors: errors);
    }

    // Validate email format
    final email = data['email'] as String;
    if (!_isValidEmail(email)) {
      errors.add('Invalid email format: $email');
    }

    // Validate status
    final status = data['status'] as String;
    if (!['active', 'inactive', 'suspended'].contains(status)) {
      errors.add(
        'Invalid status: $status. Must be: active, inactive, or suspended',
      );
    }

    // Validate online_store_enabled is boolean
    if (data['online_store_enabled'] is! bool) {
      errors.add('online_store_enabled must be boolean');
    }

    // Validate phone (not empty)
    final phone = data['phone'] as String;
    if (phone.isEmpty) {
      errors.add('Phone number cannot be empty');
    }

    // Validate timestamps
    if (!_isValidTimestamp(data['created_at'])) {
      errors.add('Invalid created_at timestamp');
    }

    if (data.containsKey('updated_at') &&
        !_isValidTimestamp(data['updated_at'])) {
      errors.add('Invalid updated_at timestamp');
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Validate product document before write
  static ValidationResult validateProduct(Map<String, dynamic> data) {
    final errors = <String>[];

    // Check required fields
    final requiredFields = [
      'id',
      'name',
      'price',
      'stock',
      'created_at',
      'listedOnline',
    ];

    for (final field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        errors.add('Missing required field: $field');
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult(isValid: false, errors: errors);
    }

    // Validate price
    final price = data['price'];
    if (price is! num || price < 0) {
      errors.add('Price must be a non-negative number');
    }

    // Validate stock
    final stock = data['stock'];
    if (stock is! int || stock < 0) {
      errors.add('Stock must be a non-negative integer');
    }

    // Validate listedOnline is boolean
    if (data['listedOnline'] is! bool) {
      errors.add('listedOnline must be boolean');
    }

    // Validate name not empty
    final name = data['name'] as String;
    if (name.isEmpty) {
      errors.add('Product name cannot be empty');
    }

    // Validate timestamps
    if (!_isValidTimestamp(data['created_at'])) {
      errors.add('Invalid created_at timestamp');
    }

    if (data.containsKey('updated_at') &&
        !_isValidTimestamp(data['updated_at'])) {
      errors.add('Invalid updated_at timestamp');
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Validate cashier document before write
  static ValidationResult validateCashier(Map<String, dynamic> data) {
    final errors = <String>[];

    // Check required fields
    final requiredFields = [
      'id',
      'name',
      'email',
      'pin',
      'role',
      'businessId',
      'isActive',
      'created_at',
    ];

    for (final field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        errors.add('Missing required field: $field');
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult(isValid: false, errors: errors);
    }

    // Validate email format
    final email = data['email'] as String;
    if (!_isValidEmail(email)) {
      errors.add('Invalid email format: $email');
    }

    // Validate role
    final role = data['role'] as String;
    if (!['admin', 'manager', 'cashier'].contains(role)) {
      errors.add('Invalid role: $role. Must be: admin, manager, or cashier');
    }

    // Validate isActive is boolean
    if (data['isActive'] is! bool) {
      errors.add('isActive must be boolean');
    }

    // Validate PIN
    final pin = data['pin'] as String;
    if (pin.length < 4) {
      errors.add('PIN must be at least 4 characters');
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Validate business settings document
  static ValidationResult validateBusinessSettings(Map<String, dynamic> data) {
    final errors = <String>[];

    // Check required fields
    final requiredFields = [
      'storeName',
      'taxEnabled',
      'taxRate',
      'currency',
      'onlineStoreEnabled',
      'updated_at',
    ];

    for (final field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        errors.add('Missing required field: $field');
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult(isValid: false, errors: errors);
    }

    // Validate tax rate
    final taxRate = data['taxRate'];
    if (taxRate is! num || taxRate < 0 || taxRate > 100) {
      errors.add('Tax rate must be between 0 and 100');
    }

    // Validate booleans
    if (data['taxEnabled'] is! bool) {
      errors.add('taxEnabled must be boolean');
    }

    if (data['onlineStoreEnabled'] is! bool) {
      errors.add('onlineStoreEnabled must be boolean');
    }

    // Validate online product count
    if (data.containsKey('onlineProductCount')) {
      final count = data['onlineProductCount'];
      if (count is! int || count < 0) {
        errors.add('onlineProductCount must be a non-negative integer');
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Validate email format
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate timestamp format
  static bool _isValidTimestamp(dynamic timestamp) {
    if (timestamp is! String) return false;

    try {
      DateTime.parse(timestamp);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Validation result class
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({required this.isValid, this.errors = const []});

  @override
  String toString() {
    if (isValid) {
      return 'ValidationResult: VALID';
    } else {
      return 'ValidationResult: INVALID\n  Errors:\n    - ${errors.join('\n    - ')}';
    }
  }
}
