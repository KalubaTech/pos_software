import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/printer_model.dart';
import '../services/database_service.dart';

class PrinterController extends GetxController {
  var printers = <PrinterModel>[].obs;
  var selectedPrinter = Rx<PrinterModel?>(null);
  var isLoading = false.obs;

  final _uuid = Uuid();
  final _dbService = Get.find<DatabaseService>();

  @override
  void onInit() {
    super.onInit();
    loadPrinters();
  }

  Future<void> loadPrinters() async {
    try {
      isLoading.value = true;
      final printersData = await _dbService.getAllPrinters();
      printers.value = printersData
          .map((data) => PrinterModel.fromJson(data))
          .toList();

      // Set the default printer as selected
      final defaultPrinter = printers.firstWhereOrNull((p) => p.isDefault);
      if (defaultPrinter != null) {
        selectedPrinter.value = defaultPrinter;
      } else if (printers.isNotEmpty) {
        selectedPrinter.value = printers.first;
      }
    } catch (e) {
      print('Error loading printers: $e');
      Get.snackbar('Error', 'Failed to load printers');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPrinter({
    required String name,
    required PrinterType type,
    required ConnectionType connectionType,
    String? address,
    int? port,
    int paperWidth = 80,
    bool setAsDefault = false,
  }) async {
    try {
      final printer = PrinterModel(
        id: _uuid.v4(),
        name: name,
        type: type,
        connectionType: connectionType,
        address: address,
        port: port,
        paperWidth: paperWidth,
        isDefault: setAsDefault,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _dbService.insertPrinter(printer.toJson());

      if (setAsDefault) {
        await _dbService.setDefaultPrinter(printer.id);
      }

      await loadPrinters();
      Get.snackbar('Success', 'Printer added successfully');
    } catch (e) {
      print('Error adding printer: $e');
      Get.snackbar('Error', 'Failed to add printer');
    }
  }

  Future<void> updatePrinter(PrinterModel printer) async {
    try {
      await _dbService.updatePrinter(printer.id, printer.toJson());
      await loadPrinters();
      Get.snackbar('Success', 'Printer updated successfully');
    } catch (e) {
      print('Error updating printer: $e');
      Get.snackbar('Error', 'Failed to update printer');
    }
  }

  Future<void> setDefaultPrinter(String printerId) async {
    try {
      await _dbService.setDefaultPrinter(printerId);
      await loadPrinters();
      Get.snackbar('Success', 'Default printer updated');
    } catch (e) {
      print('Error setting default printer: $e');
      Get.snackbar('Error', 'Failed to set default printer');
    }
  }

  Future<void> deletePrinter(String printerId) async {
    try {
      await _dbService.deletePrinter(printerId);
      await loadPrinters();
      Get.snackbar('Success', 'Printer deleted successfully');
    } catch (e) {
      print('Error deleting printer: $e');
      Get.snackbar('Error', 'Failed to delete printer');
    }
  }

  void selectPrinter(PrinterModel printer) {
    selectedPrinter.value = printer;
  }

  PrinterModel? getDefaultPrinter() {
    return printers.firstWhereOrNull((p) => p.isDefault);
  }
}
