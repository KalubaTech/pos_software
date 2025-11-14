import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/price_tag_designer_controller.dart';
import '../../../controllers/appearance_controller.dart';
import '../../../models/price_tag_template_model.dart';
import '../../../utils/colors.dart';

class TemplateListWidget extends StatelessWidget {
  const TemplateListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PriceTagDesignerController>();
    final appearanceController = Get.find<AppearanceController>();

    return Obx(() {
      final isDark = appearanceController.isDarkMode.value;

      return Container(
        width: 250,
        color: AppColors.getSurfaceColor(isDark),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Templates',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Iconsax.arrow_left_3,
                      size: 18,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    tooltip: 'Hide Templates',
                    onPressed: () => controller.toggleTemplateList(),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.getDivider(isDark)),
            Expanded(
              child: Obx(() {
                if (controller.templates.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.document,
                          size: 48,
                          color: AppColors.getTextTertiary(isDark),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No templates yet',
                          style: TextStyle(
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.templates.length,
                  itemBuilder: (context, index) {
                    final template = controller.templates[index];
                    final isSelected =
                        controller.currentTemplate.value?.id == template.id;

                    return _buildTemplateCard(
                      context,
                      controller,
                      template,
                      isSelected,
                      isDark,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTemplateCard(
    BuildContext context,
    PriceTagDesignerController controller,
    PriceTagTemplate template,
    bool isSelected,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark
                  ? AppColors.darkPrimary.withValues(alpha: 0.15)
                  : Colors.blue[50])
            : AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? (isDark ? AppColors.darkPrimary : Colors.blue)
              : AppColors.getDivider(isDark),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: () => controller.selectTemplate(template),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (isDark ? AppColors.darkPrimary : Colors.blue).withValues(
              alpha: 0.15,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Iconsax.tag,
            color: isDark ? AppColors.darkPrimary : Colors.blue[700],
          ),
        ),
        title: Text(
          template.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        subtitle: Text(
          '${template.width.toStringAsFixed(0)}×${template.height.toStringAsFixed(0)}mm',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Iconsax.more,
            size: 18,
            color: AppColors.getTextSecondary(isDark),
          ),
          color: AppColors.getSurfaceColor(isDark),
          onSelected: (value) {
            switch (value) {
              case 'duplicate':
                controller.duplicateTemplate(template);
                Get.snackbar('Success', 'Template duplicated');
                break;
              case 'delete':
                _showDeleteDialog(context, controller, template, isDark);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [
                  Icon(
                    Iconsax.copy,
                    size: 18,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Duplicate',
                    style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Iconsax.trash, size: 18, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    PriceTagDesignerController controller,
    PriceTagTemplate template,
    bool isDark,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.getSurfaceColor(isDark),
        title: Text(
          'Delete Template',
          style: TextStyle(color: AppColors.getTextPrimary(isDark)),
        ),
        content: Text(
          'Are you sure you want to delete "${template.name}"?',
          style: TextStyle(color: AppColors.getTextPrimary(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteTemplate(template.id);
              Get.back();
              Get.snackbar('Success', 'Template deleted');
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
