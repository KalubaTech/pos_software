import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/appearance_controller.dart';
import '../../controllers/business_settings_controller.dart';
import '../../utils/colors.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/responsive.dart';
import '../../utils/ui_constants.dart';
import '../../components/dialogs/enhanced_checkout_dialog.dart';
import '../../components/dialogs/variant_selection_dialog.dart';
import '../../components/widgets/local_image_widget.dart';
import '../../services/barcode_scanner_service.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CartController());
    final productController = Get.put(ProductController());
    final customerController = Get.put(CustomerController());
    final appearanceController = Get.find<AppearanceController>();

    return Obx(() {
      final isDark = appearanceController.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[100],
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (context.isMobile) {
              // Mobile: Tab view (Products / Cart)
              return DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Container(
                      color: AppColors.getSurfaceColor(isDark),
                      child: TabBar(
                        labelColor: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                        unselectedLabelColor: AppColors.getTextSecondary(
                          isDark,
                        ),
                        indicatorColor: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                        tabs: [
                          Tab(icon: Icon(Iconsax.shop), text: 'Products'),
                          Obx(
                            () => Tab(
                              icon: Icon(Iconsax.shopping_cart),
                              text: 'Cart (${cartController.cartItems.length})',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildProductsSection(
                            context,
                            productController,
                            cartController,
                            isDark,
                          ),
                          _buildCartSection(
                            context,
                            cartController,
                            customerController,
                            isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Desktop: Split view (Products | Cart)
              return Row(
                children: [
                  // Products Section
                  Expanded(
                    flex: 2,
                    child: _buildProductsSection(
                      context,
                      productController,
                      cartController,
                      isDark,
                    ),
                  ),
                  // Cart Section
                  Container(
                    width: Responsive.value<double>(
                      context,
                      mobile: 300,
                      tablet: 350,
                      desktop: 400,
                    ),
                    color: AppColors.getSurfaceColor(isDark),
                    child: _buildCartSection(
                      context,
                      cartController,
                      customerController,
                      isDark,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      );
    });
  }

  Widget _buildProductsSection(
    BuildContext context,
    ProductController productController,
    CartController cartController,
    bool isDark,
  ) {
    final barcodeScanner = Get.put(BarcodeScannerService());

    return Stack(
      children: [
        Column(
          children: [
            // Header with search and filters
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              color: AppColors.getSurfaceColor(isDark),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Point of Sale',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  TextField(
                    style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                    decoration: InputDecoration(
                      hintText: 'Search products by name or SKU...',
                      hintStyle: TextStyle(
                        color: AppColors.getTextTertiary(isDark),
                      ),
                      prefixIcon: Icon(
                        Iconsax.search_normal_1,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14.0,
                      ),
                    ),
                    onChanged: productController.searchProducts,
                  ),
                  const SizedBox(height: 16),
                  // Category Filters
                  SizedBox(
                    height: 40,
                    child: () {
                      final categories = [
                        'All',
                        'Beverages',
                        'Food',
                        'Electronics',
                        'Clothing',
                        'Home & Garden',
                      ];
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return Obx(() {
                            final isSelected =
                                (productController
                                        .selectedCategory
                                        .value
                                        .isEmpty &&
                                    category == 'All') ||
                                productController.selectedCategory.value ==
                                    category;
                            return ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  productController.filterByCategory(category);
                                }
                              },
                              backgroundColor: isDark
                                  ? AppColors.darkSurfaceVariant
                                  : Colors.grey.shade200,
                              selectedColor:
                                  (isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.primary)
                                      .withOpacity(isDark ? 0.25 : 0.15),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? (isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.primary)
                                    : AppColors.getTextSecondary(isDark),
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected
                                      ? (isDark
                                            ? AppColors.darkPrimary
                                            : AppColors.primary)
                                      : Colors.transparent,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            );
                          });
                        },
                      );
                    }(),
                  ),
                ],
              ),
            ),
            // Products Grid
            Expanded(
              child: Obx(() {
                if (productController.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  );
                }

                if (productController.filteredProducts.isEmpty) {
                  return Center(
                    child: Text(
                      'No products found',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Determine if we're on mobile
                    final isMobile = constraints.maxWidth < 600;

                    if (isMobile) {
                      // Mobile: 2 column grid with compact cards
                      return GridView.builder(
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: productController.filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product =
                              productController.filteredProducts[index];
                          return _buildMobileProductCard(
                            product,
                            cartController,
                            isDark,
                          );
                        },
                      );
                    } else {
                      // Desktop: 3 column grid
                      return GridView.builder(
                        padding: EdgeInsets.all(24),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: productController.filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product =
                              productController.filteredProducts[index];
                          return _buildProductCard(
                            product,
                            cartController,
                            isDark,
                          );
                        },
                      );
                    }
                  },
                );
              }),
            ),
          ],
        ),
        // Floating Barcode Scanner Button - Hidden on mobile to avoid blocking products
        if (!context.isMobile)
          Positioned(
            right: 24,
            bottom: 24,
            child: FloatingActionButton.extended(
              onPressed: () async {
                final barcode = await barcodeScanner.scanBarcode();
                if (barcode != null) {
                  final product = await barcodeScanner.findProductByBarcode(
                    barcode,
                  );
                  if (product != null) {
                    cartController.addToCart(product);
                    Get.snackbar(
                      'Product Added',
                      '${product.name} added to cart',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: isDark
                          ? AppColors.darkSecondary.withOpacity(0.9)
                          : Colors.green,
                      colorText: isDark
                          ? AppColors.darkTextPrimary
                          : Colors.white,
                      duration: Duration(seconds: 2),
                    );
                  } else {
                    Get.snackbar(
                      'Product Not Found',
                      'No product found with barcode: $barcode',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                  }
                }
              },
              backgroundColor: isDark
                  ? AppColors.darkPrimary
                  : AppColors.primary,
              icon: Icon(Iconsax.scan_barcode, color: Colors.white),
              label: Text(
                'Scan Barcode',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductCard(
    product,
    CartController cartController,
    bool isDark,
  ) {
    final hasVariants =
        product.variants != null && product.variants!.isNotEmpty;

    return Card(
      elevation: UIConstants.cardElevation(Get.context!, isDark: isDark),
      color: AppColors.getSurfaceColor(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: UIConstants.borderRadiusLarge,
        side: BorderSide(color: AppColors.getDivider(isDark), width: 1),
      ),
      child: InkWell(
        onTap: () {
          if (hasVariants) {
            // Show variant selection dialog
            Get.dialog(
              VariantSelectionDialog(
                product: product,
                onVariantSelected: (variant) {
                  cartController.addToCart(product, variant: variant);
                },
              ),
            );
          } else {
            // Add product directly
            cartController.addToCart(product);
          }
        },
        borderRadius: UIConstants.borderRadiusLarge,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(UIConstants.spacing12),
                    ),
                    child: LocalImageWidget(
                      imagePath: product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: Get.context!.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Get.context!.fontSizeBody,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      UIConstants.verticalSpace(UIConstants.spacing4),
                      Text(
                        product.category,
                        style: TextStyle(
                          fontSize: Get.context!.fontSizeCaption,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                      ),
                      UIConstants.verticalSpace(UIConstants.spacing8),
                      Obx(
                        () => Text(
                          CurrencyFormatter.format(product.price),
                          style: TextStyle(
                            fontSize: Get.context!.fontSizeTitle,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Variants badge
            if (hasVariants)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${product.variants!.length} variants',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileProductCard(
    product,
    CartController cartController,
    bool isDark,
  ) {
    final hasVariants =
        product.variants != null && product.variants!.isNotEmpty;
    final isLowStock = product.stock <= product.minStock;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('🔘 Mobile card tapped: ${product.name}');
          if (hasVariants) {
            Get.dialog(
              VariantSelectionDialog(
                product: product,
                onVariantSelected: (variant) {
                  cartController.addToCart(product, variant: variant);
                },
              ),
            );
          } else {
            cartController.addToCart(product);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 2,
          color: AppColors.getSurfaceColor(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isLowStock
                ? BorderSide(color: Colors.orange.withOpacity(0.5), width: 1)
                : BorderSide.none,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: LocalImageWidget(
                        imagePath: product.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    // Low stock badge
                    if (isLowStock)
                      Positioned(
                        top: 6,
                        left: 6,
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
                    // Variants badge
                    if (hasVariants)
                      Positioned(
                        top: 6,
                        right: 6,
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
                                    .withOpacity(0.95),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            '${product.variants!.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Product Info
              Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Obx(
                      () => Text(
                        CurrencyFormatter.format(product.price),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.category,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (isDark
                                        ? AppColors.darkPrimary
                                        : AppColors.primary)
                                    .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${product.stock} ${product.unit}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartSection(
    BuildContext context,
    CartController cartController,
    CustomerController customerController,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(color: AppColors.getDivider(isDark)),
        ),
      ),
      child: Column(
        children: [
          // Customer Selection
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.getDivider(isDark)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Obx(() {
                  final hasCustomer =
                      cartController.selectedCustomerId.value.isNotEmpty;
                  return InkWell(
                    onTap: () => _showCustomerSelector(
                      customerController,
                      cartController,
                      isDark,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.getDivider(isDark)),
                        borderRadius: BorderRadius.circular(8),
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : Colors.grey[50],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.user,
                            size: 20,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              hasCustomer
                                  ? cartController.selectedCustomerName.value
                                  : 'Walk-in Customer',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.getTextPrimary(isDark),
                              ),
                            ),
                          ),
                          Icon(
                            Iconsax.arrow_down_1,
                            size: 16,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Cart Items
          Expanded(
            child: Obx(() {
              if (cartController.cartItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.shopping_cart,
                        size: 64,
                        color: AppColors.getTextTertiary(isDark),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Cart is empty',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: cartController.cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartController.cartItems[index];
                  return _buildCartItem(item, cartController, isDark);
                },
              );
            }),
          ),
          // Cart Summary
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : Colors.grey[50],
              border: Border(
                top: BorderSide(color: AppColors.getDivider(isDark)),
              ),
            ),
            child: Column(
              children: [
                Obx(
                  () => _buildSummaryRow(
                    'Subtotal',
                    CurrencyFormatter.format(cartController.subtotal),
                    isDark,
                  ),
                ),
                SizedBox(height: 8),
                Obx(() {
                  final settings = Get.find<BusinessSettingsController>();
                  // Recalculate tax inside Obx for reactivity
                  final taxAmount = settings.taxEnabled.value
                      ? cartController.subtotal * (settings.taxRate.value / 100)
                      : 0.0;

                  if (settings.taxEnabled.value && taxAmount > 0) {
                    return Column(
                      children: [
                        _buildSummaryRow(
                          '${settings.taxName.value} (${settings.taxRate.value.toStringAsFixed(1)}%)',
                          CurrencyFormatter.format(taxAmount),
                          isDark,
                        ),
                        SizedBox(height: 8),
                      ],
                    );
                  }
                  return SizedBox();
                }),
                Obx(
                  () => _buildSummaryRow(
                    'Discount',
                    '-${CurrencyFormatter.format(cartController.discount.value)}',
                    isDark,
                  ),
                ),
                Divider(height: 24, color: AppColors.getDivider(isDark)),
                Obx(() {
                  final settings = Get.find<BusinessSettingsController>();
                  // Recalculate tax inside Obx for reactivity
                  final taxAmount = settings.taxEnabled.value
                      ? cartController.subtotal * (settings.taxRate.value / 100)
                      : 0.0;
                  final totalAmount =
                      cartController.subtotal +
                      taxAmount -
                      cartController.discount.value;

                  return _buildSummaryRow(
                    'Total',
                    CurrencyFormatter.format(totalAmount),
                    isDark,
                    large: true,
                  );
                }),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => cartController.clearCart(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: AppColors.getDivider(isDark)),
                          foregroundColor: AppColors.getTextPrimary(isDark),
                        ),
                        child: Text('Clear'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: cartController.cartItems.isEmpty
                              ? null
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        EnhancedCheckoutDialog(
                                          cartController: cartController,
                                        ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                            disabledBackgroundColor: AppColors.getTextTertiary(
                              isDark,
                            ),
                          ),
                          child: Text(
                            'Checkout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(item, CartController cartController, bool isDark) {
    return Card(
      margin: EdgeInsets.only(bottom: Get.context!.itemSpacing),
      color: AppColors.getSurfaceColor(isDark),
      elevation: UIConstants.cardElevation(Get.context!, isDark: isDark),
      shape: RoundedRectangleBorder(
        borderRadius: UIConstants.borderRadiusMedium,
        side: BorderSide(color: AppColors.getDivider(isDark), width: 1),
      ),
      child: Padding(
        padding: Get.context!.cardPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: UIConstants.borderRadiusMedium,
              child: LocalImageWidget(
                // Use variant image if available, otherwise product image
                imagePath:
                    item.selectedVariant?.imageUrl ?? item.product.imageUrl,
                width: Get.context!.iconSizeXLarge,
                height: Get.context!.iconSizeXLarge,
                fit: BoxFit.cover,
              ),
            ),
            UIConstants.horizontalSpace(UIConstants.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.displayName, // Shows product name with variant
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: Get.context!.fontSizeBody,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  UIConstants.verticalSpace(UIConstants.spacing4),
                  Obx(
                    () => Text(
                      CurrencyFormatter.format(
                        item.unitPrice,
                      ), // Use unitPrice which includes variant
                      style: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                        fontSize: Get.context!.fontSizeCaption,
                      ),
                    ),
                  ),
                  if (item.selectedVariant != null)
                    Container(
                      margin: EdgeInsets.only(top: UIConstants.spacing4),
                      padding: EdgeInsets.symmetric(
                        horizontal: UIConstants.spacing8,
                        vertical: UIConstants.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (isDark ? AppColors.darkPrimary : AppColors.primary)
                                .withValues(alpha: isDark ? 0.25 : 0.1),
                        borderRadius: UIConstants.borderRadiusSmall,
                      ),
                      child: Text(
                        item.selectedVariant!.attributeType,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Iconsax.minus_cirlce,
                    size: Get.context!.iconSizeMedium,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  onPressed: () => cartController.updateQuantity(
                    item.product.id,
                    item.quantity - 1,
                    variantId: item.selectedVariant?.id,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${item.quantity}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Iconsax.add_circle,
                    size: 20,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  onPressed: () => cartController.updateQuantity(
                    item.product.id,
                    item.quantity + 1,
                    variantId: item.selectedVariant?.id,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    bool isDark, {
    bool large = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: large ? 18 : 14,
            fontWeight: large ? FontWeight.bold : FontWeight.normal,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: large ? 20 : 14,
            fontWeight: large ? FontWeight.bold : FontWeight.w600,
            color: large
                ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                : AppColors.getTextPrimary(isDark),
          ),
        ),
      ],
    );
  }

  void _showCustomerSelector(
    CustomerController customerController,
    CartController cartController,
    bool isDark,
  ) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.getSurfaceColor(isDark),
        child: Container(
          width: 500,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Customer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  hintText: 'Search customers...',
                  hintStyle: TextStyle(
                    color: AppColors.getTextTertiary(isDark),
                  ),
                  prefixIcon: Icon(
                    Iconsax.search_normal,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                ),
                onChanged: customerController.searchCustomers,
              ),
              SizedBox(height: 16),
              Container(
                height: 300,
                child: Obx(() {
                  return ListView.builder(
                    itemCount: customerController.filteredCustomers.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ListTile(
                          leading: Icon(
                            Iconsax.user,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                          title: Text(
                            'Walk-in Customer',
                            style: TextStyle(
                              color: AppColors.getTextPrimary(isDark),
                            ),
                          ),
                          onTap: () {
                            cartController.setCustomer('', '');
                            Get.back();
                          },
                        );
                      }

                      final customer =
                          customerController.filteredCustomers[index - 1];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              (isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.primary)
                                  .withOpacity(isDark ? 0.25 : 0.1),
                          child: Text(
                            customer.name[0].toUpperCase(),
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          customer.name,
                          style: TextStyle(
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                        subtitle: Text(
                          customer.email,
                          style: TextStyle(
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                        onTap: () {
                          cartController.setCustomer(
                            customer.id,
                            customer.name,
                          );
                          Get.back();
                        },
                      );
                    },
                  );
                }),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.getTextSecondary(isDark)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
