import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/business_settings_controller.dart';
import '../../utils/colors.dart';

class BusinessSettingsView extends StatelessWidget {
  const BusinessSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BusinessSettingsController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(controller),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStoreInformation(controller),
                  SizedBox(height: 24),
                  _buildTaxConfiguration(controller),
                  SizedBox(height: 24),
                  _buildCurrencySettings(controller),
                  SizedBox(height: 24),
                  _buildReceiptSettings(controller),
                  SizedBox(height: 24),
                  _buildOperatingHours(controller),
                  SizedBox(height: 24),
                  _buildPaymentMethods(controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BusinessSettingsController controller) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Business Settings',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Configure your store information and preferences',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: Text('Reset to Defaults'),
                      content: Text(
                        'Are you sure you want to reset all settings to default values?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            controller.resetToDefaults();
                            Get.back();
                            Get.snackbar(
                              'Reset',
                              'Settings reset to defaults',
                              backgroundColor: Colors.orange,
                              colorText: Colors.white,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: Text(
                            'Reset',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Iconsax.refresh),
                label: Text('Reset to Defaults'),
              ),
              SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => controller.saveSettings(),
                icon: Icon(Iconsax.save_2, color: Colors.white),
                label: Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInformation(BusinessSettingsController controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.shop, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  'Store Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24),
            Obx(
              () => TextField(
                controller:
                    TextEditingController(text: controller.storeName.value)
                      ..selection = TextSelection.collapsed(
                        offset: controller.storeName.value.length,
                      ),
                decoration: InputDecoration(
                  labelText: 'Store Name *',
                  prefixIcon: Icon(Iconsax.building),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => controller.storeName.value = value,
              ),
            ),
            SizedBox(height: 16),
            Obx(
              () => TextField(
                controller:
                    TextEditingController(text: controller.storeAddress.value)
                      ..selection = TextSelection.collapsed(
                        offset: controller.storeAddress.value.length,
                      ),
                decoration: InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Iconsax.location),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
                onChanged: (value) => controller.storeAddress.value = value,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => TextField(
                      controller:
                          TextEditingController(
                              text: controller.storePhone.value,
                            )
                            ..selection = TextSelection.collapsed(
                              offset: controller.storePhone.value.length,
                            ),
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Iconsax.call),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) => controller.storePhone.value = value,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Obx(
                    () => TextField(
                      controller:
                          TextEditingController(
                              text: controller.storeEmail.value,
                            )
                            ..selection = TextSelection.collapsed(
                              offset: controller.storeEmail.value.length,
                            ),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Iconsax.sms),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => controller.storeEmail.value = value,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Obx(
              () => TextField(
                controller:
                    TextEditingController(text: controller.storeTaxId.value)
                      ..selection = TextSelection.collapsed(
                        offset: controller.storeTaxId.value.length,
                      ),
                decoration: InputDecoration(
                  labelText: 'Tax ID / Business Registration Number',
                  prefixIcon: Icon(Iconsax.card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => controller.storeTaxId.value = value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxConfiguration(BusinessSettingsController controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.receipt_1, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  'Tax Configuration',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24),
            Obx(
              () => SwitchListTile(
                value: controller.taxEnabled.value,
                onChanged: (value) => controller.taxEnabled.value = value,
                title: Text('Enable Tax'),
                subtitle: Text('Apply tax to transactions'),
                secondary: Icon(Iconsax.money_tick),
              ),
            ),
            Obx(() {
              if (!controller.taxEnabled.value) return SizedBox();
              return Column(
                children: [
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller:
                              TextEditingController(
                                  text: controller.taxName.value,
                                )
                                ..selection = TextSelection.collapsed(
                                  offset: controller.taxName.value.length,
                                ),
                          decoration: InputDecoration(
                            labelText: 'Tax Name',
                            hintText: 'VAT, GST, Sales Tax',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) =>
                              controller.taxName.value = value,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller:
                              TextEditingController(
                                  text: controller.taxRate.value.toString(),
                                )
                                ..selection = TextSelection.collapsed(
                                  offset: controller.taxRate.value
                                      .toString()
                                      .length,
                                ),
                          decoration: InputDecoration(
                            labelText: 'Tax Rate',
                            suffixText: '%',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (value) {
                            final rate = double.tryParse(value);
                            if (rate != null) controller.taxRate.value = rate;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SwitchListTile(
                    value: controller.includeTaxInPrice.value,
                    onChanged: (value) =>
                        controller.includeTaxInPrice.value = value,
                    title: Text('Include Tax in Price'),
                    subtitle: Text('Tax is already included in product prices'),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySettings(BusinessSettingsController controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.dollar_circle, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  'Currency Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      value: controller.currency.value,
                      decoration: InputDecoration(
                        labelText: 'Currency',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'ZMW',
                          child: Text('ZMW - Zambian Kwacha'),
                        ),
                        DropdownMenuItem(
                          value: 'USD',
                          child: Text('USD - US Dollar'),
                        ),
                        DropdownMenuItem(
                          value: 'EUR',
                          child: Text('EUR - Euro'),
                        ),
                        DropdownMenuItem(
                          value: 'GBP',
                          child: Text('GBP - British Pound'),
                        ),
                        DropdownMenuItem(
                          value: 'JPY',
                          child: Text('JPY - Japanese Yen'),
                        ),
                        DropdownMenuItem(
                          value: 'CNY',
                          child: Text('CNY - Chinese Yuan'),
                        ),
                        DropdownMenuItem(
                          value: 'INR',
                          child: Text('INR - Indian Rupee'),
                        ),
                        DropdownMenuItem(
                          value: 'AUD',
                          child: Text('AUD - Australian Dollar'),
                        ),
                        DropdownMenuItem(
                          value: 'CAD',
                          child: Text('CAD - Canadian Dollar'),
                        ),
                      ],
                      onChanged: (value) {
                        controller.currency.value = value!;
                        // Auto-update symbol
                        final symbols = {
                          'ZMW': 'K',
                          'USD': '\$',
                          'EUR': '€',
                          'GBP': '£',
                          'JPY': '¥',
                          'CNY': '¥',
                          'INR': '₹',
                          'AUD': '\$',
                          'CAD': '\$',
                        };
                        controller.currencySymbol.value = symbols[value] ?? 'K';
                      },
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Obx(
                    () => TextField(
                      controller:
                          TextEditingController(
                              text: controller.currencySymbol.value,
                            )
                            ..selection = TextSelection.collapsed(
                              offset: controller.currencySymbol.value.length,
                            ),
                      decoration: InputDecoration(
                        labelText: 'Currency Symbol',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) =>
                          controller.currencySymbol.value = value,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      value: controller.currencyPosition.value,
                      decoration: InputDecoration(
                        labelText: 'Symbol Position',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'before',
                          child: Text(
                            'Before (${controller.currencySymbol.value}100)',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'after',
                          child: Text(
                            'After (100${controller.currencySymbol.value})',
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          controller.currencyPosition.value = value!,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptSettings(BusinessSettingsController controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.receipt_text, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  'Receipt Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24),
            Obx(
              () => TextField(
                controller:
                    TextEditingController(text: controller.receiptHeader.value)
                      ..selection = TextSelection.collapsed(
                        offset: controller.receiptHeader.value.length,
                      ),
                decoration: InputDecoration(
                  labelText: 'Receipt Header',
                  hintText: 'Custom message at the top of receipt',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
                onChanged: (value) => controller.receiptHeader.value = value,
              ),
            ),
            SizedBox(height: 16),
            Obx(
              () => TextField(
                controller:
                    TextEditingController(text: controller.receiptFooter.value)
                      ..selection = TextSelection.collapsed(
                        offset: controller.receiptFooter.value.length,
                      ),
                decoration: InputDecoration(
                  labelText: 'Receipt Footer',
                  hintText: 'Thank you message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
                onChanged: (value) => controller.receiptFooter.value = value,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<int>(
                      value: controller.receiptWidth.value,
                      decoration: InputDecoration(
                        labelText: 'Receipt Width',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 58,
                          child: Text('58mm (Small)'),
                        ),
                        DropdownMenuItem(
                          value: 80,
                          child: Text('80mm (Standard)'),
                        ),
                      ],
                      onChanged: (value) =>
                          controller.receiptWidth.value = value!,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Obx(
              () => SwitchListTile(
                value: controller.showLogo.value,
                onChanged: (value) => controller.showLogo.value = value,
                title: Text('Show Logo on Receipt'),
                secondary: Icon(Iconsax.gallery),
              ),
            ),
            Obx(
              () => SwitchListTile(
                value: controller.showTaxBreakdown.value,
                onChanged: (value) => controller.showTaxBreakdown.value = value,
                title: Text('Show Tax Breakdown'),
                subtitle: Text('Display tax details separately'),
                secondary: Icon(Iconsax.receipt_discount),
              ),
            ),
            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 16),
            // Receipt Printer Configuration
            Row(
              children: [
                Icon(Iconsax.printer, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Receipt Printer Configuration',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 16),
            Obx(
              () => TextField(
                controller:
                    TextEditingController(
                        text: controller.receiptPrinterName.value,
                      )
                      ..selection = TextSelection.collapsed(
                        offset: controller.receiptPrinterName.value.length,
                      ),
                onChanged: (value) =>
                    controller.receiptPrinterName.value = value,
                decoration: InputDecoration(
                  labelText: 'Printer Name',
                  hintText: 'e.g., Cashier Printer 1',
                  prefixIcon: Icon(Iconsax.printer),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.receiptPrinterType.value,
                decoration: InputDecoration(
                  labelText: 'Connection Type',
                  prefixIcon: Icon(Iconsax.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ['USB', 'Network', 'Bluetooth']
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.receiptPrinterType.value = value;
                  }
                },
              ),
            ),
            SizedBox(height: 16),
            Obx(
              () => controller.receiptPrinterType.value == 'Network'
                  ? Column(
                      children: [
                        TextField(
                          controller:
                              TextEditingController(
                                  text: controller.receiptPrinterAddress.value,
                                )
                                ..selection = TextSelection.collapsed(
                                  offset: controller
                                      .receiptPrinterAddress
                                      .value
                                      .length,
                                ),
                          onChanged: (value) =>
                              controller.receiptPrinterAddress.value = value,
                          decoration: InputDecoration(
                            labelText: 'IP Address',
                            hintText: 'e.g., 192.168.1.100',
                            prefixIcon: Icon(Iconsax.global),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller:
                              TextEditingController(
                                  text: controller.receiptPrinterPort.value,
                                )
                                ..selection = TextSelection.collapsed(
                                  offset: controller
                                      .receiptPrinterPort
                                      .value
                                      .length,
                                ),
                          onChanged: (value) =>
                              controller.receiptPrinterPort.value = value,
                          decoration: InputDecoration(
                            labelText: 'Port',
                            hintText: 'e.g., 9100',
                            prefixIcon: Icon(Iconsax.link_21),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16),
                      ],
                    )
                  : controller.receiptPrinterType.value == 'Bluetooth'
                  ? Column(
                      children: [
                        TextField(
                          controller:
                              TextEditingController(
                                  text: controller.receiptPrinterAddress.value,
                                )
                                ..selection = TextSelection.collapsed(
                                  offset: controller
                                      .receiptPrinterAddress
                                      .value
                                      .length,
                                ),
                          onChanged: (value) =>
                              controller.receiptPrinterAddress.value = value,
                          decoration: InputDecoration(
                            labelText: 'Bluetooth Address',
                            hintText: 'e.g., 00:11:22:33:44:55',
                            prefixIcon: Icon(Iconsax.bluetooth),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    )
                  : SizedBox.shrink(),
            ),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.info_circle, color: AppColors.primary, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Note: This is for transaction receipt printing. For price tag/label printing, use the printer management in the Price Tag Designer.',
                      style: TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatingHours(BusinessSettingsController controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.clock, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  'Operating Hours',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => TextField(
                      controller: TextEditingController(
                        text: controller.openingTime.value,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Opening Time',
                        prefixIcon: Icon(Iconsax.clock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final time = await showTimePicker(
                          context: Get.context!,
                          initialTime: TimeOfDay(
                            hour: int.parse(
                              controller.openingTime.value.split(':')[0],
                            ),
                            minute: int.parse(
                              controller.openingTime.value.split(':')[1],
                            ),
                          ),
                        );
                        if (time != null) {
                          controller.openingTime.value =
                              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Obx(
                    () => TextField(
                      controller: TextEditingController(
                        text: controller.closingTime.value,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Closing Time',
                        prefixIcon: Icon(Iconsax.clock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final time = await showTimePicker(
                          context: Get.context!,
                          initialTime: TimeOfDay(
                            hour: int.parse(
                              controller.closingTime.value.split(':')[0],
                            ),
                            minute: int.parse(
                              controller.closingTime.value.split(':')[1],
                            ),
                          ),
                        );
                        if (time != null) {
                          controller.closingTime.value =
                              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Operating Days',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Obx(() {
              final days = [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday',
              ];
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: days.map((day) {
                  final isSelected = controller.operatingDays.contains(day);
                  return FilterChip(
                    label: Text(day),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        controller.operatingDays.add(day);
                      } else {
                        controller.operatingDays.remove(day);
                      }
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods(BusinessSettingsController controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.wallet_2, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  'Payment Methods',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24),
            Obx(
              () => SwitchListTile(
                value: controller.acceptCash.value,
                onChanged: (value) => controller.acceptCash.value = value,
                title: Text('Accept Cash'),
                secondary: Icon(Iconsax.money),
              ),
            ),
            Obx(
              () => SwitchListTile(
                value: controller.acceptCard.value,
                onChanged: (value) => controller.acceptCard.value = value,
                title: Text('Accept Card Payments'),
                subtitle: Text('Credit/Debit cards'),
                secondary: Icon(Iconsax.card),
              ),
            ),
            Obx(
              () => SwitchListTile(
                value: controller.acceptMobile.value,
                onChanged: (value) => controller.acceptMobile.value = value,
                title: Text('Accept Mobile Payments'),
                subtitle: Text('Apple Pay, Google Pay, etc.'),
                secondary: Icon(Iconsax.mobile),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
