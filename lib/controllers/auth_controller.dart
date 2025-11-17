import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/cashier_model.dart';
import '../services/database_service.dart';

class AuthController extends GetxController {
  final GetStorage _storage = GetStorage();
  final DatabaseService _db = Get.find<DatabaseService>();

  var isAuthenticated = false.obs;
  var currentCashier = Rx<CashierModel?>(null);
  var cashiers = <CashierModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    await _initializeCashiers();
    _checkStoredSession();
  }

  Future<void> _initializeCashiers() async {
    isLoading.value = true;
    try {
      print('=== INITIALIZING CASHIERS ===');
      // Load cashiers from database
      final cashiersData = await _db.getAllCashiers();
      print('Cashiers from DB: ${cashiersData.length}');

      // If no cashiers exist, create default admin
      if (cashiersData.isEmpty) {
        print('No cashiers found, creating defaults...');
        await _createDefaultCashiers();
      } else {
        cashiers.value = cashiersData
            .map((data) => CashierModel.fromJson(data))
            .toList();
        print('Loaded cashiers:');
        for (var cashier in cashiers) {
          print(
            '  - ${cashier.name} (PIN: ${cashier.pin}, Active: ${cashier.isActive})',
          );
        }
      }
    } catch (e) {
      print('Error initializing cashiers: $e');
      // Fallback to default cashiers if database fails
      await _createDefaultCashiers();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createDefaultCashiers() async {
    final defaultCashiers = [
      CashierModel(
        id: 'c1',
        name: 'Admin User',
        email: 'admin@dynamospos.com',
        pin: '1234',
        role: UserRole.admin,
        createdAt: DateTime.now().subtract(Duration(days: 365)),
        isActive: true,
      ),
      CashierModel(
        id: 'c2',
        name: 'John Cashier',
        email: 'john@dynamospos.com',
        pin: '1111',
        role: UserRole.cashier,
        createdAt: DateTime.now().subtract(Duration(days: 90)),
        isActive: true,
      ),
      CashierModel(
        id: 'c3',
        name: 'Sarah Manager',
        email: 'sarah@dynamospos.com',
        pin: '2222',
        role: UserRole.manager,
        createdAt: DateTime.now().subtract(Duration(days: 180)),
        isActive: true,
      ),
      CashierModel(
        id: 'c4',
        name: 'Mike Sales',
        email: 'mike@dynamospos.com',
        pin: '3333',
        role: UserRole.cashier,
        createdAt: DateTime.now().subtract(Duration(days: 60)),
        isActive: true,
      ),
    ];

    for (var cashier in defaultCashiers) {
      await _db.insertCashier(cashier.toJson());
    }

    cashiers.value = defaultCashiers;
  }

  void _checkStoredSession() {
    print('=== CHECKING STORED SESSION ===');
    final cashierId = _storage.read('currentCashierId');
    print('Stored cashier ID: $cashierId');
    if (cashierId != null) {
      final cashier = cashiers.firstWhereOrNull((c) => c.id == cashierId);
      if (cashier != null) {
        print('Found stored session for: ${cashier.name}');
        currentCashier.value = cashier;
        isAuthenticated.value = true;
      } else {
        print('Stored cashier not found in loaded cashiers');
      }
    } else {
      print('No stored session found');
    }
  }

  Future<bool> login(String pin) async {
    try {
      print('=== LOGIN ATTEMPT ===');
      print('PIN entered: $pin');
      print('Cashiers count: ${cashiers.length}');

      // Query database for cashier with matching PIN
      final cashierData = await _db.getCashierByPin(pin);
      print('Cashier data from DB: $cashierData');

      if (cashierData == null) {
        print('No cashier found with PIN: $pin');
        // Check if cashiers exist in memory
        final memoryCashier = cashiers.firstWhereOrNull(
          (c) => c.pin == pin && c.isActive,
        );
        if (memoryCashier != null) {
          print('Found cashier in memory: ${memoryCashier.name}');
          currentCashier.value = memoryCashier.copyWith(
            lastLogin: DateTime.now(),
          );
          isAuthenticated.value = true;
          await _storage.write('currentCashierId', memoryCashier.id);
          return true;
        }
        return false;
      }

      final cashier = CashierModel.fromJson(cashierData);
      print('Successfully loaded cashier: ${cashier.name}');
      currentCashier.value = cashier.copyWith(lastLogin: DateTime.now());
      isAuthenticated.value = true;

      // Update last login in database
      await _db.updateCashierLastLogin(cashier.id, DateTime.now());

      // Store session
      await _storage.write('currentCashierId', cashier.id);

      print('Login successful!');
      return true;
    } catch (e) {
      print('Login error: $e');
      print('Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  Future<void> logout() async {
    currentCashier.value = null;
    isAuthenticated.value = false;
    await _storage.remove('currentCashierId');

    Get.snackbar(
      'Logged Out',
      'You have been logged out successfully',
      snackPosition: SnackPosition.TOP,
    );
  }

  Future<bool> addCashier(CashierModel cashier) async {
    try {
      if (!hasPermission(UserRole.admin)) {
        Get.snackbar(
          'Access Denied',
          'Only admins can add cashiers',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Save to database
      final result = await _db.insertCashier(cashier.toJson());

      if (result > 0) {
        // Update local list
        cashiers.add(cashier);
        Get.snackbar(
          'Success',
          'Cashier added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add cashier: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> updateCashier(CashierModel cashier) async {
    try {
      if (!hasPermission(UserRole.admin)) {
        Get.snackbar(
          'Access Denied',
          'Only admins can update cashiers',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Update in database
      final result = await _db.updateCashier(cashier.id, cashier.toJson());

      if (result > 0) {
        // Update local list
        final index = cashiers.indexWhere((c) => c.id == cashier.id);
        if (index != -1) {
          cashiers[index] = cashier;
        }
        Get.snackbar(
          'Success',
          'Cashier updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update cashier: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> deleteCashier(String id) async {
    try {
      if (!hasPermission(UserRole.admin)) {
        Get.snackbar(
          'Access Denied',
          'Only admins can delete cashiers',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      if (currentCashier.value?.id == id) {
        Get.snackbar(
          'Error',
          'Cannot delete currently logged in cashier',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Delete from database
      final result = await _db.deleteCashier(id);

      if (result > 0) {
        // Remove from local list
        cashiers.removeWhere((c) => c.id == id);
        Get.snackbar(
          'Success',
          'Cashier deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete cashier: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  bool hasPermission(UserRole requiredRole) {
    if (currentCashier.value == null) return false;

    final currentRole = currentCashier.value!.role;

    switch (requiredRole) {
      case UserRole.admin:
        return currentRole == UserRole.admin;
      case UserRole.manager:
        return currentRole == UserRole.admin || currentRole == UserRole.manager;
      case UserRole.cashier:
        return true; // All roles can do cashier tasks
    }
  }

  String get currentCashierName => currentCashier.value?.name ?? 'Guest';
  String get currentCashierId => currentCashier.value?.id ?? '';
  UserRole? get currentRole => currentCashier.value?.role;
}
