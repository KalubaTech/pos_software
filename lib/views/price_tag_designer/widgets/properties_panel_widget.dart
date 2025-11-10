import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/price_tag_designer_controller.dart';
import '../../../models/price_tag_template_model.dart';

class PropertiesPanelWidget extends StatelessWidget {
  const PropertiesPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PriceTagDesignerController>();

    return Container(
      width: 300,
      color: Colors.white,
      child: Obx(() {
        final element = controller.selectedElement.value;
        final template = controller.currentTemplate.value;

        if (template == null) {
          return _buildEmptyState('No template selected');
        }

        if (element == null) {
          return _buildTemplateProperties(controller, template);
        }

        return _buildElementProperties(controller, element);
      }),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.setting_2, size: 48, color: Colors.grey[400]),
          SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildTemplateProperties(
    PriceTagDesignerController controller,
    PriceTagTemplate template,
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(Iconsax.arrow_right_3, size: 18),
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
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) => controller.updateTemplateName(value),
            ),
          ),
          SizedBox(height: 16),
          _buildPropertyField(
            label: 'Width (mm)',
            icon: Iconsax.maximize_4,
            child: TextField(
              controller: widthController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
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
            child: TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                final height = double.tryParse(value) ?? template.height;
                controller.updateTemplateSize(template.width, height);
              },
            ),
          ),
          SizedBox(height: 20),
          Divider(),
          SizedBox(height: 20),
          Text(
            'Elements',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            '${template.elements.length} element(s)',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildElementProperties(
    PriceTagDesignerController controller,
    PriceTagElement element,
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                icon: Icon(Iconsax.arrow_right_3, size: 18),
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
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getElementTypeName(element.type),
                style: TextStyle(fontWeight: FontWeight.w500),
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
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
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
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
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
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
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
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
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
            Divider(),
            SizedBox(height: 20),
            _buildPropertyField(
              label: 'Text',
              icon: Iconsax.text,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    maxLines: 2,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      hintText: 'Enter text...',
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
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.mouse_circle,
                          size: 12,
                          color: Colors.blue[700],
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Tip: Double-click element on canvas to edit',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue[900],
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
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
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
                    title: Text('Bold', style: TextStyle(fontSize: 12)),
                    value: element.bold,
                    dense: true,
                    onChanged: (value) {
                      controller.updateElement(element.copyWith(bold: value));
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text('Italic', style: TextStyle(fontSize: 12)),
                    value: element.italic,
                    dense: true,
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
            Divider(),
            SizedBox(height: 20),
            _buildPropertyField(
              label: element.type == ElementType.barcode
                  ? 'Barcode Data'
                  : 'QR Code Data',
              icon: Iconsax.scan_barcode,
              child: TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  hintText: 'Enter data to encode...',
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
                child: DropdownButtonFormField<String>(
                  value: element.barcodeType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
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
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  element.dataField!,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[700],
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[600]),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
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
