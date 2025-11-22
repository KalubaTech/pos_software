import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/universal_sync_controller.dart';
import '../../controllers/appearance_controller.dart';
import '../../services/subscription_service.dart';
import '../../services/firedart_sync_service.dart';
import '../../utils/colors.dart';
import '../../utils/responsive.dart';
import 'package:intl/intl.dart';

class SyncSettingsView extends StatelessWidget {
  const SyncSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final syncController = Get.find<UniversalSyncController>();
    final appearanceController = Get.find<AppearanceController>();
    final subscriptionService = Get.find<SubscriptionService>();
    final firedartSync = Get.find<FiredartSyncService>();

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
            _buildHeader(context, syncController, firedartSync, isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(syncController, firedartSync, isDark),
                    SizedBox(height: 24),
                    _buildSyncedDataCard(syncController, isDark),
                    SizedBox(height: 24),
                    _buildActionsCard(syncController, firedartSync, isDark),
                    SizedBox(height: 24),
                    _buildInfoCard(isDark),
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
    UniversalSyncController syncController,
    FiredartSyncService firedartSync,
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
                    Icon(Iconsax.refresh_2, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Cloud Sync',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Obx(() {
                      if (syncController.isSyncing.value) {
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
                        firedartSync.isOnline.value
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
                  'Firebase Firestore • Real-time sync',
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
                          Icon(
                            Iconsax.refresh_2,
                            color: Colors.white,
                            size: 32,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Cloud Sync',
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
                        'Firebase Firestore • Real-time bidirectional synchronization',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Obx(() {
                  if (syncController.isSyncing.value) {
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
                    firedartSync.isOnline.value
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

  Widget _buildStatusCard(
    UniversalSyncController syncController,
    FiredartSyncService firedartSync,
    bool isDark,
  ) {
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
              final isOnline = firedartSync.isOnline.value;
              final isSyncing = syncController.isSyncing.value;
              final businessId = firedartSync.businessId;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Connection Status
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline ? Colors.green : Colors.red,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        isOnline ? 'Connected' : 'Offline',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                      Spacer(),
                      if (isSyncing)
                        Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Syncing...',
                              style: TextStyle(
                                color: AppColors.getTextSecondary(isDark),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(color: AppColors.getDivider(isDark)),
                  SizedBox(height: 16),
                  // Business ID
                  _buildInfoRow(
                    'Business ID',
                    businessId ?? 'Not configured',
                    Iconsax.building,
                    isDark,
                  ),
                  SizedBox(height: 12),
                  // Sync Provider
                  _buildInfoRow(
                    'Provider',
                    'Firebase Firestore',
                    Iconsax.cloud,
                    isDark,
                  ),
                  SizedBox(height: 12),
                  // Sync Status
                  _buildInfoRow(
                    'Status',
                    syncController.syncStatus.value.isEmpty
                        ? 'Ready'
                        : syncController.syncStatus.value,
                    Iconsax.info_circle,
                    isDark,
                  ),
                  SizedBox(height: 16),
                  // Last Sync Time
                  Obx(() {
                    final lastSync = firedartSync.lastSyncTime.value;
                    if (lastSync != null) {
                      final diff = DateTime.now().difference(lastSync);
                      String timeAgo;
                      if (diff.inMinutes < 1) {
                        timeAgo = 'Just now';
                      } else if (diff.inHours < 1) {
                        timeAgo =
                            '${diff.inMinutes} minute${diff.inMinutes > 1 ? "s" : ""} ago';
                      } else if (diff.inDays < 1) {
                        timeAgo =
                            '${diff.inHours} hour${diff.inHours > 1 ? "s" : ""} ago';
                      } else {
                        timeAgo = DateFormat('MMM d, h:mm a').format(lastSync);
                      }

                      return Row(
                        children: [
                          Icon(
                            Iconsax.clock,
                            size: 16,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Last sync: ',
                            style: TextStyle(
                              color: AppColors.getTextSecondary(isDark),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              color: AppColors.getTextPrimary(isDark),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    }
                    return Text(
                      'Never synced',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  }),
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
                      'Real-time bidirectional sync with Firebase Firestore',
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

  Widget _buildSyncedDataCard(
    UniversalSyncController syncController,
    bool isDark,
  ) {
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
                  Iconsax.data,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                ),
                SizedBox(width: 12),
                Text(
                  'Synced Data',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            _buildDataTypeRow(
              'Products',
              'Inventory, pricing, categories',
              Iconsax.box,
              Colors.blue,
              isDark,
            ),
            SizedBox(height: 12),
            _buildDataTypeRow(
              'Transactions',
              'Sales, receipts, payments',
              Iconsax.receipt,
              Colors.green,
              isDark,
            ),
            SizedBox(height: 12),
            _buildDataTypeRow(
              'Customers',
              'Contact info, purchase history',
              Iconsax.user,
              Colors.purple,
              isDark,
            ),
            SizedBox(height: 12),
            _buildDataTypeRow(
              'Wallet',
              'Business wallet balance',
              Iconsax.wallet,
              Colors.orange,
              isDark,
            ),
            SizedBox(height: 12),
            _buildDataTypeRow(
              'Subscriptions',
              'Plan and billing info',
              Iconsax.crown,
              Colors.amber,
              isDark,
            ),
            SizedBox(height: 12),
            _buildDataTypeRow(
              'Settings',
              'Store configuration',
              Iconsax.setting_2,
              Colors.teal,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTypeRow(
    String title,
    String description,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          SizedBox(width: 14),
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
                SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
          Icon(Iconsax.tick_circle5, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  Widget _buildActionsCard(
    UniversalSyncController syncController,
    FiredartSyncService firedartSync,
    bool isDark,
  ) {
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
                onPressed: () async {
                  await syncController.performFullSync();
                  Get.snackbar(
                    'Sync Complete',
                    'All data synced: Products, Transactions, Customers, Wallets, Subscriptions & Settings',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: Duration(seconds: 3),
                  );
                },
                icon: Icon(Iconsax.refresh),
                label: Text('Sync All Data Now'),
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
            SizedBox(height: 8),
            Text(
              'Syncs: Products, Transactions, Customers, Templates, Cashiers, Wallets, Subscriptions & Settings',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.getTextSecondary(isDark),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await syncController.forceSubscriptionSync();
                      Get.snackbar(
                        'Subscription Synced',
                        'Subscription data refreshed',
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                        duration: Duration(seconds: 2),
                      );
                    },
                    icon: Icon(Iconsax.crown),
                    label: Text('Sync Subscription'),
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
                    onPressed: () async {
                      await syncController.syncBusinessSettingsNow();
                      Get.snackbar(
                        'Settings Synced',
                        'Business settings refreshed',
                        backgroundColor: Colors.teal,
                        colorText: Colors.white,
                        duration: Duration(seconds: 2),
                      );
                    },
                    icon: Icon(Iconsax.setting_2),
                    label: Text('Sync Settings'),
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
            SizedBox(height: 16),
            Obx(() {
              final syncQueue = firedartSync.syncQueue;
              if (syncQueue.isNotEmpty) {
                return Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.timer, size: 20, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${syncQueue.length} item${syncQueue.length > 1 ? "s" : ""} in offline queue',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.getTextPrimary(isDark),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Will sync when connection is restored',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.getTextSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
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
                  Iconsax.information,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                ),
                SizedBox(width: 12),
                Text(
                  'About Cloud Sync',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Your data is automatically synchronized with Firebase Firestore in real-time. This ensures all your devices stay up-to-date with the latest information.',
              style: TextStyle(
                color: AppColors.getTextSecondary(isDark),
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.shield_tick, size: 20, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure & Reliable',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(isDark),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Industry-standard encryption and backup',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.flash_1, size: 20, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Real-time Updates',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(isDark),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Changes appear instantly on all devices',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.wifi, size: 20, color: Colors.purple),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Offline Support',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(isDark),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Work offline, sync automatically when back online',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                      ],
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
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppColors.getTextPrimary(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
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
                        'Real-time Sync',
                        'Data updates instantly across all devices',
                        isDark,
                      ),
                      SizedBox(height: 16),
                      _buildFeatureItem(
                        'Cloud Backup',
                        'Never lose your business data',
                        isDark,
                      ),
                      SizedBox(height: 16),
                      _buildFeatureItem(
                        'Multi-device Access',
                        'Work seamlessly from any device',
                        isDark,
                      ),
                      SizedBox(height: 16),
                      _buildFeatureItem(
                        'Offline Support',
                        'Syncs automatically when back online',
                        isDark,
                      ),
                      SizedBox(height: 16),
                      _buildFeatureItem(
                        'Secure Storage',
                        'Enterprise-grade security',
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
                        onPressed: () => Get.back(),
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
                          // Navigate to subscription view
                          Get.toNamed('/settings/subscription');
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
