import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:io' show Platform;
import '../models/receipt_model.dart';
import '../utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class PrinterService extends GetxController {
  var connectedPrinter = Rx<BluetoothDevice?>(null);
  var isConnected = false.obs;
  var isScanning = false.obs;
  var availablePrinters = <BluetoothDevice>[].obs;

  BluetoothCharacteristic? _writeCharacteristic;

  // ESC/POS Commands
  static const ESC = 0x1B;
  static const GS = 0x1D;

  // Initialize
  static const INIT = [ESC, 0x40];

  // Text alignment
  static const ALIGN_LEFT = [ESC, 0x61, 0x00];
  static const ALIGN_CENTER = [ESC, 0x61, 0x01];
  static const ALIGN_RIGHT = [ESC, 0x61, 0x02];

  // Text size
  static const NORMAL = [ESC, 0x21, 0x00];
  static const DOUBLE_HEIGHT = [ESC, 0x21, 0x10];
  static const DOUBLE_WIDTH = [ESC, 0x21, 0x20];
  static const DOUBLE_SIZE = [ESC, 0x21, 0x30];

  // Text style
  static const BOLD_ON = [ESC, 0x45, 0x01];
  static const BOLD_OFF = [ESC, 0x45, 0x00];
  static const UNDERLINE_ON = [ESC, 0x2D, 0x01];
  static const UNDERLINE_OFF = [ESC, 0x2D, 0x00];

  // Feed
  static const LINE_FEED = [0x0A];
  static const CUT_PAPER = [GS, 0x56, 0x00];

  @override
  void onInit() {
    super.onInit();
    _checkBluetoothState();
  }

  Future<void> _checkBluetoothState() async {
    try {
      // isAvailable deprecated -> use isSupported
      final supported = await FlutterBluePlus.isSupported;
      if (!supported) {
        Get.snackbar('Bluetooth', 'Bluetooth not supported on this device');
      }
    } catch (e) {
      print('Bluetooth check error: $e');
    }
  }

  Future<void> scanForPrinters() async {
    try {
      isScanning.value = true;
      availablePrinters.clear();

      // Check if Bluetooth is on
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        Get.snackbar('Bluetooth', 'Please turn on Bluetooth');
        isScanning.value = false;
        return;
      }

      // Start scanning
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));

      // Listen to scan results
      FlutterBluePlus.scanResults.listen((results) {
        for (var result in results) {
          if (result.device.platformName.isNotEmpty &&
              !availablePrinters.any(
                (d) => d.remoteId == result.device.remoteId,
              )) {
            availablePrinters.add(result.device);
          }
        }
      });

      await Future.delayed(Duration(seconds: 10));
      await FlutterBluePlus.stopScan();

      isScanning.value = false;

      if (availablePrinters.isEmpty) {
        Get.snackbar('No Printers', 'No Bluetooth printers found');
      }
    } catch (e) {
      isScanning.value = false;
      Get.snackbar('Scan Error', 'Failed to scan: $e');
    }
  }

  Future<bool> connectToPrinter(BluetoothDevice device) async {
    try {
      await device.connect(timeout: Duration(seconds: 10));

      // Discover services
      List<BluetoothService> services = await device.discoverServices();

      // Find write characteristic (common UUID for printers)
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            _writeCharacteristic = characteristic;
            break;
          }
        }
        if (_writeCharacteristic != null) break;
      }

      if (_writeCharacteristic == null) {
        await device.disconnect();
        Get.snackbar('Connection Failed', 'No write characteristic found');
        return false;
      }

      connectedPrinter.value = device;
      isConnected.value = true;

      Get.snackbar('Connected', 'Printer connected successfully');
      return true;
    } catch (e) {
      Get.snackbar('Connection Error', 'Failed to connect: $e');
      return false;
    }
  }

  Future<void> disconnectPrinter() async {
    try {
      if (connectedPrinter.value != null) {
        await connectedPrinter.value!.disconnect();
        connectedPrinter.value = null;
        _writeCharacteristic = null;
        isConnected.value = false;
        Get.snackbar('Disconnected', 'Printer disconnected');
      }
    } catch (e) {
      Get.snackbar('Disconnect Error', 'Failed to disconnect: $e');
    }
  }

  Future<void> printReceipt(ReceiptModel receipt) async {
    if (!isConnected.value || _writeCharacteristic == null) {
      Get.snackbar('Print Error', 'No printer connected');
      return;
    }

    try {
      List<int> bytes = [];

      // Initialize
      bytes.addAll(INIT);

      // Store header
      bytes.addAll(ALIGN_CENTER);
      bytes.addAll(DOUBLE_SIZE);
      bytes.addAll(BOLD_ON);
      bytes.addAll(_encodeText(receipt.storeName));
      bytes.addAll(LINE_FEED);

      bytes.addAll(NORMAL);
      bytes.addAll(BOLD_OFF);
      bytes.addAll(_encodeText(receipt.storeAddress));
      bytes.addAll(LINE_FEED);
      bytes.addAll(_encodeText(receipt.storePhone));
      bytes.addAll(LINE_FEED);
      bytes.addAll(LINE_FEED);

      // Receipt info
      bytes.addAll(ALIGN_LEFT);
      bytes.addAll(_encodeText('Receipt: ${receipt.receiptNumber}'));
      bytes.addAll(LINE_FEED);
      bytes.addAll(
        _encodeText(
          'Date: ${DateFormat('MMM dd, yyyy HH:mm').format(receipt.timestamp)}',
        ),
      );
      bytes.addAll(LINE_FEED);
      bytes.addAll(_encodeText('Cashier: ${receipt.cashierName}'));
      bytes.addAll(LINE_FEED);

      if (receipt.customerName != null) {
        bytes.addAll(_encodeText('Customer: ${receipt.customerName}'));
        bytes.addAll(LINE_FEED);
      }

      bytes.addAll(LINE_FEED);
      bytes.addAll(_encodeText('${'=' * 32}'));
      bytes.addAll(LINE_FEED);

      // Items
      for (var item in receipt.items) {
        String line = '${item.name}';
        bytes.addAll(_encodeText(line));
        bytes.addAll(LINE_FEED);

        String details =
            ' ${item.quantity}x ${CurrencyFormatter.format(item.price)}'
                .padRight(20) +
            CurrencyFormatter.format(item.total).padLeft(12);
        bytes.addAll(_encodeText(details));
        bytes.addAll(LINE_FEED);
      }

      bytes.addAll(LINE_FEED);
      bytes.addAll(_encodeText('${'=' * 32}'));
      bytes.addAll(LINE_FEED);

      // Totals
      bytes.addAll(
        _encodeText(
          _formatLine('Subtotal:', CurrencyFormatter.format(receipt.subtotal)),
        ),
      );
      bytes.addAll(LINE_FEED);
      bytes.addAll(
        _encodeText(_formatLine('Tax:', CurrencyFormatter.format(receipt.tax))),
      );
      bytes.addAll(LINE_FEED);

      if (receipt.discount > 0) {
        bytes.addAll(
          _encodeText(
            _formatLine(
              'Discount:',
              '-${CurrencyFormatter.format(receipt.discount)}',
            ),
          ),
        );
        bytes.addAll(LINE_FEED);
      }

      bytes.addAll(LINE_FEED);
      bytes.addAll(BOLD_ON);
      bytes.addAll(DOUBLE_HEIGHT);
      bytes.addAll(
        _encodeText(
          _formatLine('TOTAL:', CurrencyFormatter.format(receipt.total)),
        ),
      );
      bytes.addAll(LINE_FEED);
      bytes.addAll(NORMAL);
      bytes.addAll(BOLD_OFF);
      bytes.addAll(LINE_FEED);

      // Payment info
      bytes.addAll(
        _encodeText(
          _formatLine('Payment:', receipt.paymentMethod.toUpperCase()),
        ),
      );
      bytes.addAll(LINE_FEED);
      bytes.addAll(
        _encodeText(
          _formatLine(
            'Amount Paid:',
            CurrencyFormatter.format(receipt.amountPaid),
          ),
        ),
      );
      bytes.addAll(LINE_FEED);
      bytes.addAll(
        _encodeText(
          _formatLine('Change:', CurrencyFormatter.format(receipt.change)),
        ),
      );
      bytes.addAll(LINE_FEED);
      bytes.addAll(LINE_FEED);

      // Footer
      bytes.addAll(ALIGN_CENTER);
      bytes.addAll(_encodeText('Thank you for your purchase!'));
      bytes.addAll(LINE_FEED);
      bytes.addAll(_encodeText('Please come again'));
      bytes.addAll(LINE_FEED);
      bytes.addAll(LINE_FEED);
      bytes.addAll(LINE_FEED);

      // Cut paper
      bytes.addAll(CUT_PAPER);

      // Write to printer in chunks
      const chunkSize = 20;
      for (var i = 0; i < bytes.length; i += chunkSize) {
        final end = (i + chunkSize < bytes.length)
            ? i + chunkSize
            : bytes.length;
        await _writeCharacteristic!.write(
          bytes.sublist(i, end),
          withoutResponse: false,
        );
        await Future.delayed(Duration(milliseconds: 50));
      }

      Get.snackbar('Success', 'Receipt printed successfully');
    } catch (e) {
      Get.snackbar('Print Error', 'Failed to print: $e');
    }
  }

  List<int> _encodeText(String text) {
    return text.codeUnits;
  }

  String _formatLine(String label, String value) {
    const width = 32;
    final spaces = width - label.length - value.length;
    return label + (' ' * spaces) + value;
  }

  Future<void> testPrint() async {
    if (!isConnected.value || _writeCharacteristic == null) {
      Get.snackbar('Print Error', 'No printer connected');
      return;
    }

    try {
      List<int> bytes = [];
      bytes.addAll(INIT);
      bytes.addAll(ALIGN_CENTER);
      bytes.addAll(DOUBLE_SIZE);
      bytes.addAll(BOLD_ON);
      bytes.addAll(_encodeText('TEST PRINT'));
      bytes.addAll(LINE_FEED);
      bytes.addAll(NORMAL);
      bytes.addAll(BOLD_OFF);
      bytes.addAll(_encodeText('Printer is working correctly'));
      bytes.addAll(LINE_FEED);
      bytes.addAll(LINE_FEED);
      bytes.addAll(LINE_FEED);
      bytes.addAll(CUT_PAPER);

      await _writeCharacteristic!.write(bytes, withoutResponse: false);

      Get.snackbar('Success', 'Test print successful');
    } catch (e) {
      Get.snackbar('Print Error', 'Test print failed: $e');
    }
  }
}
