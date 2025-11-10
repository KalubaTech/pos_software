import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/price_tag_template_model.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';

class PriceTagDesignerController extends GetxController {
  var templates = <PriceTagTemplate>[].obs;
  var currentTemplate = Rx<PriceTagTemplate?>(null);
  var selectedElement = Rx<PriceTagElement?>(null);
  var selectedElements = <PriceTagElement>[].obs;
  var selectedProducts = <ProductModel>[].obs;

  // Canvas settings
  var zoom = 1.0.obs;
  var showGrid = true.obs;
  var gridSize = 5.0.obs; // mm
  var snapToGrid = true.obs;

  // Panel collapse states
  var isTemplateListCollapsed = false.obs;
  var isPropertiesPanelCollapsed = false.obs;

  final _uuid = Uuid();
  final _dbService = Get.find<DatabaseService>();

  @override
  void onInit() {
    super.onInit();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      final loadedTemplates = await _dbService.getAllTemplates();
      if (loadedTemplates.isEmpty) {
        _createDefaultTemplates();
      } else {
        templates.value = loadedTemplates;
      }
    } catch (e) {
      print('Error loading templates: $e');
      _createDefaultTemplates();
    }
  }

  void _createDefaultTemplates() {
    if (templates.isEmpty) {
      // Create some default templates
      _createDefaultTemplate('Small Label (50x30mm)', 50, 30);
      _createDefaultTemplate('Medium Label (70x40mm)', 70, 40);
      _createDefaultTemplate('Large Label (100x60mm)', 100, 60);
    }
  }

  void _createDefaultTemplate(String name, double width, double height) {
    final template = PriceTagTemplate(
      id: _uuid.v4(),
      name: name,
      width: width,
      height: height,
      elements: [
        // Product name
        PriceTagElement(
          id: _uuid.v4(),
          type: ElementType.productName,
          x: 2,
          y: 2,
          width: width - 4,
          height: 8,
          text: 'Product Name',
          fontSize: 14,
          bold: true,
          dataField: 'name',
        ),
        // Price
        PriceTagElement(
          id: _uuid.v4(),
          type: ElementType.price,
          x: 2,
          y: height - 12,
          width: width - 4,
          height: 10,
          text: 'K 0.00',
          fontSize: 18,
          bold: true,
          dataField: 'price',
        ),
        // Barcode
        PriceTagElement(
          id: _uuid.v4(),
          type: ElementType.barcode,
          x: (width - 40) / 2,
          y: 12,
          width: 40,
          height: 15,
          dataField: 'barcode',
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    templates.add(template);
    _saveTemplates();
  }

  // Template Management
  void createNewTemplate(String name, double width, double height) {
    final template = PriceTagTemplate(
      id: _uuid.v4(),
      name: name,
      width: width,
      height: height,
      elements: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    templates.add(template);
    currentTemplate.value = template;
    _saveTemplates();
  }

  void selectTemplate(PriceTagTemplate template) {
    currentTemplate.value = template;
    selectedElement.value = null;
  }

  void deleteTemplate(String id) {
    templates.removeWhere((t) => t.id == id);
    if (currentTemplate.value?.id == id) {
      currentTemplate.value = null;
    }
    _saveTemplates();
  }

  void duplicateTemplate(PriceTagTemplate template) {
    final newTemplate = PriceTagTemplate(
      id: _uuid.v4(),
      name: '${template.name} (Copy)',
      width: template.width,
      height: template.height,
      elements: template.elements
          .map((e) => e.copyWith(id: _uuid.v4()))
          .toList(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    templates.add(newTemplate);
    _saveTemplates();
  }

  void updateTemplateName(String name) {
    if (currentTemplate.value != null) {
      currentTemplate.value = currentTemplate.value!.copyWith(
        name: name,
        updatedAt: DateTime.now(),
      );
      final index = templates.indexWhere(
        (t) => t.id == currentTemplate.value!.id,
      );
      if (index != -1) {
        templates[index] = currentTemplate.value!;
      }
      _saveTemplates();
    }
  }

  void updateTemplateSize(double width, double height) {
    if (currentTemplate.value != null) {
      currentTemplate.value = currentTemplate.value!.copyWith(
        width: width,
        height: height,
        updatedAt: DateTime.now(),
      );
      final index = templates.indexWhere(
        (t) => t.id == currentTemplate.value!.id,
      );
      if (index != -1) {
        templates[index] = currentTemplate.value!;
      }
      _saveTemplates();
    }
  }

  // Element Management
  void addElement(ElementType type) {
    if (currentTemplate.value == null) return;

    final element = PriceTagElement(
      id: _uuid.v4(),
      type: type,
      x: 10,
      y: 10,
      width: _getDefaultWidth(type),
      height: _getDefaultHeight(type),
      text: _getDefaultText(type),
      dataField: _getDefaultDataField(type),
      fontSize: type == ElementType.price ? 18 : 12,
      bold: type == ElementType.price || type == ElementType.productName,
    );

    final elements = List<PriceTagElement>.from(
      currentTemplate.value!.elements,
    );
    elements.add(element);

    currentTemplate.value = currentTemplate.value!.copyWith(
      elements: elements,
      updatedAt: DateTime.now(),
    );

    final index = templates.indexWhere(
      (t) => t.id == currentTemplate.value!.id,
    );
    if (index != -1) {
      templates[index] = currentTemplate.value!;
    }

    selectedElement.value = element;
    _saveTemplates();
  }

  void selectElement(PriceTagElement element) {
    selectedElement.value = element;
    selectedElements.clear();
    selectedElements.add(element);
  }

  void deselectElement() {
    selectedElement.value = null;
    selectedElements.clear();
  }

  void selectAllElements() {
    if (currentTemplate.value == null) return;
    selectedElements.value = List.from(currentTemplate.value!.elements);
    if (selectedElements.isNotEmpty) {
      selectedElement.value = selectedElements.first;
    }
  }

  void toggleElementSelection(PriceTagElement element) {
    if (selectedElements.any((e) => e.id == element.id)) {
      selectedElements.removeWhere((e) => e.id == element.id);
      if (selectedElements.isEmpty) {
        selectedElement.value = null;
      } else {
        selectedElement.value = selectedElements.first;
      }
    } else {
      selectedElements.add(element);
      selectedElement.value = element;
    }
  }

  void updateElement(PriceTagElement updatedElement, {bool save = true}) {
    if (currentTemplate.value == null) return;

    final elements = currentTemplate.value!.elements.map((e) {
      return e.id == updatedElement.id ? updatedElement : e;
    }).toList();

    currentTemplate.value = currentTemplate.value!.copyWith(
      elements: elements,
      updatedAt: DateTime.now(),
    );

    final index = templates.indexWhere(
      (t) => t.id == currentTemplate.value!.id,
    );
    if (index != -1) {
      templates[index] = currentTemplate.value!;
    }

    selectedElement.value = updatedElement;

    // Only save to database if requested (not during active drag/resize)
    if (save) {
      _saveTemplates();
    }
  }

  void deleteElement(String elementId) {
    if (currentTemplate.value == null) return;

    final elements = currentTemplate.value!.elements
        .where((e) => e.id != elementId)
        .toList();

    currentTemplate.value = currentTemplate.value!.copyWith(
      elements: elements,
      updatedAt: DateTime.now(),
    );

    final index = templates.indexWhere(
      (t) => t.id == currentTemplate.value!.id,
    );
    if (index != -1) {
      templates[index] = currentTemplate.value!;
    }

    if (selectedElement.value?.id == elementId) {
      selectedElement.value = null;
    }

    _saveTemplates();
  }

  void moveElement(
    String elementId,
    double dx,
    double dy, {
    bool save = false,
  }) {
    if (currentTemplate.value == null) return;

    final element = currentTemplate.value!.elements.firstWhere(
      (e) => e.id == elementId,
    );
    double newX = element.x + dx;
    double newY = element.y + dy;

    // Constrain to canvas without snapping during drag
    newX = newX.clamp(0, currentTemplate.value!.width - element.width);
    newY = newY.clamp(0, currentTemplate.value!.height - element.height);

    updateElement(
      element.copyWith(x: newX, y: newY),
      save: save,
    );
  }

  void snapElementToGrid(String elementId) {
    if (currentTemplate.value == null || !snapToGrid.value) {
      // Even if not snapping, save the final position
      _saveTemplates();
      return;
    }

    final element = currentTemplate.value!.elements.firstWhere(
      (e) => e.id == elementId,
    );

    double newX = (element.x / gridSize.value).round() * gridSize.value;
    double newY = (element.y / gridSize.value).round() * gridSize.value;
    double newWidth = (element.width / gridSize.value).round() * gridSize.value;
    double newHeight =
        (element.height / gridSize.value).round() * gridSize.value;

    // Apply minimum size constraints
    if (newWidth < 5.0) newWidth = 5.0;
    if (newHeight < 5.0) newHeight = 5.0;

    // Constrain to canvas
    newX = newX.clamp(0, currentTemplate.value!.width - newWidth);
    newY = newY.clamp(0, currentTemplate.value!.height - newHeight);
    newWidth = newWidth.clamp(5.0, currentTemplate.value!.width);
    newHeight = newHeight.clamp(5.0, currentTemplate.value!.height);

    updateElement(
      element.copyWith(x: newX, y: newY, width: newWidth, height: newHeight),
      save: true,
    ); // Save after snapping
  }

  void resizeElement(String elementId, double width, double height) {
    if (currentTemplate.value == null) return;

    final element = currentTemplate.value!.elements.firstWhere(
      (e) => e.id == elementId,
    );

    // Snap to grid if enabled
    if (snapToGrid.value) {
      width = (width / gridSize.value).round() * gridSize.value;
      height = (height / gridSize.value).round() * gridSize.value;
    }

    width = width.clamp(5.0, currentTemplate.value!.width);
    height = height.clamp(5.0, currentTemplate.value!.height);

    updateElement(element.copyWith(width: width, height: height));
  }

  // Canvas controls
  void setZoom(double value) {
    zoom.value = value.clamp(0.25, 4.0);
  }

  void toggleGrid() {
    showGrid.value = !showGrid.value;
  }

  void toggleSnapToGrid() {
    snapToGrid.value = !snapToGrid.value;
  }

  void setGridSize(double size) {
    gridSize.value = size;
  }

  // Panel controls
  void toggleTemplateList() {
    isTemplateListCollapsed.value = !isTemplateListCollapsed.value;
  }

  void togglePropertiesPanel() {
    isPropertiesPanelCollapsed.value = !isPropertiesPanelCollapsed.value;
  }

  // Product selection for printing
  void selectProductsForPrint(List<ProductModel> products) {
    selectedProducts.value = products;
  }

  void clearSelectedProducts() {
    selectedProducts.clear();
  }

  // Helper methods
  double _getDefaultWidth(ElementType type) {
    switch (type) {
      case ElementType.barcode:
        return 40;
      case ElementType.qrCode:
        return 20;
      case ElementType.line:
        return 30;
      default:
        return 40;
    }
  }

  double _getDefaultHeight(ElementType type) {
    switch (type) {
      case ElementType.barcode:
        return 15;
      case ElementType.qrCode:
        return 20;
      case ElementType.line:
        return 1;
      default:
        return 8;
    }
  }

  String _getDefaultText(ElementType type) {
    switch (type) {
      case ElementType.text:
        return 'Text';
      case ElementType.productName:
        return 'Product Name';
      case ElementType.price:
        return 'K 0.00';
      default:
        return '';
    }
  }

  String? _getDefaultDataField(ElementType type) {
    switch (type) {
      case ElementType.productName:
        return 'name';
      case ElementType.price:
        return 'price';
      case ElementType.barcode:
        return 'barcode';
      default:
        return null;
    }
  }

  void _saveTemplates() {
    // Save templates to local storage
    for (var template in templates) {
      _dbService.insertTemplate(template);
    }
  }

  Future<void> saveCurrentTemplate() async {
    if (currentTemplate.value != null) {
      await _dbService.insertTemplate(currentTemplate.value!);
      Get.snackbar(
        'Success',
        'Template saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    }
  }
}
