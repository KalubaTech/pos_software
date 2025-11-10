import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/price_tag_designer_controller.dart';
import '../../../models/price_tag_template_model.dart';

class ToolbarWidget extends StatelessWidget {
  const ToolbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PriceTagDesignerController>();

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              'Elements:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(width: 16),
            _buildToolButton(
              icon: Iconsax.text,
              label: 'Text',
              onPressed: () => controller.addElement(ElementType.text),
            ),
            _buildToolButton(
              icon: Iconsax.tag_2,
              label: 'Product',
              onPressed: () => controller.addElement(ElementType.productName),
            ),
            _buildToolButton(
              icon: Iconsax.dollar_circle,
              label: 'Price',
              onPressed: () => controller.addElement(ElementType.price),
            ),
            _buildToolButton(
              icon: Iconsax.barcode,
              label: 'Barcode',
              onPressed: () => controller.addElement(ElementType.barcode),
            ),
            _buildToolButton(
              icon: Iconsax.scan_barcode,
              label: 'QR Code',
              onPressed: () => controller.addElement(ElementType.qrCode),
            ),
            _buildToolButton(
              icon: Iconsax.minus,
              label: 'Line',
              onPressed: () => controller.addElement(ElementType.line),
            ),
            _buildToolButton(
              icon: Iconsax.square,
              label: 'Rectangle',
              onPressed: () => controller.addElement(ElementType.rectangle),
            ),
            SizedBox(width: 24),
            // Zoom controls
            Text(
              'Zoom:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Iconsax.minus_cirlce, size: 20),
              onPressed: () {
                final zoom = controller.zoom.value;
                controller.setZoom(zoom - 0.25);
              },
              tooltip: 'Zoom Out',
            ),
            Obx(
              () => Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${(controller.zoom.value * 100).toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Iconsax.add_circle, size: 20),
              onPressed: () {
                final zoom = controller.zoom.value;
                controller.setZoom(zoom + 0.25);
              },
              tooltip: 'Zoom In',
            ),
            SizedBox(width: 8),
            Container(
              height: 24,
              width: 1,
              color: Colors.grey[300],
              margin: EdgeInsets.symmetric(horizontal: 8),
            ),
            // Grid controls
            Obx(
              () => IconButton(
                icon: Icon(
                  controller.showGrid.value ? Iconsax.grid_1 : Iconsax.grid_15,
                  size: 20,
                  color: controller.showGrid.value ? Colors.blue : Colors.grey,
                ),
                onPressed: () => controller.toggleGrid(),
                tooltip: 'Toggle Grid',
              ),
            ),
            Obx(
              () => IconButton(
                icon: Icon(
                  Iconsax.link_21,
                  size: 20,
                  color: controller.snapToGrid.value
                      ? Colors.blue
                      : Colors.grey,
                ),
                onPressed: () => controller.toggleSnapToGrid(),
                tooltip: 'Snap to Grid',
              ),
            ),
            SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: Tooltip(
        message: label,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
          label: Text(label, style: TextStyle(fontSize: 12)),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size(0, 36),
          ),
        ),
      ),
    );
  }
}
