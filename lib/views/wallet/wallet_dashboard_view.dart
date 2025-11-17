import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wallet_controller.dart';
import '../../services/wallet_service.dart';
import '../../utils/colors.dart';
import 'wallet_transactions_view.dart';
import 'withdrawal_request_dialog.dart';

class WalletDashboardView extends StatelessWidget {
  const WalletDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WalletController>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('KalooMoney Wallet'),
        actions: [
          Obx(
            () => Switch(
              value: controller.isEnabled.value,
              onChanged: (value) {
                if (value) {
                  controller.setupWallet();
                } else {
                  _showDisableWalletDialog(context, controller);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && !controller.hasWallet) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.hasWallet || !controller.isEnabled.value) {
          return ListView(
            shrinkWrap: true,
            children: [
              _buildWalletSetupScreen(context, controller, isMobile)
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadWallet(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBalanceCard(context, controller, isMobile),
                const SizedBox(height: 16),
                _buildQuickStats(context, controller, isMobile),
                const SizedBox(height: 16),
                _buildActionButtons(context, controller, isMobile),
                const SizedBox(height: 24),
                _buildRecentTransactions(context, controller, isMobile),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWalletSetupScreen(
    BuildContext context,
    WalletController controller,
    bool isMobile,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              size: isMobile ? 80 : 120,
              color: AppColors.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'KalooMoney Wallet',
              style: TextStyle(
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Accept mobile money payments and manage your business funds securely.',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildFeatureItem(
              icon: Icons.phone_android,
              title: 'Mobile Money Payments',
              description: 'Accept MTN, Airtel, and Zambia payments',
              isMobile: isMobile,
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              icon: Icons.account_balance,
              title: 'Secure Wallet', 
              description: 'Keep your funds safe and accessible',
              isMobile: isMobile,
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              icon: Icons.trending_up,
              title: 'Easy Withdrawals',
              description: 'Withdraw to your bank or mobile money account',
              isMobile: isMobile,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: isMobile ? double.infinity : 300,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => controller.setupWallet(),
                icon: const Icon(Icons.check_circle),
                label: const Text(
                  'Enable KalooMoney',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isMobile,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    WalletController controller,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, const Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white70,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Available Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
              const Spacer(),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: controller.isWalletActive
                        ? Colors.green
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.isWalletActive ? 'ACTIVE' : 'INACTIVE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => Text(
              WalletService.formatCurrency(controller.currentBalance),
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 36 : 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              '${controller.totalTransactions} transactions',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    WalletController controller,
    bool isMobile,
  ) {
    return Obx(
      () => isMobile
          ? Column(
              children: [
                _buildStatCard(
                  icon: Icons.arrow_downward,
                  title: 'Total Deposits',
                  value: WalletService.formatCurrency(
                    controller.totalDeposits.value,
                  ),
                  count: '${controller.depositCount.value} deposits',
                  color: Colors.green,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  icon: Icons.arrow_upward,
                  title: 'Total Withdrawals',
                  value: WalletService.formatCurrency(
                    controller.totalWithdrawals.value,
                  ),
                  count: '${controller.withdrawalCount.value} withdrawals',
                  color: Colors.orange,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  icon: Icons.monetization_on,
                  title: 'Total Charges',
                  value: WalletService.formatCurrency(
                    controller.totalCharges.value,
                  ),
                  count: 'Transaction fees',
                  color: Colors.red,
                  isMobile: isMobile,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.arrow_downward,
                    title: 'Total Deposits',
                    value: WalletService.formatCurrency(
                      controller.totalDeposits.value,
                    ),
                    count: '${controller.depositCount.value} deposits',
                    color: Colors.green,
                    isMobile: isMobile,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.arrow_upward,
                    title: 'Total Withdrawals',
                    value: WalletService.formatCurrency(
                      controller.totalWithdrawals.value,
                    ),
                    count: '${controller.withdrawalCount.value} withdrawals',
                    color: Colors.orange,
                    isMobile: isMobile,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.monetization_on,
                    title: 'Total Charges',
                    value: WalletService.formatCurrency(
                      controller.totalCharges.value,
                    ),
                    count: 'Transaction fees',
                    color: Colors.red,
                    isMobile: isMobile,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String count,
    required Color color,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WalletController controller,
    bool isMobile,
  ) {
    return isMobile
        ? Column(
            children: [
              _buildActionButton(
                icon: Icons.add_circle,
                label: 'Make Deposit',
                color: Colors.green,
                onPressed: () => _showDepositInfo(context),
                isMobile: isMobile,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                icon: Icons.remove_circle,
                label: 'Request Withdrawal',
                color: Colors.orange,
                onPressed: () => _showWithdrawalDialog(context, controller),
                isMobile: isMobile,
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_circle,
                  label: 'Make Deposit',
                  color: Colors.green,
                  onPressed: () => _showDepositInfo(context),
                  isMobile: isMobile,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.remove_circle,
                  label: 'Request Withdrawal',
                  color: Colors.orange,
                  onPressed: () => _showWithdrawalDialog(context, controller),
                  isMobile: isMobile,
                ),
              ),
            ],
          );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isMobile,
  }) {
    return SizedBox(
      height: isMobile ? 56 : 64,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: isMobile ? 20 : 24),
        label: Text(label, style: TextStyle(fontSize: isMobile ? 14 : 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    WalletController controller,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Get.to(() => const WalletTransactionsView()),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          final recentTransactions = controller.transactions.take(5).toList();

          if (recentTransactions.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No transactions yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: recentTransactions
                .map((txn) => _buildTransactionItem(txn, isMobile))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildTransactionItem(transaction, bool isMobile) {
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
      default:
        icon = Icons.swap_horiz;
        color = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WalletService.getTransactionTypeDisplay(transaction.type),
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  WalletService.getTimeAgo(transaction.createdAt),
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            WalletService.formatCurrency(transaction.netAmount),
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: transaction.type == 'withdrawal'
                  ? Colors.red
                  : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void _showDepositInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Make Deposit'),
        content: const Text(
          'Deposits are automatically processed when customers pay using mobile money during checkout.\n\n'
          'Simply select "Mobile Money" as the payment method at checkout to add funds to your wallet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawalDialog(
    BuildContext context,
    WalletController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => WithdrawalRequestDialog(controller: controller),
    );
  }

  void _showDisableWalletDialog(
    BuildContext context,
    WalletController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable KalooMoney'),
        content: const Text(
          'Are you sure you want to disable your KalooMoney wallet? '
          'You will not be able to accept mobile money payments until you enable it again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.disableWallet();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }
}
