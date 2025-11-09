import 'package:get/get.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../models/receipt_model.dart';
import '../services/database_service.dart';
import '../controllers/auth_controller.dart';
import '../services/printer_service.dart';

class CartController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final AuthController _authController = Get.find<AuthController>();
  final PrinterService _printerService = Get.put(PrinterService());

  var cartItems = <CartItemModel>[].obs;
  var selectedCustomerId = ''.obs;
  var selectedCustomerName = ''.obs;
  var discount = 0.0.obs;

  double get subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  double get tax => subtotal * 0.08; // 8% tax
  double get total => subtotal + tax - discount.value;
  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  void addToCart(
    ProductModel product, {
    int quantity = 1,
    ProductVariant? variant,
  }) {
    // For products with variants, check if same variant exists
    final existingIndex = cartItems.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedVariant?.id == variant?.id,
    );

    if (existingIndex != -1) {
      // Check stock availability
      final currentQuantity = cartItems[existingIndex].quantity;
      final requestedQuantity = currentQuantity + quantity;
      final availableStock = variant?.stock ?? product.stock;

      if (product.trackInventory && requestedQuantity > availableStock) {
        Get.snackbar(
          'Insufficient Stock',
          'Only $availableStock items available',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      cartItems[existingIndex] = cartItems[existingIndex].copyWith(
        quantity: requestedQuantity,
      );
    } else {
      // Check stock for new item
      final availableStock = variant?.stock ?? product.stock;
      if (product.trackInventory && quantity > availableStock) {
        Get.snackbar(
          'Insufficient Stock',
          'Only $availableStock items available',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      cartItems.add(
        CartItemModel(
          product: product,
          selectedVariant: variant,
          quantity: quantity,
        ),
      );
    }

    final itemName = variant != null
        ? '${product.name} (${variant.name})'
        : product.name;
    Get.snackbar(
      'Added to Cart',
      '$itemName x$quantity',
      duration: Duration(seconds: 1),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void removeFromCart(String productId, {String? variantId}) {
    cartItems.removeWhere(
      (item) =>
          item.product.id == productId &&
          (variantId == null || item.selectedVariant?.id == variantId),
    );
  }

  void updateQuantity(String productId, int quantity, {String? variantId}) {
    if (quantity <= 0) {
      removeFromCart(productId, variantId: variantId);
      return;
    }

    final index = cartItems.indexWhere(
      (item) =>
          item.product.id == productId &&
          (variantId == null || item.selectedVariant?.id == variantId),
    );

    if (index != -1) {
      // Check stock availability
      final availableStock = cartItems[index].availableStock;
      if (cartItems[index].product.trackInventory &&
          quantity > availableStock) {
        Get.snackbar(
          'Insufficient Stock',
          'Only $availableStock items available',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      cartItems[index] = cartItems[index].copyWith(quantity: quantity);
    }
  }

  void clearCart() {
    cartItems.clear();
    selectedCustomerId.value = '';
    selectedCustomerName.value = '';
    discount.value = 0.0;
  }

  void setCustomer(String id, String name) {
    selectedCustomerId.value = id;
    selectedCustomerName.value = name;
  }

  void applyDiscount(double amount) {
    discount.value = amount;
  }

  Future<bool> checkout({
    PaymentMethod paymentMethod = PaymentMethod.cash,
    double amountPaid = 0,
    bool printReceipt = true,
  }) async {
    if (cartItems.isEmpty) {
      Get.snackbar('Error', 'Cart is empty');
      return false;
    }

    try {
      final cashierName = _authController.currentCashierName;
      final cashierId = _authController.currentCashierId;

      final transaction = TransactionModel(
        id: 't${DateTime.now().millisecondsSinceEpoch}',
        storeId: 's1',
        transactionDate: DateTime.now(),
        items: List.from(cartItems),
        subtotal: subtotal,
        tax: tax,
        discount: discount.value,
        total: total,
        status: TransactionStatus.completed,
        paymentMethod: paymentMethod,
        customerId: selectedCustomerId.value.isEmpty
            ? null
            : selectedCustomerId.value,
        customerName: selectedCustomerName.value.isEmpty
            ? null
            : selectedCustomerName.value,
        cashierId: cashierId,
        cashierName: cashierName,
      );

      // Save transaction to database
      await _dbService.insertTransaction(transaction);

      // Generate and print receipt if requested
      if (printReceipt) {
        final receipt = _generateReceipt(transaction, amountPaid);
        if (_printerService.isConnected.value) {
          await _printerService.printReceipt(receipt);
        }
      }

      Get.snackbar(
        'Success',
        'Transaction completed successfully',
        duration: Duration(seconds: 2),
      );

      clearCart();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to complete transaction: $e');
      return false;
    }
  }

  ReceiptModel _generateReceipt(
    TransactionModel transaction,
    double amountPaid,
  ) {
    return ReceiptModel(
      id: 'r${DateTime.now().millisecondsSinceEpoch}',
      transactionId: transaction.id,
      storeId: transaction.storeId,
      storeName: 'Dynamos POS',
      storeAddress: '123 Main Street, City, State 12345',
      storePhone: '+1 (555) 123-4567',
      timestamp: transaction.transactionDate,
      cashierId: transaction.cashierId,
      cashierName: transaction.cashierName,
      items: transaction.items
          .map(
            (item) => ReceiptItem(
              name: item.displayName, // Use displayName which includes variant
              quantity: item.quantity,
              price: item
                  .unitPrice, // Use unitPrice which includes variant adjustment
              total: item.subtotal,
            ),
          )
          .toList(),
      subtotal: transaction.subtotal,
      tax: transaction.tax,
      discount: transaction.discount,
      total: transaction.total,
      paymentMethod: transaction.paymentMethod.name,
      amountPaid: amountPaid > 0 ? amountPaid : transaction.total,
      change: amountPaid > transaction.total
          ? amountPaid - transaction.total
          : 0,
      customerName: transaction.customerName,
      receiptNumber:
          'RCP${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
    );
  }
}
