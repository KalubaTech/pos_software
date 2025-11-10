import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/price_tag_designer_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/price_tag_template_model.dart';
import '../../utils/colors.dart';
import 'widgets/canvas_widget.dart';
import 'widgets/template_list_widget.dart';
import 'widgets/properties_panel_widget.dart';
import 'widgets/toolbar_widget.dart';
import 'widgets/print_dialog_widget.dart';
import 'widgets/printer_management_dialog.dart';

class PriceTagDesignerView extends StatelessWidget {
  const PriceTagDesignerView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PriceTagDesignerController());
    final productController = Get.find<ProductController>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Top App Bar
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Iconsax.tag, color: AppColors.primary, size: 28),
                SizedBox(width: 12),
                Text(
                  'Price Tag Designer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Spacer(),
                // Template selector
                Obx(() {
                  final template = controller.currentTemplate.value;
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<PriceTagTemplate?>(
                      value: template,
                      hint: Text('Select Template'),
                      underline: SizedBox(),
                      items: controller.templates.map((t) {
                        return DropdownMenuItem(value: t, child: Text(t.name));
                      }).toList(),
                      onChanged: (template) {
                        if (template != null) {
                          controller.selectTemplate(template);
                        }
                      },
                    ),
                  );
                }),
                SizedBox(width: 12),
                // New template button
                ElevatedButton.icon(
                  onPressed: () => _showNewTemplateDialog(context, controller),
                  icon: Icon(Iconsax.add, size: 18),
                  label: Text('New Template'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                SizedBox(width: 12),
                // Save button
                Obx(() {
                  final hasTemplate = controller.currentTemplate.value != null;
                  return ElevatedButton.icon(
                    onPressed: hasTemplate
                        ? () => controller.saveCurrentTemplate()
                        : null,
                    icon: Icon(Iconsax.save_2, size: 18),
                    label: Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  );
                }),
                SizedBox(width: 12),
                // Printer settings button
                IconButton(
                  icon: Icon(Iconsax.setting_2, size: 20),
                  tooltip: 'Printer Settings',
                  onPressed: () {
                    Get.dialog(PrinterManagementDialog());
                  },
                ),
                SizedBox(width: 12),
                // Print button
                Obx(() {
                  final hasTemplate = controller.currentTemplate.value != null;
                  return ElevatedButton.icon(
                    onPressed: hasTemplate
                        ? () => _showPrintDialog(
                            context,
                            controller,
                            productController,
                          )
                        : null,
                    icon: Icon(Iconsax.printer, size: 18),
                    label: Text('Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Row(
              children: [
                // Left Sidebar - Templates
                Obx(() {
                  if (controller.isTemplateListCollapsed.value) {
                    return Container(
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          right: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(Iconsax.arrow_right_3),
                            tooltip: 'Show Templates',
                            onPressed: () => controller.toggleTemplateList(),
                          ),
                        ],
                      ),
                    );
                  }
                  return Row(
                    children: [
                      TemplateListWidget(),
                      Container(width: 1, color: Colors.grey[300]),
                    ],
                  );
                }),
                // Center - Canvas
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Toolbar
                      ToolbarWidget(),
                      // Canvas
                      Expanded(child: CanvasWidget()),
                    ],
                  ),
                ),
                // Right Sidebar - Properties
                Obx(() {
                  if (controller.isPropertiesPanelCollapsed.value) {
                    return Container(
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          left: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(Iconsax.arrow_left_3),
                            tooltip: 'Show Properties',
                            onPressed: () => controller.togglePropertiesPanel(),
                          ),
                        ],
                      ),
                    );
                  }
                  return Row(
                    children: [
                      Container(width: 1, color: Colors.grey[300]),
                      PropertiesPanelWidget(),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNewTemplateDialog(
    BuildContext context,
    PriceTagDesignerController controller,
  ) {
    final nameController = TextEditingController();
    final widthController = TextEditingController(text: '50');
    final heightController = TextEditingController(text: '30');

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Iconsax.add_square, color: AppColors.primary),
            SizedBox(width: 12),
            Text('New Template'),
          ],
        ),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Template Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Iconsax.document_text),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widthController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Width (mm)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Iconsax.maximize_4),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Height (mm)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Iconsax.maximize_4),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Common Sizes:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildSizeChip('50×30mm', () {
                    widthController.text = '50';
                    heightController.text = '30';
                  }),
                  _buildSizeChip('70×40mm', () {
                    widthController.text = '70';
                    heightController.text = '40';
                  }),
                  _buildSizeChip('100×60mm', () {
                    widthController.text = '100';
                    heightController.text = '60';
                  }),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final width = double.tryParse(widthController.text) ?? 50;
              final height = double.tryParse(heightController.text) ?? 30;

              if (name.isEmpty) {
                Get.snackbar('Error', 'Please enter a template name');
                return;
              }

              controller.createNewTemplate(name, width, height);
              Get.back();
              Get.snackbar('Success', 'Template created successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        label: Text(label, style: TextStyle(fontSize: 11)),
        backgroundColor: Colors.blue[50],
        padding: EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  void _showPrintDialog(
    BuildContext context,
    PriceTagDesignerController controller,
    ProductController productController,
  ) {
    // Small delay to avoid mouse tracking conflicts
    Future.microtask(() {
      Get.dialog(
        Dialog(
          child: PrintDialogWidget(
            template: controller.currentTemplate.value!,
            products: productController.products,
          ),
        ),
        barrierDismissible: true,
      );
    });
  }
}
