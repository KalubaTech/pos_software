import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/price_tag_designer_controller.dart';
import '../../../controllers/appearance_controller.dart';
import '../../../models/price_tag_template_model.dart';
import '../../../utils/colors.dart';

class PropertiesPanelWidget extends StatelessWidget {
  const PropertiesPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PriceTagDesignerController>();
    final appearanceController = Get.find<AppearanceController>();

    return Obx(() {
      final isDark = appearanceController.isDarkMode.value;

      return Container(
        width: 300,
        height: double.infinity,
        decoration: BoxDecoration(color: AppColors.getSurfaceColor(isDark)),
        child: Obx(() {
          final element = controller.selectedElement.value;
          final template = controller.currentTemplate.value;

          if (template == null) {
            return _buildEmptyState('No template selected', isDark);
          }

          if (element == null) {
            return _buildTemplateProperties(controller, template, isDark);
          }

          return _buildElementProperties(controller, element, isDark);
        }),
      );
    });
  }

  Widget _buildEmptyState(String message, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.setting_2,
            size: 48,
            color: AppColors.getTextTertiary(isDark),
          ),
          SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: AppColors.getTextSecondary(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateProperties(
    PriceTagDesignerController controller,
    PriceTagTemplate template,
    bool isDark,
  ) {
    final nameController = TextEditingController(text: template.name);
    final widthController = TextEditingController(
      text: template.width.toStringAsFixed(0),
    );
    final heightController = TextEditingController(
      text: template.height.toStringAsFixed(0),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Template Properties',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Iconsax.arrow_right_3,
                  size: 18,
                  color: AppColors.getTextSecondary(isDark),
                ),
                tooltip: 'Hide Properties',
                onPressed: () => controller.togglePropertiesPanel(),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildPropertyField(
            label: 'Name',
            icon: Iconsax.document_text,
            isDark: isDark,
            child: TextField(
              controller: nameController,
              style: TextStyle(color: AppColors.getTextPrimary(isDark)),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                ),
                isDense: true,
                filled: true,
                fillColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : Colors.grey[50],
              ),
              onChanged: (value) => controller.updateTemplateName(value),
            ),
          ),
          SizedBox(height: 16),
          _buildPropertyField(
            label: 'Width (mm)',
            icon: Iconsax.maximize_4,
            isDark: isDark,
            child: TextField(
              controller: widthController,
              style: TextStyle(color: AppColors.getTextPrimary(isDark)),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                ),
                isDense: true,
                filled: true,
                fillColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : Colors.grey[50],
              ),
              onChanged: (value) {
                final width = double.tryParse(value) ?? template.width;
                controller.updateTemplateSize(width, template.height);
              },
            ),
          ),
          SizedBox(height: 16),
          _buildPropertyField(
            label: 'Height (mm)',
            icon: Iconsax.maximize_4,
            isDark: isDark,
            child: TextField(
              controller: heightController,
              style: TextStyle(color: AppColors.getTextPrimary(isDark)),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                ),
                isDense: true,
                filled: true,
                fillColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : Colors.grey[50],
              ),
              onChanged: (value) {
                final height = double.tryParse(value) ?? template.height;
                controller.updateTemplateSize(template.width, height);
              },
            ),
          ),
          SizedBox(height: 20),
          Divider(color: AppColors.getDivider(isDark)),
          SizedBox(height: 20),
          Text(
            'Elements',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          SizedBox(height: 12),
          Text(
            '${template.elements.length} element(s)',
            style: TextStyle(color: AppColors.getTextSecondary(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildElementProperties(
    PriceTagDesignerController controller,
    PriceTagElement element,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Element Properties',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Iconsax.trash, color: Colors.red, size: 20),
                onPressed: () => controller.deleteElement(element.id),
                tooltip: 'Delete Element',
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Iconsax.arrow_right_3,
                  size: 18,
                  color: AppColors.getTextSecondary(isDark),
                ),
                tooltip: 'Hide Properties',
                onPressed: () => controller.togglePropertiesPanel(),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Type
          _buildPropertyField(
            label: 'Type',
            icon: Iconsax.category,
            isDark: isDark,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getElementTypeName(element.type),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),

          // Position & Size
          Row(
            children: [
              Expanded(
                child: _buildPropertyField(
                  label: 'X (mm)',
                  icon: Iconsax.maximize_4,
                  isDark: isDark,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                    decoration: InputDecoration(
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
                      isDense: true,
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : Colors.grey[50],
                    ),
                    controller: TextEditingController(
                      text: element.x.toStringAsFixed(1),
                    ),
                    onChanged: (value) {
                      final x = double.tryParse(value) ?? element.x;
                      controller.updateElement(element.copyWith(x: x));
                    },
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildPropertyField(
                  label: 'Y (mm)',
                  icon: Iconsax.maximize_4,
                  isDark: isDark,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                    decoration: InputDecoration(
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
                      isDense: true,
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : Colors.grey[50],
                    ),
                    controller: TextEditingController(
                      text: element.y.toStringAsFixed(1),
                    ),
                    onChanged: (value) {
                      final y = double.tryParse(value) ?? element.y;
                      controller.updateElement(element.copyWith(y: y));
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPropertyField(
                  label: 'Width (mm)',
                  icon: Iconsax.maximize_4,
                  isDark: isDark,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                    decoration: InputDecoration(
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
                      isDense: true,
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : Colors.grey[50],
                    ),
                    controller: TextEditingController(
                      text: element.width.toStringAsFixed(1),
                    ),
                    onChanged: (value) {
                      final width = double.tryParse(value) ?? element.width;
                      controller.updateElement(element.copyWith(width: width));
                    },
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildPropertyField(
                  label: 'Height (mm)',
                  icon: Iconsax.maximize_4,
                  isDark: isDark,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                    decoration: InputDecoration(
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
                      isDense: true,
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : Colors.grey[50],
                    ),
                    controller: TextEditingController(
                      text: element.height.toStringAsFixed(1),
                    ),
                    onChanged: (value) {
                      final height = double.tryParse(value) ?? element.height;
                      controller.updateElement(
                        element.copyWith(height: height),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // Text properties
          if (_hasTextProperties(element.type)) ...[
            SizedBox(height: 20),
            Divider(color: AppColors.getDivider(isDark)),
            SizedBox(height: 20),
            _buildPropertyField(
              label: 'Text',
              icon: Iconsax.text,
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    maxLines: 2,
                    style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                    decoration: InputDecoration(
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
                      isDense: true,
                      hintText: 'Enter text...',
                      hintStyle: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : Colors.grey[50],
                    ),
                    controller: TextEditingController(text: element.text ?? ''),
                    onChanged: (value) {
                      controller.updateElement(element.copyWith(text: value));
                    },
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.darkPrimary : Colors.blue)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.mouse_circle,
                          size: 12,
                          color: isDark
                              ? AppColors.darkPrimary
                              : Colors.blue[700],
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Tip: Double-click element on canvas to edit',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : Colors.blue[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            _buildPropertyField(
              label: 'Font Size',
              icon: Iconsax.textalign_left,
              isDark: isDark,
              child: TextField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : Colors.grey[50],
                ),
                controller: TextEditingController(
                  text: element.fontSize.toStringAsFixed(0),
                ),
                onChanged: (value) {
                  final fontSize = double.tryParse(value) ?? element.fontSize;
                  controller.updateElement(
                    element.copyWith(fontSize: fontSize),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text(
                      'Bold',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    value: element.bold,
                    dense: true,
                    activeColor: isDark
                        ? AppColors.darkPrimary
                        : AppColors.primary,
                    onChanged: (value) {
                      controller.updateElement(element.copyWith(bold: value));
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text(
                      'Italic',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    value: element.italic,
                    dense: true,
                    activeColor: isDark
                        ? AppColors.darkPrimary
                        : AppColors.primary,
                    onChanged: (value) {
                      controller.updateElement(element.copyWith(italic: value));
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildPropertyField(
              label: 'Text Align',
              icon: Iconsax.textalign_justifycenter,
              isDark: isDark,
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'left',
                    label: Text('Left', style: TextStyle(fontSize: 11)),
                  ),
                  ButtonSegment(
                    value: 'center',
                    label: Text('Center', style: TextStyle(fontSize: 11)),
                  ),
                  ButtonSegment(
                    value: 'right',
                    label: Text('Right', style: TextStyle(fontSize: 11)),
                  ),
                ],
                selected: {element.textAlign},
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return isDark ? AppColors.darkPrimary : AppColors.primary;
                    }
                    return isDark
                        ? AppColors.darkSurfaceVariant
                        : Colors.grey[200]!;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return AppColors.getTextPrimary(isDark);
                  }),
                ),
                onSelectionChanged: (Set<String> newSelection) {
                  controller.updateElement(
                    element.copyWith(textAlign: newSelection.first),
                  );
                },
              ),
            ),
          ],

          // Barcode/QR Code properties
          if (element.type == ElementType.barcode ||
              element.type == ElementType.qrCode) ...[
            SizedBox(height: 20),
            Divider(color: AppColors.getDivider(isDark)),
            SizedBox(height: 20),
            _buildPropertyField(
              label: element.type == ElementType.barcode
                  ? 'Barcode Data'
                  : 'QR Code Data',
              icon: Iconsax.scan_barcode,
              isDark: isDark,
              child: TextField(
                maxLines: 3,
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  isDense: true,
                  hintText: 'Enter data to encode...',
                  hintStyle: TextStyle(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : Colors.grey[50],
                ),
                controller: TextEditingController(
                  text: element.barcodeData ?? '',
                ),
                onChanged: (value) {
                  controller.updateElement(
                    element.copyWith(barcodeData: value.isEmpty ? null : value),
                  );
                },
              ),
            ),
            if (element.type == ElementType.barcode) ...[
              SizedBox(height: 16),
              _buildPropertyField(
                label: 'Barcode Type',
                icon: Iconsax.barcode,
                isDark: isDark,
                child: DropdownButtonFormField<String>(
                  value: element.barcodeType,
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                  dropdownColor: AppColors.getSurfaceColor(isDark),
                  decoration: InputDecoration(
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
                    isDense: true,
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : Colors.grey[50],
                  ),
                  items: [
                    DropdownMenuItem(value: 'code128', child: Text('Code 128')),
                    DropdownMenuItem(value: 'code39', child: Text('Code 39')),
                    DropdownMenuItem(value: 'ean13', child: Text('EAN-13')),
                    DropdownMenuItem(value: 'ean8', child: Text('EAN-8')),
                    DropdownMenuItem(value: 'upca', child: Text('UPC-A')),
                    DropdownMenuItem(value: 'upce', child: Text('UPC-E')),
                    DropdownMenuItem(value: 'codabar', child: Text('Codabar')),
                    DropdownMenuItem(value: 'itf', child: Text('ITF')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.updateElement(
                        element.copyWith(barcodeType: value),
                      );
                    }
                  },
                ),
              ),
            ],
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.info_circle, size: 16, color: Colors.amber[700]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Leave empty to use product data field',
                      style: TextStyle(fontSize: 11, color: Colors.amber[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Data field
          if (element.dataField != null) ...[
            SizedBox(height: 16),
            _buildPropertyField(
              label: 'Data Field',
              icon: Iconsax.data,
              isDark: isDark,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkPrimary.withOpacity(0.15)
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkPrimary.withOpacity(0.3)
                        : Colors.blue[200]!,
                  ),
                ),
                child: Text(
                  element.dataField!,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkPrimary : Colors.blue[700],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPropertyField({
    required String label,
    required IconData icon,
    required Widget child,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.getTextSecondary(isDark)),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        child,
      ],
    );
  }

  String _getElementTypeName(ElementType type) {
    switch (type) {
      case ElementType.text:
        return 'Text';
      case ElementType.productName:
        return 'Product Name';
      case ElementType.price:
        return 'Price';
      case ElementType.barcode:
        return 'Barcode';
      case ElementType.qrCode:
        return 'QR Code';
      case ElementType.line:
        return 'Line';
      case ElementType.rectangle:
        return 'Rectangle';
      default:
        return 'Unknown';
    }
  }

  bool _hasTextProperties(ElementType type) {
    return type == ElementType.text ||
        type == ElementType.productName ||
        type == ElementType.price;
  }
}
