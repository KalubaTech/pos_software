import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/product_model.dart';
import '../../controllers/appearance_controller.dart';
import '../../utils/colors.dart';
import '../../utils/currency_formatter.dart';

class VariantSelectionDialog extends StatefulWidget {
  final ProductModel product;
  final Function(ProductVariant) onVariantSelected;

  const VariantSelectionDialog({
    super.key,
    required this.product,
    required this.onVariantSelected,
  });

  @override
  State<VariantSelectionDialog> createState() => _VariantSelectionDialogState();
}

class _VariantSelectionDialogState extends State<VariantSelectionDialog> {
  ProductVariant? _selectedVariant;

  @override
  Widget build(BuildContext context) {
    final appearanceController = Get.find<AppearanceController>();
    final isDark = appearanceController.isDarkMode.value;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        constraints: BoxConstraints(maxHeight: 600),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: widget.product.imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(widget.product.imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),
                  child: widget.product.imageUrl.isEmpty
                      ? Icon(
                          Iconsax.box,
                          color: AppColors.getTextSecondary(isDark),
                        )
                      : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                      SizedBox(height: 4),
                      Obx(
                        () => Text(
                          'Base Price: ${CurrencyFormatter.format(widget.product.price)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Select Variant',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            SizedBox(height: 16),
            // Variants List
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.product.variants?.length ?? 0,
                itemBuilder: (context, index) {
                  final variant = widget.product.variants![index];
                  final isSelected = _selectedVariant?.id == variant.id;
                  final isOutOfStock = variant.stock <= 0;
                  final finalPrice =
                      widget.product.price + variant.priceAdjustment;

                  return Card(
                    color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: isSelected ? 4 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? (isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.primary)
                            : AppColors.getDivider(isDark),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: isOutOfStock
                          ? null
                          : () {
                              setState(() {
                                _selectedVariant = variant;
                              });
                            },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Variant Image
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image:
                                    variant.imageUrl != null &&
                                        variant.imageUrl!.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(variant.imageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                              ),
                              child:
                                  variant.imageUrl == null ||
                                      variant.imageUrl!.isEmpty
                                  ? Icon(
                                      Iconsax.box,
                                      size: 24,
                                      color: AppColors.getTextSecondary(isDark),
                                    )
                                  : null,
                            ),
                            SizedBox(width: 16),
                            // Variant Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        variant.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.getTextPrimary(
                                            isDark,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              (isDark
                                                      ? AppColors.darkPrimary
                                                      : AppColors.primary)
                                                  .withValues(
                                                    alpha: isDark ? 0.2 : 0.1,
                                                  ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          variant.attributeType,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark
                                                ? AppColors.darkPrimary
                                                : AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (variant.sku != null)
                                        Text(
                                          'SKU: ${variant.sku}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.getTextSecondary(
                                              isDark,
                                            ),
                                          ),
                                        ),
                                      if (variant.sku != null)
                                        Text(
                                          ' • ',
                                          style: TextStyle(
                                            color: AppColors.getTextSecondary(
                                              isDark,
                                            ),
                                          ),
                                        ),
                                      Text(
                                        'Stock: ${variant.stock}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isOutOfStock
                                              ? Colors.red
                                              : AppColors.getTextSecondary(
                                                  isDark,
                                                ),
                                          fontWeight: isOutOfStock
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Price
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Obx(
                                  () => Text(
                                    CurrencyFormatter.format(finalPrice),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isOutOfStock
                                          ? AppColors.getTextSecondary(isDark)
                                          : (isDark
                                                ? AppColors.darkPrimary
                                                : AppColors.primary),
                                    ),
                                  ),
                                ),
                                if (variant.priceAdjustment != 0)
                                  Obx(
                                    () => Text(
                                      '${variant.priceAdjustment > 0 ? '+' : ''}${CurrencyFormatter.format(variant.priceAdjustment)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: variant.priceAdjustment > 0
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(width: 8),
                            // Selection Indicator
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark
                                            ? AppColors.darkPrimary
                                            : AppColors.primary)
                                      : AppColors.getDivider(isDark),
                                  width: 2,
                                ),
                                color: isSelected
                                    ? (isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.primary)
                                    : Colors.transparent,
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.getDivider(isDark)),
                      foregroundColor: AppColors.getTextSecondary(isDark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _selectedVariant == null
                        ? null
                        : () {
                            widget.onVariantSelected(_selectedVariant!);
                            Get.back();
                          },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
