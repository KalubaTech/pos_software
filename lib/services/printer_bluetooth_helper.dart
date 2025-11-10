import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class PrinterBluetoothHelper {
  Future<List<BluetoothInfo>> listBluetooths() async {
    final List<BluetoothInfo> listResult =
        await PrintBluetoothThermal.pairedBluetooths;
    await Future.forEach(listResult, (BluetoothInfo bluetooth) {
      String name = bluetooth.name;
      String mac = bluetooth.macAdress;
      print('Bluetooth device: $name - $mac');
    });

    return listResult;
  }

  Future<bool> connectionStatus() async {
    final bool status = await PrintBluetoothThermal.connectionStatus;
    return status;
  }

  Future<bool> connectPrinter(String macAddress) async {
    try {
      print('Connecting to printer with MAC: $macAddress');
      print(
        'Current connection status: ${await PrintBluetoothThermal.connectionStatus}',
      );
      print('Paired devices: ${await PrintBluetoothThermal.pairedBluetooths}');

      final bool result = await PrintBluetoothThermal.connect(
        macPrinterAddress: macAddress,
      );

      if (result) {
        print('Successfully connected to printer');
      } else {
        print('Failed to connect to printer');
      }

      return result;
    } catch (e) {
      print('Error connecting to printer: $e');
      return false;
    }
  }

  Future<void> disconnectPrinter() async {
    try {
      await PrintBluetoothThermal.disconnect;
      print('Disconnected from printer');
    } catch (e) {
      print('Error disconnecting from printer: $e');
    }
  }

  Future<void> testPrint() async {
    Get.dialog(
      Container(child: Center(child: CircularProgressIndicator())),
      barrierColor: Colors.grey.withValues(alpha: 0.3),
    );

    try {
      print('Connecting to printer for test...');

      print('Connected to printer');
      await PrintBluetoothThermal.writeBytes(
        '\n\n PRINT TEST \n -----------------------------\n\n'.codeUnits,
      );
      await PrintBluetoothThermal.writeBytes(
        'Date / Time: ${DateTime.now()}\n-----------------------------\n\n\n\n'
            .codeUnits,
      );

      await PrintBluetoothThermal.disconnect;
      Get.back();

      Get.snackbar(
        'Success',
        'Test print completed successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Test print failed: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<List<int>> testTicket() async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    bytes += generator.reset();

    bytes += generator.text(
      'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ',
      styles: PosStyles(),
    );
    bytes += generator.text(
      'Special 1: ñÑ àÀ èÈ éÉ üÜ çÇ ôÔ',
      styles: PosStyles(codeTable: 'CP1252'),
    );
    bytes += generator.text(
      'Special 2: blåbærgrød',
      styles: PosStyles(codeTable: 'CP1252'),
    );

    bytes += generator.text('Bold text', styles: PosStyles(bold: true));
    bytes += generator.text('Reverse text', styles: PosStyles(reverse: true));
    bytes += generator.text(
      'Underlined text',
      styles: PosStyles(underline: true),
      linesAfter: 1,
    );
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
      linesAfter: 1,
    );

    bytes += generator.row([
      PosColumn(
        text: 'col3',
        width: 3,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col6',
        width: 6,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col3',
        width: 3,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
    ]);

    // Barcode
    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));

    // QR code
    bytes += generator.qrcode('example.com');

    bytes += generator.text(
      'Text size 50%',
      styles: PosStyles(fontType: PosFontType.fontB),
    );
    bytes += generator.text(
      'Text size 100%',
      styles: PosStyles(fontType: PosFontType.fontA),
    );
    bytes += generator.text(
      'Text size 200%',
      styles: PosStyles(height: PosTextSize.size2, width: PosTextSize.size2),
    );

    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }
}
