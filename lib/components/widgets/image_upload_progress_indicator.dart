import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/image_sync_service.dart';

/// Widget that displays image upload progress
class ImageUploadProgressIndicator extends StatelessWidget {
  final bool showFileName;
  final double? width;

  const ImageUploadProgressIndicator({
    super.key,
    this.showFileName = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final imageSyncService = Get.find<ImageSyncService>();

    return Obx(() {
      if (!imageSyncService.isUploading.value) {
        return SizedBox.shrink();
      }

      return Container(
        width: width,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Uploading Image...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (showFileName &&
                          imageSyncService
                              .currentUploadFile
                              .value
                              .isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          imageSyncService.currentUploadFile.value,
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: imageSyncService.uploadProgress.value,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                minHeight: 6,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '${(imageSyncService.uploadProgress.value * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Compact version for small spaces
class CompactImageUploadIndicator extends StatelessWidget {
  const CompactImageUploadIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final imageSyncService = Get.find<ImageSyncService>();

    return Obx(() {
      if (!imageSyncService.isUploading.value) {
        return SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Uploading ${(imageSyncService.uploadProgress.value * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Overlay version that appears at the bottom of the screen
class ImageUploadOverlay extends StatelessWidget {
  const ImageUploadOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final imageSyncService = Get.find<ImageSyncService>();

    return Obx(() {
      if (!imageSyncService.isUploading.value) {
        return SizedBox.shrink();
      }

      return Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: Center(
          child: ImageUploadProgressIndicator(width: 300, showFileName: true),
        ),
      );
    });
  }
}
