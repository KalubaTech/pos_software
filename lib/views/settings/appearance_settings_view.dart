import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/appearance_controller.dart';
import '../../utils/colors.dart';

class AppearanceSettingsView extends StatelessWidget {
  const AppearanceSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppearanceController());

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
                  _buildThemeSettings(controller),
                  SizedBox(height: 24),
                  _buildColorSettings(controller),
                  SizedBox(height: 24),
                  _buildFontSettings(controller),
                  SizedBox(height: 24),
                  _buildLayoutSettings(controller),
                  SizedBox(height: 24),
                  _buildPreview(controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppearanceController controller) {
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
                'Appearance Settings',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Customize the look and feel of your POS',
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
                        'Are you sure you want to reset appearance to default?',
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
                              'Appearance reset to defaults',
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

  Widget _buildThemeSettings(AppearanceController controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.moon, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  'Theme Mode',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24),
            Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: _buildThemeModeCard(
                      controller,
                      'light',
                      'Light Mode',
                      Iconsax.sun_1,
                      'Bright and clean interface',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildThemeModeCard(
                      controller,
                      'dark',
                      'Dark Mode',
                      Iconsax.moon,
                      'Easy on the eyes',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildThemeModeCard(
                      controller,
                      'system',
                      'System',
                      Iconsax.monitor,
                      'Follow system settings',
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeCard(
    AppearanceController controller,
    String mode,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = controller.themeMode.value == mode;
    return GestureDetector(
      onTap: () => controller.setThemeMode(mode),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? AppColors.primary : Colors.grey[600],
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSettings(AppearanceController controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.colorfilter, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  'Primary Color',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Choose your brand color',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            Obx(() {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: controller.colorPresets.entries.map((entry) {
                  final isSelected =
                      controller.primaryColor.value == entry.value;
                  return GestureDetector(
                    onTap: () => controller.setPrimaryColor(entry.value),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Color(entry.value),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: isSelected
                              ? Icon(Icons.check, color: Colors.white, size: 30)
                              : null,
                        ),
                        SizedBox(height: 8),
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSettings(AppearanceController controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.text, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  'Font Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text('Font Size', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: _buildFontSizeOption(
                      controller,
                      'small',
                      'Small',
                      'Aa',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildFontSizeOption(
                      controller,
                      'medium',
                      'Medium',
                      'Aa',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildFontSizeOption(
                      controller,
                      'large',
                      'Large',
                      'Aa',
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeOption(
    AppearanceController controller,
    String size,
    String label,
    String preview,
  ) {
    final isSelected = controller.fontSize.value == size;
    final fontSize = size == 'small'
        ? 20.0
        : size == 'large'
        ? 32.0
        : 26.0;

    return GestureDetector(
      onTap: () => controller.setFontSize(size),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
        ),
        child: Column(
          children: [
            Text(
              preview,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutSettings(AppearanceController controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.grid_1, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  'Layout Preferences',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24),
            Obx(
              () => SwitchListTile(
                value: controller.compactMode.value,
                onChanged: (value) => controller.compactMode.value = value,
                title: Text('Compact Mode'),
                subtitle: Text('Reduce spacing and padding'),
                secondary: Icon(Iconsax.size),
              ),
            ),
            Obx(
              () => SwitchListTile(
                value: controller.showAnimations.value,
                onChanged: (value) => controller.showAnimations.value = value,
                title: Text('Show Animations'),
                subtitle: Text('Enable smooth transitions and effects'),
                secondary: Icon(Iconsax.happyemoji),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Product Grid Columns',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: RadioListTile<int>(
                      value: 2,
                      groupValue: controller.gridColumns.value,
                      onChanged: (value) =>
                          controller.gridColumns.value = value!,
                      title: Text('2 Columns'),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<int>(
                      value: 3,
                      groupValue: controller.gridColumns.value,
                      onChanged: (value) =>
                          controller.gridColumns.value = value!,
                      title: Text('3 Columns'),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<int>(
                      value: 4,
                      groupValue: controller.gridColumns.value,
                      onChanged: (value) =>
                          controller.gridColumns.value = value!,
                      title: Text('4 Columns'),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(AppearanceController controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.eye, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  'Preview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24),
            Obx(() {
              return Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: controller.isDarkMode.value
                      ? Colors.grey[900]
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(controller.primaryColor.value),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Iconsax.box, color: Colors.white),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sample Product',
                                style: TextStyle(
                                  fontSize: 16 * controller.fontSizeMultiplier,
                                  fontWeight: FontWeight.bold,
                                  color: controller.isDarkMode.value
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              Text(
                                'Product description',
                                style: TextStyle(
                                  fontSize: 14 * controller.fontSizeMultiplier,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$99.99',
                          style: TextStyle(
                            fontSize: 18 * controller.fontSizeMultiplier,
                            fontWeight: FontWeight.bold,
                            color: Color(controller.primaryColor.value),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(controller.primaryColor.value),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        'Add to Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16 * controller.fontSizeMultiplier,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
