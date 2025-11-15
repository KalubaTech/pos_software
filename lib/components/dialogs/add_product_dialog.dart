import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/product_controller.dart';
import '../../controllers/appearance_controller.dart';
import '../../models/product_model.dart';
import '../../utils/colors.dart';
import '../../services/image_storage_service.dart';
import '../../components/widgets/local_image_widget.dart';

class AddProductDialog extends StatefulWidget {
  final ProductModel? product;

  const AddProductDialog({super.key, this.product});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();

  String _selectedCategory = 'Beverages';
  String _selectedUnit = 'pcs';
  bool _trackInventory = true;
  String? _imageUrl;
  File? _localImage;

  final List<ProductVariant> _variants = [];
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _loadProductData(widget.product!);
    } else {
      _generateSKU();
      _minStockController.text = '10'; // Set default min stock
    }
  }

  void _loadProductData(ProductModel product) {
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toString();
    _costPriceController.text = product.costPrice?.toString() ?? '';
    _stockController.text = product.stock.toString();
    _minStockController.text = product.minStock.toString();
    _skuController.text = product.sku ?? '';
    _barcodeController.text = product.barcode ?? '';
    _selectedCategory = product.category;
    _selectedUnit = product.unit ?? 'pcs';
    _trackInventory = product.trackInventory;
    _imageUrl = product.imageUrl;
    if (product.variants != null) {
      _variants.addAll(product.variants!);
    }
  }

  void _generateSKU() {
    final category = _selectedCategory.substring(0, 3).toUpperCase();
    final name = _nameController.text.isEmpty
        ? 'PRD'
        : _nameController.text.substring(0, 3).toUpperCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(8);
    _skuController.text = '$category-$name-$timestamp';
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final appearanceController = Get.find<AppearanceController>();
    final isDark = appearanceController.isDarkMode.value;

    return Theme(
      data: isDark
          ? ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: AppColors.darkPrimary,
                surface: AppColors.darkSurface,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.darkSurfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.getDivider(true)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.getDivider(true)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.darkPrimary,
                    width: 2,
                  ),
                ),
                labelStyle: TextStyle(color: AppColors.getTextSecondary(true)),
                hintStyle: TextStyle(color: AppColors.getTextTertiary(true)),
              ),
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: AppColors.getTextPrimary(true)),
                bodyMedium: TextStyle(color: AppColors.getTextPrimary(true)),
              ),
            )
          : ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
                surface: Colors.white,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
      child: Dialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 900,
          height: 700,
          child: Column(
            children: [
              _buildHeader(isEdit, isDark),
              Expanded(
                child: Row(
                  children: [
                    _buildStepper(isDark),
                    Expanded(child: _buildStepContent(isDark)),
                  ],
                ),
              ),
              _buildFooter(isEdit, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEdit, bool isDark) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.darkPrimary,
                  AppColors.darkPrimary.withValues(alpha: 0.8),
                ]
              : [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.box_add, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Edit Product' : 'Add New Product',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Fill in the product details',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          Spacer(),
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(bool isDark) {
    final steps = [
      {'icon': Iconsax.box, 'label': 'Basic Info'},
      {'icon': Iconsax.dollar_circle, 'label': 'Pricing'},
      {'icon': Iconsax.category_2, 'label': 'Variants'},
      {'icon': Iconsax.verify, 'label': 'Review'},
    ];

    return Container(
      width: 200,
      padding: EdgeInsets.all(24),
      color: isDark ? AppColors.darkSurfaceVariant : Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive
                        ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                        : isCompleted
                        ? Colors.green
                        : (isDark ? Colors.grey[700] : Colors.grey[300]),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : step['icon'] as IconData,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step['label'] as String,
                    style: TextStyle(
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isActive
                          ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                          : AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(bool isDark) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: _getStepWidget(isDark),
      ),
    );
  }

  Widget _getStepWidget(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep(isDark);
      case 1:
        return _buildPricingStep(isDark);
      case 2:
        return _buildVariantsStep(isDark);
      case 3:
        return _buildReviewStep(isDark);
      default:
        return _buildBasicInfoStep(isDark);
    }
  }

  Widget _buildBasicInfoStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        SizedBox(height: 24),
        _buildImagePicker(isDark),
        SizedBox(height: 24),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Product Name *',
            prefixIcon: Icon(Iconsax.box),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Product name is required' : null,
          onChanged: (_) => _generateSKU(),
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            prefixIcon: Icon(Iconsax.text),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          maxLines: 3,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Icon(Iconsax.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    [
                          'Beverages',
                          'Food',
                          'Electronics',
                          'Clothing',
                          'Home & Garden',
                          'Health & Beauty',
                          'Sports',
                          'Books',
                          'Toys',
                          'Other',
                        ]
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                    _generateSKU();
                  });
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedUnit,
                decoration: InputDecoration(
                  labelText: 'Unit *',
                  prefixIcon: Icon(Iconsax.box_1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ['pcs', 'kg', 'g', 'L', 'ml', 'box', 'pack']
                    .map(
                      (unit) =>
                          DropdownMenuItem(value: unit, child: Text(unit)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedUnit = value!);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _skuController,
                decoration: InputDecoration(
                  labelText: 'SKU',
                  prefixIcon: Icon(Iconsax.barcode),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Iconsax.refresh),
                    onPressed: _generateSKU,
                    tooltip: 'Generate SKU',
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: 'Barcode (EAN-13)',
                  prefixIcon: Icon(Iconsax.scan_barcode),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pricing & Inventory',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Selling Price *',
                  prefixIcon: Icon(Iconsax.dollar_circle),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Price is required';
                  if (double.tryParse(value!) == null) return 'Invalid price';
                  return null;
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _costPriceController,
                decoration: InputDecoration(
                  labelText: 'Cost Price',
                  prefixIcon: Icon(Iconsax.money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (_costPriceController.text.isNotEmpty &&
            _priceController.text.isNotEmpty)
          _buildProfitMarginCard(),
        SizedBox(height: 24),
        SwitchListTile(
          value: _trackInventory,
          onChanged: (value) => setState(() => _trackInventory = value),
          title: Text('Track Inventory'),
          subtitle: Text('Enable stock management for this product'),
          secondary: Icon(Iconsax.box_tick),
        ),
        if (_trackInventory) ...[
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _stockController,
                  decoration: InputDecoration(
                    labelText: 'Initial Stock *',
                    prefixIcon: Icon(Iconsax.box),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixText: _selectedUnit,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (!_trackInventory) return null;
                    if (value?.isEmpty ?? true) return 'Stock is required';
                    if (int.tryParse(value!) == null) return 'Invalid stock';
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _minStockController,
                  decoration: InputDecoration(
                    labelText: 'Minimum Stock Level',
                    prefixIcon: Icon(Iconsax.danger),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixText: _selectedUnit,
                    helperText: 'Alert when stock falls below this',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildProfitMarginCard() {
    final costPrice = double.tryParse(_costPriceController.text) ?? 0;
    final sellingPrice = double.tryParse(_priceController.text) ?? 0;
    final profit = sellingPrice - costPrice;
    final margin = costPrice > 0 ? ((profit / costPrice) * 100) : 0;

    return Card(
      color: margin > 0 ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              margin > 0 ? Iconsax.arrow_up : Iconsax.arrow_down,
              color: margin > 0 ? Colors.green : Colors.red,
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profit Margin',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  '${margin.toStringAsFixed(1)}% (\$${profit.toStringAsFixed(2)})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: margin > 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantsStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Product Variants',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _addVariant,
              icon: Icon(Iconsax.add, color: Colors.white),
              label: Text('Add Variant', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          'Add variations like size, color, or storage capacity',
          style: TextStyle(color: Colors.grey[600]),
        ),
        SizedBox(height: 24),
        if (_variants.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(Iconsax.category_2, size: 64, color: Colors.grey[300]),
                SizedBox(height: 16),
                Text(
                  'No variants added yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'Click "Add Variant" to create product variations',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _variants.length,
            itemBuilder: (context, index) =>
                _buildVariantCard(_variants[index], index),
          ),
      ],
    );
  }

  Widget _buildVariantCard(ProductVariant variant, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            variant.name[0],
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(variant.name),
        subtitle: Text(
          '${variant.attributeType} • Stock: ${variant.stock} • +\$${variant.priceAdjustment.toStringAsFixed(2)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Iconsax.edit, size: 20),
              onPressed: () => _editVariant(index),
            ),
            IconButton(
              icon: Icon(Iconsax.trash, size: 20, color: Colors.red),
              onPressed: () => setState(() => _variants.removeAt(index)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep(bool isDark) {
    final sellingPrice = double.tryParse(_priceController.text) ?? 0;
    final costPrice = double.tryParse(_costPriceController.text) ?? 0;
    final stock = int.tryParse(_stockController.text) ?? 0;
    final minStock = int.tryParse(_minStockController.text) ?? 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Product',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 24),
        if (_imageUrl != null || _localImage != null)
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _localImage != null
                  ? Image.file(
                      _localImage!,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    )
                  : LocalImageWidget(
                      imagePath: _imageUrl,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        SizedBox(height: 24),
        _buildReviewRow('Product Name', _nameController.text),
        _buildReviewRow('Category', _selectedCategory),
        _buildReviewRow('Description', _descriptionController.text),
        Divider(height: 32),
        _buildReviewRow('SKU', _skuController.text),
        _buildReviewRow(
          'Barcode',
          _barcodeController.text.isEmpty ? 'Not set' : _barcodeController.text,
        ),
        Divider(height: 32),
        _buildReviewRow(
          'Selling Price',
          '\$${sellingPrice.toStringAsFixed(2)}',
        ),
        if (costPrice > 0)
          _buildReviewRow('Cost Price', '\$${costPrice.toStringAsFixed(2)}'),
        if (_trackInventory) ...[
          _buildReviewRow('Stock', '$stock $_selectedUnit'),
          _buildReviewRow('Min Stock', '$minStock $_selectedUnit'),
        ],
        if (_variants.isNotEmpty) ...[
          Divider(height: 32),
          Text(
            'Variants (${_variants.length})',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          ..._variants.map(
            (v) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                '• ${v.name} (+\$${v.priceAdjustment.toStringAsFixed(2)})',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildImagePicker(bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[400]!,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: _imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LocalImageWidget(
                    imagePath: _imageUrl,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.gallery_add,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add Image',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isEdit, bool isDark) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton.icon(
              onPressed: () => setState(() => _currentStep--),
              icon: Icon(Icons.arrow_back),
              label: Text('Back'),
            )
          else
            SizedBox(),
          Row(
            children: [
              TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
              SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _currentStep < 3
                    ? () {
                        if (_currentStep == 0 || _currentStep == 1) {
                          if (_formKey.currentState?.validate() ?? false) {
                            setState(() => _currentStep++);
                          }
                        } else {
                          setState(() => _currentStep++);
                        }
                      }
                    : _saveProduct,
                icon: Icon(
                  _currentStep < 3 ? Icons.arrow_forward : Iconsax.tick_circle,
                  color: Colors.white,
                ),
                label: Text(
                  _currentStep < 3 ? 'Next' : (isEdit ? 'Update' : 'Create'),
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final imageStorageService = Get.find<ImageStorageService>();

    // Show options: Gallery or Camera
    final source = await Get.dialog<ImageSource>(
      AlertDialog(
        title: Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Iconsax.gallery),
              title: Text('Gallery'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Iconsax.camera),
              title: Text('Camera'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final savedPath = await imageStorageService.pickAndSaveImage(
      fromCamera: source == ImageSource.camera,
    );

    if (savedPath != null) {
      setState(() {
        _imageUrl = savedPath; // Store local path
        _localImage = File(savedPath);
      });

      Get.snackbar(
        'Success',
        'Image saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 1),
      );
    }
  }

  void _addVariant() {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final priceController = TextEditingController(text: '0.00');
    final stockController = TextEditingController(text: '0');
    final skuController = TextEditingController();
    final barcodeController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Variant',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Variant Name (e.g., Large, Red, 128GB)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: typeController,
                decoration: InputDecoration(
                  labelText: 'Attribute Type (e.g., Size, Color, Storage)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Price Adjustment',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: stockController,
                      decoration: InputDecoration(
                        labelText: 'Stock',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: skuController,
                decoration: InputDecoration(
                  labelText: 'Variant SKU (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: barcodeController,
                decoration: InputDecoration(
                  labelText: 'Variant Barcode (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 13,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty &&
                          typeController.text.isNotEmpty) {
                        setState(() {
                          _variants.add(
                            ProductVariant(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              name: nameController.text,
                              attributeType: typeController.text,
                              priceAdjustment:
                                  double.tryParse(priceController.text) ?? 0,
                              stock: int.tryParse(stockController.text) ?? 0,
                              sku: skuController.text.isEmpty
                                  ? null
                                  : skuController.text,
                              barcode: barcodeController.text.isEmpty
                                  ? null
                                  : barcodeController.text,
                            ),
                          );
                        });
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text('Add', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editVariant(int index) {
    final variant = _variants[index];
    final nameController = TextEditingController(text: variant.name);
    final typeController = TextEditingController(text: variant.attributeType);
    final priceController = TextEditingController(
      text: variant.priceAdjustment.toString(),
    );
    final stockController = TextEditingController(
      text: variant.stock.toString(),
    );
    final skuController = TextEditingController(text: variant.sku ?? '');
    final barcodeController = TextEditingController(
      text: variant.barcode ?? '',
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Variant',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Variant Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: typeController,
                decoration: InputDecoration(
                  labelText: 'Attribute Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Price Adjustment',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: stockController,
                      decoration: InputDecoration(
                        labelText: 'Stock',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: skuController,
                decoration: InputDecoration(
                  labelText: 'Variant SKU',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: barcodeController,
                decoration: InputDecoration(
                  labelText: 'Variant Barcode',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty &&
                          typeController.text.isNotEmpty) {
                        setState(() {
                          _variants[index] = ProductVariant(
                            id: variant.id,
                            name: nameController.text,
                            attributeType: typeController.text,
                            priceAdjustment:
                                double.tryParse(priceController.text) ?? 0,
                            stock: int.tryParse(stockController.text) ?? 0,
                            sku: skuController.text.isEmpty
                                ? null
                                : skuController.text,
                            barcode: barcodeController.text.isEmpty
                                ? null
                                : barcodeController.text,
                          );
                        });
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text(
                      'Update',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProduct() {
    if (_formKey.currentState?.validate() ?? false) {
      final controller = Get.find<ProductController>();

      final product = ProductModel(
        id:
            widget.product?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        storeId: 'store-001', // Default store ID
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0,
        category: _selectedCategory,
        imageUrl: _imageUrl ?? 'https://via.placeholder.com/300',
        stock: int.tryParse(_stockController.text) ?? 0,
        minStock: int.tryParse(_minStockController.text) ?? 10,
        sku: _skuController.text.isEmpty ? null : _skuController.text,
        barcode: _barcodeController.text.isEmpty
            ? null
            : _barcodeController.text,
        unit: _selectedUnit,
        trackInventory: _trackInventory,
        costPrice: _costPriceController.text.isEmpty
            ? null
            : double.tryParse(_costPriceController.text),
        variants: _variants.isEmpty ? null : _variants,
        lastRestocked: DateTime.now(),
      );

      if (widget.product != null) {
        controller.updateProduct(product);
        Get.back();
        Get.snackbar(
          'Success',
          'Product updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        controller.addProduct(product);
        Get.back();
        Get.snackbar(
          'Success',
          'Product added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }
}
