import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../controllers/product_controller.dart';
import '../services/image_storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class ImageEditorController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final ProductController _productController = Get.find();
  final ImageStorageService _imageStorageService = Get.find();

  // Current image being edited
  var currentImage = Rx<File?>(null);
  var originalImage = Rx<File?>(null);

  // Image dimensions
  var imageWidth = 0.0.obs;
  var imageHeight = 0.0.obs;

  // Saved images
  var savedImages = <SavedImageItem>[].obs;

  // UI State
  var isProcessing = false.obs;
  var selectedTool = 'none'.obs; // none, crop, resize, remove_bg

  // Resize values
  var resizeWidth = 0.0.obs;
  var resizeHeight = 0.0.obs;
  var maintainAspectRatio = true.obs;
  var aspectRatio = 1.0.obs;

  // Selected product for update
  var selectedProduct = Rx<ProductModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadSavedImages();
  }

  // Pick image from gallery or camera
  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        currentImage.value = file;
        originalImage.value = File(pickedFile.path);

        // Get image dimensions
        final bytes = await file.readAsBytes();
        final image = img.decodeImage(bytes);
        if (image != null) {
          imageWidth.value = image.width.toDouble();
          imageHeight.value = image.height.toDouble();
          resizeWidth.value = image.width.toDouble();
          resizeHeight.value = image.height.toDouble();
          aspectRatio.value = image.width / image.height;
        }

        // Don't add to history anymore
        // Just update dimensions

        Get.snackbar(
          'Success',
          'Image loaded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Crop image
  Future<void> cropImage() async {
    if (currentImage.value == null) return;

    try {
      isProcessing.value = true;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: currentImage.value!.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          WebUiSettings(context: Get.context!),
        ],
      );

      if (croppedFile != null) {
        final file = File(croppedFile.path);
        currentImage.value = file;

        // Update dimensions
        final bytes = await file.readAsBytes();
        final image = img.decodeImage(bytes);
        if (image != null) {
          imageWidth.value = image.width.toDouble();
          imageHeight.value = image.height.toDouble();
          resizeWidth.value = image.width.toDouble();
          resizeHeight.value = image.height.toDouble();
          aspectRatio.value = image.width / image.height;
        }

        Get.snackbar(
          'Success',
          'Image cropped successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to crop image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // Resize image
  Future<void> resizeImage(int width, int height) async {
    if (currentImage.value == null) return;

    try {
      isProcessing.value = true;

      final bytes = await currentImage.value!.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image != null) {
        final resized = img.copyResize(
          image,
          width: width,
          height: height,
          interpolation: img.Interpolation.linear,
        );

        // Save resized image
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = path.join(tempDir.path, 'resized_$timestamp.png');

        final file = File(filePath);
        await file.writeAsBytes(img.encodePng(resized));

        currentImage.value = file;
        imageWidth.value = width.toDouble();
        imageHeight.value = height.toDouble();
        resizeWidth.value = width.toDouble();
        resizeHeight.value = height.toDouble();

        Get.snackbar(
          'Success',
          'Image resized to ${width}x$height',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to resize image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // Remove background (simple implementation - can be enhanced with AI)
  Future<void> removeBackground() async {
    if (currentImage.value == null) return;

    try {
      isProcessing.value = true;

      final bytes = await currentImage.value!.readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage != null) {
        // Simple background removal based on color threshold
        // For production, consider using remove.bg API or ML model
        final processed = _simpleBackgroundRemoval(decodedImage);

        // Save processed image
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = path.join(tempDir.path, 'no_bg_$timestamp.png');

        final file = File(filePath);
        await file.writeAsBytes(img.encodePng(processed));

        currentImage.value = file;
        imageWidth.value = processed.width.toDouble();
        imageHeight.value = processed.height.toDouble();

        Get.snackbar(
          'Success',
          'Background removed (simple mode)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove background: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // Simple background removal algorithm
  img.Image _simpleBackgroundRemoval(img.Image image) {
    // Create a copy with alpha channel
    final output = img.Image(
      width: image.width,
      height: image.height,
      numChannels: 4,
    );

    // Sample corner pixels to determine background color
    final topLeftColor = image.getPixel(0, 0);
    final threshold = 30;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        // Calculate color difference from background
        final rDiff = (pixel.r - topLeftColor.r).abs();
        final gDiff = (pixel.g - topLeftColor.g).abs();
        final bDiff = (pixel.b - topLeftColor.b).abs();
        final diff = (rDiff + gDiff + bDiff) / 3;

        if (diff < threshold) {
          // Make transparent
          output.setPixelRgba(
            x,
            y,
            pixel.r.toInt(),
            pixel.g.toInt(),
            pixel.b.toInt(),
            0,
          );
        } else {
          // Keep original
          output.setPixelRgba(
            x,
            y,
            pixel.r.toInt(),
            pixel.g.toInt(),
            pixel.b.toInt(),
            255,
          );
        }
      }
    }

    return output;
  }

  // Rotate image
  Future<void> rotateImage(int degrees) async {
    if (currentImage.value == null) return;

    try {
      isProcessing.value = true;

      final bytes = await currentImage.value!.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image != null) {
        img.Image rotated;

        switch (degrees) {
          case 90:
            rotated = img.copyRotate(image, angle: 90);
            break;
          case 180:
            rotated = img.copyRotate(image, angle: 180);
            break;
          case 270:
            rotated = img.copyRotate(image, angle: 270);
            break;
          default:
            rotated = image;
        }

        // Save rotated image
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = path.join(tempDir.path, 'rotated_$timestamp.png');

        final file = File(filePath);
        await file.writeAsBytes(img.encodePng(rotated));

        currentImage.value = file;

        // Update dimensions
        imageWidth.value = rotated.width.toDouble();
        imageHeight.value = rotated.height.toDouble();
        resizeWidth.value = rotated.width.toDouble();
        resizeHeight.value = rotated.height.toDouble();

        Get.snackbar(
          'Success',
          'Image rotated $degrees degrees',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to rotate image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // Load saved images from persistent storage
  Future<void> _loadSavedImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('saved_images');

      if (savedData != null) {
        final List<dynamic> jsonList = jsonDecode(savedData);
        savedImages.value = jsonList
            .map((json) => SavedImageItem.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error loading saved images: $e');
    }
  }

  // Save saved images list to persistent storage
  Future<void> _saveSavedImagesList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = savedImages.map((item) => item.toJson()).toList();
      await prefs.setString('saved_images', jsonEncode(jsonList));
    } catch (e) {
      print('Error saving images list: $e');
    }
  }

  // Delete a saved image
  Future<void> deleteSavedImage(SavedImageItem item) async {
    try {
      // Delete file
      final file = File(item.path);
      if (await file.exists()) {
        await file.delete();
      }

      // Remove from list
      savedImages.removeWhere((i) => i.id == item.id);
      await _saveSavedImagesList();

      Get.snackbar(
        'Success',
        'Image deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Save current image to gallery/files
  Future<String?> saveImage() async {
    if (currentImage.value == null) return null;

    try {
      isProcessing.value = true;

      // Use ImageStorageService to save with proper structure
      final bytes = await currentImage.value!.readAsBytes();
      final extension = path
          .extension(currentImage.value!.path)
          .replaceAll('.', '');

      // Save using the image storage service for consistent storage
      final savedPath = await _imageStorageService.saveImageFromBytes(
        bytes,
        extension.isEmpty ? 'png' : extension,
      );

      if (savedPath != null) {
        // Decode image to get dimensions
        final decodedImage = img.decodeImage(bytes);

        // Add to saved images list
        final savedImageItem = SavedImageItem(
          id: const Uuid().v4(),
          path: savedPath,
          timestamp: DateTime.now(),
          width: decodedImage?.width.toDouble() ?? 0,
          height: decodedImage?.height.toDouble() ?? 0,
          fileSize: bytes.length,
          productId: selectedProduct.value?.id,
          productName: selectedProduct.value?.name,
        );

        savedImages.add(savedImageItem);
        await _saveSavedImagesList();

        Get.snackbar(
          'Success',
          'Image saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      return savedPath;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isProcessing.value = false;
    }
  }

  // Update product image

  Future<void> updateProductImage() async {
    if (selectedProduct.value == null) {
      Get.snackbar(
        'Error',
        'Please select a product first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (currentImage.value == null) {
      Get.snackbar(
        'Error',
        'No image to update',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isProcessing.value = true;

      print('📸 Updating product image for: ${selectedProduct.value!.name}');

      // Step 1: Delete old image if it exists and is local
      final oldImageUrl = selectedProduct.value!.imageUrl;
      if (oldImageUrl.isNotEmpty &&
          _imageStorageService.isLocalPath(oldImageUrl)) {
        print('🗑️ Deleting old image: $oldImageUrl');
        await _imageStorageService.deleteImage(oldImageUrl);
      }

      // Step 2: Save the new edited image to local storage
      print('💾 Saving new image to local storage...');
      final savedPath = await saveImage();

      if (savedPath != null) {
        print('✅ Image saved locally: $savedPath');

        // Step 3: Update product with new image path
        final updatedProduct = selectedProduct.value!.copyWith(
          imageUrl: savedPath,
        );

        print('📝 Updating product in local database...');
        final success = await _productController.updateProduct(updatedProduct);

        if (success) {
          print('✅ Product updated in local DB');
          print(
            '☁️ Cloud sync will be triggered automatically by ProductController',
          );

          Get.snackbar(
            'Success',
            'Product "${selectedProduct.value!.name}" updated with new image\n'
                'Syncing to cloud...',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          // Clear selection
          selectedProduct.value = null;
        } else {
          print('❌ Failed to update product in local DB');
          Get.snackbar(
            'Error',
            'Failed to update product in database',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        print('❌ Failed to save image');
      }
    } catch (e) {
      print('❌ Error updating product image: $e');
      Get.snackbar(
        'Error',
        'Failed to update product: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // Reset editor
  void reset() {
    currentImage.value = null;
    originalImage.value = null;
    selectedProduct.value = null;
    selectedTool.value = 'none';
    imageWidth.value = 0;
    imageHeight.value = 0;
  }

  // Calculate new height maintaining aspect ratio
  void updateWidthMaintainRatio(double newWidth) {
    if (maintainAspectRatio.value && aspectRatio.value > 0) {
      resizeWidth.value = newWidth;
      resizeHeight.value = newWidth / aspectRatio.value;
    } else {
      resizeWidth.value = newWidth;
    }
  }

  // Calculate new width maintaining aspect ratio
  void updateHeightMaintainRatio(double newHeight) {
    if (maintainAspectRatio.value && aspectRatio.value > 0) {
      resizeHeight.value = newHeight;
      resizeWidth.value = newHeight * aspectRatio.value;
    } else {
      resizeHeight.value = newHeight;
    }
  }
}

// Saved image item model
class SavedImageItem {
  final String id;
  final String path;
  final DateTime timestamp;
  final double width;
  final double height;
  final int fileSize;
  final String? productId;
  final String? productName;

  SavedImageItem({
    required this.id,
    required this.path,
    required this.timestamp,
    required this.width,
    required this.height,
    required this.fileSize,
    this.productId,
    this.productName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'timestamp': timestamp.toIso8601String(),
      'width': width,
      'height': height,
      'fileSize': fileSize,
      'productId': productId,
      'productName': productName,
    };
  }

  factory SavedImageItem.fromJson(Map<String, dynamic> json) {
    return SavedImageItem(
      id: json['id'],
      path: json['path'],
      timestamp: DateTime.parse(json['timestamp']),
      width: json['width'],
      height: json['height'],
      fileSize: json['fileSize'],
      productId: json['productId'],
      productName: json['productName'],
    );
  }
}

// Edit history item model (kept for backward compatibility, but not used)
class EditHistoryItem {
  final String action;
  final File imageFile;
  final DateTime timestamp;

  EditHistoryItem({
    required this.action,
    required this.imageFile,
    required this.timestamp,
  });
}
