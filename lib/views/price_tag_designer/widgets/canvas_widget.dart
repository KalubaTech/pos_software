import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:barcode/barcode.dart' as bc;
import 'package:qr_flutter/qr_flutter.dart';
import '../../../controllers/price_tag_designer_controller.dart';
import '../../../models/price_tag_template_model.dart';
import '../../../utils/currency_formatter.dart';

class CanvasWidget extends StatelessWidget {
  const CanvasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PriceTagDesignerController>();

    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          // Delete/Backspace - Delete selected element
          if (event.logicalKey == LogicalKeyboardKey.delete ||
              event.logicalKey == LogicalKeyboardKey.backspace) {
            final selectedElement = controller.selectedElement.value;
            if (selectedElement != null) {
              controller.deleteElement(selectedElement.id);
              Get.snackbar(
                'Element Deleted',
                'Element has been removed',
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 2),
              );
            }
          }

          // Ctrl+A - Select all elements (check for Ctrl or Command key)
          if (event.logicalKey == LogicalKeyboardKey.keyA &&
              HardwareKeyboard.instance.isControlPressed) {
            controller.selectAllElements();
            final count = controller.selectedElements.length;
            Get.snackbar(
              'All Elements Selected',
              '$count element${count != 1 ? 's' : ''} selected',
              snackPosition: SnackPosition.BOTTOM,
              duration: Duration(seconds: 2),
            );
          }
        }
      },
      child: Obx(() {
        final template = controller.currentTemplate.value;

        if (template == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.document_1, size: 80, color: Colors.grey[300]),
                SizedBox(height: 16),
                Text(
                  'No template selected',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Select a template or create a new one',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return Container(
          color: Colors.grey[200],
          child: Center(
            child: InteractiveViewer(
              minScale: 0.25,
              maxScale: 4.0,
              constrained: false,
              child: Container(
                padding: EdgeInsets.all(50),
                child: _buildCanvas(controller, template),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCanvas(
    PriceTagDesignerController controller,
    PriceTagTemplate template,
  ) {
    // Convert mm to pixels (assuming 96 DPI)
    final double mmToPixel = 3.7795275591;
    final canvasWidth = template.width * mmToPixel * controller.zoom.value;
    final canvasHeight = template.height * mmToPixel * controller.zoom.value;

    return Container(
      width: canvasWidth,
      height: canvasHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Grid
          if (controller.showGrid.value)
            CustomPaint(
              size: Size(canvasWidth, canvasHeight),
              painter: GridPainter(
                gridSize: controller.gridSize.value,
                mmToPixel: mmToPixel,
                zoom: controller.zoom.value,
              ),
            ),
          // Elements (sorted by z-index for proper stacking/overlapping)
          ...(template.elements.toList()
                ..sort((a, b) => a.zIndex.compareTo(b.zIndex)))
              .map((element) {
                return _buildElement(controller, element, mmToPixel);
              })
              .toList(),
        ],
      ),
    );
  }

  Widget _buildElement(
    PriceTagDesignerController controller,
    PriceTagElement element,
    double mmToPixel,
  ) {
    final isSelected = controller.selectedElement.value?.id == element.id;
    final zoom = controller.zoom.value;

    return Positioned(
      left: element.x * mmToPixel * zoom,
      top: element.y * mmToPixel * zoom,
      child: MouseRegion(
        cursor: isSelected
            ? SystemMouseCursors.move
            : (element.type == ElementType.text ||
                  element.type == ElementType.productName ||
                  element.type == ElementType.price)
            ? SystemMouseCursors.text
            : SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent, // More flexible hit testing
          onTap: () => controller.selectElement(element),
          onDoubleTap: () {
            // Enable text editing on double click for text elements
            if (element.type == ElementType.text ||
                element.type == ElementType.productName ||
                element.type == ElementType.price) {
              _showTextEditDialog(controller, element);
            }
          },
          onPanStart: (details) {
            // Select element when starting to drag
            controller.selectElement(element);
          },
          onPanUpdate: (details) {
            // Only move if this element is selected
            if (controller.selectedElement.value?.id == element.id) {
              final dx = details.delta.dx / (mmToPixel * zoom);
              final dy = details.delta.dy / (mmToPixel * zoom);
              controller.moveElement(element.id, dx, dy);
            }
          },
          onPanEnd: (details) {
            // Snap to grid when drag ends
            if (controller.selectedElement.value?.id == element.id) {
              controller.snapElementToGrid(element.id);
            }
          },
          child: Container(
            width: element.width * mmToPixel * zoom,
            height: element.height * mmToPixel * zoom,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                // Make content non-interactive so gestures pass through
                IgnorePointer(
                  child: _buildElementContent(element, mmToPixel * zoom),
                ),
                // Selection handles and resize corners
                if (isSelected) ...[
                  // Resize handles at all corners
                  _buildResizeHandle(
                    controller,
                    element,
                    mmToPixel,
                    zoom,
                    Alignment.topLeft,
                    'tl',
                  ),
                  _buildResizeHandle(
                    controller,
                    element,
                    mmToPixel,
                    zoom,
                    Alignment.topRight,
                    'tr',
                  ),
                  _buildResizeHandle(
                    controller,
                    element,
                    mmToPixel,
                    zoom,
                    Alignment.bottomLeft,
                    'bl',
                  ),
                  _buildResizeHandle(
                    controller,
                    element,
                    mmToPixel,
                    zoom,
                    Alignment.bottomRight,
                    'br',
                  ),
                  // Edge handles for proportional resize
                  _buildResizeHandle(
                    controller,
                    element,
                    mmToPixel,
                    zoom,
                    Alignment.topCenter,
                    't',
                  ),
                  _buildResizeHandle(
                    controller,
                    element,
                    mmToPixel,
                    zoom,
                    Alignment.bottomCenter,
                    'b',
                  ),
                  _buildResizeHandle(
                    controller,
                    element,
                    mmToPixel,
                    zoom,
                    Alignment.centerLeft,
                    'l',
                  ),
                  _buildResizeHandle(
                    controller,
                    element,
                    mmToPixel,
                    zoom,
                    Alignment.centerRight,
                    'r',
                  ),
                  // Label and action buttons
                  Positioned(
                    top: -24,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getElementLabel(element),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Add edit button for text elements
                          if (element.type == ElementType.text ||
                              element.type == ElementType.productName ||
                              element.type == ElementType.price) ...[
                            SizedBox(width: 4),
                            InkWell(
                              onTap: () =>
                                  _showTextEditDialog(controller, element),
                              child: Icon(
                                Iconsax.edit_2,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          SizedBox(width: 4),
                          InkWell(
                            onTap: () => controller.deleteElement(element.id),
                            child: Icon(
                              Iconsax.trash,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElementContent(PriceTagElement element, double scale) {
    switch (element.type) {
      case ElementType.text:
      case ElementType.productName:
        return Container(
          alignment: _getAlignment(element.textAlign),
          color: element.fillBackground
              ? _hexToColor(element.backgroundColor)
              : Colors.transparent,
          padding: EdgeInsets.all(2 * scale / 3.78),
          child: Text(
            element.text ?? 'Text',
            style: TextStyle(
              fontSize: element.fontSize * scale / 3.78,
              fontWeight: element.bold ? FontWeight.bold : FontWeight.normal,
              fontStyle: element.italic ? FontStyle.italic : FontStyle.normal,
              color: _hexToColor(element.color),
            ),
            textAlign: _getTextAlign(element.textAlign),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );

      case ElementType.price:
        return Container(
          alignment: _getAlignment(element.textAlign),
          color: element.fillBackground
              ? _hexToColor(element.backgroundColor)
              : Colors.transparent,
          padding: EdgeInsets.all(2 * scale / 3.78),
          child: Text(
            element.text ?? CurrencyFormatter.format(0),
            style: TextStyle(
              fontSize: element.fontSize * scale / 3.78,
              fontWeight: FontWeight.bold,
              color: _hexToColor(element.color),
            ),
            textAlign: _getTextAlign(element.textAlign),
          ),
        );

      case ElementType.barcode:
        final barcodeData =
            element.barcodeData ?? element.dataField ?? '1234567890';
        final barcodeType = _getBarcodeType(element.barcodeType);

        return Container(
          color: element.fillBackground
              ? _hexToColor(element.backgroundColor)
              : Colors.transparent,
          padding: EdgeInsets.all(4 * scale / 3.78),
          child: BarcodeWidget(
            barcode: barcodeType,
            data: barcodeData,
            width: double.infinity,
            height: double.infinity,
            drawText: true,
            style: TextStyle(fontSize: 8 * scale / 3.78),
            errorBuilder: (context, error) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.barcode, size: 20 * scale / 3.78),
                  Text(
                    'Invalid data',
                    style: TextStyle(fontSize: 6 * scale / 3.78),
                  ),
                ],
              ),
            ),
          ),
        );

      case ElementType.qrCode:
        final qrData =
            element.barcodeData ?? element.dataField ?? 'Sample QR Code';

        return Container(
          color: element.fillBackground
              ? _hexToColor(element.backgroundColor)
              : Colors.transparent,
          padding: EdgeInsets.all(4 * scale / 3.78),
          child: QrImageView(
            data: qrData,
            size: double.infinity,
            errorStateBuilder: (context, error) => Center(
              child: Icon(
                Iconsax.scan_barcode,
                size: 20 * scale / 3.78,
                color: Colors.black,
              ),
            ),
          ),
        );

      case ElementType.line:
        return Container(color: _hexToColor(element.color));

      case ElementType.rectangle:
        return Container(
          decoration: BoxDecoration(
            color: element.fillBackground
                ? _hexToColor(element.backgroundColor)
                : Colors.transparent,
            border: Border.all(
              color: _hexToColor(element.borderColor),
              width: element.borderWidth * scale / 3.78,
            ),
          ),
        );

      default:
        return SizedBox();
    }
  }

  Widget _buildResizeHandle(
    PriceTagDesignerController controller,
    PriceTagElement element,
    double mmToPixel,
    double zoom,
    Alignment alignment,
    String position,
  ) {
    // Position the handle based on alignment
    double? left, right, top, bottom;

    switch (position) {
      case 'tl': // Top-left
        left = -6;
        top = -6;
        break;
      case 'tr': // Top-right
        right = -6;
        top = -6;
        break;
      case 'bl': // Bottom-left
        left = -6;
        bottom = -6;
        break;
      case 'br': // Bottom-right
        right = -6;
        bottom = -6;
        break;
      case 't': // Top-center
        left = (element.width * mmToPixel * zoom / 2) - 6;
        top = -6;
        break;
      case 'b': // Bottom-center
        left = (element.width * mmToPixel * zoom / 2) - 6;
        bottom = -6;
        break;
      case 'l': // Center-left
        left = -6;
        top = (element.height * mmToPixel * zoom / 2) - 6;
        break;
      case 'r': // Center-right
        right = -6;
        top = (element.height * mmToPixel * zoom / 2) - 6;
        break;
    }

    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: MouseRegion(
        cursor: _getResizeCursor(position),
        onExit: (_) {
          // Clean up mouse region on exit to prevent tracking issues
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            // Mark that we're resizing to prevent parent drag
            // This is handled by the opaque behavior
          },
          onPanUpdate: (details) {
            final dx = details.delta.dx / (mmToPixel * zoom);
            final dy = details.delta.dy / (mmToPixel * zoom);

            double newX = element.x;
            double newY = element.y;
            double newWidth = element.width;
            double newHeight = element.height;

            // Calculate new dimensions based on handle position
            switch (position) {
              case 'tl': // Top-left corner
                newX = element.x + dx;
                newY = element.y + dy;
                newWidth = element.width - dx;
                newHeight = element.height - dy;
                break;
              case 'tr': // Top-right corner
                newY = element.y + dy;
                newWidth = element.width + dx;
                newHeight = element.height - dy;
                break;
              case 'bl': // Bottom-left corner
                newX = element.x + dx;
                newWidth = element.width - dx;
                newHeight = element.height + dy;
                break;
              case 'br': // Bottom-right corner
                newWidth = element.width + dx;
                newHeight = element.height + dy;
                break;
              case 't': // Top edge
                newY = element.y + dy;
                newHeight = element.height - dy;
                break;
              case 'b': // Bottom edge
                newHeight = element.height + dy;
                break;
              case 'l': // Left edge
                newX = element.x + dx;
                newWidth = element.width - dx;
                break;
              case 'r': // Right edge
                newWidth = element.width + dx;
                break;
            }

            // Apply minimum size constraints
            if (newWidth < 5.0) newWidth = 5.0;
            if (newHeight < 5.0) newHeight = 5.0;

            // If size changed due to constraints, adjust position
            if (position.contains('l') && newWidth != element.width - dx) {
              newX = element.x + element.width - newWidth;
            }
            if (position.contains('t') && newHeight != element.height - dy) {
              newY = element.y + element.height - newHeight;
            }

            // Constrain to canvas boundaries (without snapping during drag)
            if (controller.currentTemplate.value != null) {
              newX = newX.clamp(
                0.0,
                controller.currentTemplate.value!.width - newWidth,
              );
              newY = newY.clamp(
                0.0,
                controller.currentTemplate.value!.height - newHeight,
              );
            }

            // Update element with new position and size (without saving)
            controller.updateElement(
              element.copyWith(
                x: newX,
                y: newY,
                width: newWidth,
                height: newHeight,
              ),
              save: false, // Don't save to database during drag
            );
          },
          onPanEnd: (details) {
            // Snap to grid and save when resize ends
            controller.snapElementToGrid(element.id);
          },
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(color: Colors.white, width: 2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SystemMouseCursor _getResizeCursor(String position) {
    switch (position) {
      case 'tl':
      case 'br':
        return SystemMouseCursors.resizeUpLeftDownRight;
      case 'tr':
      case 'bl':
        return SystemMouseCursors.resizeUpRightDownLeft;
      case 't':
      case 'b':
        return SystemMouseCursors.resizeUpDown;
      case 'l':
      case 'r':
        return SystemMouseCursors.resizeLeftRight;
      default:
        return SystemMouseCursors.grab;
    }
  }

  String _getElementLabel(PriceTagElement element) {
    switch (element.type) {
      case ElementType.text:
        return 'Text';
      case ElementType.productName:
        return 'Product';
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
        return 'Element';
    }
  }

  Alignment _getAlignment(String align) {
    switch (align) {
      case 'center':
        return Alignment.center;
      case 'right':
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }

  TextAlign _getTextAlign(String align) {
    switch (align) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  bc.Barcode _getBarcodeType(String type) {
    switch (type.toLowerCase()) {
      case 'code128':
        return bc.Barcode.code128();
      case 'code39':
        return bc.Barcode.code39();
      case 'ean13':
        return bc.Barcode.ean13();
      case 'ean8':
        return bc.Barcode.ean8();
      case 'upca':
        return bc.Barcode.upcA();
      case 'upce':
        return bc.Barcode.upcE();
      case 'codabar':
        return bc.Barcode.codabar();
      case 'itf':
        return bc.Barcode.itf();
      default:
        return bc.Barcode.code128();
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  void _showTextEditDialog(
    PriceTagDesignerController controller,
    PriceTagElement element,
  ) {
    final textController = TextEditingController(text: element.text ?? '');

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Iconsax.text, color: Colors.blue),
            SizedBox(width: 12),
            Text('Edit ${_getElementLabel(element)}'),
          ],
        ),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter text content:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: textController,
                autofocus: true,
                maxLines: element.type == ElementType.text ? 3 : 1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: element.type == ElementType.price
                      ? 'e.g., 999.99'
                      : 'Enter text...',
                  prefixIcon: Icon(Iconsax.edit_2),
                ),
                keyboardType: element.type == ElementType.price
                    ? TextInputType.number
                    : TextInputType.text,
                onSubmitted: (value) {
                  controller.updateElement(
                    element.copyWith(text: value),
                    save: true,
                  );
                  Get.back();
                },
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.info_circle,
                      size: 16,
                      color: Colors.blue[700],
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tip: Double-click any text element to edit',
                        style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              controller.updateElement(
                element.copyWith(text: textController.text),
                save: true,
              );
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final double gridSize;
  final double mmToPixel;
  final double zoom;

  GridPainter({
    required this.gridSize,
    required this.mmToPixel,
    required this.zoom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5;

    final spacing = gridSize * mmToPixel * zoom;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
