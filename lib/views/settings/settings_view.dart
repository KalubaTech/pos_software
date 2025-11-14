import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/appearance_controller.dart';
import '../../utils/colors.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final appearanceController = Get.find<AppearanceController>();

    return Obx(() {
      final isDark = appearanceController.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[100],
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              SizedBox(height: 24),
              _buildSection('Store Information', [
                _buildSettingTile(
                  'Store Name',
                  'Dynamos POS',
                  Iconsax.shop,
                  isDark,
                  onTap: () {},
                ),
                _buildSettingTile(
                  'Store Address',
                  '123 Main Street, City, State 12345',
                  Iconsax.location,
                  isDark,
                  onTap: () {},
                ),
                _buildSettingTile(
                  'Contact Number',
                  '+1 (555) 123-4567',
                  Iconsax.call,
                  isDark,
                  onTap: () {},
                ),
                _buildSettingTile(
                  'Email',
                  'contact@dynamospos.com',
                  Iconsax.sms,
                  isDark,
                  onTap: () {},
                ),
              ], isDark),
              SizedBox(height: 24),
              _buildSection('Business Settings', [
                _buildSettingTile(
                  'Tax Rate',
                  '8%',
                  Iconsax.percentage_circle,
                  isDark,
                  onTap: () {},
                ),
                _buildSettingTile(
                  'Currency',
                  'USD (\$)',
                  Iconsax.dollar_circle,
                  isDark,
                  onTap: () {},
                ),
                _buildSettingTile(
                  'Receipt Template',
                  'Standard',
                  Iconsax.receipt_2_1,
                  isDark,
                  onTap: () {},
                ),
              ], isDark),
              SizedBox(height: 24),
              _buildSection('Appearance', [
                _buildSwitchTile(
                  'Dark Mode',
                  isDark,
                  Iconsax.moon,
                  isDark,
                  onChanged: (value) => appearanceController.toggleTheme(),
                ),
                _buildSettingTile(
                  'Theme Color',
                  'Teal',
                  Iconsax.colorfilter,
                  isDark,
                  onTap: () {},
                ),
              ], isDark),
              SizedBox(height: 24),
              _buildSection('Security', [
                _buildSettingTile(
                  'Change Password',
                  'Update your password',
                  Iconsax.lock,
                  isDark,
                  onTap: () {},
                ),
                _buildSwitchTile(
                  'Two-Factor Authentication',
                  false,
                  Iconsax.security_safe,
                  isDark,
                  onChanged: (value) {},
                ),
              ], isDark),
              SizedBox(height: 24),
              _buildSection('Data Management', [
                _buildSettingTile(
                  'Backup Data',
                  'Last backup: Never',
                  Iconsax.cloud_add,
                  isDark,
                  onTap: () {},
                ),
                _buildSettingTile(
                  'Export Data',
                  'Download your data',
                  Iconsax.document_download,
                  isDark,
                  onTap: () {},
                ),
                _buildSettingTile(
                  'Clear Cache',
                  'Free up storage space',
                  Iconsax.trash,
                  isDark,
                  onTap: () {},
                  textColor: Colors.orange,
                ),
              ], isDark),
              SizedBox(height: 24),
              _buildSection('About', [
                _buildSettingTile(
                  'Version',
                  '1.0.0',
                  Iconsax.information,
                  isDark,
                  showArrow: false,
                ),
                _buildSettingTile(
                  'Terms of Service',
                  'Read our terms',
                  Iconsax.document_text,
                  isDark,
                  onTap: () {},
                ),
                _buildSettingTile(
                  'Privacy Policy',
                  'Read our privacy policy',
                  Iconsax.shield_tick,
                  isDark,
                  onTap: () {},
                ),
              ], isDark),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Iconsax.logout, color: Colors.white),
                  label: Text('Logout', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSection(String title, List<Widget> children, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getDivider(isDark), width: 1),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.getDivider(isDark)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    bool isDark, {
    VoidCallback? onTap,
    bool showArrow = true,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.darkPrimary : AppColors.primary)
              .withOpacity(isDark ? 0.25 : 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDark ? AppColors.darkPrimary : AppColors.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.getTextPrimary(isDark),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.getTextSecondary(isDark)),
      ),
      trailing: showArrow
          ? Icon(
              Iconsax.arrow_right_3,
              color: AppColors.getTextSecondary(isDark),
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    IconData icon,
    bool isDark, {
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.darkPrimary : AppColors.primary)
              .withOpacity(isDark ? 0.25 : 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDark ? AppColors.darkPrimary : AppColors.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.getTextPrimary(isDark),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: isDark ? AppColors.darkPrimary : AppColors.primary,
        activeTrackColor: (isDark ? AppColors.darkPrimary : AppColors.primary)
            .withOpacity(0.5),
      ),
    );
  }
}
