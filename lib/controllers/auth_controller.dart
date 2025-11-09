import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/cashier_model.dart';

class AuthController extends GetxController {
  final GetStorage _storage = GetStorage();

  var isAuthenticated = false.obs;
  var currentCashier = Rx<CashierModel?>(null);
  var cashiers = <CashierModel>[].obs;

  // Mock cashiers for demo
  final List<CashierModel> _mockCashiers = [
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

  @override
  void onInit() {
    super.onInit();
    cashiers.value = _mockCashiers;
    _checkStoredSession();
  }

  void _checkStoredSession() {
    final cashierId = _storage.read('currentCashierId');
    if (cashierId != null) {
      final cashier = cashiers.firstWhereOrNull((c) => c.id == cashierId);
      if (cashier != null) {
        currentCashier.value = cashier;
        isAuthenticated.value = true;
      }
    }
  }

  Future<bool> login(String pin) async {
    try {
      final cashier = cashiers.firstWhereOrNull(
        (c) => c.pin == pin && c.isActive,
      );

      if (cashier == null) {
        return false;
      }

      currentCashier.value = cashier.copyWith(lastLogin: DateTime.now());
      isAuthenticated.value = true;

      // Store session
      await _storage.write('currentCashierId', cashier.id);

      return true;
    } catch (e) {
      print('Login error: $e');
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
        Get.snackbar('Access Denied', 'Only admins can add cashiers');
        return false;
      }

      cashiers.add(cashier);
      Get.snackbar('Success', 'Cashier added successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add cashier: $e');
      return false;
    }
  }

  Future<bool> updateCashier(CashierModel cashier) async {
    try {
      if (!hasPermission(UserRole.admin)) {
        Get.snackbar('Access Denied', 'Only admins can update cashiers');
        return false;
      }

      final index = cashiers.indexWhere((c) => c.id == cashier.id);
      if (index != -1) {
        cashiers[index] = cashier;
        Get.snackbar('Success', 'Cashier updated successfully');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update cashier: $e');
      return false;
    }
  }

  Future<bool> deleteCashier(String id) async {
    try {
      if (!hasPermission(UserRole.admin)) {
        Get.snackbar('Access Denied', 'Only admins can delete cashiers');
        return false;
      }

      if (currentCashier.value?.id == id) {
        Get.snackbar('Error', 'Cannot delete currently logged in cashier');
        return false;
      }

      cashiers.removeWhere((c) => c.id == id);
      Get.snackbar('Success', 'Cashier deleted successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete cashier: $e');
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
