import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/business_settings_controller.dart';
import '../../utils/colors.dart';
import '../../utils/currency_formatter.dart';
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

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // Products Section
          Expanded(
            flex: 2,
            child: _buildProductsSection(
              context,
              productController,
              cartController,
            ),
          ),
          // Cart Section
          Container(
            width: 400,
            color: Colors.white,
            child: _buildCartSection(
              context,
              cartController,
              customerController,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(
    BuildContext context,
    ProductController productController,
    CartController cartController,
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
              color: Colors.white,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Point of Sale',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products by name or SKU...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(
                        Iconsax.search_normal_1,
                        color: Colors.grey.shade600,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
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
                              backgroundColor: Colors.grey.shade200,
                              selectedColor: AppColors.primary.withOpacity(
                                0.15,
                              ),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primary
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
                  return Center(child: CircularProgressIndicator());
                }

                if (productController.filteredProducts.isEmpty) {
                  return Center(child: Text('No products found'));
                }

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
                    final product = productController.filteredProducts[index];
                    return _buildProductCard(product, cartController);
                  },
                );
              }),
            ),
          ],
        ),
        // Floating Barcode Scanner Button
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
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
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
            backgroundColor: AppColors.primary,
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

  Widget _buildProductCard(product, CartController cartController) {
    final hasVariants =
        product.variants != null && product.variants!.isNotEmpty;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: LocalImageWidget(
                      imagePath: product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
                    color: AppColors.primary,
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

  Widget _buildCartSection(
    BuildContext context,
    CartController cartController,
    CustomerController customerController,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: BorderDirectional(start: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Customer Selection
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
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
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.user, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              hasCustomer
                                  ? cartController.selectedCustomerName.value
                                  : 'Walk-in Customer',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Icon(Iconsax.arrow_down_1, size: 16),
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
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Cart is empty',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
                  return _buildCartItem(item, cartController);
                },
              );
            }),
          ),
          // Cart Summary
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                Obx(
                  () => _buildSummaryRow(
                    'Subtotal',
                    CurrencyFormatter.format(cartController.subtotal),
                  ),
                ),
                SizedBox(height: 8),
                Obx(
                  () => _buildSummaryRow(
                    'Tax (8%)',
                    CurrencyFormatter.format(cartController.tax),
                  ),
                ),
                SizedBox(height: 8),
                Obx(
                  () => _buildSummaryRow(
                    'Discount',
                    '-${CurrencyFormatter.format(cartController.discount.value)}',
                  ),
                ),
                Divider(height: 24),
                Obx(
                  () => _buildSummaryRow(
                    'Total',
                    CurrencyFormatter.format(cartController.total),
                    large: true,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => cartController.clearCart(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
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
                            backgroundColor: AppColors.primary,
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

  Widget _buildCartItem(item, CartController cartController) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LocalImageWidget(
                // Use variant image if available, otherwise product image
                imagePath:
                    item.selectedVariant?.imageUrl ?? item.product.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayName, // Shows product name with variant
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Obx(
                    () => Text(
                      CurrencyFormatter.format(
                        item.unitPrice,
                      ), // Use unitPrice which includes variant
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
                  if (item.selectedVariant != null)
                    Container(
                      margin: EdgeInsets.only(top: 4),
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.selectedVariant!.attributeType,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Iconsax.minus_cirlce, size: 20),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: Icon(Iconsax.add_circle, size: 20),
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

  Widget _buildSummaryRow(String label, String value, {bool large = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: large ? 18 : 14,
            fontWeight: large ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: large ? 20 : 14,
            fontWeight: large ? FontWeight.bold : FontWeight.w600,
            color: large ? AppColors.primary : Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showCustomerSelector(
    CustomerController customerController,
    CartController cartController,
  ) {
    Get.dialog(
      Dialog(
        child: Container(
          width: 500,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Customer',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search customers...',
                  prefixIcon: Icon(Iconsax.search_normal),
                  border: OutlineInputBorder(),
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
                          leading: Icon(Iconsax.user),
                          title: Text('Walk-in Customer'),
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
                          child: Text(customer.name[0].toUpperCase()),
                        ),
                        title: Text(customer.name),
                        subtitle: Text(customer.email),
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
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
