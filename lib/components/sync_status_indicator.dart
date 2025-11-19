import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../services/firedart_sync_service.dart'; // Using Firedart instead!
import '../utils/colors.dart';

/// Widget to display current sync status
class SyncStatusIndicator extends StatelessWidget {
  final bool showLabel;
  final double iconSize;
  final bool compact;

  const SyncStatusIndicator({
    super.key,
    this.showLabel = true,
    this.iconSize = 16,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final syncService = Get.find<FiredartSyncService>();

      return Obx(() {
        // Syncing state
        if (syncService.isSyncing.value) {
          return _buildStatus(
            icon: SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.blue),
              ),
            ),
            label: 'Syncing...',
            color: Colors.blue,
          );
        }

        // Offline state
        if (!syncService.isOnline.value) {
          return _buildStatus(
            icon: Icon(
              Iconsax.cloud_cross,
              color: Colors.orange,
              size: iconSize,
            ),
            label: 'Offline',
            color: Colors.orange,
          );
        }

        // Error state
        if (syncService.syncErrors.isNotEmpty) {
          return _buildStatus(
            icon: Icon(Iconsax.warning_2, color: Colors.red, size: iconSize),
            label: '${syncService.syncErrors.length} errors',
            color: Colors.red,
          );
        }

        // Synced state
        return _buildStatus(
          icon: Icon(Iconsax.cloud_change, color: Colors.green, size: iconSize),
          label: _formatLastSync(syncService.lastSyncTime.value),
          color: Colors.green,
        );
      });
    } catch (e) {
      // SyncService not initialized
      return _buildStatus(
        icon: Icon(Iconsax.cloud_minus, color: Colors.grey, size: iconSize),
        label: 'Not syncing',
        color: Colors.grey,
      );
    }
  }

  Widget _buildStatus({
    required Widget icon,
    required String label,
    required Color color,
  }) {
    if (compact) {
      return Tooltip(message: label, child: icon);
    }

    if (!showLabel) {
      return icon;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatLastSync(DateTime? time) {
    if (time == null) return 'Synced';

    final difference = DateTime.now().difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Sync status badge - larger version for settings page
class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      final syncService = Get.find<FiredartSyncService>();

      return Obx(() {
        final stats = syncService.getSyncStats();
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.getDivider(isDark)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.cloud_connection,
                    color: syncService.isOnline.value
                        ? Colors.green
                        : Colors.orange,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cloud Sync',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          syncService.isOnline.value
                              ? 'Connected'
                              : 'Offline Mode',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (syncService.isSyncing.value)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              SizedBox(height: 16),
              Divider(color: AppColors.getDivider(isDark)),
              SizedBox(height: 16),
              _buildStatRow(
                'Last Synced',
                _formatDateTime(syncService.lastSyncTime.value),
                isDark,
              ),
              SizedBox(height: 8),
              _buildStatRow('Queued Items', '${stats['queuedItems']}', isDark),
              SizedBox(height: 8),
              _buildStatRow(
                'Active Listeners',
                '${stats['activeListeners']}',
                isDark,
              ),
              if (syncService.syncErrors.isNotEmpty) ...[
                SizedBox(height: 8),
                _buildStatRow(
                  'Errors',
                  '${stats['errors']}',
                  isDark,
                  color: Colors.red,
                ),
              ],
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      syncService.isOnline.value && !syncService.isSyncing.value
                      ? () => syncService.syncNow()
                      : null,
                  icon: Icon(Iconsax.refresh, size: 18),
                  label: Text('Sync Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      });
    } catch (e) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Sync not available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
  }

  Widget _buildStatRow(
    String label,
    String value,
    bool isDark, {
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.getTextPrimary(isDark),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime? time) {
    if (time == null) return 'Never';

    final difference = DateTime.now().difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
  }
}
