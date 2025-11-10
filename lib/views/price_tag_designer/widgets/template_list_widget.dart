import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/price_tag_designer_controller.dart';
import '../../../models/price_tag_template_model.dart';

class TemplateListWidget extends StatelessWidget {
  const TemplateListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PriceTagDesignerController>();

    return Container(
      width: 250,
      color: Colors.white,
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
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Iconsax.arrow_left_3, size: 18),
                  tooltip: 'Hide Templates',
                  onPressed: () => controller.toggleTemplateList(),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: Obx(() {
              if (controller.templates.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.document, size: 48, color: Colors.grey[400]),
                      SizedBox(height: 12),
                      Text(
                        'No templates yet',
                        style: TextStyle(color: Colors.grey[600]),
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
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    PriceTagDesignerController controller,
    PriceTagTemplate template,
    bool isSelected,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: () => controller.selectTemplate(template),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(Iconsax.tag, color: Colors.blue[700]),
        ),
        title: Text(
          template.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '${template.width.toStringAsFixed(0)}×${template.height.toStringAsFixed(0)}mm',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Iconsax.more, size: 18),
          onSelected: (value) {
            switch (value) {
              case 'duplicate':
                controller.duplicateTemplate(template);
                Get.snackbar('Success', 'Template duplicated');
                break;
              case 'delete':
                _showDeleteDialog(context, controller, template);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [
                  Icon(Iconsax.copy, size: 18),
                  SizedBox(width: 12),
                  Text('Duplicate'),
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
  ) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
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
