import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/price_tag_designer_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/appearance_controller.dart';
import '../../models/price_tag_template_model.dart';
import '../../utils/colors.dart';
import '../../utils/responsive.dart';
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
    final appearanceController = Get.find<AppearanceController>();

    return Obx(() {
      final isDark = appearanceController.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[100],
        body: Column(
          children: [
            // Top App Bar
            _buildHeader(context, controller, productController, isDark),
            // Main Content
            Expanded(
              child: context.isMobile
                  ? Column(
                      children: [
                        // Mobile: Just show canvas, hide sidebars
                        // Toolbar
                        ToolbarWidget(),
                        // Canvas
                        Expanded(child: CanvasWidget()),
                        // Bottom action bar with template/properties access
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.getSurfaceColor(isDark),
                            border: Border(
                              top: BorderSide(
                                color: AppColors.getDivider(isDark),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Get.bottomSheet(
                                    Container(
                                      height: 400,
                                      decoration: BoxDecoration(
                                        color: AppColors.getSurfaceColor(
                                          isDark,
                                        ),
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                      ),
                                      child: TemplateListWidget(),
                                    ),
                                  );
                                },
                                icon: Icon(Iconsax.note, size: 18),
                                label: Text('Templates'),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  Get.bottomSheet(
                                    Container(
                                      height: 500,
                                      decoration: BoxDecoration(
                                        color: AppColors.getSurfaceColor(
                                          isDark,
                                        ),
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                      ),
                                      child: PropertiesPanelWidget(),
                                    ),
                                  );
                                },
                                icon: Icon(Iconsax.setting_3, size: 18),
                                label: Text('Properties'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        // Left Sidebar - Templates
                        Obx(() {
                          if (controller.isTemplateListCollapsed.value) {
                            return Container(
                              width: 48,
                              decoration: BoxDecoration(
                                color: AppColors.getSurfaceColor(isDark),
                                border: Border(
                                  right: BorderSide(
                                    color: AppColors.getDivider(isDark),
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Iconsax.arrow_right_3,
                                      color: AppColors.getTextSecondary(isDark),
                                    ),
                                    tooltip: 'Show Templates',
                                    onPressed: () =>
                                        controller.toggleTemplateList(),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Row(
                            children: [
                              TemplateListWidget(),
                              Container(
                                width: 1,
                                color: AppColors.getDivider(isDark),
                              ),
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
                                color: AppColors.getSurfaceColor(isDark),
                                border: Border(
                                  left: BorderSide(
                                    color: AppColors.getDivider(isDark),
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Iconsax.arrow_left_3,
                                      color: AppColors.getTextSecondary(isDark),
                                    ),
                                    tooltip: 'Show Properties',
                                    onPressed: () =>
                                        controller.togglePropertiesPanel(),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Row(
                            children: [
                              Container(
                                width: 1,
                                color: AppColors.getDivider(isDark),
                              ),
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
    });
  }

  Widget _buildHeader(
    BuildContext context,
    PriceTagDesignerController controller,
    ProductController productController,
    bool isDark,
  ) {
    final isMobile = context.isMobile;

    if (isMobile) {
      // Mobile: Compact header with menu
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.getSurfaceColor(isDark),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
          border: BorderDirectional(
            bottom: BorderSide(color: AppColors.getDivider(isDark)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title row
            Row(
              children: [
                Icon(
                  Iconsax.tag,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Price Tags',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Actions menu
                PopupMenuButton<String>(
                  icon: Icon(
                    Iconsax.more,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  color: AppColors.getSurfaceColor(isDark),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'new',
                      child: Row(
                        children: [
                          Icon(Iconsax.add, size: 18),
                          SizedBox(width: 12),
                          Text('New Template'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'save',
                      enabled: controller.currentTemplate.value != null,
                      child: Row(
                        children: [
                          Icon(Iconsax.save_2, size: 18, color: Colors.orange),
                          SizedBox(width: 12),
                          Text('Save'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'printer',
                      child: Row(
                        children: [
                          Icon(Iconsax.setting_2, size: 18),
                          SizedBox(width: 12),
                          Text('Printer Settings'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'print',
                      enabled: controller.currentTemplate.value != null,
                      child: Row(
                        children: [
                          Icon(Iconsax.printer, size: 18, color: Colors.green),
                          SizedBox(width: 12),
                          Text('Print'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'new':
                        _showNewTemplateDialog(context, controller, isDark);
                        break;
                      case 'save':
                        controller.saveCurrentTemplate();
                        break;
                      case 'printer':
                        Get.dialog(PrinterManagementDialog());
                        break;
                      case 'print':
                        _showPrintDialog(
                          context,
                          controller,
                          productController,
                        );
                        break;
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            // Template selector
            Obx(() {
              final template = controller.currentTemplate.value;
              return Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: isDark
                      ? Border.all(color: AppColors.getDivider(isDark))
                      : null,
                ),
                child: DropdownButton<PriceTagTemplate?>(
                  value: template,
                  hint: Text(
                    'Select Template',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                      fontSize: 13,
                    ),
                  ),
                  isExpanded: true,
                  underline: SizedBox(),
                  dropdownColor: AppColors.getSurfaceColor(isDark),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                  items: controller.templates.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(
                        t.name,
                        style: TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (template) {
                    if (template != null) {
                      controller.selectTemplate(template);
                    }
                  },
                ),
              );
            }),
          ],
        ),
      );
    }

    // Desktop: Full header with all buttons
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: BorderDirectional(
          bottom: BorderSide(color: AppColors.getDivider(isDark)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.tag,
            color: isDark ? AppColors.darkPrimary : AppColors.primary,
            size: 28,
          ),
          SizedBox(width: 12),
          Text(
            'Price Tag Designer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          Spacer(),
          // Template selector
          Obx(() {
            final template = controller.currentTemplate.value;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: isDark
                    ? Border.all(color: AppColors.getDivider(isDark))
                    : null,
              ),
              child: DropdownButton<PriceTagTemplate?>(
                value: template,
                hint: Text(
                  'Select Template',
                  style: TextStyle(color: AppColors.getTextSecondary(isDark)),
                ),
                underline: SizedBox(),
                dropdownColor: AppColors.getSurfaceColor(isDark),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getTextPrimary(isDark),
                ),
                items: controller.templates.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t.name, style: TextStyle(fontSize: 12)),
                  );
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
            onPressed: () =>
                _showNewTemplateDialog(context, controller, isDark),
            icon: Icon(Iconsax.add, size: 18),
            label: Text('New Template'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.darkPrimary
                  : AppColors.primary,
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
                disabledBackgroundColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : Colors.grey[300],
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            );
          }),
          SizedBox(width: 12),
          // Printer settings button
          IconButton(
            icon: Icon(
              Iconsax.setting_2,
              size: 20,
              color: AppColors.getTextSecondary(isDark),
            ),
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
                  ? () =>
                        _showPrintDialog(context, controller, productController)
                  : null,
              icon: Icon(Iconsax.printer, size: 18),
              label: Text('Print'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : Colors.grey[300],
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showNewTemplateDialog(
    BuildContext context,
    PriceTagDesignerController controller,
    bool isDark,
  ) {
    final nameController = TextEditingController();
    final widthController = TextEditingController(text: '50');
    final heightController = TextEditingController(text: '30');

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.getSurfaceColor(isDark),
        title: Row(
          children: [
            Icon(
              Iconsax.add_square,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
            SizedBox(width: 12),
            Text(
              'New Template',
              style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            ),
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
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  labelText: 'Template Name',
                  labelStyle: TextStyle(
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
                  prefixIcon: Icon(
                    Iconsax.document_text,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : Colors.grey[50],
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widthController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                      decoration: InputDecoration(
                        labelText: 'Width (mm)',
                        labelStyle: TextStyle(
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
                        prefixIcon: Icon(
                          Iconsax.maximize_4,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkSurfaceVariant
                            : Colors.grey[50],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: heightController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                      decoration: InputDecoration(
                        labelText: 'Height (mm)',
                        labelStyle: TextStyle(
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
                        prefixIcon: Icon(
                          Iconsax.maximize_4,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkSurfaceVariant
                            : Colors.grey[50],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Common Sizes:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildSizeChip('50×30mm', () {
                    widthController.text = '50';
                    heightController.text = '30';
                  }, isDark),
                  _buildSizeChip('70×40mm', () {
                    widthController.text = '70';
                    heightController.text = '40';
                  }, isDark),
                  _buildSizeChip('100×60mm', () {
                    widthController.text = '100';
                    heightController.text = '60';
                  }, isDark),
                ],
              ),
            ],
          ),
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
              backgroundColor: isDark
                  ? AppColors.darkPrimary
                  : AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeChip(String label, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        backgroundColor: isDark
            ? AppColors.darkPrimary.withOpacity(0.2)
            : Colors.blue[50],
        side: isDark
            ? BorderSide(color: AppColors.darkPrimary.withOpacity(0.3))
            : BorderSide.none,
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
