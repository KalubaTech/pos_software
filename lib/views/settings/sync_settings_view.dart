import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/sync_controller.dart';
import '../../controllers/appearance_controller.dart';
import '../../services/subscription_service.dart';
import '../../utils/colors.dart';
import '../../utils/responsive.dart';

class SyncSettingsView extends StatelessWidget {
  const SyncSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SyncController());
    final appearanceController = Get.find<AppearanceController>();
    final subscriptionService = Get.find<SubscriptionService>();

    return Obx(() {
      final isDark = appearanceController.isDarkMode.value;
      final hasAccess = subscriptionService.hasAccessToSync;

      // Show subscription gate if no access
      if (!hasAccess) {
        return _buildSubscriptionGate(isDark);
      }

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
        body: Column(
          children: [
            _buildHeader(context, controller, isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(controller, isDark),
                    SizedBox(height: 24),
                    _buildConfigurationCard(controller, isDark),
                    SizedBox(height: 24),
                    _buildSyncStatsCard(controller, isDark),
                    SizedBox(height: 24),
                    _buildActionsCard(controller, isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(
    BuildContext context,
    SyncController controller,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(context.isMobile ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.darkPrimary,
                  AppColors.darkPrimary.withValues(alpha: 0.8),
                ]
              : [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: context.isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.refresh, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Data Sync',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Obx(() {
                      if (controller.isSyncing) {
                        return SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        );
                      }
                      return Icon(
                        controller.isConfigured.value
                            ? Iconsax.tick_circle5
                            : Iconsax.warning_2,
                        color: Colors.white,
                        size: 24,
                      );
                    }),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Sync with external database',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Iconsax.refresh, color: Colors.white, size: 32),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Data Sync',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Sync transactions, products, and customers across devices',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Obx(() {
                  if (controller.isSyncing) {
                    return SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  }
                  return Icon(
                    controller.isConfigured.value
                        ? Iconsax.tick_circle5
                        : Iconsax.warning_2,
                    color: Colors.white,
                    size: 32,
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildStatusCard(SyncController controller, bool isDark) {
    return Card(
      color: AppColors.getSurfaceColor(isDark),
      elevation: isDark ? 8 : 2,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Iconsax.status,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                ),
                SizedBox(width: 12),
                Text(
                  'Sync Status',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Obx(() {
              final isConfigured = controller.isConfigured.value;
              final isSyncing = controller.isSyncing;

              return Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isConfigured ? Colors.green : Colors.orange,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    isConfigured
                        ? (isSyncing ? 'Syncing...' : 'Configured & Ready')
                        : 'Not Configured',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: 16),
            Obx(() {
              final config = controller.config;
              if (config == null) {
                return Text(
                  'Configure sync settings below to get started',
                  style: TextStyle(color: AppColors.getTextSecondary(isDark)),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Business ID',
                    config.businessId,
                    Iconsax.building,
                    isDark,
                  ),
                  SizedBox(height: 8),
                  _buildInfoRow(
                    'Auto Sync',
                    config.autoSync ? 'Enabled' : 'Disabled',
                    Iconsax.autobrightness,
                    isDark,
                  ),
                  SizedBox(height: 8),
                  _buildInfoRow(
                    'Sync Interval',
                    '${config.syncIntervalMinutes} minutes',
                    Iconsax.timer,
                    isDark,
                  ),
                ],
              );
            }),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                      .withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.info_circle,
                    size: 16,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Syncs: Transactions, Products, Customers & Inventory levels',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextSecondary(isDark),
                      ),
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

  Widget _buildConfigurationCard(SyncController controller, bool isDark) {
    return Card(
      color: AppColors.getSurfaceColor(isDark),
      elevation: isDark ? 8 : 2,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Iconsax.setting_2,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                ),
                SizedBox(width: 12),
                Text(
                  'Configuration',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Obx(
              () => TextField(
                controller:
                    TextEditingController(
                        text: controller.businessIdController.value,
                      )
                      ..selection = TextSelection.collapsed(
                        offset: controller.businessIdController.value.length,
                      ),
                onChanged: (value) =>
                    controller.businessIdController.value = value,
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  labelText: 'Business ID *',
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  hintText: 'e.g., BUS_12345',
                  hintStyle: TextStyle(
                    color: AppColors.getTextTertiary(isDark),
                  ),
                  prefixIcon: Icon(
                    Iconsax.building,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Obx(
              () => TextField(
                controller:
                    TextEditingController(
                        text: controller.apiUrlController.value,
                      )
                      ..selection = TextSelection.collapsed(
                        offset: controller.apiUrlController.value.length,
                      ),
                onChanged: (value) => controller.apiUrlController.value = value,
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  labelText: 'API Base URL',
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  hintText: 'https://api.yourserver.com',
                  hintStyle: TextStyle(
                    color: AppColors.getTextTertiary(isDark),
                  ),
                  prefixIcon: Icon(
                    Iconsax.global,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Obx(
              () => TextField(
                controller:
                    TextEditingController(
                        text: controller.apiKeyController.value,
                      )
                      ..selection = TextSelection.collapsed(
                        offset: controller.apiKeyController.value.length,
                      ),
                onChanged: (value) => controller.apiKeyController.value = value,
                obscureText: true,
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  labelText: 'API Key *',
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  hintText: 'Enter your API key',
                  hintStyle: TextStyle(
                    color: AppColors.getTextTertiary(isDark),
                  ),
                  prefixIcon: Icon(
                    Iconsax.key,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Obx(
              () => SwitchListTile(
                value: controller.autoSync.value,
                onChanged: (value) => controller.autoSync.value = value,
                activeColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                title: Text(
                  'Auto Sync',
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                ),
                subtitle: Text(
                  'Automatically sync data at intervals',
                  style: TextStyle(color: AppColors.getTextSecondary(isDark)),
                ),
              ),
            ),
            Obx(() {
              if (controller.autoSync.value) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    Text(
                      'Sync Interval: ${controller.syncInterval.value} minutes',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    Slider(
                      value: controller.syncInterval.value.toDouble(),
                      min: 5,
                      max: 60,
                      divisions: 11,
                      label: '${controller.syncInterval.value} min',
                      activeColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.primary,
                      onChanged: (value) =>
                          controller.syncInterval.value = value.toInt(),
                    ),
                  ],
                );
              }
              return SizedBox.shrink();
            }),
            SizedBox(height: 16),
            Obx(
              () => SwitchListTile(
                value: controller.syncOnlyWifi.value,
                onChanged: (value) => controller.syncOnlyWifi.value = value,
                activeColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                title: Text(
                  'Sync Only on WiFi',
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                ),
                subtitle: Text(
                  'Prevent mobile data usage',
                  style: TextStyle(color: AppColors.getTextSecondary(isDark)),
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    return OutlinedButton.icon(
                      onPressed: controller.isTesting.value
                          ? null
                          : () => controller.testConnection(),
                      icon: controller.isTesting.value
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Iconsax.link),
                      label: Text('Test Connection'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.getDivider(isDark)),
                        foregroundColor: AppColors.getTextPrimary(isDark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => controller.saveConfiguration(),
                    icon: Icon(Iconsax.tick_circle),
                    label: Text('Save Config'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  Widget _buildSyncStatsCard(SyncController controller, bool isDark) {
    return Card(
      color: AppColors.getSurfaceColor(isDark),
      elevation: isDark ? 8 : 2,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Iconsax.chart,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                ),
                SizedBox(width: 12),
                Text(
                  'Sync Statistics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Obx(() {
              final stats = controller.stats;
              return Row(
                children: [
                  Expanded(
                    child: _buildStatTile(
                      'Pending',
                      stats.totalPending.toString(),
                      Iconsax.timer_1,
                      Colors.orange,
                      isDark,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildStatTile(
                      'Synced',
                      stats.totalSynced.toString(),
                      Iconsax.tick_circle,
                      Colors.green,
                      isDark,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildStatTile(
                      'Failed',
                      stats.totalFailed.toString(),
                      Iconsax.close_circle,
                      Colors.red,
                      isDark,
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: 16),
            Obx(() {
              final lastSync = controller.stats.lastSyncTime;
              if (lastSync == null) {
                return Text(
                  'Never synced',
                  style: TextStyle(
                    color: AppColors.getTextSecondary(isDark),
                    fontStyle: FontStyle.italic,
                  ),
                );
              }

              final diff = DateTime.now().difference(lastSync);
              String timeAgo;
              if (diff.inMinutes < 1) {
                timeAgo = 'Just now';
              } else if (diff.inHours < 1) {
                timeAgo = '${diff.inMinutes} minutes ago';
              } else if (diff.inDays < 1) {
                timeAgo = '${diff.inHours} hours ago';
              } else {
                timeAgo = '${diff.inDays} days ago';
              }

              return Text(
                'Last sync: $timeAgo',
                style: TextStyle(color: AppColors.getTextSecondary(isDark)),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(SyncController controller, bool isDark) {
    return Card(
      color: AppColors.getSurfaceColor(isDark),
      elevation: isDark ? 8 : 2,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Iconsax.flash,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                ),
                SizedBox(width: 12),
                Text(
                  'Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.syncNow(),
                icon: Icon(Iconsax.refresh),
                label: Text('Sync Now'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: isDark
                      ? AppColors.darkPrimary
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.retryFailed(),
                    icon: Icon(Iconsax.refresh_2),
                    label: Text('Retry Failed'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.getDivider(isDark)),
                      foregroundColor: AppColors.getTextPrimary(isDark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.cleanup(),
                    icon: Icon(Iconsax.trash),
                    label: Text('Cleanup'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.getDivider(isDark)),
                      foregroundColor: AppColors.getTextPrimary(isDark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  Widget _buildStatTile(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.getTextSecondary(isDark)),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: AppColors.getTextSecondary(isDark),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.getTextPrimary(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionGate(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          margin: EdgeInsets.all(24),
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.crown_1, size: 64, color: Colors.blue),
                ),
                SizedBox(height: 24),
                Text(
                  'Premium Feature',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Cloud synchronization is a premium feature',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                SizedBox(height: 32),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        'Transactions sync',
                        'All sales data across devices',
                        isDark,
                      ),
                      SizedBox(height: 16),
                      _buildFeatureItem(
                        'Products & Inventory',
                        'Stock levels updated everywhere',
                        isDark,
                      ),
                      SizedBox(height: 16),
                      _buildFeatureItem(
                        'Customer data',
                        'Centralized customer database',
                        isDark,
                      ),
                      SizedBox(height: 16),
                      _buildFeatureItem(
                        'Automatic sync',
                        'Background updates every few minutes',
                        isDark,
                      ),
                      SizedBox(height: 16),
                      _buildFeatureItem(
                        'Cloud backup',
                        'Never lose your business data',
                        isDark,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Go back or close
                          Get.back();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                          ),
                          foregroundColor: isDark
                              ? AppColors.darkPrimary
                              : AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Maybe Later',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to subscription tab (index 3)
                          final tabController =
                              Get.context!
                                      .findAncestorStateOfType<
                                        State<StatefulWidget>
                                      >()
                                      ?.widget
                                  as dynamic;
                          if (tabController != null) {
                            try {
                              (tabController as dynamic)._tabController
                                  ?.animateTo(3);
                            } catch (e) {
                              print('Could not switch tab: $e');
                            }
                          }
                        },
                        icon: Icon(Iconsax.crown_1, size: 20),
                        label: Text(
                          'View Plans',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'All offline features remain completely free',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getTextSecondary(isDark),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String subtitle, bool isDark) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Iconsax.tick_circle5, color: Colors.blue, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
