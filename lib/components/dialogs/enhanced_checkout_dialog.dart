import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/appearance_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../controllers/business_settings_controller.dart';
import '../../services/printer_service.dart';
import '../../services/wallet_service.dart';
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
    final appearanceController = Get.find<AppearanceController>();
    final isDark = appearanceController.isDarkMode.value;

    return Dialog(
      backgroundColor: AppColors.getSurfaceColor(isDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        constraints: BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildOrderSummary(isDark),
                    SizedBox(height: 24),
                    _buildPaymentMethods(isDark),
                    SizedBox(height: 24),
                    if (selectedMethod == PaymentMethod.cash)
                      _buildCashPayment(isDark),
                    SizedBox(height: 24),
                    _buildPrintOption(isDark),
                  ],
                ),
              ),
            ),
            _buildFooter(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
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

  Widget _buildOrderSummary(bool isDark) {
    return FadeInUp(
      duration: Duration(milliseconds: 400),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.getDivider(isDark)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          (isDark ? AppColors.darkPrimary : AppColors.primary)
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.cartController.itemCount} items',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 24, color: AppColors.getDivider(isDark)),
            Obx(
              () => _buildSummaryRow(
                'Subtotal',
                CurrencyFormatter.format(widget.cartController.subtotal),
                isDark: isDark,
              ),
            ),
            SizedBox(height: 8),
            Obx(() {
              final settings = Get.find<BusinessSettingsController>();
              // Force recalculation by reading settings inside Obx
              final taxAmount = settings.taxEnabled.value
                  ? widget.cartController.subtotal *
                        (settings.taxRate.value / 100)
                  : 0.0;

              if (settings.taxEnabled.value && taxAmount > 0) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: _buildSummaryRow(
                    '${settings.taxName.value} (${settings.taxRate.value.toStringAsFixed(1)}%)',
                    CurrencyFormatter.format(taxAmount),
                    isDark: isDark,
                  ),
                );
              }
              return SizedBox();
            }),
            Obx(() {
              if (widget.cartController.discount.value > 0) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: _buildSummaryRow(
                    'Discount',
                    '-${CurrencyFormatter.format(widget.cartController.discount.value)}',
                    color: Colors.green,
                    isDark: isDark,
                  ),
                );
              }
              return SizedBox();
            }),
            Divider(height: 16, color: AppColors.getDivider(isDark)),
            Obx(() {
              final settings = Get.find<BusinessSettingsController>();
              // Recalculate tax inside Obx for reactivity
              final taxAmount = settings.taxEnabled.value
                  ? widget.cartController.subtotal *
                        (settings.taxRate.value / 100)
                  : 0.0;
              final totalAmount =
                  widget.cartController.subtotal +
                  taxAmount -
                  widget.cartController.discount.value;

              return _buildSummaryRow(
                'TOTAL',
                CurrencyFormatter.format(totalAmount),
                large: true,
                isDark: isDark,
              );
            }),
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
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: large ? 18 : 14,
            fontWeight: large ? FontWeight.bold : FontWeight.normal,
            color: color ?? AppColors.getTextPrimary(isDark),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: large ? 22 : 14,
            fontWeight: large ? FontWeight.bold : FontWeight.w600,
            color:
                color ??
                (large
                    ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                    : AppColors.getTextPrimary(isDark)),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods(bool isDark) {
    // Get settings controller
    final settings = Get.find<BusinessSettingsController>();

    // Check if wallet is enabled
    bool isWalletEnabled = false;
    try {
      final walletController = Get.find<WalletController>();
      isWalletEnabled = walletController.isEnabled.value;
    } catch (e) {
      // WalletController not found, wallet is not enabled
      isWalletEnabled = false;
    }

    // Check if mobile (small screen)
    final isMobile = MediaQuery.of(Get.context!).size.width < 600;

    return FadeInUp(
      duration: Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          SizedBox(height: 16),

          // Use dropdown on mobile, grid on desktop
          if (isMobile)
            _buildPaymentDropdown(isDark, isWalletEnabled, settings)
          else
            _buildPaymentGrid(isDark, isWalletEnabled, settings),

          // Show info message if wallet is disabled
          if (!isWalletEnabled && settings.acceptMobile.value) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.info_circle, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mobile money payments require KalooMoney wallet. Enable it in Settings.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.blue[200] : Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentDropdown(
    bool isDark,
    bool isWalletEnabled,
    BusinessSettingsController settings,
  ) {
    // Build payment methods list based on settings
    final paymentMethods = <Map<String, dynamic>>[];

    if (settings.acceptCash.value) {
      paymentMethods.add({
        'method': PaymentMethod.cash,
        'icon': Iconsax.money,
        'label': 'Cash',
      });
    }

    if (settings.acceptCard.value) {
      paymentMethods.add({
        'method': PaymentMethod.card,
        'icon': Iconsax.card,
        'label': 'Card',
      });
    }

    // Show mobile money if setting is enabled (regardless of wallet status)
    if (settings.acceptMobile.value) {
      paymentMethods.add({
        'method': PaymentMethod.mobile,
        'icon': Iconsax.mobile,
        'label': 'Mobile Money',
      });
    }

    // Always show "Other" as a fallback
    paymentMethods.add({
      'method': PaymentMethod.other,
      'icon': Iconsax.wallet_3,
      'label': 'Other',
    });

    // Ensure selected method is in the list, otherwise default to first available
    if (!paymentMethods.any((m) => m['method'] == selectedMethod)) {
      setState(() {
        selectedMethod = paymentMethods.first['method'] as PaymentMethod;
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getDivider(isDark)),
      ),
      child: DropdownButtonFormField<PaymentMethod>(
        value: selectedMethod,
        isExpanded: true,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          prefixIcon: Icon(
            paymentMethods.firstWhere(
              (m) => m['method'] == selectedMethod,
            )['icon'],
            color: isDark ? AppColors.darkPrimary : AppColors.primary,
          ),
        ),
        dropdownColor: AppColors.getSurfaceColor(isDark),
        style: TextStyle(color: AppColors.getTextPrimary(isDark), fontSize: 16),
        items: paymentMethods.map((method) {
          return DropdownMenuItem<PaymentMethod>(
            value: method['method'] as PaymentMethod,
            child: Row(
              children: [
                Icon(
                  method['icon'] as IconData,
                  size: 20,
                  color: AppColors.getTextSecondary(isDark),
                ),
                SizedBox(width: 12),
                Text(method['label'] as String),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => selectedMethod = value);
          }
        },
      ),
    );
  }

  Widget _buildPaymentGrid(
    bool isDark,
    bool isWalletEnabled,
    BusinessSettingsController settings,
  ) {
    // Build payment options list based on settings
    final paymentOptions = <Widget>[];

    if (settings.acceptCash.value) {
      paymentOptions.add(
        _buildPaymentOption(PaymentMethod.cash, Iconsax.money, 'Cash', isDark),
      );
    }

    if (settings.acceptCard.value) {
      paymentOptions.add(
        _buildPaymentOption(PaymentMethod.card, Iconsax.card, 'Card', isDark),
      );
    }

    // Show mobile money if setting is enabled (regardless of wallet status)
    if (settings.acceptMobile.value) {
      paymentOptions.add(
        _buildPaymentOption(
          PaymentMethod.mobile,
          Iconsax.mobile,
          'Mobile',
          isDark,
        ),
      );
    }

    // Always show "Other" as a fallback
    paymentOptions.add(
      _buildPaymentOption(
        PaymentMethod.other,
        Iconsax.wallet_3,
        'Other',
        isDark,
      ),
    );

    // Ensure selected method is available, otherwise default to first
    final availableMethods = <PaymentMethod>[];
    if (settings.acceptCash.value) availableMethods.add(PaymentMethod.cash);
    if (settings.acceptCard.value) availableMethods.add(PaymentMethod.card);
    if (settings.acceptMobile.value) availableMethods.add(PaymentMethod.mobile);
    availableMethods.add(PaymentMethod.other);

    if (!availableMethods.contains(selectedMethod)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedMethod = availableMethods.first;
        });
      });
    }

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: paymentOptions.length > 3 ? 4 : paymentOptions.length,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.85,
      physics: NeverScrollableScrollPhysics(),
      children: paymentOptions,
    );
  }

  Widget _buildPaymentOption(
    PaymentMethod method,
    IconData icon,
    String label,
    bool isDark,
  ) {
    final isSelected = selectedMethod == method;

    return InkWell(
      onTap: () => setState(() => selectedMethod = method),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkPrimary : AppColors.primary)
              : (isDark ? AppColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                : AppColors.getDivider(isDark),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Colors.white
                  : AppColors.getTextSecondary(isDark),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : AppColors.getTextPrimary(isDark),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashPayment(bool isDark) {
    return FadeInUp(
      duration: Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount Received',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Iconsax.dollar_circle,
                size: 28,
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
              ),
              hintText: '0.00',
              hintStyle: TextStyle(color: AppColors.getTextSecondary(isDark)),
              filled: true,
              fillColor: isDark
                  ? AppColors.darkSurfaceVariant
                  : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getDivider(isDark)),
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
                  color: Colors.green.withValues(alpha: isDark ? 0.2 : 0.1),
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
                        color: isDark ? Colors.green[400] : Colors.green[700],
                      ),
                    ),
                    Obx(
                      () => Text(
                        CurrencyFormatter.format(change),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.green[400] : Colors.green[700],
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
                  color: Colors.orange.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.warning_2,
                      color: isDark ? Colors.orange[400] : Colors.orange[700],
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Amount received is less than total',
                      style: TextStyle(
                        color: isDark ? Colors.orange[400] : Colors.orange[700],
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

  Widget _buildPrintOption(bool isDark) {
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
                ? (isDark
                      ? Colors.blue.withValues(alpha: 0.2)
                      : Colors.blue.withValues(alpha: 0.05))
                : (isDark
                      ? Colors.grey.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrinterConnected
                  ? (isDark
                        ? Colors.blue.withValues(alpha: 0.4)
                        : Colors.blue.withValues(alpha: 0.2))
                  : (isDark
                        ? Colors.grey.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.2)),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Iconsax.printer,
                color: isPrinterConnected
                    ? (isDark ? Colors.blue[400] : Colors.blue)
                    : AppColors.getTextSecondary(isDark),
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
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    Text(
                      isPrinterConnected
                          ? 'Printer connected'
                          : 'No printer connected',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: printReceipt && isPrinterConnected,
                onChanged: isPrinterConnected
                    ? (value) => setState(() => printReceipt = value)
                    : null,
                activeColor: isDark ? AppColors.darkPrimary : AppColors.primary,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFooter(bool isDark) {
    final isMobile = MediaQuery.of(Get.context!).size.width < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              children: [
                // Complete Payment button (full width on mobile)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.primary,
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
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
                SizedBox(height: 12),
                // Cancel button (full width on mobile)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isProcessing ? null : () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.getDivider(isDark)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: AppColors.getTextSecondary(isDark),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isProcessing ? null : () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.getDivider(isDark)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: AppColors.getTextSecondary(isDark),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
                      backgroundColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.primary,
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
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
    // If mobile payment is selected, show mobile money dialog
    if (selectedMethod == PaymentMethod.mobile) {
      Get.back(); // Close checkout dialog first
      _showMobileMoneyDialog();
      return;
    }

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

  void _showMobileMoneyDialog() {
    final phoneController = TextEditingController();
    final nameController = TextEditingController();
    String selectedOperator = 'Airtel Money';
    final operators = ['Airtel Money', 'MTN Mobile Money', 'Zamtel Kwacha'];

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          final appearanceController = Get.find<AppearanceController>();
          final isDark = appearanceController.isDarkMode.value;

          return Dialog(
            backgroundColor: AppColors.getSurfaceColor(isDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: 500,
              constraints: BoxConstraints(maxHeight: 600),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  (isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.primary)
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Iconsax.mobile,
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.primary,
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mobile Money Payment',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.getTextPrimary(isDark),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Pay with KalooMoney Wallet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.getTextSecondary(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),

                      // Amount Display
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                              (isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.primary)
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Amount to Pay',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.getTextSecondary(isDark),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              CurrencyFormatter.format(
                                widget.cartController.total,
                              ),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Customer Name
                      TextField(
                        controller: nameController,
                        style: TextStyle(
                          color: AppColors.getTextPrimary(isDark),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Customer Name (Optional)',
                          labelStyle: TextStyle(
                            color: AppColors.getTextSecondary(isDark),
                          ),
                          prefixIcon: Icon(
                            Iconsax.user,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkSurfaceVariant
                              : Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.getDivider(isDark),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Phone Number
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                          color: AppColors.getTextPrimary(isDark),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Phone Number *',
                          labelStyle: TextStyle(
                            color: AppColors.getTextSecondary(isDark),
                          ),
                          hintText: '0977123456',
                          hintStyle: TextStyle(
                            color: AppColors.getTextSecondary(isDark),
                          ),
                          prefixIcon: Icon(
                            Iconsax.call,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkSurfaceVariant
                              : Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.getDivider(isDark),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Payment Method Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedOperator,
                        style: TextStyle(
                          color: AppColors.getTextPrimary(isDark),
                        ),
                        dropdownColor: AppColors.getSurfaceColor(isDark),
                        decoration: InputDecoration(
                          labelText: 'Payment Method *',
                          labelStyle: TextStyle(
                            color: AppColors.getTextSecondary(isDark),
                          ),
                          prefixIcon: Icon(
                            Iconsax.wallet_3,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkSurfaceVariant
                              : Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.getDivider(isDark),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        items: operators.map((String operator) {
                          return DropdownMenuItem<String>(
                            value: operator,
                            child: Text(operator),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setDialogState(() {
                              selectedOperator = newValue;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 24),

                      // Info Box
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.info_circle,
                              color: Colors.blue,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Payment will be processed through your KalooMoney business wallet',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.blue[200]
                                      : Colors.blue[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(
                                  color: AppColors.getDivider(isDark),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getTextSecondary(isDark),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _processMobileMoneyPayment(
                                phoneController.text,
                                nameController.text,
                                selectedOperator,
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                'Pay Now',
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
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _processMobileMoneyPayment(
    String phone,
    String name,
    String operator,
  ) async {
    // Validate phone number
    if (phone.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a phone number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Close the mobile money dialog
    Get.back();

    // Map operator names to API codes
    final operatorCode = operator.toLowerCase().contains('airtel')
        ? 'airtel'
        : operator.toLowerCase().contains('mtn')
        ? 'mtn'
        : operator.toLowerCase().contains('zamtel')
        ? 'zamtel'
        : 'airtel'; // default

    // Show initiating payment notification
    Get.snackbar(
      'Processing...',
      'Initiating payment to $phone via $operator',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: Icon(Iconsax.mobile, color: Colors.white),
      duration: Duration(seconds: 3),
    );

    try {
      final businessController = Get.find<BusinessSettingsController>();
      final walletController = Get.find<WalletController>();

      // Create payment reference
      final reference =
          'POS-${businessController.storeName.value}-${DateTime.now().millisecondsSinceEpoch}';

      // Initiate payment through Lenco API via WalletService
      final paymentResult = await WalletService.processMobileMoneyPayment(
        amount: widget.cartController.total,
        phoneNumber: phone,
        operator: operatorCode,
        reference: reference,
      );

      if (paymentResult == null) {
        Get.snackbar(
          'Error',
          'Failed to initiate payment. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
        return;
      }

      if (!paymentResult['success']) {
        Get.snackbar(
          'Payment Failed',
          paymentResult['error'] ?? 'Unknown error occurred',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
        return;
      }

      // Payment initiated successfully
      final paymentStatus = paymentResult['status'];

      if (paymentStatus == 'pay-offline') {
        // Show approval required notification
        Get.snackbar(
          'Approval Required',
          'Please check your phone and approve the payment request from $operator',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: Icon(Iconsax.mobile, color: Colors.white),
          duration: Duration(seconds: 5),
        );

        // Start checking payment status with polling
        await _checkPaymentStatusAndComplete(
          paymentResult: paymentResult,
          walletController: walletController,
          customerName: name,
          operator: operator,
        );
      } else if (paymentStatus == 'completed') {
        // Payment already completed
        await _completePaymentAndCheckout(
          paymentResult: paymentResult,
          walletController: walletController,
          customerName: name,
          operator: operator,
        );
      } else {
        // Unknown status
        Get.snackbar(
          'Unknown Status',
          'Payment status: $paymentStatus. Please check manually.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
      }
    } catch (e) {
      print('Mobile money payment error: $e');
      Get.snackbar(
        'Error',
        e.toString().contains('WalletController')
            ? 'KalooMoney wallet is not set up. Please enable it in Settings.'
            : 'Payment failed: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    }
  }

  Future<void> _checkPaymentStatusAndComplete({
    required Map<String, dynamic> paymentResult,
    required WalletController walletController,
    required String customerName,
    required String operator,
  }) async {
    final reference = paymentResult['transactionId'];
    final lencoReference = paymentResult['lencoReference'];

    // Show checking status dialog
    final currentAttempt = 0.obs;
    final maxAttempts = 5;

    Get.dialog(
      Obx(
        () => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Checking Payment Status...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Attempt ${currentAttempt.value + 1} of $maxAttempts',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                LinearProgressIndicator(
                  value: (currentAttempt.value + 1) / maxAttempts,
                ),
                SizedBox(height: 16),
                Text(
                  'Please approve the payment on your phone',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    Map<String, dynamic>? confirmed;

    // Poll for payment status
    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(Duration(seconds: 5));
      currentAttempt.value = i;

      print('Checking payment status... Attempt ${i + 1}/$maxAttempts');

      final statusCheck = await WalletService.checkTransactionStatus(
        reference,
        lencoReference: lencoReference,
      );

      if (statusCheck != null &&
          statusCheck['success'] == true &&
          statusCheck['found'] == true) {
        final currentStatus = statusCheck['status'];
        print('Current status: $currentStatus');

        if (currentStatus == 'completed') {
          confirmed = {
            ...paymentResult,
            'status': 'completed',
            'completedAt': statusCheck['completedAt'],
            'mmAccountName': statusCheck['mmAccountName'],
            'mmOperatorTxnId': statusCheck['mmOperatorTxnId'],
          };
          break;
        } else if (currentStatus == 'failed') {
          confirmed = {
            'success': false,
            'error': statusCheck['reasonForFailure'] ?? 'Payment failed',
            'status': 'failed',
            'mmAccountName': statusCheck['mmAccountName'],
          };
          break;
        }
      }
    }

    // Close checking dialog
    Get.back();

    if (confirmed != null && confirmed['status'] == 'completed') {
      // Payment successful
      await _completePaymentAndCheckout(
        paymentResult: confirmed,
        walletController: walletController,
        customerName: customerName,
        operator: operator,
      );
    } else if (confirmed != null && confirmed['status'] == 'failed') {
      // Payment failed - DON'T clear cart
      Get.snackbar(
        'Payment Failed',
        confirmed['error'] ?? 'Payment was declined or failed',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    } else {
      // Payment not confirmed yet - DON'T clear cart
      Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.pending_outlined, color: Colors.orange),
              SizedBox(width: 8),
              Text('Payment Pending'),
            ],
          ),
          content: Text(
            'We couldn\'t confirm your payment yet. The transaction may still be processing.\n\n'
            'Reference: ${lencoReference ?? reference}\n\n'
            'Your items remain in cart. Please check your mobile money messages or contact support if the amount was deducted.',
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('Close')),
            ElevatedButton.icon(
              onPressed: () {
                Get.back(); // Close the pending dialog
                // Retry status check
                _checkPaymentStatusAndComplete(
                  paymentResult: paymentResult,
                  walletController: walletController,
                  customerName: customerName,
                  operator: operator,
                );
              },
              icon: Icon(Icons.refresh),
              label: Text('Check Status Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _completePaymentAndCheckout({
    required Map<String, dynamic> paymentResult,
    required WalletController walletController,
    required String customerName,
    required String operator,
  }) async {
    try {
      // Process deposit to wallet
      final success = await walletController.processDeposit(
        amount: widget.cartController.total,
        paymentMethod: operator,
        customerPhone: paymentResult['phone'],
        customerName: customerName.isEmpty ? null : customerName,
        description: 'POS Sale Payment (Mobile Money)',
        referenceId: paymentResult['transactionId'],
      );

      if (success) {
        // ONLY NOW complete the checkout (which will clear cart)
        final checkoutSuccess = await widget.cartController.checkout(
          paymentMethod: PaymentMethod.mobile,
          amountPaid: widget.cartController.total,
          printReceipt:
              printReceipt && (printerService?.isConnected.value ?? false),
        );

        if (checkoutSuccess) {
          Get.snackbar(
            'Payment Successful! 🎉',
            'Payment confirmed from ${paymentResult['mmAccountName'] ?? paymentResult['phone']}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: Icon(Iconsax.tick_circle, color: Colors.white),
            duration: Duration(seconds: 5),
          );
          _showSuccessDialog(widget.cartController.total);
        }
      }
    } catch (e) {
      print('Error completing payment: $e');
      Get.snackbar(
        'Error',
        'Payment was successful but there was an error completing the checkout: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
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
