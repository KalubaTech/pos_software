import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LocalImageWidget extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const LocalImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // If no image path, show placeholder
    if (imagePath == null || imagePath!.isEmpty) {
      return _buildPlaceholder();
    }

    // Check if it's a URL (use CachedNetworkImage for remote images)
    if (imagePath!.startsWith('http://') || imagePath!.startsWith('https://')) {
      // Safe conversion of width/height for cache settings
      int? cacheWidth;
      int? cacheHeight;

      if (width != null && width!.isFinite && width! > 0) {
        cacheWidth = width!.toInt();
      }
      if (height != null && height!.isFinite && height! > 0) {
        cacheHeight = height!.toInt();
      }

      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: CachedNetworkImage(
          imageUrl: imagePath!,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) => _buildError(),
          // Cache settings for optimal performance
          memCacheWidth: cacheWidth,
          memCacheHeight: cacheHeight,
          maxWidthDiskCache: 1024,
          maxHeightDiskCache: 1024,
        ),
      );
    }

    // Local file image
    final file = File(imagePath!);

    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildPlaceholder();
        }

        if (snapshot.hasData && snapshot.data == true) {
          return ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.zero,
            child: Image.file(
              file,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                return _buildError();
              },
            ),
          );
        }

        return _buildError();
      },
    );
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) return placeholder!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      child: Center(
        child: Icon(
          Iconsax.image,
          size: (width != null && width! < 100) ? 24 : 48,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildError() {
    if (errorWidget != null) return errorWidget!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.gallery_slash,
              size: (width != null && width! < 100) ? 20 : 40,
              color: Colors.grey[400],
            ),
            if (width == null || width! >= 100) ...[
              SizedBox(height: 8),
              Text(
                'Image not found',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Circular avatar version
class LocalImageAvatar extends StatelessWidget {
  final String? imagePath;
  final double radius;
  final Color? backgroundColor;

  const LocalImageAvatar({
    super.key,
    required this.imagePath,
    this.radius = 20,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[200],
      child: ClipOval(
        child: LocalImageWidget(
          imagePath: imagePath,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: Icon(
            Iconsax.image,
            size: radius,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }
}
