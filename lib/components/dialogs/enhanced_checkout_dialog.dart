import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/business_settings_controller.dart';
import '../../services/printer_service.dart';
import '../../models/transaction_model.dart';
import '../../utils/colors.dart';
import '../../utils/currency_formatter.dart';

class EnhancedCheckoutDialog extends StatefulWidget {
  final CartController cartController;

  const EnhancedCheckoutDialog({super.key, required this.cartController});

  @override
  State<EnhancedCheckoutDialog> createState() => _EnhancedCheckoutDialogState();
}

class _EnhancedCheckoutDialogState extends State<EnhancedCheckoutDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PaymentMethod selectedMethod = PaymentMethod.cash;
  final TextEditingController amountController = TextEditingController();
  PrinterService? printerService;
  final AuthController authController = Get.find();
  bool printReceipt = false;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    amountController.text = widget.cartController.total.toStringAsFixed(2);

    // Try to get PrinterService if available (only on mobile)
    try {
      printerService = Get.find<PrinterService>();
      printReceipt = true;
    } catch (e) {
      // PrinterService not available (Windows/Web/Linux)
      printerService = null;
      printReceipt = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        constraints: BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildOrderSummary(),
                    SizedBox(height: 24),
                    _buildPaymentMethods(),
                    SizedBox(height: 24),
                    if (selectedMethod == PaymentMethod.cash)
                      _buildCashPayment(),
                    SizedBox(height: 24),
                    _buildPrintOption(),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Iconsax.card, color: Colors.white, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete Payment',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Obx(
                  () => Text(
                    'Cashier: ${authController.currentCashierName}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return FadeInUp(
      duration: Duration(milliseconds: 400),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.cartController.itemCount} items',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            Obx(
              () => _buildSummaryRow(
                'Subtotal',
                CurrencyFormatter.format(widget.cartController.subtotal),
              ),
            ),
            SizedBox(height: 8),
            Obx(
              () => _buildSummaryRow(
                'Tax (8%)',
                CurrencyFormatter.format(widget.cartController.tax),
              ),
            ),
            SizedBox(height: 8),
            Obx(() {
              if (widget.cartController.discount.value > 0) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: _buildSummaryRow(
                    'Discount',
                    '-${CurrencyFormatter.format(widget.cartController.discount.value)}',
                    color: Colors.green,
                  ),
                );
              }
              return SizedBox();
            }),
            Divider(height: 16),
            Obx(
              () => _buildSummaryRow(
                'TOTAL',
                CurrencyFormatter.format(widget.cartController.total),
                large: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool large = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: large ? 18 : 14,
            fontWeight: large ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: large ? 22 : 14,
            fontWeight: large ? FontWeight.bold : FontWeight.w600,
            color: color ?? (large ? AppColors.primary : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return FadeInUp(
      duration: Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildPaymentOption(PaymentMethod.cash, Iconsax.money, 'Cash'),
              _buildPaymentOption(PaymentMethod.card, Iconsax.card, 'Card'),
              _buildPaymentOption(
                PaymentMethod.mobile,
                Iconsax.mobile,
                'Mobile',
              ),
              _buildPaymentOption(
                PaymentMethod.other,
                Iconsax.wallet_3,
                'Other',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    PaymentMethod method,
    IconData icon,
    String label,
  ) {
    final isSelected = selectedMethod == method;

    return InkWell(
      onTap: () => setState(() => selectedMethod = method),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashPayment() {
    return FadeInUp(
      duration: Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount Received',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixIcon: Icon(Iconsax.dollar_circle, size: 28),
              hintText: '0.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
          SizedBox(height: 16),
          Obx(() {
            final amount = double.tryParse(amountController.text) ?? 0;
            final total = widget.cartController.total;
            final change = amount - total;

            if (change >= 0) {
              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Change:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    Obx(
                      () => Text(
                        CurrencyFormatter.format(change),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.warning_2, color: Colors.orange[700]),
                    SizedBox(width: 12),
                    Text(
                      'Amount received is less than total',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildPrintOption() {
    // Don't show print option if printer service not available
    if (printerService == null) {
      return SizedBox.shrink();
    }

    return FadeInUp(
      duration: Duration(milliseconds: 700),
      child: Obx(() {
        final isPrinterConnected = printerService!.isConnected.value;

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isPrinterConnected
                ? Colors.blue.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrinterConnected
                  ? Colors.blue.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Iconsax.printer,
                color: isPrinterConnected ? Colors.blue : Colors.grey[600],
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Print Receipt',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      isPrinterConnected
                          ? 'Printer connected'
                          : 'No printer connected',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Switch(
                value: printReceipt && isPrinterConnected,
                onChanged: isPrinterConnected
                    ? (value) => setState(() => printReceipt = value)
                    : null,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isProcessing ? null : () => Get.back(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: isProcessing
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Complete Payment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    if (selectedMethod == PaymentMethod.cash) {
      final amount = double.tryParse(amountController.text) ?? 0;
      if (amount < widget.cartController.total) {
        Get.snackbar('Error', 'Amount received is less than total');
        return;
      }
    }

    setState(() => isProcessing = true);

    final amount =
        double.tryParse(amountController.text) ?? widget.cartController.total;
    final success = await widget.cartController.checkout(
      paymentMethod: selectedMethod,
      amountPaid: amount,
      printReceipt:
          printReceipt && (printerService?.isConnected.value ?? false),
    );

    if (success) {
      Get.back();
      _showSuccessDialog(amount);
    } else {
      setState(() => isProcessing = false);
    }
  }

  void _showSuccessDialog(double amountPaid) {
    final change = amountPaid - widget.cartController.total;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeInDown(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.tick_circle,
                    size: 80,
                    color: Colors.green,
                  ),
                ),
              ),
              SizedBox(height: 24),
              FadeInUp(
                child: Text(
                  'Payment Successful!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Transaction completed successfully',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              if (selectedMethod == PaymentMethod.cash && change > 0) ...[
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Change to Return',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 8),
                      Obx(
                        () => Text(
                          CurrencyFormatter.format(change),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    amountController.dispose();
    super.dispose();
  }
}
