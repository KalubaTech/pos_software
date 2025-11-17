import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';

class BarcodeScannerService extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();

  var isScanning = false.obs;
  var lastScannedCode = ''.obs;
  var hasCameraPermission = false.obs;

  /// Check camera permission
  Future<bool> checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      hasCameraPermission.value = status.isGranted;
      return status.isGranted;
    } catch (e) {
      print('Error checking camera permission: $e');
      return false;
    }
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      hasCameraPermission.value = status.isGranted;

      if (status.isPermanentlyDenied) {
        _showPermissionSettingsDialog();
      }

      return status.isGranted;
    } catch (e) {
      print('Error requesting camera permission: $e');
      Get.snackbar(
        'Permission Error',
        'Failed to request camera permission',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Show camera scanner dialog
  Future<String?> scanBarcode() async {
    try {
      // Check permission first
      final hasPermission = await checkCameraPermission();
      if (!hasPermission) {
        final granted = await requestCameraPermission();
        if (!granted) {
          return null;
        }
      }

      isScanning.value = true;
      String? scannedCode;

      await Get.dialog(
        Dialog(
          child: Container(
            width: Get.width * 0.9,
            height: Get.height * 0.7,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BarcodeScannerWidget(
                onDetect: (barcode) {
                  if (barcode.isNotEmpty) {
                    scannedCode = barcode;
                    lastScannedCode.value = barcode;
                    Get.back();
                  }
                },
              ),
            ),
          ),
        ),
        barrierDismissible: true,
      );

      isScanning.value = false;
      return scannedCode;
    } catch (e) {
      isScanning.value = false;
      Get.snackbar('Scan Error', 'Failed to scan barcode: $e');
      return null;
    }
  }

  Future<ProductModel?> findProductByBarcode(String barcode) async {
    try {
      return await _dbService.getProductByBarcode(barcode);
    } catch (e) {
      Get.snackbar('Error', 'Failed to find product: $e');
      return null;
    }
  }

  /// Generate barcode for products
  String generateBarcode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return timestamp.toString().substring(timestamp.toString().length - 13);
  }

  /// Validate barcode format (EAN-13)
  bool isValidBarcode(String barcode) {
    if (barcode.length != 13) return false;
    if (!RegExp(r'^\d+$').hasMatch(barcode)) return false;

    // Check digit validation
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      int digit = int.parse(barcode[i]);
      sum += (i % 2 == 0) ? digit : digit * 3;
    }
    int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(barcode[12]);
  }

  void _showPermissionSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Text('Permission Required'),
          ],
        ),
        content: Text(
          'Camera permission is required to scan barcodes. Please enable it in app settings.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            icon: Icon(Icons.settings, size: 18),
            label: Text('Open Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}

/// Camera barcode scanner widget
class BarcodeScannerWidget extends StatefulWidget {
  final Function(String) onDetect;

  const BarcodeScannerWidget({Key? key, required this.onDetect})
    : super(key: key);

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.qrCode,
    ],
  );

  bool hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (capture) {
            if (hasScanned) return;

            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null && !hasScanned) {
                hasScanned = true;
                widget.onDetect(barcode.rawValue!);
                break;
              }
            }
          },
        ),
        // Overlay with scanning guide
        Positioned.fill(child: CustomPaint(painter: ScannerOverlayPainter())),
        // Top bar with close button and flash toggle
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: Colors.white),
                ),
                Text(
                  'Scan Barcode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => controller.toggleTorch(),
                  icon: Icon(Icons.flash_on, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        // Bottom instruction
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
            child: Text(
              'Position the barcode within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

/// Custom painter for scanner overlay
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaWidth = size.width * 0.7;
    final double scanAreaHeight = size.height * 0.3;
    final double left = (size.width - scanAreaWidth) / 2;
    final double top = (size.height - scanAreaHeight) / 2;

    // Draw semi-transparent overlay
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Draw the four rectangles around the scan area
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, top), paint); // Top
    canvas.drawRect(Rect.fromLTWH(0, top, left, scanAreaHeight), paint); // Left
    canvas.drawRect(
      Rect.fromLTWH(
        left + scanAreaWidth,
        top,
        size.width - left - scanAreaWidth,
        scanAreaHeight,
      ),
      paint,
    ); // Right
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        top + scanAreaHeight,
        size.width,
        size.height - top - scanAreaHeight,
      ),
      paint,
    ); // Bottom

    // Draw scan area border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final borderRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, scanAreaWidth, scanAreaHeight),
      Radius.circular(16),
    );
    canvas.drawRRect(borderRect, borderPaint);

    // Draw corner accents
    final accentPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top + cornerLength),
      Offset(left, top),
      accentPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      accentPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + scanAreaWidth - cornerLength, top),
      Offset(left + scanAreaWidth, top),
      accentPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaWidth, top),
      Offset(left + scanAreaWidth, top + cornerLength),
      accentPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + scanAreaHeight - cornerLength),
      Offset(left, top + scanAreaHeight),
      accentPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaHeight),
      Offset(left + cornerLength, top + scanAreaHeight),
      accentPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + scanAreaWidth - cornerLength, top + scanAreaHeight),
      Offset(left + scanAreaWidth, top + scanAreaHeight),
      accentPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaWidth, top + scanAreaHeight - cornerLength),
      Offset(left + scanAreaWidth, top + scanAreaHeight),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
