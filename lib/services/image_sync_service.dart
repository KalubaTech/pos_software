import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Service for uploading and syncing product images to remote server
class ImageSyncService extends GetxController {
  static const String uploadUrl = 'https://kalootech.com/image_upload.php';
  static const String baseImageUrl = 'https://kalootech.com/';

  // Image compression settings
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int jpegQuality = 85;
  static const int maxFileSizeKB = 500; // Max 500KB after compression

  // Upload progress tracking
  final RxDouble uploadProgress = 0.0.obs;
  final RxBool isUploading = false.obs;
  final RxString currentUploadFile = ''.obs;

  /// Compress image before upload
  /// Returns compressed image file or null if compression fails
  Future<File?> compressImage(File imageFile) async {
    try {
      print('🗜️ Compressing image: ${p.basename(imageFile.path)}');

      // Read image
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        print('❌ Failed to decode image');
        return null;
      }

      // Get original size
      final originalSizeKB = bytes.length / 1024;
      print('📏 Original size: ${originalSizeKB.toStringAsFixed(2)} KB');

      // Resize if larger than max dimensions
      if (image.width > maxImageWidth || image.height > maxImageHeight) {
        final aspectRatio = image.width / image.height;
        int newWidth, newHeight;

        if (image.width > image.height) {
          newWidth = maxImageWidth;
          newHeight = (maxImageWidth / aspectRatio).round();
        } else {
          newHeight = maxImageHeight;
          newWidth = (maxImageHeight * aspectRatio).round();
        }

        image = img.copyResize(image, width: newWidth, height: newHeight);
        print('📐 Resized to: ${image.width}x${image.height}');
      }

      // Compress to JPEG
      List<int> compressedBytes = img.encodeJpg(image, quality: jpegQuality);

      // Check if still too large
      double compressedSizeKB = compressedBytes.length / 1024;
      int quality = jpegQuality;

      // Further compression if needed
      while (compressedSizeKB > maxFileSizeKB && quality > 50) {
        quality -= 10;
        compressedBytes = img.encodeJpg(image, quality: quality);
        compressedSizeKB = compressedBytes.length / 1024;
        print('🔄 Re-compressing with quality: $quality');
      }

      print('✅ Compressed size: ${compressedSizeKB.toStringAsFixed(2)} KB');

      // Save compressed image to temp directory
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      print('❌ Error compressing image: $e');
      return null;
    }
  }

  /// Upload a local image file to the server
  /// Returns the remote image path or null if upload fails
  Future<String?> uploadImage(String localPath, {bool compress = true}) async {
    try {
      isUploading.value = true;
      uploadProgress.value = 0.0;
      currentUploadFile.value = p.basename(localPath);

      print('📤 Uploading image: $localPath');

      // Check if file exists
      File file = File(localPath);
      if (!await file.exists()) {
        print('❌ Image file not found: $localPath');
        isUploading.value = false;
        return null;
      }

      // Compress image if enabled
      if (compress) {
        uploadProgress.value = 0.2; // 20% - starting compression
        final compressedFile = await compressImage(file);
        if (compressedFile != null) {
          file = compressedFile;
          print('✅ Using compressed image');
        } else {
          print('⚠️ Compression failed, using original image');
        }
      }

      uploadProgress.value = 0.4; // 40% - preparing upload

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      uploadProgress.value = 0.5; // 50% - creating request

      // Add file to request
      request.files.add(await http.MultipartFile.fromPath('image', file.path));

      uploadProgress.value = 0.7; // 70% - sending request

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      uploadProgress.value = 0.9; // 90% - processing response

      if (response.statusCode == 200) {
        // Parse response
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final remotePath = jsonResponse['path'] as String;
          final fullUrl = baseImageUrl + remotePath;
          uploadProgress.value = 1.0; // 100% - complete
          print('✅ Image uploaded successfully: $fullUrl');

          // Clean up compressed file if created
          if (compress && file.path != localPath) {
            await file.delete();
          }

          isUploading.value = false;
          return fullUrl;
        } else {
          print('❌ Upload failed: ${jsonResponse['message']}');
          isUploading.value = false;
          return null;
        }
      } else {
        print('❌ Upload failed with status: ${response.statusCode}');
        isUploading.value = false;
        return null;
      }
    } catch (e) {
      print('❌ Error uploading image: $e');
      isUploading.value = false;
      uploadProgress.value = 0.0;
      return null;
    }
  }

  /// Upload image if it's a local file path
  /// Returns remote URL if uploaded, or original URL if already remote
  Future<String> processImageUrl(String imageUrl) async {
    // If already a remote URL, return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      print('ℹ️ Image already remote: $imageUrl');
      return imageUrl;
    }

    // If placeholder, return as is
    if (imageUrl.contains('placeholder')) {
      return imageUrl;
    }

    // Try to upload local file
    final remoteUrl = await uploadImage(imageUrl);
    if (remoteUrl != null) {
      return remoteUrl;
    }

    // If upload failed, return original (or placeholder)
    print('⚠️ Using original URL after upload failure');
    return imageUrl;
  }

  /// Batch upload multiple images
  /// Returns map of original paths to remote URLs
  Future<Map<String, String>> uploadMultipleImages(
    List<String> localPaths,
  ) async {
    final Map<String, String> results = {};

    for (var localPath in localPaths) {
      final remoteUrl = await processImageUrl(localPath);
      results[localPath] = remoteUrl;
    }

    return results;
  }

  /// Check if an image URL is a local file path
  bool isLocalImage(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return false;
    }
    if (imageUrl.contains('placeholder')) {
      return false;
    }
    return true;
  }

  /// Get local file path from image URL (if applicable)
  String? getLocalPath(String imageUrl) {
    if (isLocalImage(imageUrl)) {
      return imageUrl;
    }
    return null;
  }
}
