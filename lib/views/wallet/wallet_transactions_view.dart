import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wallet_controller.dart';
import '../../services/wallet_service.dart';
import '../../utils/colors.dart';

class WalletTransactionsView extends StatefulWidget {
  const WalletTransactionsView({Key? key}) : super(key: key);

  @override
  State<WalletTransactionsView> createState() => _WalletTransactionsViewState();
}

class _WalletTransactionsViewState extends State<WalletTransactionsView> {
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WalletController>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Filter chips
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Deposits', 'deposit'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Withdrawals', 'withdrawal'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Charges', 'charge'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', 'completed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Transactions list
          Expanded(
            child: Obx(() {
              var transactions = controller.transactions.toList();

              // Apply filters
              if (_selectedFilter != 'all') {
                if (_selectedFilter == 'completed' ||
                    _selectedFilter == 'pending') {
                  transactions = transactions
                      .where((t) => t.status == _selectedFilter)
                      .toList();
                } else {
                  transactions = transactions
                      .where((t) => t.type == _selectedFilter)
                      .toList();
                }
              }

              // Apply search
              if (_searchQuery.isNotEmpty) {
                transactions = transactions.where((t) {
                  final searchLower = _searchQuery.toLowerCase();
                  return (t.description ?? '').toLowerCase().contains(
                        searchLower,
                      ) ||
                      t.transactionId.toLowerCase().contains(searchLower) ||
                      (t.customerPhone?.toLowerCase().contains(searchLower) ??
                          false) ||
                      (t.customerName?.toLowerCase().contains(searchLower) ??
                          false);
                }).toList();
              }

              if (transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions found',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadTransactions(),
                child: ListView.builder(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return _buildTransactionCard(transaction, isMobile);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildTransactionCard(transaction, bool isMobile) {
    IconData icon;
    Color color;

    switch (transaction.type) {
      case 'deposit':
        icon = Icons.arrow_downward;
        color = Colors.green;
        break;
      case 'withdrawal':
        icon = Icons.arrow_upward;
        color = Colors.orange;
        break;
      case 'charge':
        icon = Icons.monetization_on;
        color = Colors.red;
        break;
      case 'refund':
        icon = Icons.replay;
        color = Colors.blue;
        break;
      default:
        icon = Icons.swap_horiz;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showTransactionDetails(transaction),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                WalletService.getTransactionTypeDisplay(
                                  transaction.type,
                                ),
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: transaction.status == 'completed'
                                    ? Colors.green.withOpacity(0.1)
                                    : transaction.status == 'pending'
                                    ? Colors.orange.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                WalletService.getTransactionStatusDisplay(
                                  transaction.status,
                                ),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: transaction.status == 'completed'
                                      ? Colors.green
                                      : transaction.status == 'pending'
                                      ? Colors.orange
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaction.description,
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              WalletService.getTimeAgo(transaction.createdAt),
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            if (transaction.paymentMethod != null) ...[
                              const SizedBox(width: 12),
                              Icon(
                                Icons.phone_android,
                                size: 12,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                WalletService.getPaymentMethodDisplay(
                                  transaction.paymentMethod!,
                                ),
                                style: TextStyle(
                                  fontSize: isMobile ? 11 : 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        WalletService.formatCurrency(transaction.amount),
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: transaction.type == 'withdrawal'
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                      if (transaction.chargeAmount > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Fee: ${WalletService.formatCurrency(transaction.chargeAmount)}',
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 11,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(transaction) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Transaction Details',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Transaction ID', transaction.transactionId),
              _buildDetailRow(
                'Type',
                WalletService.getTransactionTypeDisplay(transaction.type),
              ),
              _buildDetailRow(
                'Status',
                WalletService.getTransactionStatusDisplay(transaction.status),
              ),
              _buildDetailRow(
                'Amount',
                WalletService.formatCurrency(transaction.amount),
              ),
              if (transaction.chargeAmount > 0)
                _buildDetailRow(
                  'Charge',
                  WalletService.formatCurrency(transaction.chargeAmount),
                ),
              _buildDetailRow(
                'Net Amount',
                WalletService.formatCurrency(transaction.netAmount),
              ),
              if (transaction.paymentMethod != null)
                _buildDetailRow(
                  'Payment Method',
                  WalletService.getPaymentMethodDisplay(
                    transaction.paymentMethod!,
                  ),
                ),
              if (transaction.customerPhone != null)
                _buildDetailRow('Customer Phone', transaction.customerPhone!),
              if (transaction.customerName != null)
                _buildDetailRow('Customer Name', transaction.customerName!),
              _buildDetailRow(
                'Balance Before',
                WalletService.formatCurrency(transaction.balanceBefore),
              ),
              _buildDetailRow(
                'Balance After',
                WalletService.formatCurrency(transaction.balanceAfter),
              ),
              if (transaction.referenceId != null)
                _buildDetailRow('Reference ID', transaction.referenceId!),
              _buildDetailRow('Date', transaction.createdAt.toString()),
              if (transaction.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.description,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Transactions'),
              leading: Radio<String>(
                value: 'all',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Deposits Only'),
              leading: Radio<String>(
                value: 'deposit',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Withdrawals Only'),
              leading: Radio<String>(
                value: 'withdrawal',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Charges Only'),
              leading: Radio<String>(
                value: 'charge',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
