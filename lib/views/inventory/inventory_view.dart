import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/appearance_controller.dart';
import '../../models/product_model.dart';
import '../../utils/colors.dart';
import '../../components/widgets/local_image_widget.dart';

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());
    final appearanceController = Get.find<AppearanceController>();

    return Obx(() {
      final isDark = appearanceController.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[100],
        body: Column(
          children: [
            _buildHeader(controller, isDark),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  );
                }

                if (controller.filteredProducts.isEmpty) {
                  return Center(
                    child: Text(
                      'No products found',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  );
                }

                return _buildProductsList(controller, isDark);
              }),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddProductDialog(controller, isDark),
          backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
          icon: Icon(Iconsax.add),
          label: Text('Add Product'),
        ),
      );
    });
  }

  Widget _buildHeader(ProductController controller, bool isDark) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        border: Border(
          bottom: BorderSide(color: AppColors.getDivider(isDark), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Inventory',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                        .withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          (isDark ? AppColors.darkPrimary : AppColors.primary)
                              .withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${controller.filteredProducts.length} products',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    hintStyle: TextStyle(
                      color: AppColors.getTextTertiary(isDark),
                    ),
                    prefixIcon: Icon(
                      Iconsax.search_normal,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : Colors.grey[100],
                  ),
                  onChanged: controller.searchProducts,
                ),
              ),
              SizedBox(width: 16),
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.getDivider(isDark)),
                  ),
                  child: DropdownButton<String>(
                    value: controller.selectedCategory.value.isEmpty
                        ? 'All'
                        : controller.selectedCategory.value,
                    dropdownColor: isDark
                        ? AppColors.darkSurface
                        : Colors.white,
                    style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                    underline: SizedBox(),
                    items:
                        [
                              'All',
                              'Beverages',
                              'Food',
                              'Electronics',
                              'Clothing',
                              'Home & Garden',
                            ]
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                    onChanged: (value) =>
                        controller.filterByCategory(value ?? ''),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(ProductController controller, bool isDark) {
    return ListView.builder(
      padding: EdgeInsets.all(24),
      itemCount: controller.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = controller.filteredProducts[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          color: AppColors.getSurfaceColor(isDark),
          elevation: isDark ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.getDivider(isDark), width: 1),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LocalImageWidget(
                imagePath: product.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              product.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  product.description,
                  style: TextStyle(color: AppColors.getTextSecondary(isDark)),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            (isDark ? AppColors.darkPrimary : AppColors.primary)
                                .withOpacity(isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color:
                              (isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.primary)
                                  .withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        product.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.isAvailable
                            ? (isDark ? AppColors.darkSecondary : Colors.green)
                                  .withOpacity(isDark ? 0.2 : 0.1)
                            : Colors.red.withOpacity(isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: product.isAvailable
                              ? (isDark
                                        ? AppColors.darkSecondary
                                        : Colors.green)
                                    .withOpacity(0.3)
                              : Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        product.isAvailable ? 'Available' : 'Out of Stock',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: product.isAvailable
                              ? (isDark
                                    ? AppColors.darkSecondary
                                    : Colors.green)
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                ),
                SizedBox(width: 16),
                PopupMenuButton(
                  color: AppColors.getSurfaceColor(isDark),
                  icon: Icon(
                    Iconsax.more,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.edit,
                            size: 18,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Edit',
                            style: TextStyle(
                              color: AppColors.getTextPrimary(isDark),
                            ),
                          ),
                        ],
                      ),
                      onTap: () => Future.delayed(
                        Duration.zero,
                        () =>
                            _showEditProductDialog(controller, product, isDark),
                      ),
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Iconsax.trash, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: () => Future.delayed(
                        Duration.zero,
                        () => _showDeleteConfirmation(
                          controller,
                          product,
                          isDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddProductDialog(ProductController controller, bool isDark) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final categoryController = TextEditingController(text: 'Beverages');
    final imageController = TextEditingController(
      text: 'https://via.placeholder.com/400',
    );

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.getSurfaceColor(isDark),
        child: Container(
          width: 500,
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Product',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    labelStyle: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    prefixIcon: Icon(
                      Iconsax.box,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : Colors.grey[50],
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descController,
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    prefixIcon: Icon(
                      Iconsax.document_text,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : Colors.grey[50],
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    prefixIcon: Icon(
                      Iconsax.dollar_circle,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : Colors.grey[50],
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    prefixIcon: Icon(
                      Iconsax.category,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : Colors.grey[50],
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: imageController,
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                  decoration: InputDecoration(
                    labelText: 'Image URL',
                    labelStyle: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    prefixIcon: Icon(
                      Iconsax.image,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : Colors.grey[50],
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.getTextSecondary(isDark),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty ||
                            priceController.text.isEmpty) {
                          Get.snackbar('Error', 'Please fill required fields');
                          return;
                        }

                        final product = ProductModel(
                          id: 'p${DateTime.now().millisecondsSinceEpoch}',
                          storeId: 's1',
                          name: nameController.text,
                          description: descController.text,
                          price: double.tryParse(priceController.text) ?? 0.0,
                          category: categoryController.text,
                          imageUrl: imageController.text,
                          isAvailable: true,
                        );

                        await controller.addProduct(product);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text('Add Product'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProductDialog(
    ProductController controller,
    ProductModel product,
    bool isDark,
  ) {
    final nameController = TextEditingController(text: product.name);
    final descController = TextEditingController(text: product.description);
    final priceController = TextEditingController(
      text: product.price.toString(),
    );
    final categoryController = TextEditingController(text: product.category);
    final imageController = TextEditingController(text: product.imageUrl);

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.getSurfaceColor(isDark),
        child: Container(
          width: 500,
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Product',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    labelStyle: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    prefixIcon: Icon(
                      Iconsax.box,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : Colors.grey[50],
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descController,
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    prefixIcon: Icon(
                      Iconsax.document_text,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : Colors.grey[50],
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    prefixIcon: Icon(
                      Iconsax.dollar_circle,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : Colors.grey[50],
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    prefixIcon: Icon(
                      Iconsax.category,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : Colors.grey[50],
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: imageController,
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                  decoration: InputDecoration(
                    labelText: 'Image URL',
                    labelStyle: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    prefixIcon: Icon(
                      Iconsax.image,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : Colors.grey[50],
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.getTextSecondary(isDark),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final updatedProduct = ProductModel(
                          id: product.id,
                          storeId: product.storeId,
                          name: nameController.text,
                          description: descController.text,
                          price:
                              double.tryParse(priceController.text) ??
                              product.price,
                          category: categoryController.text,
                          imageUrl: imageController.text,
                          isAvailable: product.isAvailable,
                        );

                        await controller.updateProduct(updatedProduct);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    ProductController controller,
    ProductModel product,
    bool isDark,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.getSurfaceColor(isDark),
        title: Text(
          'Delete Product',
          style: TextStyle(color: AppColors.getTextPrimary(isDark)),
        ),
        content: Text(
          'Are you sure you want to delete ${product.name}?',
          style: TextStyle(color: AppColors.getTextSecondary(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.getTextSecondary(isDark)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteProduct(product.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
