import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../models/receipt_model.dart';
import '../utils/currency_formatter.dart';
import '../controllers/business_settings_controller.dart';
import '../services/bluetooth_permission_service.dart';
import 'package:intl/intl.dart';

class PrinterService extends GetxController {
  var isConnected = false.obs;
  var isScanning = false.obs;
  var availablePrinters = <BluetoothInfo>[].obs;
  var connectedPrinter = Rx<BluetoothInfo?>(null);
  var savedPrinterMac = ''.obs;
  final _storage = GetStorage();

  // Connection stability tracking
  var connectionAttempts = 0;
  var lastConnectionCheck = DateTime.now();
  bool _isReconnecting = false;

  @override
  void onInit() {
    super.onInit();
    _loadSavedPrinter();
    _checkConnectionStatus();
    _startConnectionMonitor();
  }

  @override
  void onClose() {
    _stopConnectionMonitor();
    super.onClose();
  }

  // Monitor connection status periodically
  void _startConnectionMonitor() {
    // Check connection every 5 seconds
    Future.delayed(Duration(seconds: 5), () async {
      if (!Get.isRegistered<PrinterService>()) return;

      await _monitorConnection();
      _startConnectionMonitor(); // Schedule next check
    });
  }

  void _stopConnectionMonitor() {
    // Cleanup if needed
  }

  // Monitor and maintain connection
  Future<void> _monitorConnection() async {
    try {
      // Skip if already reconnecting
      if (_isReconnecting) return;

      // Check current status
      final status = await PrintBluetoothThermal.connectionStatus;
      final wasConnected = isConnected.value;
      isConnected.value = status;

      // If we lost connection and have a saved printer, try to reconnect
      if (!status && wasConnected && savedPrinterMac.value.isNotEmpty) {
        print('Connection lost. Attempting to reconnect...');
        await _attemptReconnect();
      }
    } catch (e) {
      print('Error in connection monitor: $e');
    }
  }

  // Attempt to reconnect with exponential backoff
  Future<void> _attemptReconnect() async {
    if (_isReconnecting) return;

    _isReconnecting = true;
    try {
      // Wait a bit before reconnecting
      await Future.delayed(Duration(milliseconds: 500));

      final success = await connectPrinter(savedPrinterMac.value, silent: true);

      if (success) {
        print('Reconnection successful');
        connectionAttempts = 0;
      } else {
        connectionAttempts++;
        print('Reconnection failed. Attempts: $connectionAttempts');
      }
    } catch (e) {
      print('Error during reconnection: $e');
      connectionAttempts++;
    } finally {
      _isReconnecting = false;
    }
  }

  // Load saved printer MAC from storage
  void _loadSavedPrinter() {
    final savedMac = _storage.read('saved_printer_mac');
    if (savedMac != null && savedMac.isNotEmpty) {
      savedPrinterMac.value = savedMac;
    }
  }

  // Save printer MAC to storage (public method)
  void savePrinterMac(String macAddress) {
    _storage.write('saved_printer_mac', macAddress);
    savedPrinterMac.value = macAddress;
  }

  Future<void> _checkConnectionStatus() async {
    try {
      final status = await PrintBluetoothThermal.connectionStatus;
      isConnected.value = status;
    } catch (e) {
      print('Error checking connection status: $e');
    }
  }

  // List paired Bluetooth printers (without auto-reconnection)
  Future<List<BluetoothInfo>> listBluetoothPrinters() async {
    try {
      // Check Bluetooth permissions first
      final bluetoothService = Get.find<BluetoothPermissionService>();
      final hasPermission = await bluetoothService.checkBluetoothForPrinter();

      if (!hasPermission) {
        Get.snackbar(
          'Permission Required',
          'Bluetooth permissions are needed to scan for printers',
          snackPosition: SnackPosition.BOTTOM,
        );
        return [];
      }

      isScanning.value = true;
      final List<BluetoothInfo> listResult =
          await PrintBluetoothThermal.pairedBluetooths;
      availablePrinters.value = listResult;

      // Just set the saved printer as connectedPrinter if found (don't auto-connect)
      if (savedPrinterMac.value.isNotEmpty) {
        final savedPrinter = listResult.firstWhereOrNull(
          (p) => p.macAdress == savedPrinterMac.value,
        );
        if (savedPrinter != null) {
          connectedPrinter.value = savedPrinter;
          // Check connection status without triggering reconnection
          await connectionStatus();
        }
      }

      return listResult;
    } on Exception catch (e) {
      print('Error listing Bluetooth printers: $e');

      // Check if it's a Bluetooth disabled error
      if (e.toString().contains('bluetooth') ||
          e.toString().contains('Bluetooth')) {
        final bluetoothService = Get.find<BluetoothPermissionService>();
        await bluetoothService.showBluetoothEnableDialog();
      } else {
        Get.snackbar('Error', 'Failed to list printers: $e');
      }
      return [];
    } catch (e) {
      print('Error listing Bluetooth printers: $e');
      Get.snackbar('Error', 'Failed to list printers: $e');
      return [];
    } finally {
      isScanning.value = false;
    }
  }

  // Get connection status
  Future<bool> connectionStatus() async {
    try {
      final bool status = await PrintBluetoothThermal.connectionStatus;
      isConnected.value = status;
      return status;
    } catch (e) {
      print('Error getting connection status: $e');
      return false;
    }
  }

  // Connect to printer with retry logic
  Future<bool> connectPrinter(String macAddress, {bool silent = false}) async {
    try {
      if (!silent) {
        print('Connecting to printer: $macAddress');
      }

      // Disconnect first if already connected to avoid conflicts
      try {
        final currentStatus = await PrintBluetoothThermal.connectionStatus;
        if (currentStatus) {
          await PrintBluetoothThermal.disconnect;
          await Future.delayed(Duration(milliseconds: 500));
        }
      } catch (e) {
        print('Error during disconnect before connect: $e');
      }

      // Attempt connection with timeout
      final bool result =
          await PrintBluetoothThermal.connect(
            macPrinterAddress: macAddress,
          ).timeout(
            Duration(seconds: 10),
            onTimeout: () {
              print('Connection timeout');
              return false;
            },
          );

      if (result) {
        isConnected.value = true;
        connectionAttempts = 0;
        savePrinterMac(macAddress); // Save to storage

        // Find and set connected printer
        final printer = availablePrinters.firstWhereOrNull(
          (p) => p.macAdress == macAddress,
        );
        connectedPrinter.value = printer;

        if (!silent) {
          Get.snackbar(
            'Success',
            'Connected to printer',
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      } else {
        if (!silent) {
          Get.snackbar(
            'Error',
            'Failed to connect to printer',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }

      return result;
    } catch (e) {
      print('Error connecting to printer: $e');
      if (!silent) {
        Get.snackbar(
          'Error',
          'Failed to connect: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return false;
    }
  }

  // Disconnect from printer
  Future<void> disconnectPrinter() async {
    try {
      await PrintBluetoothThermal.disconnect;
      isConnected.value = false;
      connectedPrinter.value = null;
      Get.snackbar('Success', 'Disconnected from printer');
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  // Ensure printer is connected before operation
  Future<bool> ensureConnection({int maxRetries = 3}) async {
    try {
      // Check if we have a saved printer
      if (savedPrinterMac.value.isEmpty) {
        print('No saved printer to connect to');
        return false;
      }

      // Check current connection status
      final status = await connectionStatus();
      if (status) {
        print('Already connected');
        return true;
      }

      // Try to reconnect with retries
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        print('Connection attempt $attempt of $maxRetries');

        final success = await connectPrinter(
          savedPrinterMac.value,
          silent:
              attempt < maxRetries, // Only show notification on last attempt
        );

        if (success) {
          // Verify connection
          await Future.delayed(Duration(milliseconds: 500));
          final verified = await connectionStatus();
          if (verified) {
            print('Connection verified');
            return true;
          }
        }

        // Wait before retry (exponential backoff)
        if (attempt < maxRetries) {
          final waitTime = Duration(milliseconds: 500 * attempt);
          print('Waiting ${waitTime.inMilliseconds}ms before retry...');
          await Future.delayed(waitTime);
        }
      }

      print('Failed to establish connection after $maxRetries attempts');
      return false;
    } catch (e) {
      print('Error ensuring connection: $e');
      return false;
    }
  }

  // Professional printing dialog
  void _showPrintingDialog({
    required String title,
    required String message,
    String? receiptNumber,
  }) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Animated background pattern
                Positioned.fill(
                  child: CustomPaint(painter: _PrintPatternPainter()),
                ),
                // Content
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Printer icon with animation
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 600),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.print_rounded,
                                size: 56,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 24),

                      // Title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),

                      // Receipt number if provided
                      if (receiptNumber != null) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'Receipt #$receiptNumber',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],

                      // Message
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32),

                      // Animated progress indicator
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 800),
                        builder: (context, value, child) {
                          return SizedBox(
                            width: 60,
                            height: 60,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Background circle
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                // Progress indicator
                                CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                                // Center dot
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 24),

                      // Status text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _PulsingDot(),
                          SizedBox(width: 8),
                          Text(
                            'Processing...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
    );
  }

  // Test print
  Future<void> testPrint() async {
    try {
      _showPrintingDialog(
        title: 'Test Print',
        message: 'Sending test print to printer...',
      );

      // Check connection and connect if needed
      bool connected = await connectionStatus();
      if (!connected && savedPrinterMac.value.isNotEmpty) {
        await connectPrinter(savedPrinterMac.value);
      }

      List<int> bytes = await _testTicket();
      await PrintBluetoothThermal.writeBytes(bytes);

      Get.back(); // Close loading dialog
      Get.snackbar('Success', 'Test print completed');
    } catch (e) {
      Get.back(); // Close loading dialog
      print('Error in test print: $e');
      Get.snackbar('Error', 'Test print failed: $e');
    }
  }

  // Generate test ticket
  Future<List<int>> _testTicket() async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    bytes += generator.reset();
    bytes += generator.text(
      'PRINT TEST',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      '-----------------------------',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Date/Time: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      '-----------------------------',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);
    bytes += generator.text('Regular text test');
    bytes += generator.text('Bold text test', styles: PosStyles(bold: true));
    bytes += generator.text(
      'Underlined test',
      styles: PosStyles(underline: true),
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      'Align left',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Align center',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Align right',
      styles: PosStyles(align: PosAlign.right),
    );
    bytes += generator.feed(2);
    bytes += generator.qrcode('Test QR Code');
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  // Print receipt from ReceiptModel
  Future<void> printReceipt(ReceiptModel receipt) async {
    try {
      _showPrintingDialog(
        title: 'Printing Receipt',
        message: 'Please wait while we print your receipt...',
        receiptNumber: receipt.receiptNumber,
      );

      // Check connection and connect if needed
      bool connected = await connectionStatus();
      if (!connected && savedPrinterMac.value.isNotEmpty) {
        await connectPrinter(savedPrinterMac.value);
      }

      List<int> bytes = await _generateReceipt(receipt);
      await PrintBluetoothThermal.writeBytes(bytes);

      Get.back(); // Close loading dialog
      Get.snackbar('Success', 'Receipt printed successfully');
    } catch (e) {
      Get.back(); // Close loading dialog
      print('Error printing receipt: $e');
      Get.snackbar('Error', 'Failed to print receipt: $e');
    }
  }

  // Generate receipt bytes
  Future<List<int>> _generateReceipt(ReceiptModel receipt) async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    // Get business settings for store name
    final businessSettings = Get.find<BusinessSettingsController>();

    bytes += generator.reset();

    // Store header - Use store name from business settings
    bytes += generator.text(
      businessSettings.storeName.value.toUpperCase(),
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      businessSettings.storeAddress.value,
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Phone: ${businessSettings.storePhone.value}',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(1);

    // Receipt title
    bytes += generator.text(
      '******************************************',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'CASH RECEIPT',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      '******************************************',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(1);

    // Receipt info
    bytes += generator.text(
      'Receipt #: ${receipt.receiptNumber}',
      styles: PosStyles(),
    );
    bytes += generator.text(
      'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(receipt.timestamp)}',
      styles: PosStyles(),
    );
    bytes += generator.text(
      'Cashier: ${receipt.cashierName}',
      styles: PosStyles(),
    );
    if (receipt.customerName != null) {
      bytes += generator.text(
        'Customer: ${receipt.customerName}',
        styles: PosStyles(),
      );
    }
    bytes += generator.feed(1);

    // Column headers
    bytes += generator.row([
      PosColumn(
        text: 'Item',
        width: 6,
        styles: PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(
        text: 'Qty',
        width: 2,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
      PosColumn(
        text: 'Price',
        width: 4,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    bytes += generator.text('-----------------------------');

    // Items
    for (var item in receipt.items) {
      bytes += generator.row([
        PosColumn(
          text: item.name,
          width: 6,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '${item.quantity}',
          width: 2,
          styles: PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: CurrencyFormatter.format(item.total),
          width: 4,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.text('-----------------------------');
    bytes += generator.feed(1);

    // Totals
    bytes += generator.row([
      PosColumn(
        text: 'Subtotal:',
        width: 6,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: CurrencyFormatter.format(receipt.subtotal),
        width: 6,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Tax:',
        width: 6,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: CurrencyFormatter.format(receipt.tax),
        width: 6,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    if (receipt.discount > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'Discount:',
          width: 6,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '-${CurrencyFormatter.format(receipt.discount)}',
          width: 6,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.text('-----------------------------');

    bytes += generator.row([
      PosColumn(
        text: 'TOTAL:',
        width: 6,
        styles: PosStyles(
          align: PosAlign.left,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
      PosColumn(
        text: CurrencyFormatter.format(receipt.total),
        width: 6,
        styles: PosStyles(
          align: PosAlign.right,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    ]);

    bytes += generator.feed(1);

    // Payment details
    bytes += generator.row([
      PosColumn(
        text: 'Cash:',
        width: 6,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: CurrencyFormatter.format(receipt.amountPaid),
        width: 6,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Change:',
        width: 6,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: CurrencyFormatter.format(receipt.change),
        width: 6,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Payment:',
        width: 6,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: receipt.paymentMethod.toUpperCase(),
        width: 6,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.text('-----------------------------');
    bytes += generator.feed(1);

    // Footer
    bytes += generator.text(
      'THANK YOU!',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.feed(1);

    // QR Code with transaction ID
    bytes += generator.qrcode(receipt.transactionId);
    bytes += generator.feed(2);

    bytes += generator.text(
      'Powered by Dynamos POS',
      styles: PosStyles(align: PosAlign.center, fontType: PosFontType.fontB),
    );

    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }
}

// Custom painter for background pattern
class _PrintPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw printer-like pattern
    final spacing = 20.0;
    for (double i = 0; i < size.height; i += spacing) {
      // Horizontal lines
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Draw diagonal lines
    for (double i = -size.height; i < size.width; i += spacing * 2) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint..color = Colors.white.withOpacity(0.03),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Pulsing dot animation widget
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(_animation.value),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(_animation.value * 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}
