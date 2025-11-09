import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import '../../utils/colors.dart';
import '../../controllers/auth_controller.dart';
import '../../services/printer_service.dart';
import '../../models/cashier_model.dart';
import 'business_settings_view.dart';
import 'appearance_settings_view.dart';

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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSystemSettings(authController),
                BusinessSettingsView(),
                AppearanceSettingsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
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
          Text(
            'Settings',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Manage your POS system configuration',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          SizedBox(height: 24),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(icon: Icon(Iconsax.setting_2), text: 'System'),
              Tab(icon: Icon(Iconsax.shop), text: 'Business'),
              Tab(icon: Icon(Iconsax.brush_2), text: 'Appearance'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSettings(AuthController authController) {
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
          // Printer Configuration (only show if available)
          if (printerService != null)
            FadeInUp(
              duration: Duration(milliseconds: 400),
              child: _buildPrinterSection(printerService),
            ),
          if (printerService != null) SizedBox(height: 24),

          // Cashier Management (Admin only)
          Obx(() {
            if (authController.hasPermission(UserRole.admin)) {
              return FadeInUp(
                duration: Duration(milliseconds: 500),
                child: _buildCashierSection(authController),
              );
            }
            return SizedBox();
          }),
        ],
      ),
    );
  }

  Widget _buildPrinterSection(PrinterService printerService) {
    return _buildSectionCard(
      title: 'Printer Configuration',
      icon: Iconsax.printer,
      iconColor: Colors.blue,
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
                              connectedDevice.platformName,
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
                            await printerService.connectedPrinter.value!
                                .disconnect();
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
                        device.platformName,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(device.remoteId.toString()),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await printerService.connectToPrinter(device);
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
                onPressed: () => printerService.scanForPrinters(),
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

  Widget _buildCashierSection(AuthController authController) {
    return _buildSectionCard(
      title: 'Cashier Management',
      icon: Iconsax.people,
      iconColor: Colors.purple,
      trailing: IconButton(
        icon: Icon(Iconsax.add_circle, color: AppColors.primary),
        onPressed: () => _showAddCashierDialog(authController),
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
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(cashier.role.name.toUpperCase()),
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
                        icon: Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(Iconsax.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                            onTap: () => Future.delayed(
                              Duration.zero,
                              () => _showEditCashierDialog(
                                authController,
                                cashier,
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  void _showAddCashierDialog(AuthController authController) {
    final nameController = TextEditingController();
    final pinController = TextEditingController();
    UserRole selectedRole = UserRole.cashier;

    Get.dialog(
      Dialog(
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
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Iconsax.user_add, color: AppColors.primary),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Add New Cashier',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Iconsax.user),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: pinController,
                decoration: InputDecoration(
                  labelText: 'PIN (4 digits)',
                  prefixIcon: Icon(Iconsax.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButtonFormField<UserRole>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(Iconsax.user_tag),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                    child: Text('Cancel'),
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
                      backgroundColor: AppColors.primary,
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
  ) {
    final nameController = TextEditingController(text: cashier.name);
    UserRole selectedRole = cashier.role;
    bool isActive = cashier.isActive;

    Get.dialog(
      Dialog(
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
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Iconsax.edit, color: AppColors.primary),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Edit Cashier',
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
                      labelText: 'Full Name',
                      prefixIcon: Icon(Iconsax.user),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<UserRole>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(Iconsax.user_tag),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                    title: Text('Active Status'),
                    subtitle: Text(
                      isActive
                          ? 'This cashier can log in'
                          : 'This cashier cannot log in',
                    ),
                    value: isActive,
                    onChanged: (value) {
                      setState(() => isActive = value);
                    },
                    activeColor: AppColors.primary,
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('Cancel'),
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
                          backgroundColor: AppColors.primary,
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
