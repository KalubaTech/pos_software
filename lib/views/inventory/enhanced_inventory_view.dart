import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/appearance_controller.dart';
import '../../models/product_model.dart';
import '../../utils/colors.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/responsive.dart';
import '../../utils/ui_constants.dart';
import '../../components/dialogs/add_product_dialog.dart';
import '../../components/widgets/local_image_widget.dart';

class EnhancedInventoryView extends StatelessWidget {
  const EnhancedInventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());
    final appearanceController = Get.find<AppearanceController>();

    return Obx(() {
      final isDark = appearanceController.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
        body: Column(
          children: [
            _buildHeader(context, controller, isDark),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.filteredProducts.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                // On mobile, include stats in the scrollable area
                return _buildProductsGridWithStats(controller, isDark);
              }),
            ),
          ],
        ),
        floatingActionButton: context.isMobile
            ? FloatingActionButton(
                onPressed: () => _showAddProductDialog(controller),
                backgroundColor: isDark
                    ? AppColors.darkPrimary
                    : AppColors.primary,
                child: Icon(Iconsax.add, color: Colors.white),
              )
            : FloatingActionButton.extended(
                onPressed: () => _showAddProductDialog(controller),
                backgroundColor: isDark
                    ? AppColors.darkPrimary
                    : AppColors.primary,
                icon: Icon(Iconsax.add, color: Colors.white),
                label: Text(
                  'Add Product',
                  style: TextStyle(color: Colors.white),
                ),
              ),
      );
    });
  }

  Widget _buildHeader(
    BuildContext context,
    ProductController controller,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(context.isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        boxShadow: isDark
            ? []
            : [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.isMobile ? 'Inventory' : 'Inventory Management',
                      style: TextStyle(
                        fontSize: context.isMobile ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      context.isMobile
                          ? 'Manage products'
                          : 'Manage products, stock levels, and variants',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                        fontSize: context.isMobile ? 12 : 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.isMobile ? 12 : 16,
                    vertical: context.isMobile ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    context.isMobile
                        ? '${controller.filteredProducts.length}'
                        : '${controller.filteredProducts.length} Products',
                    style: TextStyle(
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: context.isMobile ? 14 : 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Make search row responsive - stack on mobile
          Responsive.isMobile(context)
              ? Column(
                  children: [
                    TextField(
                      style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: TextStyle(
                          color: AppColors.getTextSecondary(isDark),
                        ),
                        prefixIcon: Icon(
                          Iconsax.search_normal,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.getDivider(isDark),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.getDivider(isDark),
                          ),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkSurfaceVariant
                            : Colors.grey[50],
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onChanged: controller.searchProducts,
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => DropdownButtonFormField<String>(
                              value: controller.selectedCategory.value.isEmpty
                                  ? 'All'
                                  : controller.selectedCategory.value,
                              style: TextStyle(
                                color: AppColors.getTextPrimary(isDark),
                                fontSize: 14,
                              ),
                              dropdownColor: AppColors.getSurfaceColor(isDark),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.getDivider(isDark),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.getDivider(isDark),
                                  ),
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? AppColors.darkSurfaceVariant
                                    : Colors.grey[50],
                                prefixIcon: Icon(
                                  Iconsax.category,
                                  size: 18,
                                  color: AppColors.getTextSecondary(isDark),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              isExpanded: true,
                              items: [
                                DropdownMenuItem(
                                  value: 'All',
                                  child: Text(
                                    'All',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Beverages',
                                  child: Text(
                                    'Beverages',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Food',
                                  child: Text('Food'),
                                ),
                                DropdownMenuItem(
                                  value: 'Electronics',
                                  child: Text(
                                    'Electronics',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Clothing',
                                  child: Text(
                                    'Clothing',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Home & Garden',
                                  child: Text(
                                    'Home',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              onChanged: (value) =>
                                  controller.filterByCategory(value ?? ''),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.getDivider(isDark),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: PopupMenuButton<String>(
                            icon: Icon(
                              Iconsax.filter,
                              size: 20,
                              color: AppColors.getTextSecondary(isDark),
                            ),
                            color: AppColors.getSurfaceColor(isDark),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            itemBuilder: (context) =>
                                _buildFilterMenuItems(isDark),
                            onSelected: (value) {
                              // Filter products based on stock status
                              // This would need to be implemented in the controller
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        style: TextStyle(
                          color: AppColors.getTextPrimary(isDark),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by name, SKU, or barcode...',
                          hintStyle: TextStyle(
                            color: AppColors.getTextSecondary(isDark),
                          ),
                          prefixIcon: Icon(
                            Iconsax.search_normal,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.getDivider(isDark),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.getDivider(isDark),
                            ),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkSurfaceVariant
                              : Colors.grey[50],
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
                          style: TextStyle(
                            color: AppColors.getTextPrimary(isDark),
                          ),
                          dropdownColor: AppColors.getSurfaceColor(isDark),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.getDivider(isDark),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.getDivider(isDark),
                              ),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? AppColors.darkSurfaceVariant
                                : Colors.grey[50],
                            prefixIcon: Icon(
                              Iconsax.category,
                              color: AppColors.getTextSecondary(isDark),
                            ),
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
                            DropdownMenuItem(
                              value: 'Food',
                              child: Text('Food'),
                            ),
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
                        border: Border.all(color: AppColors.getDivider(isDark)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Iconsax.filter,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                        color: AppColors.getSurfaceColor(isDark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'all',
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.box,
                                  size: 18,
                                  color: AppColors.getTextSecondary(isDark),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'All Products',
                                  style: TextStyle(
                                    color: AppColors.getTextPrimary(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'low_stock',
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.danger,
                                  size: 18,
                                  color: Colors.orange,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Low Stock',
                                  style: TextStyle(
                                    color: AppColors.getTextPrimary(isDark),
                                  ),
                                ),
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
                                Text(
                                  'Out of Stock',
                                  style: TextStyle(
                                    color: AppColors.getTextPrimary(isDark),
                                  ),
                                ),
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
                                Text(
                                  'In Stock',
                                  style: TextStyle(
                                    color: AppColors.getTextPrimary(isDark),
                                  ),
                                ),
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

  Widget _buildProductsGridWithStats(
    ProductController controller,
    bool isDark,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          // On mobile: CustomScrollView with stats header and products list
          return Obx(() {
            final products = controller.filteredProducts;
            return CustomScrollView(
              slivers: [
                // Stats as header
                SliverToBoxAdapter(child: _buildQuickStats(controller, isDark)),
                // Products list
                SliverPadding(
                  padding: EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index.isOdd) {
                        return SizedBox(height: 12);
                      }
                      final productIndex = index ~/ 2;
                      return _buildMobileProductCard(
                        products[productIndex],
                        controller,
                        isDark,
                      );
                    }, childCount: products.length * 2 - 1),
                  ),
                ),
              ],
            );
          });
        }

        // Desktop: Stats at top, grid below (original layout)
        return Column(
          children: [
            _buildQuickStats(controller, isDark),
            Expanded(child: _buildProductsGrid(controller, isDark)),
          ],
        );
      },
    );
  }

  Widget _buildQuickStats(ProductController controller, bool isDark) {
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            if (isMobile) {
              // Horizontal scrollable row for mobile
              return SizedBox(
                height: 80, // Reduced height for compact cards
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    SizedBox(
                      width: 180, // Slightly narrower for compact design
                      child: _buildStatCard(
                        'Total Products',
                        '$totalProducts',
                        Iconsax.box,
                        Colors.blue,
                        Colors.blue.withValues(alpha: 0.1),
                        isDark,
                        expanded: false,
                        compact: true,
                      ),
                    ),
                    SizedBox(width: 12),
                    SizedBox(
                      width: 180,
                      child: _buildStatCard(
                        'Low Stock',
                        '$lowStockCount',
                        Iconsax.danger,
                        Colors.orange,
                        Colors.orange.withValues(alpha: 0.1),
                        isDark,
                        expanded: false,
                        compact: true,
                      ),
                    ),
                    SizedBox(width: 12),
                    SizedBox(
                      width: 180,
                      child: _buildStatCard(
                        'Out of Stock',
                        '$outOfStockCount',
                        Iconsax.close_circle,
                        Colors.red,
                        Colors.red.withValues(alpha: 0.1),
                        isDark,
                        expanded: false,
                        compact: true,
                      ),
                    ),
                    SizedBox(width: 12),
                    SizedBox(
                      width: 200, // Wider for currency value
                      child: Obx(
                        () => _buildStatCard(
                          'Total Value',
                          CurrencyFormatter.format(totalValue),
                          Iconsax.dollar_circle,
                          Colors.green,
                          Colors.green.withValues(alpha: 0.1),
                          isDark,
                          expanded: false,
                          compact: true,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Row layout for desktop
            return Row(
              children: [
                _buildStatCard(
                  'Total Products',
                  '$totalProducts',
                  Iconsax.box,
                  Colors.blue,
                  Colors.blue.withValues(alpha: 0.1),
                  isDark,
                ),
                SizedBox(width: 16),
                _buildStatCard(
                  'Low Stock',
                  '$lowStockCount',
                  Iconsax.danger,
                  Colors.orange,
                  Colors.orange.withValues(alpha: 0.1),
                  isDark,
                ),
                SizedBox(width: 16),
                _buildStatCard(
                  'Out of Stock',
                  '$outOfStockCount',
                  Iconsax.close_circle,
                  Colors.red,
                  Colors.red.withValues(alpha: 0.1),
                  isDark,
                ),
                SizedBox(width: 16),
                Obx(
                  () => _buildStatCard(
                    'Total Value',
                    CurrencyFormatter.format(totalValue),
                    Iconsax.dollar_circle,
                    Colors.green,
                    Colors.green.withValues(alpha: 0.1),
                    isDark,
                  ),
                ),
              ],
            );
          },
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
    bool isDark, {
    bool expanded = true,
    bool compact = false, // New parameter for compact mobile layout
  }) {
    final card = FadeInUp(
      duration: Duration(milliseconds: 400),
      child: Container(
        padding: compact ? EdgeInsets.all(12) : EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.getSurfaceColor(isDark),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? []
              : [
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
              padding: compact ? EdgeInsets.all(8) : EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: compact ? 20 : 24),
            ),
            SizedBox(width: compact ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                      fontSize: compact ? 11 : 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: compact ? 18 : 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return expanded ? Expanded(child: card) : card;
  }

  Widget _buildProductsGrid(ProductController controller, bool isDark) {
    // Keep Obx scoped tightly: only the list/grid is reactive to product list changes
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          // List view for mobile - much better UX for scrolling
          return Obx(() {
            final products = controller.filteredProducts;
            return ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: products.length,
              separatorBuilder: (context, index) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildMobileProductCard(
                  products[index],
                  controller,
                  isDark,
                );
              },
            );
          });
        }

        // Grid view for tablet/desktop
        final crossAxisCount = UIConstants.gridCrossAxisCount(
          context,
          mobile: 2, // 2 columns on small tablets
          tablet: 3, // 3 columns on tablet
          desktop: 4, // 4 columns on desktop
        );

        final childAspectRatio = Responsive.value<double>(
          context,
          mobile: 1.0,
          tablet: 0.85,
          desktop: 0.75,
        );

        final spacing = UIConstants.gridSpacing(context);
        final padding = context.screenPadding;

        return Obx(() {
          final products = controller.filteredProducts;
          return GridView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: padding.left,
              vertical: UIConstants.spacing12,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(products[index], controller, isDark);
            },
          );
        });
      },
    );
  }

  Widget _buildMobileProductCard(
    ProductModel product,
    ProductController controller,
    bool isDark,
  ) {
    final stockStatus = _getStockStatus(product);
    final isLowStock = product.stock <= product.minStock;
    final hasVariants =
        product.variants != null && product.variants!.isNotEmpty;

    return FadeInUp(
      duration: Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getSurfaceColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: isLowStock
              ? Border.all(color: Colors.orange.withOpacity(0.3), width: 1.5)
              : null,
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showProductDetails(product, controller, isDark),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image with Badge
                  Stack(
                    children: [
                      Hero(
                        tag: 'product_${product.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LocalImageWidget(
                              imagePath: product.imageUrl,
                              height: 90,
                              width: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      // Low stock badge
                      if (isLowStock)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.warning_2,
                                  size: 10,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'Low',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Variant badge
                      if (hasVariants)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.primary)
                                      .withOpacity(0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${product.variants!.length} types',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 12),
                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name & Menu
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getTextPrimary(isDark),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            PopupMenuButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.more_vert,
                                size: 20,
                                color: AppColors.getTextSecondary(isDark),
                              ),
                              color: AppColors.getSurfaceColor(isDark),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Iconsax.edit,
                                        size: 18,
                                        color: AppColors.getTextSecondary(
                                          isDark,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Edit',
                                        style: TextStyle(
                                          color: AppColors.getTextPrimary(
                                            isDark,
                                          ),
                                        ),
                                      ),
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
                                      Icon(
                                        Iconsax.add_square,
                                        size: 18,
                                        color: AppColors.getTextSecondary(
                                          isDark,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Adjust Stock',
                                        style: TextStyle(
                                          color: AppColors.getTextPrimary(
                                            isDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () => Future.delayed(
                                    Duration.zero,
                                    () => _showStockAdjustment(
                                      product,
                                      controller,
                                    ),
                                  ),
                                ),
                                if (hasVariants)
                                  PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Iconsax.category_2,
                                          size: 18,
                                          color: AppColors.getTextSecondary(
                                            isDark,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'View Variants',
                                          style: TextStyle(
                                            color: AppColors.getTextPrimary(
                                              isDark,
                                            ),
                                          ),
                                        ),
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
                        SizedBox(height: 6),
                        // Category Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (isDark
                                        ? AppColors.darkPrimary
                                        : AppColors.primary)
                                    .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.category,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        // SKU
                        Row(
                          children: [
                            Icon(
                              Iconsax.barcode,
                              size: 12,
                              color: AppColors.getTextSecondary(isDark),
                            ),
                            SizedBox(width: 4),
                            Text(
                              product.sku ?? 'No SKU',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.getTextSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        // Price & Stock
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Price
                            Obx(
                              () => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Price',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.getTextSecondary(isDark),
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(product.price),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Stock Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: stockStatus['color'],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    stockStatus['icon'],
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '${product.totalStock} ${product.unit}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
    ProductModel product,
    ProductController controller,
    bool isDark,
  ) {
    final stockStatus = _getStockStatus(product);

    return FadeInUp(
      duration: Duration(milliseconds: 400),
      child: Card(
        color: AppColors.getSurfaceColor(isDark),
        elevation: isDark ? 8 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => _showProductDetails(product, controller, isDark),
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
                          color: AppColors.getTextPrimary(isDark),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        product.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Iconsax.barcode,
                            size: 14,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                          SizedBox(width: 4),
                          Text(
                            product.sku ?? 'No SKU',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.getTextSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Obx(
                                  () => Text(
                                    CurrencyFormatter.format(product.price),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Stock: ${product.totalStock} ${product.unit}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.getTextSecondary(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton(
                            icon: Icon(
                              Icons.more_vert,
                              color: AppColors.getTextSecondary(isDark),
                            ),
                            color: AppColors.getSurfaceColor(isDark),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(
                                      Iconsax.edit,
                                      size: 18,
                                      color: AppColors.getTextSecondary(isDark),
                                    ),
                                    SizedBox(width: 12),
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
                                  () => _showEditProductDialog(
                                    product,
                                    controller,
                                  ),
                                ),
                              ),
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(
                                      Iconsax.add_square,
                                      size: 18,
                                      color: AppColors.getTextSecondary(isDark),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Adjust Stock',
                                      style: TextStyle(
                                        color: AppColors.getTextPrimary(isDark),
                                      ),
                                    ),
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
                                      Icon(
                                        Iconsax.category_2,
                                        size: 18,
                                        color: AppColors.getTextSecondary(
                                          isDark,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Manage Variants',
                                        style: TextStyle(
                                          color: AppColors.getTextPrimary(
                                            isDark,
                                          ),
                                        ),
                                      ),
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          Icon(Iconsax.box, size: 80, color: AppColors.getTextTertiary(isDark)),
          SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first product to get started',
            style: TextStyle(color: AppColors.getTextSecondary(isDark)),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showProductDetails(
    ProductModel product,
    ProductController controller,
    bool isDark,
  ) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.getSurfaceColor(isDark),
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
                              color: AppColors.getTextPrimary(isDark),
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildInfoRow(
                            Iconsax.category,
                            'Category',
                            product.category,
                            isDark,
                          ),
                          _buildInfoRow(
                            Iconsax.barcode,
                            'SKU',
                            product.sku ?? 'N/A',
                            isDark,
                          ),
                          _buildInfoRow(
                            Iconsax.scan_barcode,
                            'Barcode',
                            product.barcode ?? 'N/A',
                            isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(height: 32, color: AppColors.getDivider(isDark)),
                Obx(
                  () => _buildDetailRow(
                    'Price',
                    CurrencyFormatter.format(product.price),
                    isDark,
                  ),
                ),
                if (product.costPrice != null)
                  Obx(
                    () => _buildDetailRow(
                      'Cost',
                      CurrencyFormatter.format(product.costPrice!),
                      isDark,
                    ),
                  ),
                if (product.costPrice != null)
                  _buildDetailRow(
                    'Margin',
                    '${product.profitMargin.toStringAsFixed(1)}%',
                    isDark,
                  ),
                _buildDetailRow(
                  'Stock',
                  '${product.totalStock} ${product.unit}',
                  isDark,
                ),
                _buildDetailRow(
                  'Min Stock',
                  '${product.minStock} ${product.unit}',
                  isDark,
                ),
                _buildDetailRow('Status', product.stockStatus, isDark),
                if (product.variants != null &&
                    product.variants!.isNotEmpty) ...[
                  Divider(height: 32, color: AppColors.getDivider(isDark)),
                  Text(
                    'Variants (${product.variants!.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                  SizedBox(height: 12),
                  ...product.variants!.map(
                    (variant) => Card(
                      color: AppColors.getSurfaceColor(isDark),
                      elevation: isDark ? 4 : 1,
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                (isDark
                                        ? AppColors.darkPrimary
                                        : AppColors.primary)
                                    .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Iconsax.category_2,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                          ),
                        ),
                        title: Text(
                          variant.name,
                          style: TextStyle(
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                        subtitle: Text(
                          '${variant.attributeType} • SKU: ${variant.sku ?? "N/A"}',
                          style: TextStyle(
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Obx(
                              () => Text(
                                '+${CurrencyFormatter.format(variant.priceAdjustment)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getTextPrimary(isDark),
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Stock: ${variant.stock}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.getTextSecondary(isDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.primary,
                        ),
                      ),
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
                        backgroundColor: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
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

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.getTextSecondary(isDark)),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: AppColors.getTextSecondary(isDark),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.getTextSecondary(isDark)),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildFilterMenuItems(bool isDark) {
    return [
      PopupMenuItem(
        value: 'all',
        child: Row(
          children: [
            Icon(
              Iconsax.box,
              size: 18,
              color: AppColors.getTextSecondary(isDark),
            ),
            SizedBox(width: 12),
            Text(
              'All Products',
              style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            ),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'low_stock',
        child: Row(
          children: [
            Icon(Iconsax.danger, size: 18, color: Colors.orange),
            SizedBox(width: 12),
            Text(
              'Low Stock',
              style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            ),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'out_of_stock',
        child: Row(
          children: [
            Icon(Iconsax.close_circle, size: 18, color: Colors.red),
            SizedBox(width: 12),
            Text(
              'Out of Stock',
              style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            ),
          ],
        ),
      ),
    ];
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
    final appearanceController = Get.find<AppearanceController>();

    Get.dialog(
      Obx(() {
        final isDark = appearanceController.isDarkMode.value;
        return Dialog(
          backgroundColor: AppColors.getSurfaceColor(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 400,
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adjust Stock',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  product.name,
                  style: TextStyle(color: AppColors.getTextSecondary(isDark)),
                ),
                SizedBox(height: 20),
                Text(
                  'Current Stock: ${product.stock} ${product.unit}',
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                  decoration: InputDecoration(
                    labelText: 'New Stock Quantity',
                    labelStyle: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.getDivider(isDark),
                      ),
                    ),
                    suffixText: product.unit,
                    suffixStyle: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
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
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.primary,
                        ),
                      ),
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
                        backgroundColor: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
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
        );
      }),
    );
  }

  void _showVariantsDialog(ProductModel product, ProductController controller) {
    final appearanceController = Get.find<AppearanceController>();

    Get.dialog(
      Obx(() {
        final isDark = appearanceController.isDarkMode.value;
        return Dialog(
          backgroundColor: AppColors.getSurfaceColor(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 600,
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Variants',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  product.name,
                  style: TextStyle(color: AppColors.getTextSecondary(isDark)),
                ),
                Divider(height: 32, color: AppColors.getDivider(isDark)),
                Container(
                  constraints: BoxConstraints(maxHeight: 400),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: product.variants!.length,
                    itemBuilder: (context, index) {
                      final variant = product.variants![index];
                      return Card(
                        color: AppColors.getSurfaceColor(isDark),
                        elevation: isDark ? 4 : 1,
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                (isDark
                                        ? AppColors.darkPrimary
                                        : AppColors.primary)
                                    .withValues(alpha: 0.1),
                            child: Text(
                              variant.name[0],
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                          title: Text(
                            variant.name,
                            style: TextStyle(
                              color: AppColors.getTextPrimary(isDark),
                            ),
                          ),
                          subtitle: Text(
                            '${variant.attributeType} • Stock: ${variant.stock}',
                            style: TextStyle(
                              color: AppColors.getTextSecondary(isDark),
                            ),
                          ),
                          trailing: Obx(
                            () => Text(
                              '+${CurrencyFormatter.format(variant.priceAdjustment)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.getTextPrimary(isDark),
                              ),
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
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
