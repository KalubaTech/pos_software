import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../../services/printer_service.dart';
import '../../../controllers/appearance_controller.dart';
import '../../../models/price_tag_template_model.dart';
import '../../../models/product_model.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/colors.dart';

class PrintDialogWidget extends StatefulWidget {
  final PriceTagTemplate template;
  final List<ProductModel> products;

  const PrintDialogWidget({
    super.key,
    required this.template,
    required this.products,
  });

  @override
  State<PrintDialogWidget> createState() => _PrintDialogWidgetState();
}

class _PrintDialogWidgetState extends State<PrintDialogWidget> {
  final printerService = Get.find<PrinterService>();
  BluetoothInfo? selectedPrinter;
  String? selectedPrinterMac;
  int numberOfCopies = 1;

  @override
  void initState() {
    super.initState();
    // Just get the already connected printer from settings
    _loadConnectedPrinter();
  }

  void _loadConnectedPrinter() {
    final connected = printerService.connectedPrinter.value;
    if (connected != null) {
      setState(() {
        selectedPrinter = connected;
        selectedPrinterMac = connected.macAdress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appearanceController = Get.find<AppearanceController>();
    final isDark = appearanceController.isDarkMode.value;

    // Limit dialog height to viewport to avoid vertical overflow
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 600,
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Container(
        width: 600,
        padding: EdgeInsets.all(24),
        color: AppColors.getSurfaceColor(isDark),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Iconsax.printer,
                  color: isDark ? AppColors.darkPrimary : Colors.blue,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'Print Price Tags',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    Iconsax.close_circle,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Template: ${widget.template.name} (${widget.template.width.toStringAsFixed(0)}×${widget.template.height.toStringAsFixed(0)}mm)',
              style: TextStyle(color: AppColors.getTextSecondary(isDark)),
            ),
            SizedBox(height: 20),
            Divider(color: AppColors.getDivider(isDark)),
            SizedBox(height: 20),

            // Printer Selection
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.getDivider(isDark)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.printer,
                        size: 20,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Select Printer',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Display connected printer (read-only, no selection)
                  Obx(() {
                    final connected = printerService.connectedPrinter.value;

                    if (connected == null) {
                      return Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.orange.withOpacity(0.15)
                              : Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? Colors.orange.withOpacity(0.3)
                                : Colors.orange[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.warning_2,
                              color: isDark
                                  ? Colors.orange
                                  : Colors.orange[700],
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'No Printer Connected',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.orange
                                          : Colors.orange[900],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Please connect a printer in System Settings first.',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.orange[300]
                                          : Colors.orange[800],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Show connected printer (read-only)
                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.green.withOpacity(0.15)
                            : Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? Colors.green.withOpacity(0.3)
                              : Colors.green[300]!,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.green[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Iconsax.printer,
                              color: isDark ? Colors.green : Colors.green[700],
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  connected.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.getTextPrimary(isDark),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.green
                                            : Colors.green[600],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'CONNECTED',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      connected.macAdress,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.getTextSecondary(
                                          isDark,
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
                  }),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Number of copies selector
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.getDivider(isDark)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.copy,
                        size: 20,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Number of Copies',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        onPressed: numberOfCopies > 1
                            ? () {
                                setState(() {
                                  numberOfCopies--;
                                });
                              }
                            : null,
                        icon: Icon(Iconsax.minus),
                        iconSize: 32,
                        color: isDark ? AppColors.darkPrimary : Colors.blue,
                      ),
                      SizedBox(width: 16),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.getDivider(isDark),
                          ),
                        ),
                        child: Text(
                          '$numberOfCopies',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            numberOfCopies++;
                          });
                        },
                        icon: Icon(Iconsax.add_circle),
                        iconSize: 32,
                        color: isDark ? AppColors.darkPrimary : Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Actions
            Row(
              children: [
                // Total tags count
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.document_text,
                        size: 20,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Total: $numberOfCopies label(s)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                // Test print button
                if (selectedPrinter != null)
                  TextButton.icon(
                    onPressed: () => _testPrint(),
                    icon: Icon(Iconsax.document_text_1, size: 18),
                    label: Text('Test Print'),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark
                          ? AppColors.darkPrimary
                          : Colors.blue,
                    ),
                  ),
                SizedBox(width: 8),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Cancel'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.getTextSecondary(isDark),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: selectedPrinter == null
                      ? null
                      : () => _printTags(),
                  icon: Icon(Iconsax.printer),
                  label: Text('Print Labels'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.darkPrimary
                        : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Test print with simple commands
  Future<void> _testPrint() async {
    if (selectedPrinter == null) return;

    final appearanceController = Get.find<AppearanceController>();
    final isDark = appearanceController.isDarkMode.value;

    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: AppColors.getSurfaceColor(isDark),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: isDark ? AppColors.darkPrimary : Colors.blue,
                ),
                SizedBox(height: 16),
                Text(
                  'Sending test print...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // Ensure stable connection
      print('Ensuring printer connection for test print...');
      final connected = await printerService.ensureConnection(maxRetries: 3);

      if (!connected) {
        Get.back(); // Close dialog
        Get.snackbar(
          'Connection Failed',
          'Could not connect to printer',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Generate simple TSPL test print
      List<int> bytes = [];

      // TSPL test print commands
      bytes.addAll('SIZE 60 mm, 40 mm\r\n'.codeUnits);
      bytes.addAll('GAP 2 mm, 0 mm\r\n'.codeUnits);
      bytes.addAll('DIRECTION 0\r\n'.codeUnits);
      bytes.addAll('DENSITY 8\r\n'.codeUnits);
      bytes.addAll('CLS\r\n'.codeUnits);

      // Title text
      bytes.addAll('TEXT 150,50,"4",0,2,2,"TEST PRINT"\r\n'.codeUnits);

      // Printer model
      bytes.addAll(
        'TEXT 120,120,"3",0,1,1,"PT-260 Label Printer"\r\n'.codeUnits,
      );

      // Timestamp
      bytes.addAll(
        'TEXT 80,170,"2",0,1,1,"${DateTime.now().toString().substring(0, 19)}"\r\n'
            .codeUnits,
      );

      // Horizontal line
      bytes.addAll('BAR 50,210,380,2\r\n'.codeUnits);

      // TSPL indicator
      bytes.addAll(
        'TEXT 140,230,"3",0,1,1,"Using TSPL Commands"\r\n'.codeUnits,
      );

      bytes.addAll('PRINT 1,1\r\n'.codeUnits);

      print('Test print: ${bytes.length} bytes');
      print('TSPL Commands: ${String.fromCharCodes(bytes.take(100))}');

      final result = await PrintBluetoothThermal.writeBytes(bytes);
      print('Write result: $result');

      await Future.delayed(Duration(milliseconds: 1000));

      Get.back(); // Close dialog

      if (result) {
        Get.snackbar(
          'Test Print Sent',
          'Check your printer. Bytes sent: ${bytes.length}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Print May Have Failed',
          'Command sent but result unclear',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close dialog
      print('Test print error: $e');
      Get.snackbar(
        'Test Print Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _printTags() async {
    final appearanceController = Get.find<AppearanceController>();
    final isDark = appearanceController.isDarkMode.value;

    // Check if printer is selected
    if (selectedPrinter == null) {
      Get.snackbar(
        'No Printer Selected',
        'Please select a printer before printing',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: Icon(Iconsax.warning_2, color: Colors.white),
      );
      return;
    }

    // Show printing dialog
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: AppColors.getSurfaceColor(isDark),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: isDark ? AppColors.darkPrimary : Colors.blue,
                ),
                SizedBox(height: 16),
                Text(
                  'Printing $numberOfCopies label(s)...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please wait',
                  style: TextStyle(color: AppColors.getTextSecondary(isDark)),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // Ensure stable connection with retries
      print('Ensuring printer connection...');
      final connected = await printerService.ensureConnection(maxRetries: 3);

      if (!connected) {
        Get.back(); // Close printing dialog
        Get.snackbar(
          'Connection Failed',
          'Could not establish stable connection to printer. Please check:\n'
              '• Printer is powered on\n'
              '• Bluetooth is enabled\n'
              '• Printer is in range',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          icon: Icon(Iconsax.warning_2, color: Colors.white),
        );
        return;
      }

      print('Connection stable. Starting print job...');

      // Generate and print each label (no product data, just template design)
      int successCount = 0;
      int failCount = 0;

      for (int i = 0; i < numberOfCopies; i++) {
        try {
          // Verify connection before each print
          final stillConnected = await printerService.connectionStatus();
          if (!stillConnected) {
            print(
              'Connection lost during printing. Attempting to reconnect...',
            );
            final reconnected = await printerService.ensureConnection(
              maxRetries: 2,
            );
            if (!reconnected) {
              throw Exception('Lost connection to printer');
            }
          }

          // Generate label from template design (without product data)
          final bytes = await _generateLabelFromTemplate();

          // Debug: Print byte array info
          print('Generated ${bytes.length} bytes for label ${i + 1}');
          print('TSPL preview: ${String.fromCharCodes(bytes.take(100))}');

          // Send to printer with verification
          final result = await PrintBluetoothThermal.writeBytes(bytes);
          print('Write result for label ${i + 1}: $result');

          if (result) {
            successCount++;
            print('Label ${i + 1} sent successfully');
          } else {
            failCount++;
            print('Label ${i + 1} may have failed');
          }

          // Small delay between labels to avoid overwhelming printer
          if (i < numberOfCopies - 1) {
            await Future.delayed(Duration(milliseconds: 500));
          }
        } catch (e) {
          failCount++;
          print('Error printing label ${i + 1}: $e');
        }
      }

      Get.back(); // Close printing dialog

      // Show result
      if (failCount == 0) {
        Get.back(); // Close print dialog
        Get.snackbar(
          'Print Complete',
          'Successfully printed $successCount label(s)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: Icon(Iconsax.tick_circle, color: Colors.white),
        );
      } else {
        Get.snackbar(
          'Print Partially Complete',
          'Printed: $successCount, Failed: $failCount',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.back(); // Close printing dialog
      print('Print error: $e');
      Get.snackbar(
        'Print Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Iconsax.warning_2, color: Colors.white),
      );
    }
  }

  // Generate label from template design (without product data)
  Future<List<int>> _generateLabelFromTemplate() async {
    List<int> bytes = [];

    // Use EXACT template dimensions from canvas
    bytes.addAll(
      'SIZE ${widget.template.width.toStringAsFixed(1)} mm, ${widget.template.height.toStringAsFixed(1)} mm\r\n'
          .codeUnits,
    );
    bytes.addAll('GAP 2 mm, 0 mm\r\n'.codeUnits); // Gap between labels
    bytes.addAll('DIRECTION 0\r\n'.codeUnits); // Print direction
    bytes.addAll('REFERENCE 0,0\r\n'.codeUnits); // Reference point (top-left)
    bytes.addAll(
      'DENSITY 8\r\n'.codeUnits,
    ); // Print density (0-15, 8 is medium)
    bytes.addAll('CLS\r\n'.codeUnits); // Clear buffer

    // Sort elements by zIndex for proper layering (as designed on canvas)
    final sortedElements = List<PriceTagElement>.from(widget.template.elements)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    // Render all template elements with exact canvas dimensions
    for (var element in sortedElements) {
      bytes.addAll(await _generateTSPLElement(element, null));
    }

    // Print command
    bytes.addAll('PRINT 1,1\r\n'.codeUnits);

    return bytes;
  }

  // Generate TSPL commands for a single element
  List<int> _generateTSPLElement(
    PriceTagElement element,
    ProductModel? product, // Made nullable
  ) {
    List<int> bytes = [];

    // Convert mm to dots with EXACT precision
    // PT-260 printer uses 203 DPI = 8 dots per mm
    // Do NOT round until final command to maintain precision
    double x = element.x * 8.0;
    double y = element.y * 8.0;
    double width = element.width * 8.0;
    double height = element.height * 8.0;

    // Handle background fill first if needed
    if (element.fillBackground && element.type != ElementType.line) {
      int rectX = x.round();
      int rectY = y.round();
      int rectWidth = width.round();
      int rectHeight = height.round();
      // For text/barcode, background is fill, but TSPL no direct, use BOX with thickness 0? But BOX is border.
      // To fill, use BAR for solid rectangle.
      bytes.addAll('BAR $rectX,$rectY,$rectWidth,$rectHeight\r\n'.codeUnits);
    }

    switch (element.type) {
      case ElementType.text:
        if (element.text != null && element.text!.isNotEmpty) {
          bytes.addAll(_generateTSPLText(x, y, element, element.text!));
        }
        break;

      case ElementType.productName:
        // Render element.text (the placeholder/design text) when printing template
        if (element.text != null && element.text!.isNotEmpty) {
          bytes.addAll(_generateTSPLText(x, y, element, element.text!));
        } else if (product != null) {
          // Fallback to product data if available
          bytes.addAll(_generateTSPLText(x, y, element, product.name));
        }
        break;

      case ElementType.price:
        // Render element.text (the placeholder/design text) when printing template
        if (element.text != null && element.text!.isNotEmpty) {
          bytes.addAll(_generateTSPLText(x, y, element, element.text!));
        } else if (product != null) {
          // Fallback to product data if available
          final priceText = CurrencyFormatter.format(product.price);
          bytes.addAll(_generateTSPLText(x, y, element, priceText));
        }
        break;

      case ElementType.barcode:
        final barcodeData = element.barcodeData ?? product?.barcode ?? '';
        if (barcodeData.isNotEmpty) {
          print('Generating barcode: "$barcodeData" at ($x, $y)');
          bytes.addAll(_generateTSPLBarcode(x, y, element, barcodeData));
        } else {
          print('Warning: Barcode element has no data');
        }
        break;

      case ElementType.qrCode:
        final qrData =
            element.barcodeData ?? product?.barcode ?? product?.name ?? '';
        if (qrData.isNotEmpty) {
          bytes.addAll(_generateTSPLQRCode(x, y, element, qrData));
        }
        break;

      case ElementType.line:
        // Determine if horizontal or vertical based on dimensions
        if (element.width >= element.height) {
          // Horizontal line
          int lineThickness = height.round();
          if (lineThickness < 1) lineThickness = 1;
          int lineY = (y + height / 2).round() - (lineThickness ~/ 2);
          int lineX = x.round();
          int lineWidth = width.round();
          bytes.addAll(
            'BAR $lineX,$lineY,$lineWidth,$lineThickness\r\n'.codeUnits,
          );
        } else {
          // Vertical line
          int lineThickness = width.round();
          if (lineThickness < 1) lineThickness = 1;
          int lineX = (x + width / 2).round() - (lineThickness ~/ 2);
          int lineY = y.round();
          int lineHeight = height.round();
          bytes.addAll(
            'BAR $lineX,$lineY,$lineThickness,$lineHeight\r\n'.codeUnits,
          );
        }
        break;

      case ElementType.rectangle:
        // Draw rectangle/box
        if (element.borderWidth > 0) {
          int borderWidth = (element.borderWidth * 8.0).round();
          if (borderWidth < 1) borderWidth = 1;
          int rectX = x.round();
          int rectY = y.round();
          int rectX2 = (x + width).round();
          int rectY2 = (y + height).round();
          bytes.addAll(
            'BOX $rectX,$rectY,$rectX2,$rectY2,$borderWidth\r\n'.codeUnits,
          );
        }
        break;

      default:
        break;
    }

    return bytes;
  }

  // Generate TSPL text command with exact canvas font size and positioning
  List<int> _generateTSPLText(
    double x,
    double y,
    PriceTagElement element,
    String text,
  ) {
    List<int> bytes = [];

    // PRECISE font size calculation matching canvas rendering
    // Canvas renders text as: fontSize * scale / 3.7795... where scale = 3.7795 * zoom, at zoom=1, fontSize pixels
    // fontSize is in screen pixels corresponding to physical size at 96 DPI
    // Physical height mm = fontSize / (96 / 25.4) ≈ fontSize / 3.78
    // Printer dots = mm * 8 (203 DPI / 25.4 ≈ 8)
    double desiredHeightDots = element.fontSize * 8.0 / 3.7795275591;

    // Use font "4" (24x32 base), as it's mid-range
    double baseFontHeight = 32.0; // For font "4"
    double baseCharWidth = 24.0; // For font "4"

    // Calculate scale for height
    double scaleValue = desiredHeightDots / baseFontHeight;
    int xScale = scaleValue.round();
    int yScale = scaleValue.round();

    xScale = xScale.clamp(1, 10);
    yScale = yScale.clamp(1, 10);

    // Use TSPL built-in font "4" which is proportional? No, fixed pitch
    String font = "4";

    // Handle rotation precisely
    int rotation = 0;
    if (element.rotation >= 45 && element.rotation < 135)
      rotation = 90;
    else if (element.rotation >= 135 && element.rotation < 225)
      rotation = 180;
    else if (element.rotation >= 225 && element.rotation < 315)
      rotation = 270;

    // PRECISE text alignment using base char width
    double charWidthDots = baseCharWidth * xScale;
    double textWidthDots = text.length * charWidthDots;

    double adjustedX = x;
    if (element.textAlign == 'center') {
      adjustedX = x + (element.width * 8.0 / 2.0) - (textWidthDots / 2.0);
    } else if (element.textAlign == 'right') {
      adjustedX = x + (element.width * 8.0) - textWidthDots;
    }

    // Vertical positioning: TSPL TEXT y is top of character cell
    double adjustedY = y;

    // Round to final integer coordinates
    int finalX = adjustedX.round();
    int finalY = adjustedY.round();

    // Clean text - escape quotes and special characters
    String cleanText = text.replaceAll('"', '\\"').replaceAll('\\', '\\\\');

    // TSPL TEXT command: TEXT x, y, "font", rotation, x-scale, y-scale, "text"
    bytes.addAll(
      'TEXT $finalX,$finalY,"$font",$rotation,$xScale,$yScale,"$cleanText"\r\n'
          .codeUnits,
    );

    return bytes;
  }

  // Generate TSPL barcode command with EXACT canvas dimensions
  List<int> _generateTSPLBarcode(
    double x,
    double y,
    PriceTagElement element,
    String data,
  ) {
    List<int> bytes = [];

    // Clean and validate barcode data
    String cleanData = data.trim();
    if (cleanData.isEmpty) return bytes;

    // Determine barcode type
    String barcodeType = '128'; // Default to Code 128 (most versatile)

    if (element.barcodeType.toLowerCase() == 'ean13' ||
        cleanData.length == 13) {
      barcodeType = 'EAN13';
    } else if (element.barcodeType.toLowerCase() == 'ean8' ||
        cleanData.length == 8) {
      barcodeType = 'EAN8';
    } else if (element.barcodeType.toLowerCase() == 'code39') {
      barcodeType = '39';
    } else if (element.barcodeType.toLowerCase() == 'code128') {
      barcodeType = '128';
    }

    // Use EXACT height from canvas element converted to dots
    // BUT leave space for human-readable text below bars (typically 25-30 dots at scale 1, scale accordingly)
    double heightDots = element.height * 8.0;
    // Estimate text height: approx 12 dots * scale, but use 30 as base
    int barcodeHeight = (heightDots - 30).round(); // Subtract space for text
    if (barcodeHeight < 50) barcodeHeight = 50; // Minimum for readability
    if (barcodeHeight > 800) barcodeHeight = 800;

    // Calculate bar width based on EXACT element width
    // For optimal scanning, aim for 2-3 dots narrow bar
    double widthDots = element.width * 8.0;
    // Estimate: Code 128 needs ~11 bars per character
    double barsNeeded = cleanData.length * 11.0;
    int narrowBar = (widthDots / barsNeeded / 3.0).round();

    if (narrowBar < 2) narrowBar = 2;
    if (narrowBar > 4) narrowBar = 4;
    int wideBar = narrowBar * 3; // 3:1 ratio

    // Rotation must be 0, 90, 180, or 270
    int rotationValue = 0;
    if (element.rotation >= 45 && element.rotation < 135)
      rotationValue = 90;
    else if (element.rotation >= 135 && element.rotation < 225)
      rotationValue = 180;
    else if (element.rotation >= 225 && element.rotation < 315)
      rotationValue = 270;

    // Round coordinates
    int finalX = x.round();
    int finalY = y.round();

    // BARCODE command format:
    // BARCODE x, y, "type", height, human_readable, rotation, narrow, wide, "data"
    final barcodeCommand =
        'BARCODE $finalX,$finalY,"$barcodeType",$barcodeHeight,1,$rotationValue,$narrowBar,$wideBar,"$cleanData"\r\n';
    print('Barcode command: $barcodeCommand');

    bytes.addAll(barcodeCommand.codeUnits);

    return bytes;
  }

  // Generate TSPL QR code command with EXACT canvas dimensions
  List<int> _generateTSPLQRCode(
    double x,
    double y,
    PriceTagElement element,
    String data,
  ) {
    List<int> bytes = [];

    // Calculate QR code cell/module size from EXACT element width
    // QR code typically has 21-177 modules depending on data and error correction
    // For moderate data with high error correction: ~33-41 modules
    double elementWidthDots = element.width * 8.0;
    int cellSize = (elementWidthDots / 35.0).round(); // Assume 35 modules

    if (cellSize < 2) cellSize = 2; // Minimum readable size
    if (cellSize > 12) cellSize = 12; // Maximum practical size

    // Use element rotation
    int rotationValue = 0;
    if (element.rotation >= 45 && element.rotation < 135)
      rotationValue = 90;
    else if (element.rotation >= 135 && element.rotation < 225)
      rotationValue = 180;
    else if (element.rotation >= 225 && element.rotation < 315)
      rotationValue = 270;

    // Round coordinates
    int finalX = x.round();
    int finalY = y.round();

    // QRCODE command: QRCODE x, y, error_level, cell_size, mode, rotation, "data"
    // error_level: L (7%), M (15%), Q (25%), H (30%) - use H for best reliability
    // mode: A (auto), M (manual)
    // cell_size: module/cell width in dots
    bytes.addAll(
      'QRCODE $finalX,$finalY,H,$cellSize,A,$rotationValue,"$data"\r\n'
          .codeUnits,
    );

    return bytes;
  }
}
