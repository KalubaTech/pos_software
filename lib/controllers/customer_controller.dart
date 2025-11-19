import 'package:get/get.dart';
import '../models/client_model.dart';
import '../services/database_service.dart';
import 'universal_sync_controller.dart';

class CustomerController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  UniversalSyncController? _syncController;

  var customers = <ClientModel>[].obs;
  var filteredCustomers = <ClientModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Try to get universal sync controller
    try {
      _syncController = Get.find<UniversalSyncController>();
      print('✅ CustomerController: Universal sync connected');
    } catch (e) {
      print('⚠️ CustomerController: Sync not available yet');
    }
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    try {
      isLoading.value = true;
      final result = await _dbService.getAllCustomers();
      customers.value = result;
      filteredCustomers.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load customers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void searchCustomers(String query) {
    if (query.isEmpty) {
      filteredCustomers.value = customers;
    } else {
      filteredCustomers.value = customers
          .where(
            (c) =>
                c.name.toLowerCase().contains(query.toLowerCase()) ||
                c.email.toLowerCase().contains(query.toLowerCase()) ||
                c.phoneNumber.contains(query),
          )
          .toList();
    }
  }

  Future<bool> addCustomer(ClientModel customer) async {
    try {
      final id = await _dbService.insertCustomer(customer);
      if (id > 0) {
        await fetchCustomers();

        // Sync to cloud via UniversalSyncController
        _syncController?.syncCustomer(customer);

        Get.snackbar('Success', 'Customer added successfully');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add customer: $e');
      return false;
    }
  }

  Future<bool> updateCustomer(ClientModel customer) async {
    try {
      final count = await _dbService.updateCustomer(customer);
      if (count > 0) {
        await fetchCustomers();

        // Sync to cloud via UniversalSyncController
        _syncController?.syncCustomer(customer);

        Get.snackbar('Success', 'Customer updated successfully');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update customer: $e');
      return false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    try {
      final count = await _dbService.deleteCustomer(id);
      if (count > 0) {
        await fetchCustomers();

        // Sync deletion to cloud via UniversalSyncController
        _syncController?.deleteCustomerFromCloud(id);

        Get.snackbar('Success', 'Customer deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete customer: $e');
      return false;
    }
  }
}
