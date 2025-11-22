import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/image_editor_controller.dart';
import '../../controllers/product_controller.dart';

class ImageEditorView extends StatelessWidget {
  const ImageEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(ImageEditorController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        backgroundColor:  isDark ? Colors.black : Colors.grey[100],
        title: const Text('Image Editor', style: TextStyle(fontSize: 16)),
        centerTitle: false,
        actions: [
          // Save Image
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => controller.saveImage(),
            tooltip: 'Save Image',
          ),
          // Reset
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Reset Editor'),
                  content: const Text(
                    'Are you sure? This will clear all changes.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        controller.reset();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Toolbar
          Container(
            width: 80,
            color: isDark ? Colors.grey[850] : Colors.white,
            child: _buildToolbar(controller, context),
          ),
          // Main Canvas
          Expanded(child: _buildCanvas(controller, context)),
          // Right Panel (Properties & History)
          Container(
            width: 300,
            color: isDark ? Colors.grey[850] : Colors.white,
            child: _buildRightPanel(controller, context),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(controller, context),
    );
  }

  Widget _buildToolbar(ImageEditorController controller, BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildToolButton(
          icon: Iconsax.gallery_add,
          label: 'Load',
          onTap: () => _showLoadOptions(controller, context),
          controller: controller,
          context: context,
        ),
        const Divider(),
        _buildToolButton(
          icon: Iconsax.crop,
          label: 'Crop',
          onTap: () => controller.cropImage(),
          controller: controller,
          context: context,
        ),
        _buildToolButton(
          icon: Iconsax.size,
          label: 'Resize',
          onTap: () => controller.selectedTool.value = 'resize',
          controller: controller,
          context: context,
        ),
        _buildToolButton(
          icon: Iconsax.brush_1,
          label: 'Remove BG',
          onTap: () => _confirmBackgroundRemoval(controller, context),
          controller: controller,
          context: context,
        ),
        _buildToolButton(
          icon: Iconsax.rotate_left,
          label: 'Rotate L',
          onTap: () => controller.rotateImage(270),
          controller: controller,
          context: context,
        ),
        _buildToolButton(
          icon: Iconsax.rotate_right,
          label: 'Rotate R',
          onTap: () => controller.rotateImage(90),
          controller: controller,
          context: context,
        ),
        const Divider(),
        _buildToolButton(
          icon: Iconsax.save_2,
          label: 'Save',
          onTap: () => controller.saveImage(),
          controller: controller,
          context: context,
        ),
        _buildToolButton(
          icon: Iconsax.box,
          label: 'Product',
          onTap: () => _showProductSelector(controller, context),
          controller: controller,
          context: context,
        ),
      ],
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ImageEditorController controller,
    required BuildContext context,
  }) {
    return Obx(() {
      final hasImage = controller.currentImage.value != null;
      final isProcessing = controller.isProcessing.value;

      return Tooltip(
        message: label,
        child: InkWell(
          onTap: (hasImage && !isProcessing) ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: (hasImage && !isProcessing)
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: (hasImage && !isProcessing)
                        ? Theme.of(context).textTheme.bodySmall?.color
                        : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCanvas(ImageEditorController controller, BuildContext context) {
    return Obx(() {
      final image = controller.currentImage.value;
      final isProcessing = controller.isProcessing.value;

      if (isProcessing) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Processing...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        );
      }

      if (image == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.gallery_slash, size: 100, color: Colors.grey[400]),
              const SizedBox(height: 24),
              Text(
                'No Image Loaded',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showLoadOptions(controller, context),
                icon: const Icon(Iconsax.gallery_add),
                label: const Text('Load Image'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.file(image, fit: BoxFit.contain),
          ),
        ),
      );
    });
  }

  Widget _buildRightPanel(
    ImageEditorController controller,
    BuildContext context,
  ) {
    return Obx(() {
      final selectedTool = controller.selectedTool.value;

      return Column(
        children: [
          // Properties Section
          Expanded(
            child: selectedTool == 'resize'
                ? _buildResizePanel(controller, context)
                : _buildHistoryPanel(controller, context),
          ),
        ],
      );
    });
  }

  Widget _buildResizePanel(
    ImageEditorController controller,
    BuildContext context,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Resize Image',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        // Original dimensions
        Obx(
          () => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Original Size',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.imageWidth.value.toInt()} × ${controller.imageHeight.value.toInt()} px',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Aspect ratio lock
        Obx(
          () => SwitchListTile(
            title: const Text('Lock Aspect Ratio'),
            subtitle: Text(
              'Ratio: ${controller.aspectRatio.value.toStringAsFixed(2)}',
            ),
            value: controller.maintainAspectRatio.value,
            onChanged: (value) {
              controller.maintainAspectRatio.value = value;
            },
          ),
        ),

        const SizedBox(height: 16),

        // Width input
        Obx(
          () => TextField(
            decoration: const InputDecoration(
              labelText: 'Width (px)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Iconsax.arrow_right_3),
            ),
            keyboardType: TextInputType.number,
            controller: TextEditingController(
              text: controller.resizeWidth.value.toInt().toString(),
            ),
            onChanged: (value) {
              final width = double.tryParse(value);
              if (width != null && width > 0) {
                controller.updateWidthMaintainRatio(width);
              }
            },
          ),
        ),

        const SizedBox(height: 16),

        // Height input
        Obx(
          () => TextField(
            decoration: const InputDecoration(
              labelText: 'Height (px)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Iconsax.arrow_down_1),
            ),
            keyboardType: TextInputType.number,
            controller: TextEditingController(
              text: controller.resizeHeight.value.toInt().toString(),
            ),
            onChanged: (value) {
              final height = double.tryParse(value);
              if (height != null && height > 0) {
                controller.updateHeightMaintainRatio(height);
              }
            },
          ),
        ),

        const SizedBox(height: 24),

        // Preset sizes
        Text('Quick Presets', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _presetButton('256×256', 256, 256, controller),
            _presetButton('512×512', 512, 512, controller),
            _presetButton('1024×1024', 1024, 1024, controller),
            _presetButton('1920×1080', 1920, 1080, controller),
          ],
        ),

        const SizedBox(height: 24),

        // Apply button
        Obx(
          () => ElevatedButton.icon(
            onPressed: controller.isProcessing.value
                ? null
                : () {
                    controller.resizeImage(
                      controller.resizeWidth.value.toInt(),
                      controller.resizeHeight.value.toInt(),
                    );
                    controller.selectedTool.value = 'none';
                  },
            icon: const Icon(Iconsax.tick_circle),
            label: const Text('Apply Resize'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ),
      ],
    );
  }

  Widget _presetButton(
    String label,
    int width,
    int height,
    ImageEditorController controller,
  ) {
    return OutlinedButton(
      onPressed: () {
        controller.resizeWidth.value = width.toDouble();
        controller.resizeHeight.value = height.toDouble();
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildHistoryPanel(
    ImageEditorController controller,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Iconsax.gallery, size: 20),
              const SizedBox(width: 8),
              Text(
                'Saved Images',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Obx(() {
            if (controller.savedImages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.gallery, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No saved images yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Edit and save images to see them here',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: controller.savedImages.length,
              itemBuilder: (context, index) {
                final item = controller.savedImages[index];

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      // Load saved image into editor
                      controller.currentImage.value = File(item.path);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.file(
                            File(item.path),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 32),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.productName != null)
                                Text(
                                  item.productName!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              Text(
                                _formatTime(item.timestamp),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${item.width.toInt()}×${item.height.toInt()}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 18),
                                    onPressed: () {
                                      Get.dialog(
                                        AlertDialog(
                                          title: const Text('Delete Image'),
                                          content: const Text(
                                            'Are you sure you want to delete this saved image?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Get.back(),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                controller.deleteSavedImage(
                                                  item,
                                                );
                                                Get.back();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
    ImageEditorController controller,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() {
        final selectedProduct = controller.selectedProduct.value;
        final hasImage = controller.currentImage.value != null;

        return Row(
          children: [
            // Image info
            if (hasImage) ...[
              Icon(Iconsax.image, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                '${controller.imageWidth.value.toInt()} × ${controller.imageHeight.value.toInt()} px',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 24),
            ],

            // Selected product
            if (selectedProduct != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.box,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      selectedProduct.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => controller.selectedProduct.value = null,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Spacer(),

            // Action buttons
            if (hasImage) ...[
              OutlinedButton.icon(
                onPressed: () => controller.saveImage(),
                icon: const Icon(Iconsax.save_2),
                label: const Text('Save'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: selectedProduct != null
                    ? () => controller.updateProductImage()
                    : () => _showProductSelector(controller, context),
                icon: Icon(
                  selectedProduct != null ? Iconsax.tick_circle : Iconsax.box,
                ),
                label: Text(
                  selectedProduct != null ? 'Update Product' : 'Select Product',
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  void _showLoadOptions(
    ImageEditorController controller,
    BuildContext context,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Load Image',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const CircleAvatar(child: Icon(Iconsax.gallery)),
              title: const Text('From Gallery'),
              subtitle: const Text('Choose from your photos'),
              onTap: () {
                Get.back();
                controller.pickImage(source: ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const CircleAvatar(child: Icon(Iconsax.camera)),
              title: const Text('Take Photo'),
              subtitle: const Text('Use camera to capture'),
              onTap: () {
                Get.back();
                controller.pickImage(source: ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showProductSelector(
    ImageEditorController controller,
    BuildContext context,
  ) {
    final productController = Get.find<ProductController>();

    Get.dialog(
      AlertDialog(
        title: const Text('Select Product'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Obx(() {
            if (productController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final products = productController.products;

            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.box, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No products available',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: product.imageUrl.isNotEmpty
                        ? (product.imageUrl.startsWith('http')
                              ? NetworkImage(product.imageUrl)
                              : FileImage(File(product.imageUrl))
                                    as ImageProvider)
                        : null,
                    child: product.imageUrl.isEmpty
                        ? const Icon(Iconsax.box)
                        : null,
                  ),
                  title: Text(product.name),
                  subtitle: Text(product.category),
                  trailing: Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    controller.selectedProduct.value = product;
                    Get.back();
                  },
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _confirmBackgroundRemoval(
    ImageEditorController controller,
    BuildContext context,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Background'),
        content: const Text(
          'This will attempt to remove the background from your image. '
          'The simple algorithm works best with solid-color backgrounds.\n\n'
          'For professional results, consider using AI-powered services.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.removeBackground();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
