import 'package:get/get.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';
import 'universal_sync_controller.dart';
import 'business_settings_controller.dart';

class ProductController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  UniversalSyncController? _syncController;

  var products = <ProductModel>[].obs;
  var filteredProducts = <ProductModel>[].obs;
  var isLoading = false.obs;
  var selectedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Try to get universal sync controller
    try {
      _syncController = Get.find<UniversalSyncController>();
      print('✅ ProductController: Universal sync connected');
    } catch (e) {
      print('⚠️ ProductController: Sync not available yet');
    }
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final result = await _dbService.getAllProducts();
      products.value = result;
      filteredProducts.value = result;
    } catch (e) {
      print('Error loading products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    if (category.isEmpty || category == 'All') {
      filteredProducts.value = products;
    } else {
      filteredProducts.value = products
          .where((p) => p.category == category)
          .toList();
    }
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      filteredProducts.value = products;
    } else {
      filteredProducts.value = products
          .where(
            (p) =>
                p.name.toLowerCase().contains(query.toLowerCase()) ||
                p.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }

  Future<bool> addProduct(ProductModel product) async {
    try {
      print('📦 Adding product: ${product.name}');
      print('   - Listed Online: ${product.listedOnline}');

      // Try to get sync controller if not already available
      if (_syncController == null) {
        try {
          _syncController = Get.find<UniversalSyncController>();
          print('✅ ProductController: Universal sync connected (late)');
        } catch (e) {
          print('⚠️ ProductController: Sync still not available');
        }
      }

      print(
        '   - Sync Controller: ${_syncController != null ? "Available" : "NULL"}',
      );

      final id = await _dbService.insertProduct(product);
      if (id > 0) {
        await fetchProducts();

        // Sync to cloud via UniversalSyncController
        if (_syncController != null) {
          print('🔄 Calling syncProduct...');
          _syncController?.syncProduct(product);
        } else {
          print('⚠️ Cannot sync - UniversalSyncController is NULL');
        }

        // Update online product count
        _updateOnlineProductCount();

        return true;
      }
      return false;
    } catch (e) {
      print('Error adding product: $e');
      return false;
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    try {
      print('📦 Updating product: ${product.name}');
      print('   - Listed Online: ${product.listedOnline}');

      // Try to get sync controller if not already available
      if (_syncController == null) {
        try {
          _syncController = Get.find<UniversalSyncController>();
          print('✅ ProductController: Universal sync connected (late)');
        } catch (e) {
          print('⚠️ ProductController: Sync still not available');
        }
      }

      print(
        '   - Sync Controller: ${_syncController != null ? "Available" : "NULL"}',
      );

      final count = await _dbService.updateProduct(product);
      if (count > 0) {
        await fetchProducts();

        // Sync to cloud via UniversalSyncController
        if (_syncController != null) {
          print('🔄 Calling syncProduct...');
          _syncController?.syncProduct(product);
        } else {
          print('⚠️ Cannot sync - UniversalSyncController is NULL');
        }

        // Update online product count
        _updateOnlineProductCount();

        return true;
      }
      return false;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final count = await _dbService.deleteProduct(id);
      if (count > 0) {
        await fetchProducts();

        // Sync deletion to cloud via UniversalSyncController
        _syncController?.deleteProductFromCloud(id);

        // Update online product count
        _updateOnlineProductCount();

        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  void _updateOnlineProductCount() {
    try {
      final settingsController = Get.find<BusinessSettingsController>();
      final onlineCount = products.where((p) => p.listedOnline).length;
      settingsController.updateOnlineProductCount(onlineCount);
    } catch (e) {
      // BusinessSettingsController not available yet
      print('⚠️ ProductController: Could not update online product count');
    }
  }
}
