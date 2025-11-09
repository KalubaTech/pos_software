import 'package:get/get.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';

class ProductController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();

  var products = <ProductModel>[].obs;
  var filteredProducts = <ProductModel>[].obs;
  var isLoading = false.obs;
  var selectedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final result = await _dbService.getAllProducts();
      products.value = result;
      filteredProducts.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products: $e');
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
      final id = await _dbService.insertProduct(product);
      if (id > 0) {
        await fetchProducts();
        Get.snackbar('Success', 'Product added successfully');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: $e');
      return false;
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    try {
      final count = await _dbService.updateProduct(product);
      if (count > 0) {
        await fetchProducts();
        Get.snackbar('Success', 'Product updated successfully');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update product: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final count = await _dbService.deleteProduct(id);
      if (count > 0) {
        await fetchProducts();
        Get.snackbar('Success', 'Product deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: $e');
      return false;
    }
  }
}
