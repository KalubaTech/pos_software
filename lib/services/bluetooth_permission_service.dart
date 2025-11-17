import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class BluetoothPermissionService extends GetxController {
  var isBluetoothEnabled = false.obs;
  var hasBluetoothPermission = false.obs;

  /// Check if Bluetooth is available on this platform
  bool get isBluetoothSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Check Bluetooth permissions (Android 12+)
  Future<bool> checkBluetoothPermissions() async {
    if (!isBluetoothSupported) return true;

    try {
      if (Platform.isAndroid) {
        // Android 12+ requires BLUETOOTH_SCAN and BLUETOOTH_CONNECT
        final bluetoothScan = await Permission.bluetoothScan.status;
        final bluetoothConnect = await Permission.bluetoothConnect.status;

        hasBluetoothPermission.value =
            bluetoothScan.isGranted && bluetoothConnect.isGranted;

        return hasBluetoothPermission.value;
      } else if (Platform.isIOS) {
        final bluetooth = await Permission.bluetooth.status;
        hasBluetoothPermission.value = bluetooth.isGranted;
        return hasBluetoothPermission.value;
      }
    } catch (e) {
      print('Error checking Bluetooth permissions: $e');
    }

    return false;
  }

  /// Request Bluetooth permissions
  Future<bool> requestBluetoothPermissions() async {
    if (!isBluetoothSupported) return true;

    try {
      if (Platform.isAndroid) {
        // Request both BLUETOOTH_SCAN and BLUETOOTH_CONNECT
        final Map<Permission, PermissionStatus> statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
        ].request();

        final allGranted = statuses.values.every((status) => status.isGranted);
        hasBluetoothPermission.value = allGranted;

        if (!allGranted) {
          // Check if any permission is permanently denied
          final anyPermanentlyDenied = statuses.values.any(
            (status) => status.isPermanentlyDenied,
          );

          if (anyPermanentlyDenied) {
            _showPermissionSettingsDialog();
          }
        }

        return allGranted;
      } else if (Platform.isIOS) {
        final status = await Permission.bluetooth.request();
        hasBluetoothPermission.value = status.isGranted;

        if (status.isPermanentlyDenied) {
          _showPermissionSettingsDialog();
        }

        return status.isGranted;
      }
    } catch (e) {
      print('Error requesting Bluetooth permissions: $e');
      Get.snackbar(
        'Permission Error',
        'Failed to request Bluetooth permissions',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    return false;
  }

  /// Prompt user to enable Bluetooth if it's off
  Future<bool> ensureBluetoothEnabled() async {
    if (!isBluetoothSupported) return true;

    // First check permissions
    final hasPermission = await checkBluetoothPermissions();
    if (!hasPermission) {
      final granted = await requestBluetoothPermissions();
      if (!granted) {
        return false;
      }
    }

    // Check if Bluetooth is enabled
    // Note: There's no standard way to check Bluetooth state in Flutter
    // This is typically handled by the Bluetooth plugin you're using
    // For now, we'll show a dialog if connection fails

    return true;
  }

  /// Show dialog prompting user to turn on Bluetooth
  Future<void> showBluetoothEnableDialog() async {
    return Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.bluetooth_disabled, color: Colors.orange),
            SizedBox(width: 12),
            Text('Bluetooth is Off'),
          ],
        ),
        content: Text(
          'This feature requires Bluetooth to be enabled. Please turn on Bluetooth in your device settings.',
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

  /// Show dialog to open app settings for permissions
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
          'Bluetooth permissions are required for this feature. Please enable them in app settings.',
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

  /// Check and request Bluetooth permissions before using printer
  Future<bool> checkBluetoothForPrinter() async {
    if (!isBluetoothSupported) return true;

    try {
      // Check permissions first
      final hasPermission = await checkBluetoothPermissions();
      if (!hasPermission) {
        final granted = await requestBluetoothPermissions();
        if (!granted) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Error checking Bluetooth for printer: $e');
      return false;
    }
  }
}
