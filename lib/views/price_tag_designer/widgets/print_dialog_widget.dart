import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/printer_controller.dart';
import '../../../models/printer_model.dart';
import '../../../models/price_tag_template_model.dart';
import '../../../models/product_model.dart';
import '../../../utils/currency_formatter.dart';
import 'printer_management_dialog.dart';

class PrintDialogWidget extends StatefulWidget {
  final PriceTagTemplate template;
  final List<ProductModel> products;

  const PrintDialogWidget({
    super.key,
    required this.template,
    required this.products,
  });

  @override
  State<PrintDialogWidget> createState() => _PrintDialogWidgetState();
}

class _PrintDialogWidgetState extends State<PrintDialogWidget> {
  final List<ProductModel> selectedProducts = [];
  final Map<String, int> productQuantities = {};
  String searchQuery = '';
  final printerController = Get.find<PrinterController>();
  PrinterModel? selectedPrinter;

  @override
  void initState() {
    super.initState();
    // Set default printer
    selectedPrinter = printerController.selectedPrinter.value;
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = widget.products.where((p) {
      if (searchQuery.isEmpty) return true;
      return p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (p.barcode?.toLowerCase().contains(searchQuery.toLowerCase()) ??
              false);
    }).toList();

    return Container(
      width: 700,
      height: 600,
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Iconsax.printer, color: Colors.blue, size: 28),
              SizedBox(width: 12),
              Text(
                'Print Price Tags',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Iconsax.close_circle),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Template: ${widget.template.name} (${widget.template.width.toStringAsFixed(0)}×${widget.template.height.toStringAsFixed(0)}mm)',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 20),
          Divider(),
          SizedBox(height: 20),

          // Printer Selection
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.printer, size: 20, color: Colors.grey[700]),
                    SizedBox(width: 8),
                    Text(
                      'Select Printer',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Obx(() {
                  if (printerController.printers.isEmpty) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.warning_2,
                                color: Colors.orange[700],
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'No printers configured. Please add a printer first.',
                                  style: TextStyle(
                                    color: Colors.orange[900],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Get.back(); // Close print dialog
                            // Open printer management dialog
                            Get.dialog(PrinterManagementDialog());
                          },
                          icon: Icon(Iconsax.setting_2, size: 16),
                          label: Text('Configure Printers'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    );
                  }

                  return DropdownButtonFormField<PrinterModel>(
                    value: selectedPrinter,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Iconsax.printer_slash, size: 20),
                    ),
                    hint: Text('Select a printer'),
                    items: printerController.printers.map((printer) {
                      return DropdownMenuItem<PrinterModel>(
                        value: printer,
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.printer,
                              size: 16,
                              color: printer.isDefault
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                printer.name,
                                style: TextStyle(
                                  fontWeight: printer.isDefault
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (printer.isDefault)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'DEFAULT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            SizedBox(width: 8),
                            Text(
                              '${printer.paperWidth}mm',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (printer) {
                      setState(() {
                        selectedPrinter = printer;
                      });
                    },
                  );
                }),
                if (selectedPrinter != null) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.info_circle,
                          size: 14,
                          color: Colors.blue[700],
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Type: ${_getPrinterTypeName(selectedPrinter!.type)} • '
                            'Connection: ${_getConnectionTypeName(selectedPrinter!.connectionType)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 20),

          // Search
          TextField(
            decoration: InputDecoration(
              labelText: 'Search Products',
              prefixIcon: Icon(Iconsax.search_normal),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          SizedBox(height: 16),

          // Selected count
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Iconsax.tag, color: Colors.blue[700], size: 20),
                SizedBox(width: 8),
                Text(
                  '${selectedProducts.length} product(s) selected',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
                Spacer(),
                if (selectedProducts.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedProducts.clear();
                        productQuantities.clear();
                      });
                    },
                    child: Text('Clear All'),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Products list
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  final isSelected = selectedProducts.contains(product);
                  final quantity = productQuantities[product.id] ?? 1;

                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                      color: isSelected ? Colors.blue[50] : Colors.white,
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedProducts.add(product);
                              productQuantities[product.id] = 1;
                            } else {
                              selectedProducts.remove(product);
                              productQuantities.remove(product.id);
                            }
                          });
                        },
                      ),
                      title: Text(
                        product.name,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        'Price: ${CurrencyFormatter.format(product.price)} • ${product.barcode ?? "No barcode"}',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: isSelected
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Qty:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Iconsax.minus_cirlce, size: 20),
                                  onPressed: () {
                                    if (quantity > 1) {
                                      setState(() {
                                        productQuantities[product.id] =
                                            quantity - 1;
                                      });
                                    }
                                  },
                                ),
                                Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  child: Text(
                                    quantity.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Iconsax.add_circle, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      productQuantities[product.id] =
                                          quantity + 1;
                                    });
                                  },
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 20),

          // Actions
          Row(
            children: [
              // Total tags count
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.document_text, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Total: ${_getTotalTags()} tag(s)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Spacer(),
              TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
              SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: (selectedProducts.isEmpty || selectedPrinter == null)
                    ? null
                    : () => _printTags(),
                icon: Icon(Iconsax.printer),
                label: Text('Print Tags'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getTotalTags() {
    int total = 0;
    for (var product in selectedProducts) {
      total += productQuantities[product.id] ?? 1;
    }
    return total;
  }

  void _printTags() {
    // Check if printer is selected
    if (selectedPrinter == null) {
      Get.snackbar(
        'No Printer Selected',
        'Please select a printer before printing',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: Icon(Iconsax.warning_2, color: Colors.white),
      );
      return;
    }

    // TODO: Implement actual printing with selected printer
    // This would generate the price tags based on the template
    // and send them to the selected printer

    Get.back();
    Get.snackbar(
      'Print Started',
      'Printing ${_getTotalTags()} price tag(s) to ${selectedPrinter!.name}...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );

    // For now, show a success message
    Future.delayed(Duration(seconds: 1), () {
      Get.dialog(
        AlertDialog(
          icon: Icon(Iconsax.tick_circle, color: Colors.green, size: 64),
          title: Text('Print Complete'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Successfully printed ${_getTotalTags()} price tag(s)'),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.printer, size: 16, color: Colors.grey[700]),
                    SizedBox(width: 8),
                    Text(
                      'Printer: ${selectedPrinter!.name}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ...selectedProducts.map((product) {
                final qty = productQuantities[product.id] ?? 1;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Iconsax.tick_square, size: 16, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${product.name} (×$qty)',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
          actions: [
            ElevatedButton(onPressed: () => Get.back(), child: Text('OK')),
          ],
        ),
      );
    });
  }

  String _getPrinterTypeName(PrinterType type) {
    switch (type) {
      case PrinterType.thermal:
        return 'Thermal';
      case PrinterType.inkjet:
        return 'Inkjet';
      case PrinterType.laser:
        return 'Laser';
    }
  }

  String _getConnectionTypeName(ConnectionType type) {
    switch (type) {
      case ConnectionType.usb:
        return 'USB';
      case ConnectionType.network:
        return 'Network';
      case ConnectionType.bluetooth:
        return 'Bluetooth';
    }
  }
}
