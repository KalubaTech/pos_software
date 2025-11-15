import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import '../../utils/colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/business_settings_controller.dart';
import '../../controllers/appearance_controller.dart';
import '../../services/printer_service.dart';
import '../../services/printer_bluetooth_helper.dart';
import '../../models/cashier_model.dart';
import 'business_settings_view.dart';
import 'appearance_settings_view.dart';
import 'sync_settings_view.dart';
import 'subscription_view.dart';

class EnhancedSettingsView extends StatefulWidget {
  const EnhancedSettingsView({super.key});

  @override
  State<EnhancedSettingsView> createState() => _EnhancedSettingsViewState();
}

class _EnhancedSettingsViewState extends State<EnhancedSettingsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final appearanceController = Get.find<AppearanceController>();

    return Obx(() {
      final isDark = appearanceController.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
        body: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSystemSettings(authController, isDark),
                  BusinessSettingsView(),
                  AppearanceSettingsView(),
                  SubscriptionView(),
                  SyncSettingsView(),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Manage your POS system configuration',
            style: TextStyle(
              color: AppColors.getTextSecondary(isDark),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 24),
          TabBar(
            controller: _tabController,
            labelColor: isDark ? AppColors.darkPrimary : AppColors.primary,
            unselectedLabelColor: AppColors.getTextSecondary(isDark),
            indicatorColor: isDark ? AppColors.darkPrimary : AppColors.primary,
            tabs: [
              Tab(icon: Icon(Iconsax.setting_2), text: 'System'),
              Tab(icon: Icon(Iconsax.shop), text: 'Business'),
              Tab(icon: Icon(Iconsax.brush_2), text: 'Appearance'),
              Tab(icon: Icon(Iconsax.crown_1), text: 'Subscription'),
              Tab(icon: Icon(Iconsax.cloud), text: 'Sync'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSettings(AuthController authController, bool isDark) {
    PrinterService? printerService;

    // Try to get PrinterService if available
    try {
      printerService = Get.find<PrinterService>();
    } catch (e) {
      printerService = null;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Printer Configuration - always show
          FadeInUp(
            duration: Duration(milliseconds: 400),
            child: printerService != null
                ? _buildPrinterSection(printerService, isDark)
                : _buildPrinterUnavailableSection(isDark),
          ),
          SizedBox(height: 24),

          // Cashier Management (Admin only)
          Obx(() {
            if (authController.hasPermission(UserRole.admin)) {
              return FadeInUp(
                duration: Duration(milliseconds: 500),
                child: _buildCashierSection(authController, isDark),
              );
            }
            return SizedBox();
          }),
        ],
      ),
    );
  }

  Widget _buildPrinterSection(PrinterService printerService, bool isDark) {
    return _buildSectionCard(
      title: 'Printer Configuration',
      icon: Iconsax.printer,
      iconColor: Colors.blue,
      isDark: isDark,
      children: [
        Obx(() {
          final isConnected = printerService.isConnected.value;
          final connectedDevice = printerService.connectedPrinter.value;

          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isConnected
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isConnected
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isConnected ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isConnected ? Iconsax.tick_circle : Iconsax.warning_2,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isConnected
                                ? 'Printer Connected'
                                : 'No Printer Connected',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (isConnected && connectedDevice != null) ...[
                            SizedBox(height: 4),
                            Text(
                              connectedDevice.name,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Get.dialog(
                          Dialog(
                            child: _buildPrinterScanDialog(printerService),
                          ),
                        );
                      },
                      icon: Icon(Iconsax.search_normal, size: 18),
                      label: Text('Scan for Printers'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  if (isConnected)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          if (printerService.connectedPrinter.value != null) {
                            await printerService.disconnectPrinter();
                            printerService.connectedPrinter.value = null;
                            printerService.isConnected.value = false;
                          }
                        },
                        icon: Icon(Iconsax.close_circle, size: 18),
                        label: Text('Disconnect'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.red),
                          foregroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPrinterUnavailableSection(bool isDark) {
    final businessController = Get.find<BusinessSettingsController>();

    return _buildSectionCard(
      title: 'Printer Configuration',
      icon: Iconsax.printer,
      iconColor: Colors.blue,
      isDark: isDark,
      children: [
        Obx(() {
          final hasPrinter =
              businessController.receiptPrinterName.value.isNotEmpty;

          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: hasPrinter
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasPrinter
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: hasPrinter ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        hasPrinter ? Iconsax.tick_circle : Iconsax.warning_2,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasPrinter
                                ? 'Printer Configured'
                                : 'No Printer Configured',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (hasPrinter) ...[
                            SizedBox(height: 4),
                            Text(
                              businessController.receiptPrinterName.value,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${businessController.receiptPrinterType.value} Connection',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showManualPrinterDialog(businessController),
                  icon: Icon(Iconsax.setting_2, size: 18),
                  label: Text(hasPrinter ? 'Configure Printer' : 'Add Printer'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.info_circle, color: Colors.blue, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Configure your receipt printer here. For mobile Bluetooth scanning, use an Android or iOS device.',
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  void _showManualPrinterDialog(BusinessSettingsController controller) {
    final nameController = TextEditingController(
      text: controller.receiptPrinterName.value,
    );
    final addressController = TextEditingController(
      text: controller.receiptPrinterAddress.value,
    );
    final portController = TextEditingController(
      text: controller.receiptPrinterPort.value,
    );
    String selectedType = controller.receiptPrinterType.value;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: 500,
              padding: EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Iconsax.printer, color: Colors.blue),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Configure Printer',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Printer Name',
                        hintText: 'e.g., Main Counter Printer',
                        prefixIcon: Icon(Iconsax.printer),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: InputDecoration(
                        labelText: 'Connection Type',
                        prefixIcon: Icon(Iconsax.link),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: ['USB', 'Network', 'Bluetooth']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedType = value);
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    if (selectedType == 'Network') ...[
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: 'IP Address',
                          hintText: 'e.g., 192.168.1.100',
                          prefixIcon: Icon(Iconsax.global),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: portController,
                        decoration: InputDecoration(
                          labelText: 'Port',
                          hintText: 'e.g., 9100',
                          prefixIcon: Icon(Iconsax.link_21),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (selectedType == 'Bluetooth') ...[
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: 'Bluetooth Address',
                          hintText: 'e.g., 00:11:22:33:44:55',
                          prefixIcon: Icon(Iconsax.bluetooth),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        readOnly: true,
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showBluetoothScanDialog(
                              nameController,
                              addressController,
                              setState,
                            );
                          },
                          icon: Icon(Iconsax.search_normal, size: 18),
                          label: Text('Scan for Bluetooth Printers'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: 'Device Path (Optional)',
                          hintText: 'e.g., COM3 or /dev/usb/lp0',
                          prefixIcon: Icon(Iconsax.link),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text('Cancel'),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            controller.receiptPrinterName.value =
                                nameController.text;
                            controller.receiptPrinterType.value = selectedType;
                            controller.receiptPrinterAddress.value =
                                addressController.text;
                            controller.receiptPrinterPort.value =
                                portController.text;
                            controller.saveSettings();
                            Get.back();
                            Get.snackbar(
                              'Success',
                              'Printer configured successfully',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          },
                          icon: Icon(Iconsax.tick_circle, size: 18),
                          label: Text('Save Configuration'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showBluetoothScanDialog(
    TextEditingController nameController,
    TextEditingController addressController,
    StateSetter parentSetState,
  ) {
    final printerHelper = PrinterBluetoothHelper();
    final isScanning = false.obs;
    final devices = <dynamic>[].obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Iconsax.bluetooth, color: Colors.blue, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Scan Bluetooth Printers',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Obx(() {
                if (isScanning.value) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Scanning for Bluetooth printers...'),
                          SizedBox(height: 8),
                          Text(
                            'Make sure printer is powered on and in pairing mode',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (devices.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Iconsax.search_status,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No printers found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Click "Scan" to search for nearby Bluetooth printers',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Container(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Iconsax.printer, color: Colors.blue),
                          ),
                          title: Text(
                            device.name,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(device.macAdress),
                          trailing: ElevatedButton(
                            onPressed: () {
                              // Fill in the name and address
                              if (nameController.text.isEmpty) {
                                nameController.text = device.name;
                              }
                              addressController.text = device.macAdress;

                              // Update parent dialog
                              parentSetState(() {});

                              // Close scan dialog
                              Get.back();

                              Get.snackbar(
                                'Selected',
                                'Printer selected: ${device.name}',
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Select'),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      isScanning.value = true;
                      try {
                        final result = await printerHelper.listBluetooths();
                        devices.value = result;

                        if (result.isEmpty) {
                          Get.snackbar(
                            'No Devices',
                            'No Bluetooth printers found. Make sure your printer is paired.',
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                          );
                        }
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to scan: $e',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      } finally {
                        isScanning.value = false;
                      }
                    },
                    icon: Icon(Iconsax.refresh, size: 18),
                    label: Text('Scan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrinterScanDialog(PrinterService printerService) {
    return Container(
      width: 500,
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.printer, color: Colors.blue, size: 28),
              SizedBox(width: 12),
              Text(
                'Available Printers',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 20),
          Obx(() {
            final isScanning = printerService.isScanning.value;
            final devices = printerService.availablePrinters;

            if (isScanning) {
              return Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Scanning for Bluetooth printers...'),
                  ],
                ),
              );
            }

            if (devices.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Iconsax.search_status,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No printers found',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Make sure Bluetooth is enabled and printer is in pairing mode',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Container(
              constraints: BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Iconsax.printer, color: Colors.blue),
                      ),
                      title: Text(
                        device.name,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(device.macAdress),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await printerService.connectPrinter(device.macAdress);
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Connect'),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
              SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => printerService.listBluetoothPrinters(),
                icon: Icon(Iconsax.refresh, size: 18),
                label: Text('Scan Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCashierSection(AuthController authController, bool isDark) {
    return _buildSectionCard(
      title: 'Cashier Management',
      icon: Iconsax.people,
      iconColor: Colors.purple,
      isDark: isDark,
      trailing: IconButton(
        icon: Icon(
          Iconsax.add_circle,
          color: isDark ? AppColors.darkPrimary : AppColors.primary,
        ),
        onPressed: () => _showAddCashierDialog(authController, isDark),
        tooltip: 'Add Cashier',
      ),
      children: [
        Obx(
          () => ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: authController.cashiers.length,
            itemBuilder: (context, index) {
              final cashier = authController.cashiers[index];
              return Card(
                color: AppColors.getSurfaceColor(isDark),
                elevation: isDark ? 4 : 1,
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRoleColor(
                      cashier.role,
                    ).withValues(alpha: 0.2),
                    child: Icon(
                      Iconsax.user,
                      color: _getRoleColor(cashier.role),
                    ),
                  ),
                  title: Text(
                    cashier.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                  subtitle: Text(
                    cashier.role.name.toUpperCase(),
                    style: TextStyle(color: AppColors.getTextSecondary(isDark)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: cashier.isActive
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          cashier.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: cashier.isActive
                                ? Colors.green[700]
                                : Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      PopupMenuButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                        color: AppColors.getSurfaceColor(isDark),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.edit,
                                  size: 18,
                                  color: AppColors.getTextSecondary(isDark),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: AppColors.getTextPrimary(isDark),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => Future.delayed(
                              Duration.zero,
                              () => _showEditCashierDialog(
                                authController,
                                cashier,
                                isDark,
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.trash,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                            onTap: () =>
                                authController.deleteCashier(cashier.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.manager:
        return Colors.orange;
      case UserRole.cashier:
        return Colors.blue;
    }
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
    Widget? trailing,
    bool isDark = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.getDivider(isDark)),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  void _showAddCashierDialog(AuthController authController, bool isDark) {
    final nameController = TextEditingController();
    final pinController = TextEditingController();
    UserRole selectedRole = UserRole.cashier;

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.getSurfaceColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 450,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          (isDark ? AppColors.darkPrimary : AppColors.primary)
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Iconsax.user_add,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Add New Cashier',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              TextField(
                controller: nameController,
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  prefixIcon: Icon(
                    Iconsax.user,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : Colors.grey[50],
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: pinController,
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  labelText: 'PIN (4 digits)',
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  prefixIcon: Icon(
                    Iconsax.lock,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButtonFormField<UserRole>(
                    value: selectedRole,
                    style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                    dropdownColor: AppColors.getSurfaceColor(isDark),
                    decoration: InputDecoration(
                      labelText: 'Role',
                      labelStyle: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      prefixIcon: Icon(
                        Iconsax.user_tag,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.getDivider(isDark),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.getDivider(isDark),
                        ),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : Colors.grey[50],
                    ),
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedRole = value);
                      }
                    },
                  );
                },
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty &&
                          pinController.text.length == 4) {
                        final newCashier = CashierModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          email:
                              '${nameController.text.toLowerCase().replaceAll(' ', '.')}@pos.local',
                          pin: pinController.text,
                          role: selectedRole,
                          isActive: true,
                          createdAt: DateTime.now(),
                        );
                        authController.addCashier(newCashier);
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Cashier added successfully',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      } else {
                        Get.snackbar(
                          'Error',
                          'Please fill all fields correctly',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text('Add Cashier'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditCashierDialog(
    AuthController authController,
    CashierModel cashier,
    bool isDark,
  ) {
    final nameController = TextEditingController(text: cashier.name);
    UserRole selectedRole = cashier.role;
    bool isActive = cashier.isActive;

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.getSurfaceColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: 450,
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              (isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.primary)
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Iconsax.edit,
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Edit Cashier',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      prefixIcon: Icon(
                        Iconsax.user,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.getDivider(isDark),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.getDivider(isDark),
                        ),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : Colors.grey[50],
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<UserRole>(
                    value: selectedRole,
                    style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                    dropdownColor: AppColors.getSurfaceColor(isDark),
                    decoration: InputDecoration(
                      labelText: 'Role',
                      labelStyle: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      prefixIcon: Icon(
                        Iconsax.user_tag,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.getDivider(isDark),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.getDivider(isDark),
                        ),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : Colors.grey[50],
                    ),
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedRole = value);
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(
                      'Active Status',
                      style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                    ),
                    subtitle: Text(
                      isActive
                          ? 'This cashier can log in'
                          : 'This cashier cannot log in',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                    value: isActive,
                    onChanged: (value) {
                      setState(() => isActive = value);
                    },
                    activeColor: isDark
                        ? AppColors.darkPrimary
                        : AppColors.primary,
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isNotEmpty) {
                            final updatedCashier = cashier.copyWith(
                              name: nameController.text,
                              role: selectedRole,
                              isActive: isActive,
                            );
                            authController.updateCashier(updatedCashier);
                            Get.back();
                            Get.snackbar(
                              'Success',
                              'Cashier updated successfully',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.darkPrimary
                              : AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text('Save Changes'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
