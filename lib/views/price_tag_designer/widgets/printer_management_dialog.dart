import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../../controllers/printer_controller.dart';
import '../../../controllers/appearance_controller.dart';
import '../../../models/printer_model.dart';
import '../../../services/printer_bluetooth_helper.dart';
import '../../../utils/colors.dart';

class PrinterManagementDialog extends StatelessWidget {
  const PrinterManagementDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PrinterController>();

    return Dialog(
      child: Container(
        width: 700,
        height: 600,
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.printer, color: AppColors.primary, size: 28),
                SizedBox(width: 12),
                Text(
                  'Printer Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Iconsax.close_circle),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Configure your printers for printing price tags',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddPrinterDialog(context, controller),
                  icon: Icon(Iconsax.add, size: 18),
                  label: Text('Add Printer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.printers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.printer,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No printers configured',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add a printer to start printing',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.printers.length,
                  itemBuilder: (context, index) {
                    final printer = controller.printers[index];
                    return _buildPrinterCard(context, controller, printer);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrinterCard(
    BuildContext context,
    PrinterController controller,
    PrinterModel printer,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: printer.isDefault ? Colors.green[100] : Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Iconsax.printer,
            color: printer.isDefault ? Colors.green[700] : Colors.blue[700],
          ),
        ),
        title: Row(
          children: [
            Text(
              printer.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (printer.isDefault) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'DEFAULT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('Type: ${_getPrinterTypeName(printer.type)}'),
            Text(
              'Connection: ${_getConnectionTypeName(printer.connectionType)}',
            ),
            if (printer.address != null) Text('Address: ${printer.address}'),
            Text('Paper: ${printer.paperWidth}mm'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Iconsax.more),
          onSelected: (value) {
            switch (value) {
              case 'default':
                controller.setDefaultPrinter(printer.id);
                break;
              case 'edit':
                _showEditPrinterDialog(context, controller, printer);
                break;
              case 'delete':
                _showDeleteConfirmation(context, controller, printer);
                break;
            }
          },
          itemBuilder: (context) => [
            if (!printer.isDefault)
              PopupMenuItem(
                value: 'default',
                child: Row(
                  children: [
                    Icon(Iconsax.tick_circle, size: 18),
                    SizedBox(width: 12),
                    Text('Set as Default'),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Iconsax.edit, size: 18),
                  SizedBox(width: 12),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Iconsax.trash, size: 18, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPrinterDialog(
    BuildContext context,
    PrinterController controller,
  ) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final portController = TextEditingController(text: '9100');
    var selectedType = PrinterType.thermal;
    var selectedConnection = ConnectionType.usb;
    var selectedPaperWidth = 80;
    var setAsDefault = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Iconsax.add_circle, color: AppColors.primary),
                SizedBox(width: 12),
                Text('Add Printer'),
              ],
            ),
            content: Container(
              width: 450,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Printer Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Iconsax.printer),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<PrinterType>(
                      value: selectedType,
                      decoration: InputDecoration(
                        labelText: 'Printer Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Iconsax.category),
                      ),
                      items: PrinterType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getPrinterTypeName(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedType = value);
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<ConnectionType>(
                      value: selectedConnection,
                      decoration: InputDecoration(
                        labelText: 'Connection Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Iconsax.link),
                      ),
                      items: ConnectionType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getConnectionTypeName(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedConnection = value);
                        }
                      },
                    ),
                    if (selectedConnection == ConnectionType.network) ...[
                      SizedBox(height: 16),
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: 'IP Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Iconsax.global),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: portController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Port',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Iconsax.link_1),
                        ),
                      ),
                    ],
                    if (selectedConnection == ConnectionType.bluetooth) ...[
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: addressController,
                              decoration: InputDecoration(
                                labelText: 'Bluetooth Address',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Iconsax.bluetooth),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _showBluetoothScanDialog(
                              context,
                              addressController,
                              nameController,
                            ),
                            icon: Icon(Iconsax.scan, size: 16),
                            label: Text('Scan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedPaperWidth,
                      decoration: InputDecoration(
                        labelText: 'Paper Width',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Iconsax.maximize_4),
                      ),
                      items: [58, 80].map((width) {
                        return DropdownMenuItem(
                          value: width,
                          child: Text('${width}mm'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedPaperWidth = value);
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    CheckboxListTile(
                      title: Text('Set as default printer'),
                      value: setAsDefault,
                      onChanged: (value) {
                        setState(() => setAsDefault = value ?? false);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Please enter a printer name');
                    return;
                  }

                  await controller.addPrinter(
                    name: nameController.text.trim(),
                    type: selectedType,
                    connectionType: selectedConnection,
                    address: addressController.text.trim().isEmpty
                        ? null
                        : addressController.text.trim(),
                    port: portController.text.trim().isEmpty
                        ? null
                        : int.tryParse(portController.text),
                    paperWidth: selectedPaperWidth,
                    setAsDefault: setAsDefault,
                  );

                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text('Add Printer'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditPrinterDialog(
    BuildContext context,
    PrinterController controller,
    PrinterModel printer,
  ) {
    // Similar to add dialog but with pre-filled values
    Get.snackbar('Info', 'Edit functionality will be implemented');
  }

  void _showDeleteConfirmation(
    BuildContext context,
    PrinterController controller,
    PrinterModel printer,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Printer'),
        content: Text('Are you sure you want to delete "${printer.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              controller.deletePrinter(printer.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBluetoothScanDialog(
    BuildContext context,
    TextEditingController addressController,
    TextEditingController nameController,
  ) {
    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          bool isScanning = true; // Start scanning immediately
          List<BluetoothInfo> devices = [];

          Future<void> scanDevices() async {
            setState(() {
              isScanning = true;
              devices = [];
            });

            try {
              final helper = PrinterBluetoothHelper();
              final scannedDevices = await helper.listBluetooths();
              setState(() {
                devices = scannedDevices;
                isScanning = false;
              });
            } catch (e) {
              setState(() => isScanning = false);
              Get.snackbar(
                'Scan Error',
                'Failed to scan Bluetooth devices: $e',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          }

          // Trigger scan automatically when dialog opens
          Future.delayed(Duration.zero, () => scanDevices());

          return AlertDialog(
            title: Row(
              children: [
                Icon(Iconsax.bluetooth, color: AppColors.primary),
                SizedBox(width: 12),
                Text('Scan for Bluetooth Printers'),
              ],
            ),
            content: Container(
              width: 500,
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Available paired Bluetooth devices',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: isScanning ? null : scanDevices,
                        icon: Icon(Iconsax.scan, size: 16),
                        label: Text('Scan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),
                  Expanded(
                    child: isScanning
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Scanning for devices...'),
                              ],
                            ),
                          )
                        : devices.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.bluetooth,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No devices found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Click Scan to find paired printers',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: devices.length,
                            itemBuilder: (context, index) {
                              final device = devices[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Icon(
                                    Iconsax.bluetooth,
                                    color: AppColors.primary,
                                  ),
                                  title: Text(
                                    device.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    device.macAdress,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      addressController.text = device.macAdress;
                                      if (device.name.isNotEmpty) {
                                        nameController.text = device.name;
                                      }
                                      Get.back();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text('Select'),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: Text('Close')),
            ],
          );
        },
      ),
    );
  }

  String _getPrinterTypeName(PrinterType type) {
    switch (type) {
      case PrinterType.thermal:
        return 'Thermal';
      case PrinterType.inkjet:
        return 'Inkjet';
      case PrinterType.laser:
        return 'Laser';
    }
  }

  String _getConnectionTypeName(ConnectionType type) {
    switch (type) {
      case ConnectionType.usb:
        return 'USB';
      case ConnectionType.network:
        return 'Network (WiFi/Ethernet)';
      case ConnectionType.bluetooth:
        return 'Bluetooth';
    }
  }
}
