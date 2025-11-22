import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/subscription_model.dart';
import '../../models/unresolved_transaction_model.dart';
import '../../services/subscription_service.dart';
import '../../controllers/appearance_controller.dart';
import '../../controllers/business_settings_controller.dart';
import '../../controllers/universal_sync_controller.dart';
import '../../utils/colors.dart';
import '../../utils/responsive.dart';
import 'package:intl/intl.dart';
// import '../../debug_unresolved_test.dart'; // Commented out for production build

class SubscriptionView extends StatefulWidget {
  const SubscriptionView({super.key});

  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  // Observable for tracking payment checking status
  static final RxBool isCheckingPayment = false.obs;
  static final RxString checkingReference = ''.obs;
  static final RxInt checkingAttempt = 0.obs;
  static final RxInt maxAttempts = 5.obs;

  // Observable for result notification
  static final RxBool showResultNotification = false.obs;
  static final RxString resultTitle = ''.obs;
  static final RxString resultMessage = ''.obs;
  static final RxString resultType =
      'info'.obs; // success, error, warning, info

  // Scroll controller to scroll to top when checking starts
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Helper method to show result notification
  void _showResultNotification({
    required String title,
    required String message,
    required String type, // success, error, warning, info
  }) {
    resultTitle.value = title;
    resultMessage.value = message;
    resultType.value = type;
    showResultNotification.value = true;

    // Scroll to top to show notification
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    // NOTE: Notification stays visible until user manually dismisses it
    // No auto-dismiss - user must click the close button (×)
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionService = Get.find<SubscriptionService>();
    final appearanceController = Get.find<AppearanceController>();
    final businessController = Get.find<BusinessSettingsController>();

    return Obx(() {
      final isDark = appearanceController.isDarkMode.value;
      final currentSubscription = subscriptionService.currentSubscription.value;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              SizedBox(height: 24),
              // DEBUG PANEL - Commented out for production build
              /* if (kDebugMode)
                Card(
                  color: Colors.red.shade50,
                  margin: EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bug_report, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              '🐛 DEBUG TOOLS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade900,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed:
                                  UnresolvedTransactionsDebugger.checkStatus,
                              icon: Icon(Icons.info_outline, size: 16),
                              label: Text('Check Status'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: UnresolvedTransactionsDebugger
                                  .addTestTransaction,
                              icon: Icon(Icons.add_circle_outline, size: 16),
                              label: Text('Add Test'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: UnresolvedTransactionsDebugger
                                  .reloadFromDatabase,
                              icon: Icon(Icons.refresh, size: 16),
                              label: Text('Reload'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: UnresolvedTransactionsDebugger
                                  .clearAllTransactions,
                              icon: Icon(Icons.delete_outline, size: 16),
                              label: Text('Clear All'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: UnresolvedTransactionsDebugger
                                  .runFullDiagnostics,
                              icon: Icon(Icons.science_outlined, size: 16),
                              label: Text('Full Diagnostics'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ), */
              // Result notification card
              Obx(() {
                if (showResultNotification.value) {
                  return FadeInDown(
                    duration: Duration(milliseconds: 300),
                    child: _buildResultNotificationCard(isDark),
                  );
                }
                return SizedBox.shrink();
              }),
              if (showResultNotification.value) SizedBox(height: 16),
              // Payment checking status card
              Obx(() {
                if (isCheckingPayment.value) {
                  return FadeInDown(
                    duration: Duration(milliseconds: 300),
                    child: _buildCheckingStatusCard(isDark),
                  );
                }
                return SizedBox.shrink();
              }),
              if (isCheckingPayment.value) SizedBox(height: 24),
              // Unresolved transactions section
              Obx(() {
                // Debug logging to track observable updates
                print('🔍 [Obx] Unresolved transactions rebuild triggered');
                print(
                  '📊 [Obx] Count: ${subscriptionService.unresolvedTransactions.length}',
                );
                print(
                  '📋 [Obx] isEmpty: ${subscriptionService.unresolvedTransactions.isEmpty}',
                );
                print(
                  '📋 [Obx] isNotEmpty: ${subscriptionService.unresolvedTransactions.isNotEmpty}',
                );

                if (subscriptionService.unresolvedTransactions.isNotEmpty) {
                  print('✅ [Obx] Showing unresolved section');
                  print(
                    '📝 [Obx] Transactions: ${subscriptionService.unresolvedTransactions.map((t) => t.transactionId).toList()}',
                  );

                  return FadeInUp(
                    duration: Duration(milliseconds: 300),
                    child: Column(
                      children: [
                        _buildUnresolvedTransactionsSection(
                          subscriptionService,
                          businessController,
                          isDark,
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  );
                } else {
                  print('❌ [Obx] Hiding unresolved section (list is empty)');
                }
                return SizedBox.shrink();
              }),
              if (currentSubscription != null)
                FadeInUp(
                  duration: Duration(milliseconds: 300),
                  child: _buildCurrentSubscriptionCard(
                    currentSubscription,
                    isDark,
                  ),
                ),
              SizedBox(height: 32),
              FadeInUp(
                duration: Duration(milliseconds: 400),
                child: _buildPlansSection(
                  context,
                  subscriptionService,
                  businessController,
                  isDark,
                ),
              ),
              SizedBox(height: 32),
              FadeInUp(
                duration: Duration(milliseconds: 500),
                child: _buildFeaturesComparison(isDark),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Iconsax.crown_1, color: Colors.blue, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subscription Plans',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Unlock cloud sync and premium features',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Manual sync button for debugging subscription issues
            IconButton(
              onPressed: () async {
                try {
                  Get.dialog(
                    Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Syncing subscription...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    barrierDismissible: false,
                  );

                  final subscriptionService = Get.find<SubscriptionService>();
                  final universalSync = Get.find<UniversalSyncController>();

                  print('🔍 === MANUAL SYNC DEBUG ===');
                  print(
                    'Current subscription: ${subscriptionService.currentSubscription.value?.planName ?? "NULL"}',
                  );
                  print(
                    'Status: ${subscriptionService.currentSubscription.value?.status.name ?? "N/A"}',
                  );
                  print(
                    'Business ID: ${subscriptionService.currentSubscription.value?.businessId ?? "N/A"}',
                  );

                  // Push current subscription to cloud
                  if (subscriptionService.currentSubscription.value != null) {
                    print('📤 Pushing subscription to cloud...');
                    await universalSync.syncSubscription(
                      subscriptionService.currentSubscription.value!,
                    );
                    print('✅ Push complete');
                  } else {
                    print('❌ No local subscription to push!');
                  }

                  print('⏳ Waiting 2 seconds...');
                  await Future.delayed(Duration(seconds: 2));

                  // Then pull from cloud to sync
                  print('📥 Pulling from cloud...');
                  await universalSync.forceSubscriptionSync();
                  Get.back(); // Close loading dialog

                  Get.snackbar(
                    '✅ Sync Complete',
                    'Subscription synced successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: Duration(seconds: 3),
                  );
                } catch (e) {
                  Get.back(); // Close loading dialog
                  Get.snackbar(
                    '❌ Sync Failed',
                    'Error: $e',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    duration: Duration(seconds: 5),
                  );
                }
              },
              icon: Icon(
                Iconsax.refresh,
                color: AppColors.getTextSecondary(isDark),
              ),
              tooltip: 'Sync Subscription',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnresolvedTransactionsSection(
    SubscriptionService subscriptionService,
    BusinessSettingsController businessController,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.clock, color: Colors.orange, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Unresolved Transactions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange),
              ),
              child: Text(
                '${subscriptionService.unresolvedTransactions.length}',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          'These transactions could not be verified. You can retry checking their status.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        SizedBox(height: 16),
        ...subscriptionService.unresolvedTransactions.map((transaction) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: _buildUnresolvedTransactionCard(
              transaction,
              subscriptionService,
              businessController,
              isDark,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildUnresolvedTransactionCard(
    UnresolvedTransactionModel transaction,
    SubscriptionService subscriptionService,
    BusinessSettingsController businessController,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Iconsax.wallet, color: Colors.orange, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.planName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'K${transaction.amount.toStringAsFixed(2)} • ${transaction.operatorName}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    transaction.status,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(transaction.status),
                  ),
                ),
                child: Text(
                  transaction.statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(transaction.status),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(color: AppColors.getDivider(isDark)),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Reference',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      transaction.lencoReference ?? transaction.transactionId,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone Number',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      transaction.phone,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Iconsax.clock,
                size: 14,
                color: AppColors.getTextSecondary(isDark),
              ),
              SizedBox(width: 6),
              Text(
                '${transaction.hoursSinceCreated}h ago • ${transaction.checkAttempts} attempts',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
            ],
          ),
          if (transaction.canRetry) ...[
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _retryUnresolvedTransaction(
                  transaction,
                  subscriptionService,
                  businessController,
                ),
                icon: Icon(Iconsax.refresh, size: 18),
                label: Text('Retry Status Check'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.checking:
        return Colors.blue;
      case TransactionStatus.timeout:
        return Colors.red;
      case TransactionStatus.notFound:
        return Colors.orange;
      case TransactionStatus.resolved:
        return Colors.green;
    }
  }

  Future<void> _retryUnresolvedTransaction(
    UnresolvedTransactionModel transaction,
    SubscriptionService subscriptionService,
    BusinessSettingsController businessController,
  ) async {
    _showResultNotification(
      title: 'Checking Status...',
      message: 'Retrying transaction status check...',
      type: 'info',
    );

    final result = await subscriptionService.retryUnresolvedTransaction(
      transaction,
    );

    if (result != null) {
      if (result['success'] == true && result['status'] == 'completed') {
        _showResultNotification(
          title: 'Payment Successful! 🎉',
          message: result['message'] ?? 'Subscription activated!',
          type: 'success',
        );
      } else if (result['status'] == 'failed') {
        _showResultNotification(
          title: 'Payment Failed',
          message: result['message'] ?? 'Payment was declined',
          type: 'error',
        );
      } else if (result['status'] == 'pending') {
        _showResultNotification(
          title: 'Still Pending',
          message: result['message'] ?? 'Payment is still being processed',
          type: 'warning',
        );
      } else {
        _showResultNotification(
          title: 'Not Found',
          message: result['message'] ?? 'Transaction not found yet',
          type: 'warning',
        );
      }
    }
  }

  Widget _buildCurrentSubscriptionCard(
    SubscriptionModel subscription,
    bool isDark,
  ) {
    final isActive = subscription.isActive;
    final isFree = subscription.plan == SubscriptionPlan.free;

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isActive && !isFree
            ? LinearGradient(
                colors: [Colors.blue, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isActive && !isFree
            ? null
            : (isDark ? AppColors.darkSurface : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: !isActive || isFree
            ? Border.all(color: AppColors.getDivider(isDark))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isActive ? Iconsax.tick_circle5 : Iconsax.info_circle,
                color: isActive && !isFree
                    ? Colors.white
                    : (isActive ? Colors.green : Colors.orange),
                size: 40,
              ),
              SizedBox(width: 40),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isActive ? 'Current Plan' : 'Expired Plan',
                      style: TextStyle(
                        fontSize: 14,
                        color: isActive && !isFree
                            ? Colors.white70
                            : AppColors.getTextSecondary(isDark),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subscription.planName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isActive && !isFree
                            ? Colors.white
                            : AppColors.getTextPrimary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isFree)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive && !isFree
                        ? Colors.white.withValues(alpha: 0.2)
                        : (isActive
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Expired',
                    style: TextStyle(
                      color: isActive && !isFree
                          ? Colors.white
                          : (isActive ? Colors.green : Colors.orange),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (!isFree) ...[
            SizedBox(height: 24),
            Divider(
              color: isActive && !isFree
                  ? Colors.white.withValues(alpha: 0.3)
                  : AppColors.getDivider(isDark),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Start Date',
                    DateFormat('MMM dd, yyyy').format(subscription.startDate),
                    isActive && !isFree,
                    isDark,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    'End Date',
                    DateFormat('MMM dd, yyyy').format(subscription.endDate),
                    isActive && !isFree,
                    isDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Days Remaining',
                    '${subscription.daysRemaining} days',
                    isActive && !isFree,
                    isDark,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    'Amount Paid',
                    'K${subscription.amount.toStringAsFixed(2)}',
                    isActive && !isFree,
                    isDark,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, bool isLight, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isLight
                ? Colors.white70
                : AppColors.getTextSecondary(isDark),
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isLight ? Colors.white : AppColors.getTextPrimary(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildPlansSection(
    BuildContext context,
    SubscriptionService subscriptionService,
    BusinessSettingsController businessController,
    bool isDark,
  ) {
    final plans = SubscriptionPlanOption.getAllPlans();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: context.isMobile ? 1 : 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: context.isMobile ? 0.85 : 0.65,
          ),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            return _buildPlanCard(
              context,
              plans[index],
              subscriptionService,
              businessController,
              isDark,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    SubscriptionPlanOption plan,
    SubscriptionService subscriptionService,
    BusinessSettingsController businessController,
    bool isDark,
  ) {
    final currentPlan = subscriptionService.currentPlan;
    final isCurrentPlan = currentPlan == plan.plan;

    return Container(
      padding: EdgeInsets.all(context.isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: plan.isPopular
              ? Colors.blue
              : (isCurrentPlan ? Colors.green : AppColors.getDivider(isDark)),
          width: plan.isPopular || isCurrentPlan ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plan.isPopular)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'BEST VALUE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (plan.isPopular) SizedBox(height: context.isMobile ? 8 : 12),
          if (isCurrentPlan)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green),
              ),
              child: Text(
                'CURRENT PLAN',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (isCurrentPlan) SizedBox(height: context.isMobile ? 8 : 12),
          Text(
            plan.title,
            style: TextStyle(
              fontSize: context.isMobile ? 18 : 24,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          SizedBox(height: context.isMobile ? 2 : 4),
          Text(
            plan.subtitle,
            style: TextStyle(
              fontSize: context.isMobile ? 10 : 13,
              color: AppColors.getTextSecondary(isDark),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: context.isMobile ? 8 : 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'K',
                style: TextStyle(
                  fontSize: context.isMobile ? 14 : 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              Text(
                plan.price.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: context.isMobile ? 24 : 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: context.isMobile ? 2 : 4),
          Text(
            plan.pricePerMonth,
            style: TextStyle(
              fontSize: context.isMobile ? 10 : 13,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          if (plan.savings != null) ...[
            SizedBox(height: context.isMobile ? 4 : 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.isMobile ? 8 : 10,
                vertical: context.isMobile ? 2 : 4,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Save K${plan.savings!.toStringAsFixed(0)}',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: context.isMobile ? 10 : 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          SizedBox(height: context.isMobile ? 8 : 20),
          ...plan.features
              .take(context.isMobile ? 3 : plan.features.length)
              .map(
                (feature) => Padding(
                  padding: EdgeInsets.only(bottom: context.isMobile ? 4 : 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Iconsax.tick_circle5,
                        color: Colors.green,
                        size: context.isMobile ? 12 : 18,
                      ),
                      SizedBox(width: context.isMobile ? 10 : 15),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: context.isMobile ? 10 : 13,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          if (context.isMobile && plan.features.length > 3)
            Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                '+${plan.features.length - 3} more',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.getTextSecondary(isDark),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrentPlan
                  ? null
                  : () => _showPaymentDialog(
                      plan,
                      subscriptionService,
                      businessController,
                      isDark,
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentPlan ? Colors.grey : Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: context.isMobile ? 10 : 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isCurrentPlan ? 'Current Plan' : 'Subscribe',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: context.isMobile ? 13 : 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesComparison(bool isDark) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s Included',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          SizedBox(height: 20),
          _buildFeatureRow(
            'All Offline Features',
            'POS, Inventory, Sales, Reports',
            true,
            isDark,
          ),
          _buildFeatureRow(
            'Cloud Synchronization',
            'Sync data across devices',
            false,
            isDark,
            premiumOnly: true,
          ),
          _buildFeatureRow(
            'Multi-device Support',
            'Access from anywhere',
            false,
            isDark,
            premiumOnly: true,
          ),
          _buildFeatureRow(
            'Real-time Sync',
            'Automatic background sync',
            false,
            isDark,
            premiumOnly: true,
          ),
          _buildFeatureRow(
            'Priority Support',
            'Get help when you need it',
            false,
            isDark,
            premiumOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(
    String title,
    String subtitle,
    bool alwaysIncluded,
    bool isDark, {
    bool premiumOnly = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            alwaysIncluded ? Iconsax.tick_circle5 : Iconsax.crown_1,
            color: alwaysIncluded ? Colors.green : Colors.blue,
            size: 24,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (premiumOnly) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'PREMIUM',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultNotificationCard(bool isDark) {
    // Determine colors and icon based on result type
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData iconData;

    switch (resultType.value) {
      case 'success':
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        borderColor = Colors.green;
        textColor = Colors.green.shade700;
        iconData = Iconsax.tick_circle;
        break;
      case 'error':
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        borderColor = Colors.red;
        textColor = Colors.red.shade700;
        iconData = Iconsax.close_circle;
        break;
      case 'warning':
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        borderColor = Colors.orange;
        textColor = Colors.orange.shade700;
        iconData = Iconsax.warning_2;
        break;
      default: // info
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        borderColor = Colors.blue;
        textColor = Colors.blue.shade700;
        iconData = Iconsax.info_circle;
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: borderColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: borderColor, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        resultTitle.value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Iconsax.close_square, size: 20),
                      color: textColor.withValues(alpha: 0.6),
                      onPressed: () {
                        showResultNotification.value = false;
                      },
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  resultMessage.value,
                  style: TextStyle(fontSize: 14, color: textColor, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckingStatusCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Animated loader
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Checking Payment Status...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 4),
                    Obx(
                      () => Text(
                        'Attempt ${checkingAttempt.value} of ${maxAttempts.value}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Progress bar
          Obx(() {
            final progress = checkingAttempt.value / maxAttempts.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.blue.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    minHeight: 8,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Iconsax.info_circle,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please approve the payment on your phone',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (checkingReference.value.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.document_text,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ref: ${checkingReference.value}',
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  // Check payment status in background with intervals
  Future<void> _checkPaymentStatus({
    required Map<String, dynamic> paymentResult,
    required SubscriptionPlanOption plan,
    required SubscriptionService subscriptionService,
    required BusinessSettingsController businessController,
    required String operator,
  }) async {
    final reference = paymentResult['transactionId'];
    final lencoReference = paymentResult['lencoReference'];
    final checkingStatus = true.obs;
    final showManualCheck = false.obs;

    // Show loading UI
    isCheckingPayment.value = true;
    checkingReference.value = lencoReference ?? reference;
    checkingAttempt.value = 0;
    maxAttempts.value = 5;

    // Scroll to top to show the checking status card
    await Future.delayed(
      Duration(milliseconds: 100),
    ); // Small delay to ensure UI updates
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    print('=== STARTING BACKGROUND STATUS CHECK ===');
    print('Reference: $reference');
    print('Lenco Reference: $lencoReference');
    print('Will check 5 times with 5-second intervals');
    print('========================================');

    // Create a custom polling loop to update UI
    Map<String, dynamic>? confirmed;

    if (paymentResult['success'] == true &&
        paymentResult['status'] == 'pay-offline') {
      for (int i = 0; i < 5; i++) {
        await Future.delayed(Duration(seconds: 5));

        checkingAttempt.value = i + 1;
        print('Checking status... Attempt ${i + 1}/5');

        final statusCheck = await subscriptionService.checkTransactionStatus(
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
              'confirmedViaPolling': true,
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
        } else {
          print('Transaction not found yet, continuing...');
        }
      }

      // If still not found after all attempts
      if (confirmed == null) {
        confirmed = {
          'success': false,
          'error': 'Payment confirmation pending',
          'status': 'not-found',
          'note': 'Transaction not found. Please check status manually.',
          'transactionId': reference,
          'lencoReference': lencoReference,
        };
      }
    }

    // Hide loading UI
    isCheckingPayment.value = false;
    checkingAttempt.value = 0;

    print('=== POLLING COMPLETED ===');
    print('Result: ${confirmed?.toString()}');
    print('========================');

    if (confirmed != null) {
      if (confirmed['status'] == 'completed') {
        print('✅ Payment COMPLETED - Activating subscription');
        // Payment successful - activate subscription
        final success = await subscriptionService.activateSubscription(
          businessId: businessController.storeName.value.isNotEmpty
              ? businessController.storeName.value
              : 'default',
          plan: plan.plan,
          transactionId: confirmed['transactionId'],
          paymentMethod: '$operator (${paymentResult['phone']})',
        );

        if (success) {
          _showResultNotification(
            title: 'Payment Successful! 🎉',
            message:
                'Your subscription is now active.\n${confirmed['mmAccountName'] != null ? 'Account: ${confirmed['mmAccountName']}' : ''}',
            type: 'success',
          );
        }
      } else if (confirmed['status'] == 'failed') {
        print('❌ Payment FAILED');
        // Payment failed
        _showResultNotification(
          title: 'Payment Failed',
          message:
              '${confirmed['error'] ?? 'Payment was declined'}${confirmed['mmAccountName'] != null ? '\nAccount: ${confirmed['mmAccountName']}' : ''}',
          type: 'error',
        );
      } else if (confirmed['status'] == 'not-found') {
        print('⚠️ Transaction NOT FOUND - Adding to unresolved');
        // Transaction not found after 5 attempts - add to unresolved
        await subscriptionService.addUnresolvedTransaction(
          businessId: businessController.storeName.value.isNotEmpty
              ? businessController.storeName.value
              : 'default',
          plan: plan.plan,
          transactionId: reference,
          lencoReference: lencoReference,
          phone: paymentResult['phone'] ?? '',
          operator: operator,
          amount: plan.price,
        );

        checkingStatus.value = false;
        showManualCheck.value = true;

        // Show information about unresolved transaction
        _showResultNotification(
          title: 'Transaction Saved',
          message:
              'Payment status could not be confirmed yet. The transaction has been saved to "Unresolved Transactions" where you can check it later.',
          type: 'warning',
        );

        // Show dialog instead of snackbar for better visibility
        Get.dialog(
          AlertDialog(
            backgroundColor: Colors.orange.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.orange, width: 2),
            ),
            title: Row(
              children: [
                Icon(Iconsax.info_circle, color: Colors.orange),
                SizedBox(width: 12),
                Text(
                  'Payment Status',
                  style: TextStyle(color: Colors.orange.shade900),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction not found yet. The payment may still be processing.',
                  style: TextStyle(fontSize: 14, color: Colors.orange.shade900),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Reference:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        reference,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Lenco Reference:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        lencoReference ?? 'N/A',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'You can check the status manually or wait and try again later.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Later', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Get.back(); // Close dialog first
                  _manualStatusCheck(
                    reference: reference,
                    lencoReference: lencoReference,
                    plan: plan,
                    subscriptionService: subscriptionService,
                    businessController: businessController,
                    operator: operator,
                    paymentResult: paymentResult,
                  );
                },
                icon: Icon(Iconsax.refresh, size: 18),
                label: Text('Check Status Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      }
    }
  }

  // Manual status check
  Future<void> _manualStatusCheck({
    required String reference,
    required String lencoReference,
    required SubscriptionPlanOption plan,
    required SubscriptionService subscriptionService,
    required BusinessSettingsController businessController,
    required String operator,
    required Map<String, dynamic> paymentResult,
  }) async {
    // Show loading UI
    isCheckingPayment.value = true;
    checkingReference.value = lencoReference;
    checkingAttempt.value = 1;
    maxAttempts.value = 1;

    _showResultNotification(
      title: 'Checking Status...',
      message: 'Checking payment status for transaction:\n$lencoReference',
      type: 'info',
    );

    final statusCheck = await subscriptionService.checkTransactionStatus(
      reference,
      lencoReference: lencoReference,
    );

    // Hide loading UI
    isCheckingPayment.value = false;

    if (statusCheck != null && statusCheck['success'] == true) {
      if (statusCheck['found'] == true) {
        final status = statusCheck['status'];

        if (status == 'completed') {
          // Activate subscription
          final success = await subscriptionService.activateSubscription(
            businessId: businessController.storeName.value.isNotEmpty
                ? businessController.storeName.value
                : 'default',
            plan: plan.plan,
            transactionId: reference,
            paymentMethod: '$operator (${paymentResult['phone']})',
          );

          if (success) {
            _showResultNotification(
              title: 'Payment Successful! 🎉',
              message:
                  'Your subscription is now active.\n${statusCheck['mmAccountName'] != null ? 'Account: ${statusCheck['mmAccountName']}' : ''}',
              type: 'success',
            );
          }
        } else if (status == 'failed') {
          _showResultNotification(
            title: 'Payment Failed',
            message:
                '${statusCheck['reasonForFailure'] ?? 'Payment was declined'}${statusCheck['mmAccountName'] != null ? '\nAccount: ${statusCheck['mmAccountName']}' : ''}',
            type: 'error',
          );
        } else {
          _showResultNotification(
            title: 'Payment Pending',
            message:
                'Payment is still being processed.\nCurrent status: $status',
            type: 'warning',
          );
        }
      } else {
        _showResultNotification(
          title: 'Transaction Not Found',
          message:
              'Transaction not found yet. Please try again in a few moments.\nLenco Ref: $lencoReference',
          type: 'warning',
        );
      }
    } else {
      _showResultNotification(
        title: 'Error',
        message:
            statusCheck?['error'] ??
            'Failed to check payment status. Please try again.',
        type: 'error',
      );
    }
  }

  void _showPaymentDialog(
    SubscriptionPlanOption plan,
    SubscriptionService subscriptionService,
    BusinessSettingsController businessController,
    bool isDark,
  ) {
    final phoneController = TextEditingController();
    final paymentMethod = 'Mobile Money'.obs;
    final isProcessing = false.obs;

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.getSurfaceColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(Get.context!).size.width * 0.9,
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.8,
          ),
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Iconsax.card, color: Colors.blue, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Complete Payment',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Plan:',
                            style: TextStyle(
                              color: AppColors.getTextSecondary(isDark),
                            ),
                          ),
                          Text(
                            plan.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextPrimary(isDark),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount:',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.getTextSecondary(isDark),
                            ),
                          ),
                          Text(
                            'K${plan.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: paymentMethod.value,
                    style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                    dropdownColor: AppColors.getSurfaceColor(isDark),
                    decoration: InputDecoration(
                      labelText: 'Payment Method',
                      labelStyle: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      prefixIcon: Icon(
                        Iconsax.wallet,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items:
                        [
                          'Mobile Money',
                          'MTN Mobile Money',
                          'Airtel Money',
                          'Zamtel Kwacha',
                        ].map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) paymentMethod.value = value;
                    },
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    hintText: '0977123456',
                    prefixIcon: Icon(
                      Iconsax.call,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 24),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: isProcessing.value ? null : () => Get.back(),
                        child: Text('Cancel'),
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: isProcessing.value
                              ? null
                              : () async {
                                  if (phoneController.text.isEmpty) {
                                    _showResultNotification(
                                      title: 'Missing Information',
                                      message:
                                          'Please enter your phone number to continue.',
                                      type: 'warning',
                                    );
                                    return;
                                  }

                                  isProcessing.value = true;

                                  Get.back();

                                  try {
                                    // Determine operator from phone or payment method
                                    String operator;
                                    if (paymentMethod.value ==
                                        'MTN Mobile Money') {
                                      operator = 'mtn';
                                    } else if (paymentMethod.value ==
                                        'Airtel Money') {
                                      operator = 'airtel';
                                    } else if (paymentMethod.value ==
                                        'Zamtel Kwacha') {
                                      operator = 'zamtel';
                                    } else {
                                      // Auto-detect from phone number
                                      operator =
                                          subscriptionService.detectOperator(
                                            phoneController.text,
                                          ) ??
                                          'airtel'; // Default to airtel
                                    }

                                    // Format phone number
                                    final formattedPhone = subscriptionService
                                        .formatPhoneNumber(
                                          phoneController.text,
                                        );

                                    // Show initiating message
                                    _showResultNotification(
                                      title: 'Processing Payment...',
                                      message:
                                          'Initiating payment to $formattedPhone via ${operator.toUpperCase()}',
                                      type: 'info',
                                    );

                                    // Process payment with real API
                                    final paymentResult =
                                        await subscriptionService
                                            .processPayment(
                                              plan: plan.plan,
                                              businessId:
                                                  businessController
                                                      .storeName
                                                      .value
                                                      .isNotEmpty
                                                  ? businessController
                                                        .storeName
                                                        .value
                                                  : 'default',
                                              phoneNumber: formattedPhone,
                                              operator: operator,
                                            );

                                    // Check if payment was initiated successfully
                                    if (subscriptionService.isPaymentSuccessful(
                                      paymentResult,
                                    )) {
                                      final status = paymentResult!['status'];

                                      print('=== PAYMENT RESULT ===');
                                      print('Status: $status');
                                      print(
                                        'Transaction ID: ${paymentResult['transactionId']}',
                                      );
                                      print(
                                        'Lenco Reference: ${paymentResult['lencoReference']}',
                                      );
                                      print('====================');

                                      if (status == 'pay-offline') {
                                        // Close the dialog immediately

                                        print(
                                          'Dialog closed - starting background status checking',
                                        );

                                        // Show approval message
                                        _showResultNotification(
                                          title: 'Approval Required 📱',
                                          message:
                                              'Please check your phone and approve the payment request. We are checking the status automatically...',
                                          type: 'warning',
                                        );

                                        // Start checking status in background
                                        _checkPaymentStatus(
                                          paymentResult: paymentResult,
                                          plan: plan,
                                          subscriptionService:
                                              subscriptionService,
                                          businessController:
                                              businessController,
                                          operator: operator,
                                        );
                                      } else if (status == 'completed') {
                                        // Payment already completed (instant payment)
                                        final success = await subscriptionService
                                            .activateSubscription(
                                              businessId:
                                                  businessController
                                                      .storeName
                                                      .value
                                                      .isNotEmpty
                                                  ? businessController
                                                        .storeName
                                                        .value
                                                  : 'default',
                                              plan: plan.plan,
                                              transactionId:
                                                  paymentResult['transactionId'],
                                              paymentMethod:
                                                  '$operator (${paymentResult['phone']})',
                                            );

                                        if (success) {
                                          Get.back();
                                          _showResultNotification(
                                            title: 'Payment Successful! 🎉',
                                            message:
                                                'Your subscription has been activated!\nReference: ${paymentResult['lencoReference']}',
                                            type: 'success',
                                          );
                                        }
                                      }
                                    } else {
                                      // Payment failed
                                      _showResultNotification(
                                        title: 'Payment Failed',
                                        message:
                                            paymentResult?['error'] ??
                                            'Unable to process payment. Please try again.',
                                        type: 'error',
                                      );
                                    }
                                  } catch (e) {
                                    _showResultNotification(
                                      title: 'Payment Error',
                                      message:
                                          'An error occurred while processing your payment:\n$e',
                                      type: 'error',
                                    );
                                  } finally {
                                    isProcessing.value = false;
                                  }
                                },
                          icon: isProcessing.value
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(Iconsax.tick_circle, size: 18),
                          label: Text(
                            isProcessing.value
                                ? 'Processing...'
                                : 'Pay K${plan.price.toStringAsFixed(2)}',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.info_circle, color: Colors.blue, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You will receive a prompt on your phone to complete the payment.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
