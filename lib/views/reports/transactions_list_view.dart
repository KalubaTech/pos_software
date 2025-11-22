import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/appearance_controller.dart';
import '../../models/transaction_model.dart';
import '../../utils/colors.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/responsive.dart';

class TransactionsListView extends StatefulWidget {
  const TransactionsListView({super.key});

  @override
  State<TransactionsListView> createState() => _TransactionsListViewState();
}

class _TransactionsListViewState extends State<TransactionsListView> {
  String _selectedPaymentFilter = 'all';
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final transactionController = Get.find<TransactionController>();
    final appearanceController = Get.find<AppearanceController>();

    return Obx(() {
      final isDark = appearanceController.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[100],
        appBar: AppBar(
          backgroundColor: AppColors.getSurfaceColor(isDark),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Iconsax.arrow_left,
              color: AppColors.getTextPrimary(isDark),
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'All Transactions',
            style: TextStyle(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Iconsax.filter,
                color: AppColors.getTextPrimary(isDark),
              ),
              onPressed: () => _showFilterDialog(context, isDark),
            ),
          ],
        ),
        body: Column(
          children: [
            // Search and Date Filter
            Container(
              color: AppColors.getSurfaceColor(isDark),
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                    decoration: InputDecoration(
                      hintText: 'Search by ID or customer...',
                      hintStyle: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      prefixIcon: Icon(
                        Iconsax.search_normal,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      transactionController.searchTransactions(value);
                    },
                  ),
                  SizedBox(height: 12),
                  // Date filter and payment filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Date filter chip
                        ActionChip(
                          avatar: Icon(
                            Iconsax.calendar,
                            size: 18,
                            color: _selectedDateRange != null
                                ? (isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.primary)
                                : AppColors.getTextSecondary(isDark),
                          ),
                          label: Text(
                            _selectedDateRange != null
                                ? '${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)}'
                                : 'Date Range',
                            style: TextStyle(
                              color: _selectedDateRange != null
                                  ? (isDark
                                        ? AppColors.darkPrimary
                                        : AppColors.primary)
                                  : AppColors.getTextPrimary(isDark),
                            ),
                          ),
                          backgroundColor: _selectedDateRange != null
                              ? (isDark
                                        ? AppColors.darkPrimary
                                        : AppColors.primary)
                                    .withOpacity(0.1)
                              : isDark
                              ? AppColors.darkSurfaceVariant
                              : Colors.grey[200],
                          side: BorderSide(
                            color: _selectedDateRange != null
                                ? (isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.primary)
                                : AppColors.getDivider(isDark),
                          ),
                          onPressed: () =>
                              _selectDateRange(context, transactionController),
                        ),
                        if (_selectedDateRange != null) ...[
                          SizedBox(width: 8),
                          ActionChip(
                            avatar: Icon(Iconsax.close_circle, size: 16),
                            label: Text('Clear'),
                            onPressed: () {
                              setState(() {
                                _selectedDateRange = null;
                              });
                              transactionController.fetchTransactions();
                            },
                          ),
                        ],
                        SizedBox(width: 8),
                        _buildFilterChip('All', 'all', isDark),
                        SizedBox(width: 8),
                        _buildFilterChip('Cash', 'cash', isDark),
                        SizedBox(width: 8),
                        _buildFilterChip('Card', 'card', isDark),
                        SizedBox(width: 8),
                        _buildFilterChip('Mobile', 'mobile', isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Transactions list
            Expanded(
              child: Obx(() {
                if (transactionController.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  );
                }

                var transactions = transactionController.filteredTransactions
                    .toList();

                // Apply payment filter
                if (_selectedPaymentFilter != 'all') {
                  transactions = transactions
                      .where(
                        (t) => t.paymentMethod.name == _selectedPaymentFilter,
                      )
                      .toList();
                }

                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.receipt_disscount,
                          size: 64,
                          color: AppColors.getTextTertiary(isDark),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(
                            color: AppColors.getTextTertiary(isDark),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => transactionController.fetchTransactions(),
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  child: context.isMobile
                      ? _buildMobileList(transactions, isDark)
                      : _buildDesktopList(transactions, isDark),
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMobileList(List<TransactionModel> transactions, bool isDark) {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildMobileTransactionCard(transaction, isDark);
      },
    );
  }

  Widget _buildDesktopList(List<TransactionModel> transactions, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getSurfaceColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.getDivider(isDark), width: 1),
        ),
        child: Table(
          columnWidths: {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
            5: FixedColumnWidth(60),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.getDivider(isDark)),
                ),
              ),
              children: [
                _buildTableHeader('ID', isDark),
                _buildTableHeader('Date & Time', isDark),
                _buildTableHeader('Customer', isDark),
                _buildTableHeader('Payment', isDark),
                _buildTableHeader('Total', isDark),
                _buildTableHeader('', isDark),
              ],
            ),
            ...transactions.map((transaction) {
              return TableRow(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.getDivider(isDark).withOpacity(0.5),
                    ),
                  ),
                ),
                children: [
                  _buildTableCell(_formatTransactionId(transaction.id), isDark),
                  _buildTableCell(
                    DateFormat(
                      'MMM dd, yyyy - HH:mm',
                    ).format(transaction.transactionDate),
                    isDark,
                  ),
                  _buildTableCell(transaction.customerName ?? 'Guest', isDark),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: _buildPaymentBadge(
                      transaction.paymentMethod.name.toUpperCase(),
                      isDark,
                      compact: true,
                    ),
                  ),
                  _buildTableCell(
                    CurrencyFormatter.format(transaction.total),
                    isDark,
                    bold: true,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: IconButton(
                      icon: Icon(
                        Iconsax.eye,
                        size: 18,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      onPressed: () =>
                          _showTransactionDetails(transaction, isDark),
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTransactionCard(
    TransactionModel transaction,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => _showTransactionDetails(transaction, isDark),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.getDivider(isDark), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.primary)
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _formatTransactionId(transaction.id),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      _buildPaymentBadge(
                        transaction.paymentMethod.name.toUpperCase(),
                        isDark,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  CurrencyFormatter.format(transaction.total),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Iconsax.user,
                  size: 16,
                  color: AppColors.getTextSecondary(isDark),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    transaction.customerName ?? 'Guest Customer',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Iconsax.calendar,
                  size: 16,
                  color: AppColors.getTextSecondary(isDark),
                ),
                SizedBox(width: 8),
                Text(
                  DateFormat(
                    'MMM dd, yyyy - HH:mm',
                  ).format(transaction.transactionDate),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = _selectedPaymentFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPaymentFilter = value;
        });
      },
      selectedColor: (isDark ? AppColors.darkPrimary : AppColors.primary)
          .withOpacity(0.2),
      checkmarkColor: isDark ? AppColors.darkPrimary : AppColors.primary,
      backgroundColor: isDark ? AppColors.darkSurfaceVariant : Colors.grey[200],
      side: BorderSide(
        color: isSelected
            ? (isDark ? AppColors.darkPrimary : AppColors.primary)
            : AppColors.getDivider(isDark),
      ),
    );
  }

  Widget _buildPaymentBadge(
    String method,
    bool isDark, {
    bool compact = false,
  }) {
    Color badgeColor;
    IconData icon;

    switch (method.toLowerCase()) {
      case 'cash':
        badgeColor = Colors.green;
        icon = Iconsax.money;
        break;
      case 'card':
        badgeColor = Colors.blue;
        icon = Iconsax.card;
        break;
      case 'mobile':
        badgeColor = Colors.purple;
        icon = Iconsax.mobile;
        break;
      default:
        badgeColor = Colors.grey;
        icon = Iconsax.wallet_3;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(isDark ? 0.25 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 10 : 12, color: badgeColor),
          SizedBox(width: 4),
          Text(
            method,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTransactionId(String id) {
    if (id.length <= 8) return '#$id';
    final first = id.substring(0, 4);
    final last = id.substring(id.length - 4);
    return '#$first...$last';
  }

  Widget _buildTableHeader(String text, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: AppColors.getTextSecondary(isDark),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, bool isDark, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          color: AppColors.getTextPrimary(isDark),
        ),
      ),
    );
  }

  Future<void> _selectDateRange(
    BuildContext context,
    TransactionController controller,
  ) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      await controller.fetchTransactions(
        startDate: picked.start,
        endDate: picked.end,
      );
    }
  }

  void _showFilterDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getSurfaceColor(isDark),
        title: Text(
          'Filter Transactions',
          style: TextStyle(color: AppColors.getTextPrimary(isDark)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            SizedBox(height: 8),
            _buildFilterOption('All', 'all', isDark),
            _buildFilterOption('Cash', 'cash', isDark),
            _buildFilterOption('Card', 'card', isDark),
            _buildFilterOption('Mobile', 'mobile', isDark),
            _buildFilterOption('Other', 'other', isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedPaymentFilter = 'all';
                _selectedDateRange = null;
              });
              Get.find<TransactionController>().fetchTransactions();
              Get.back();
            },
            child: Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.darkPrimary
                  : AppColors.primary,
            ),
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String label, String value, bool isDark) {
    return RadioListTile<String>(
      title: Text(
        label,
        style: TextStyle(color: AppColors.getTextPrimary(isDark)),
      ),
      value: value,
      groupValue: _selectedPaymentFilter,
      activeColor: isDark ? AppColors.darkPrimary : AppColors.primary,
      onChanged: (value) {
        setState(() {
          _selectedPaymentFilter = value!;
        });
      },
    );
  }

  void _showTransactionDetails(TransactionModel transaction, bool isDark) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.getSurfaceColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: Get.context!.isMobile ? double.infinity : 500,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transaction Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            '#${transaction.id}',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.getTextSecondary(isDark),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Iconsax.close_circle,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        'Customer',
                        transaction.customerName ?? 'Guest Customer',
                        Iconsax.user,
                        isDark,
                      ),
                      SizedBox(height: 12),
                      _buildDetailRow(
                        'Date & Time',
                        DateFormat(
                          'MMM dd, yyyy - HH:mm',
                        ).format(transaction.transactionDate),
                        Iconsax.calendar,
                        isDark,
                      ),
                      SizedBox(height: 12),
                      _buildDetailRow(
                        'Payment Method',
                        transaction.paymentMethod.name.toUpperCase(),
                        Iconsax.wallet_3,
                        isDark,
                      ),
                      SizedBox(height: 12),
                      _buildDetailRow(
                        'Cashier',
                        transaction.cashierName,
                        Iconsax.user_tag,
                        isDark,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Items (${transaction.items.length})',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                      SizedBox(height: 12),
                      ...transaction.items.map((item) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceVariant
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.getTextPrimary(isDark),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${item.quantity} x ${CurrencyFormatter.format(item.product.price)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.getTextSecondary(
                                          isDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(item.subtotal),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getTextPrimary(isDark),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              // Footer
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Get.back(),
                    icon: Icon(Iconsax.close_square, size: 18),
                    label: Text('Close'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppColors.getDivider(isDark)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.getTextSecondary(isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.getTextPrimary(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
