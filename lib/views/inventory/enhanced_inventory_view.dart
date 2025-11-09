import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/business_settings_controller.dart';
import '../../models/product_model.dart';
import '../../utils/colors.dart';
import '../../utils/currency_formatter.dart';
import '../../components/dialogs/add_product_dialog.dart';
import '../../components/widgets/local_image_widget.dart';

class EnhancedInventoryView extends StatelessWidget {
  const EnhancedInventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(controller),
          _buildQuickStats(controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.filteredProducts.isEmpty) {
                return _buildEmptyState();
              }

              return _buildProductsGrid(controller);
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(controller),
        backgroundColor: AppColors.primary,
        icon: Icon(Iconsax.add, color: Colors.white),
        label: Text('Add Product', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHeader(ProductController controller) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inventory Management',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage products, stock levels, and variants',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.filteredProducts.length} Products',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, SKU, or barcode...',
                    prefixIcon: Icon(Iconsax.search_normal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: controller.searchProducts,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedCategory.value.isEmpty
                        ? 'All'
                        : controller.selectedCategory.value,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      prefixIcon: Icon(Iconsax.category),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All Categories'),
                      ),
                      DropdownMenuItem(
                        value: 'Beverages',
                        child: Text('Beverages'),
                      ),
                      DropdownMenuItem(value: 'Food', child: Text('Food')),
                      DropdownMenuItem(
                        value: 'Electronics',
                        child: Text('Electronics'),
                      ),
                      DropdownMenuItem(
                        value: 'Clothing',
                        child: Text('Clothing'),
                      ),
                      DropdownMenuItem(
                        value: 'Home & Garden',
                        child: Text('Home & Garden'),
                      ),
                    ],
                    onChanged: (value) =>
                        controller.filterByCategory(value ?? ''),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PopupMenuButton<String>(
                  icon: Icon(Iconsax.filter),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'all',
                      child: Row(
                        children: [
                          Icon(Iconsax.box, size: 18),
                          SizedBox(width: 12),
                          Text('All Products'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'low_stock',
                      child: Row(
                        children: [
                          Icon(Iconsax.danger, size: 18, color: Colors.orange),
                          SizedBox(width: 12),
                          Text('Low Stock'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'out_of_stock',
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.close_circle,
                            size: 18,
                            color: Colors.red,
                          ),
                          SizedBox(width: 12),
                          Text('Out of Stock'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'in_stock',
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.tick_circle,
                            size: 18,
                            color: Colors.green,
                          ),
                          SizedBox(width: 12),
                          Text('In Stock'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    // Filter products based on stock status
                    // This would need to be implemented in the controller
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ProductController controller) {
    return Obx(() {
      final products = controller.products;
      final totalProducts = products.length;
      final lowStockCount = products.where((p) => p.isLowStock).length;
      final outOfStockCount = products.where((p) => p.isOutOfStock).length;
      final totalValue = products.fold<double>(
        0,
        (sum, p) => sum + (p.price * p.stock),
      );

      return Container(
        margin: EdgeInsets.all(24),
        child: Row(
          children: [
            _buildStatCard(
              'Total Products',
              '$totalProducts',
              Iconsax.box,
              Colors.blue,
              Colors.blue.withValues(alpha: 0.1),
            ),
            SizedBox(width: 16),
            _buildStatCard(
              'Low Stock',
              '$lowStockCount',
              Iconsax.danger,
              Colors.orange,
              Colors.orange.withValues(alpha: 0.1),
            ),
            SizedBox(width: 16),
            _buildStatCard(
              'Out of Stock',
              '$outOfStockCount',
              Iconsax.close_circle,
              Colors.red,
              Colors.red.withValues(alpha: 0.1),
            ),
            SizedBox(width: 16),
            Obx(
              () => _buildStatCard(
                'Total Value',
                CurrencyFormatter.format(totalValue),
                Iconsax.dollar_circle,
                Colors.green,
                Colors.green.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    return Expanded(
      child: FadeInUp(
        duration: Duration(milliseconds: 400),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsGrid(ProductController controller) {
    return Obx(() {
      final products = controller.filteredProducts;
      return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(products[index], controller);
        },
      );
    });
  }

  Widget _buildProductCard(ProductModel product, ProductController controller) {
    final stockStatus = _getStockStatus(product);

    return FadeInUp(
      duration: Duration(milliseconds: 400),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => _showProductDetails(product, controller),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with Stock Badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: LocalImageWidget(
                      imagePath: product.imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: stockStatus['color'],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            stockStatus['icon'],
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            stockStatus['label'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Product Info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        product.category,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Iconsax.barcode,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            product.sku ?? 'No SKU',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(
                                () => Text(
                                  CurrencyFormatter.format(product.price),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              Text(
                                'Stock: ${product.totalStock} ${product.unit}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          PopupMenuButton(
                            icon: Icon(Icons.more_vert),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(Iconsax.edit, size: 18),
                                    SizedBox(width: 12),
                                    Text('Edit'),
                                  ],
                                ),
                                onTap: () => Future.delayed(
                                  Duration.zero,
                                  () => _showEditProductDialog(
                                    product,
                                    controller,
                                  ),
                                ),
                              ),
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(Iconsax.add_square, size: 18),
                                    SizedBox(width: 12),
                                    Text('Adjust Stock'),
                                  ],
                                ),
                                onTap: () => Future.delayed(
                                  Duration.zero,
                                  () =>
                                      _showStockAdjustment(product, controller),
                                ),
                              ),
                              if (product.variants != null &&
                                  product.variants!.isNotEmpty)
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Iconsax.category_2, size: 18),
                                      SizedBox(width: 12),
                                      Text('Manage Variants'),
                                    ],
                                  ),
                                  onTap: () => Future.delayed(
                                    Duration.zero,
                                    () => _showVariantsDialog(
                                      product,
                                      controller,
                                    ),
                                  ),
                                ),
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(
                                      Iconsax.trash,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                                onTap: () =>
                                    controller.deleteProduct(product.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStockStatus(ProductModel product) {
    if (product.isOutOfStock) {
      return {
        'label': 'Out of Stock',
        'color': Colors.red,
        'icon': Iconsax.close_circle,
      };
    } else if (product.isLowStock) {
      return {
        'label': 'Low Stock',
        'color': Colors.orange,
        'icon': Iconsax.danger,
      };
    } else {
      return {
        'label': 'In Stock',
        'color': Colors.green,
        'icon': Iconsax.tick_circle,
      };
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.box, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first product to get started',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(ProductModel product, ProductController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 600,
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LocalImageWidget(
                        imagePath: product.imageUrl,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildInfoRow(
                            Iconsax.category,
                            'Category',
                            product.category,
                          ),
                          _buildInfoRow(
                            Iconsax.barcode,
                            'SKU',
                            product.sku ?? 'N/A',
                          ),
                          _buildInfoRow(
                            Iconsax.scan_barcode,
                            'Barcode',
                            product.barcode ?? 'N/A',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(height: 32),
                Obx(
                  () => _buildDetailRow(
                    'Price',
                    CurrencyFormatter.format(product.price),
                  ),
                ),
                if (product.costPrice != null)
                  Obx(
                    () => _buildDetailRow(
                      'Cost',
                      CurrencyFormatter.format(product.costPrice!),
                    ),
                  ),
                if (product.costPrice != null)
                  _buildDetailRow(
                    'Margin',
                    '${product.profitMargin.toStringAsFixed(1)}%',
                  ),
                _buildDetailRow(
                  'Stock',
                  '${product.totalStock} ${product.unit}',
                ),
                _buildDetailRow(
                  'Min Stock',
                  '${product.minStock} ${product.unit}',
                ),
                _buildDetailRow('Status', product.stockStatus),
                if (product.variants != null &&
                    product.variants!.isNotEmpty) ...[
                  Divider(height: 32),
                  Text(
                    'Variants (${product.variants!.length})',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  ...product.variants!.map(
                    (variant) => Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Iconsax.category_2,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(variant.name),
                        subtitle: Text(
                          '${variant.attributeType} • SKU: ${variant.sku ?? "N/A"}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Obx(
                              () => Text(
                                '+${CurrencyFormatter.format(variant.priceAdjustment)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              'Stock: ${variant.stock}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Close'),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        _showEditProductDialog(product, controller);
                      },
                      icon: Icon(Iconsax.edit, size: 18, color: Colors.white),
                      label: Text(
                        'Edit',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAddProductDialog(ProductController controller) {
    Get.dialog(AddProductDialog());
  }

  void _showEditProductDialog(
    ProductModel product,
    ProductController controller,
  ) {
    Get.dialog(AddProductDialog(product: product));
  }

  void _showStockAdjustment(
    ProductModel product,
    ProductController controller,
  ) {
    final stockController = TextEditingController(
      text: product.stock.toString(),
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adjust Stock',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(product.name, style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 20),
              Text('Current Stock: ${product.stock} ${product.unit}'),
              SizedBox(height: 16),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'New Stock Quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixText: product.unit,
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final newStock =
                          int.tryParse(stockController.text) ?? product.stock;
                      final updatedProduct = product.copyWith(
                        stock: newStock,
                        lastRestocked: DateTime.now(),
                      );
                      controller.updateProduct(updatedProduct);
                      Get.back();
                      Get.snackbar(
                        'Success',
                        'Stock updated successfully',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text(
                      'Update',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVariantsDialog(ProductModel product, ProductController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 600,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Variants',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(product.name, style: TextStyle(color: Colors.grey[600])),
              Divider(height: 32),
              Container(
                constraints: BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: product.variants!.length,
                  itemBuilder: (context, index) {
                    final variant = product.variants![index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            variant.name[0],
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                        title: Text(variant.name),
                        subtitle: Text(
                          '${variant.attributeType} • Stock: ${variant.stock}',
                        ),
                        trailing: Obx(
                          () => Text(
                            '+${CurrencyFormatter.format(variant.priceAdjustment)}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Get.back(), child: Text('Close')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
