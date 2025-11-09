import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ImageStorageService extends GetxController {
  static const String _imagesFolder = 'product_images';
  final _uuid = Uuid();

  // Get the app's document directory
  Future<Directory> get _imagesDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesPath = path.join(appDir.path, _imagesFolder);
    final directory = Directory(imagesPath);

    // Create directory if it doesn't exist
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  // Save image from file picker to local storage
  Future<String?> saveImage(XFile imageFile) async {
    try {
      final directory = await _imagesDirectory;
      final extension = path.extension(imageFile.path);
      final fileName = '${_uuid.v4()}$extension';
      final savedPath = path.join(directory.path, fileName);

      // Copy image to app directory
      final File sourceFile = File(imageFile.path);
      await sourceFile.copy(savedPath);

      return savedPath;
    } catch (e) {
      print('Error saving image: $e');
      Get.snackbar(
        'Error',
        'Failed to save image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Save image from bytes (useful for downloaded images)
  Future<String?> saveImageFromBytes(Uint8List bytes, String extension) async {
    try {
      final directory = await _imagesDirectory;
      final fileName = '${_uuid.v4()}.$extension';
      final savedPath = path.join(directory.path, fileName);

      final file = File(savedPath);
      await file.writeAsBytes(bytes);

      return savedPath;
    } catch (e) {
      print('Error saving image from bytes: $e');
      return null;
    }
  }

  // Delete an image
  Future<bool> deleteImage(String imagePath) async {
    try {
      if (imagePath.isEmpty) return true;

      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Check if image exists
  Future<bool> imageExists(String imagePath) async {
    if (imagePath.isEmpty) return false;
    final file = File(imagePath);
    return await file.exists();
  }

  // Get image file
  File? getImageFile(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    return File(imagePath);
  }

  // Copy image from one location to another (useful for duplicating products)
  Future<String?> copyImage(String sourcePath) async {
    try {
      if (sourcePath.isEmpty) return null;

      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return null;

      final directory = await _imagesDirectory;
      final extension = path.extension(sourcePath);
      final fileName = '${_uuid.v4()}$extension';
      final newPath = path.join(directory.path, fileName);

      await sourceFile.copy(newPath);
      return newPath;
    } catch (e) {
      print('Error copying image: $e');
      return null;
    }
  }

  // Get all images in the directory
  Future<List<String>> getAllImages() async {
    try {
      final directory = await _imagesDirectory;
      final files = directory.listSync();

      return files
          .where((file) => file is File)
          .map((file) => file.path)
          .toList();
    } catch (e) {
      print('Error getting all images: $e');
      return [];
    }
  }

  // Clean up unused images (call this periodically)
  Future<void> cleanupUnusedImages(List<String> usedImagePaths) async {
    try {
      final allImages = await getAllImages();

      for (final imagePath in allImages) {
        if (!usedImagePaths.contains(imagePath)) {
          await deleteImage(imagePath);
          print('Deleted unused image: $imagePath');
        }
      }
    } catch (e) {
      print('Error cleaning up images: $e');
    }
  }

  // Get image size
  Future<int> getImageSize(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      print('Error getting image size: $e');
      return 0;
    }
  }

  // Get total size of all images
  Future<int> getTotalImagesSize() async {
    try {
      final allImages = await getAllImages();
      int totalSize = 0;

      for (final imagePath in allImages) {
        totalSize += await getImageSize(imagePath);
      }

      return totalSize;
    } catch (e) {
      print('Error getting total images size: $e');
      return 0;
    }
  }

  // Format size in human-readable format
  String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  // Pick and save image from gallery/camera
  Future<String?> pickAndSaveImage({bool fromCamera = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return null;

      return await saveImage(image);
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Create a default placeholder image path
  String getPlaceholderPath() {
    return ''; // Empty string indicates no image
  }

  // Check if path is a valid local path
  bool isLocalPath(String? path) {
    if (path == null || path.isEmpty) return false;
    return !path.startsWith('http://') && !path.startsWith('https://');
  }

  // Migrate URL images to local storage (for existing products)
  Future<String?> migrateUrlToLocal(String url) async {
    try {
      if (isLocalPath(url)) return url; // Already local

      // Download image from URL
      final HttpClient httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        print('Failed to download image: ${response.statusCode}');
        return null;
      }

      // Get image bytes
      final bytes = await consolidateHttpClientResponseBytes(response);

      // Get extension from URL
      final uri = Uri.parse(url);
      final extension = path.extension(uri.path);

      // Save locally
      return await saveImageFromBytes(
        bytes,
        extension.isEmpty ? 'jpg' : extension.substring(1),
      );
    } catch (e) {
      print('Error migrating image: $e');
      return null;
    }
  }
}

// Helper function to consolidate bytes
Future<Uint8List> consolidateHttpClientResponseBytes(
  HttpClientResponse response,
) async {
  final completer = Completer<Uint8List>();
  final chunks = <List<int>>[];
  int contentLength = 0;

  response.listen(
    (List<int> chunk) {
      chunks.add(chunk);
      contentLength += chunk.length;
    },
    onDone: () {
      final bytes = Uint8List(contentLength);
      int offset = 0;
      for (final chunk in chunks) {
        bytes.setRange(offset, offset + chunk.length, chunk);
        offset += chunk.length;
      }
      completer.complete(bytes);
    },
    onError: (error) {
      completer.completeError(error);
    },
    cancelOnError: true,
  );

  return completer.future;
}
