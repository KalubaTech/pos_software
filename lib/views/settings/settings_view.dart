import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../utils/colors.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            _buildSection('Store Information', [
              _buildSettingTile(
                'Store Name',
                'Dynamos POS',
                Iconsax.shop,
                onTap: () {},
              ),
              _buildSettingTile(
                'Store Address',
                '123 Main Street, City, State 12345',
                Iconsax.location,
                onTap: () {},
              ),
              _buildSettingTile(
                'Contact Number',
                '+1 (555) 123-4567',
                Iconsax.call,
                onTap: () {},
              ),
              _buildSettingTile(
                'Email',
                'contact@dynamospos.com',
                Iconsax.sms,
                onTap: () {},
              ),
            ]),
            SizedBox(height: 24),
            _buildSection('Business Settings', [
              _buildSettingTile(
                'Tax Rate',
                '8%',
                Iconsax.percentage_circle,
                onTap: () {},
              ),
              _buildSettingTile(
                'Currency',
                'USD (\$)',
                Iconsax.dollar_circle,
                onTap: () {},
              ),
              _buildSettingTile(
                'Receipt Template',
                'Standard',
                Iconsax.receipt_2_1,
                onTap: () {},
              ),
            ]),
            SizedBox(height: 24),
            _buildSection('Appearance', [
              _buildSwitchTile(
                'Dark Mode',
                false,
                Iconsax.moon,
                onChanged: (value) {},
              ),
              _buildSettingTile(
                'Theme Color',
                'Teal',
                Iconsax.colorfilter,
                onTap: () {},
              ),
            ]),
            SizedBox(height: 24),
            _buildSection('Security', [
              _buildSettingTile(
                'Change Password',
                'Update your password',
                Iconsax.lock,
                onTap: () {},
              ),
              _buildSwitchTile(
                'Two-Factor Authentication',
                false,
                Iconsax.security_safe,
                onChanged: (value) {},
              ),
            ]),
            SizedBox(height: 24),
            _buildSection('Data Management', [
              _buildSettingTile(
                'Backup Data',
                'Last backup: Never',
                Iconsax.cloud_add,
                onTap: () {},
              ),
              _buildSettingTile(
                'Export Data',
                'Download your data',
                Iconsax.document_download,
                onTap: () {},
              ),
              _buildSettingTile(
                'Clear Cache',
                'Free up storage space',
                Iconsax.trash,
                onTap: () {},
                textColor: Colors.orange,
              ),
            ]),
            SizedBox(height: 24),
            _buildSection('About', [
              _buildSettingTile(
                'Version',
                '1.0.0',
                Iconsax.information,
                showArrow: false,
              ),
              _buildSettingTile(
                'Terms of Service',
                'Read our terms',
                Iconsax.document_text,
                onTap: () {},
              ),
              _buildSettingTile(
                'Privacy Policy',
                'Read our privacy policy',
                Iconsax.shield_tick,
                onTap: () {},
              ),
            ]),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Iconsax.logout),
                label: Text('Logout'),
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
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
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
                color: Colors.grey[800],
              ),
            ),
          ),
          Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
    bool showArrow = true,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
      ),
      subtitle: Text(subtitle),
      trailing: showArrow ? Icon(Iconsax.arrow_right_3) : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    IconData icon, {
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}
