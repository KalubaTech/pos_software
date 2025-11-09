import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';

class BarcodeScannerService extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final ImagePicker _picker = ImagePicker();

  var isScanning = false.obs;
  var lastScannedCode = ''.obs;

  // Simulate barcode scanning (in production, use mobile_scanner or similar)
  Future<String?> scanBarcode() async {
    try {
      isScanning.value = true;

      // For demo purposes, return one of the actual barcodes from products
      // In production, this would use camera to scan actual barcodes
      await Future.delayed(Duration(seconds: 1));

      final mockBarcodes = [
        '7501234567890', // Espresso
        '7501234567899', // Croissant
        '7501234567905', // Wireless Mouse
        '7501234567911', // Headphones
        '7501234567900', // Sandwich
        '7501234567893', // Cappuccino
      ];

      mockBarcodes.shuffle();
      final code = mockBarcodes.first;

      lastScannedCode.value = code;
      isScanning.value = false;

      return code;
    } catch (e) {
      isScanning.value = false;
      Get.snackbar('Scan Error', 'Failed to scan barcode: $e');
      return null;
    }
  }

  Future<ProductModel?> findProductByBarcode(String barcode) async {
    try {
      // Use database service to find product by barcode
      return await _dbService.getProductByBarcode(barcode);
    } catch (e) {
      Get.snackbar('Error', 'Failed to find product: $e');
      return null;
    }
  }

  Future<String?> scanBarcodeFromImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image == null) return null;

      // In production, use a barcode detection library like google_mlkit_barcode_scanning
      // For demo, simulate successful scan
      await Future.delayed(Duration(milliseconds: 500));

      return await scanBarcode();
    } catch (e) {
      Get.snackbar('Error', 'Failed to scan from image: $e');
      return null;
    }
  }

  // Generate barcode for products
  String generateBarcode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return timestamp.toString().substring(timestamp.toString().length - 13);
  }

  // Validate barcode format (EAN-13)
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
}
