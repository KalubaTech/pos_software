import 'package:get/get.dart';
import '../models/wallet_model.dart';
import '../models/wallet_transaction_model.dart';
import '../models/withdrawal_request_model.dart';
import '../services/wallet_database_service.dart';
import '../services/wallet_service.dart';

class WalletController extends GetxController {
  final WalletDatabaseService _walletDb;

  // Observable state
  final Rx<WalletModel?> wallet = Rx<WalletModel?>(null);
  final RxList<WalletTransactionModel> transactions =
      <WalletTransactionModel>[].obs;
  final RxList<WithdrawalRequestModel> withdrawalRequests =
      <WithdrawalRequestModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isEnabled = false.obs;
  final RxString error = ''.obs;

  // Statistics
  final RxDouble totalDeposits = 0.0.obs;
  final RxDouble totalWithdrawals = 0.0.obs;
  final RxDouble totalCharges = 0.0.obs;
  final RxInt depositCount = 0.obs;
  final RxInt withdrawalCount = 0.obs;

  WalletController(this._walletDb);

  // Getter for current business ID (should come from your business settings)
  String get businessId => 'BUSINESS_001'; // Replace with actual business ID
  String get businessName => 'My Business'; // Replace with actual business name

  @override
  void onInit() {
    super.onInit();
    loadWallet();
  }

  // ==================== WALLET MANAGEMENT ====================

  Future<void> loadWallet() async {
    try {
      isLoading.value = true;
      error.value = '';

      final existingWallet = await _walletDb.getWalletByBusinessId(businessId);

      if (existingWallet != null) {
        wallet.value = existingWallet;
        isEnabled.value = existingWallet.isEnabled;
        await loadTransactions();
        await loadWithdrawalRequests();
        await loadStatistics();
      }
    } catch (e) {
      error.value = 'Failed to load wallet: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setupWallet() async {
    try {
      isLoading.value = true;
      error.value = '';

      final existingWallet = await _walletDb.getWalletByBusinessId(businessId);

      if (existingWallet != null) {
        // Wallet already exists, just enable it
        await _walletDb.enableWallet(businessId, true);
        wallet.value = existingWallet.copyWith(isEnabled: true);
        isEnabled.value = true;
        Get.snackbar(
          'Success',
          'KalooMoney wallet has been enabled!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Create new wallet
        final newWallet = WalletModel(
          businessId: businessId,
          businessName: businessName,
          isEnabled: true,
        );

        final createdWallet = await _walletDb.createWallet(newWallet);
        wallet.value = createdWallet;
        isEnabled.value = true;

        Get.snackbar(
          'Success',
          'KalooMoney wallet has been set up successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      await loadTransactions();
      await loadWithdrawalRequests();
    } catch (e) {
      error.value = 'Failed to setup wallet: $e';
      Get.snackbar(
        'Error',
        'Failed to setup wallet: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> disableWallet() async {
    try {
      isLoading.value = true;
      await _walletDb.enableWallet(businessId, false);
      if (wallet.value != null) {
        wallet.value = wallet.value!.copyWith(isEnabled: false);
      }
      isEnabled.value = false;
      Get.snackbar(
        'Success',
        'KalooMoney wallet has been disabled',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Failed to disable wallet: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== TRANSACTION MANAGEMENT ====================

  Future<void> loadTransactions() async {
    if (wallet.value == null) return;

    try {
      final txns = await _walletDb.getTransactionsByWalletId(wallet.value!.id!);
      transactions.value = txns;
    } catch (e) {
      error.value = 'Failed to load transactions: $e';
    }
  }

  Future<bool> processDeposit({
    required double amount,
    required String paymentMethod,
    required String customerPhone,
    String? customerName,
    String? referenceId,
    String? description,
  }) async {
    if (wallet.value == null || !isEnabled.value) {
      Get.snackbar(
        'Error',
        'KalooMoney wallet is not enabled',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      isLoading.value = true;

      // Calculate charge
      final chargeAmount = WalletService.calculateCharge(
        amount: amount,
        paymentMethod: paymentMethod,
      );

      // Calculate net amount (amount after deducting charge)
      final netAmount = WalletService.calculateNetAmount(
        amount: amount,
        chargeAmount: chargeAmount,
      );

      final currentBalance = wallet.value!.balance;
      final newBalance = currentBalance + netAmount;

      // Create transaction
      final transaction = WalletTransactionModel(
        walletId: wallet.value!.id!,
        businessId: businessId,
        transactionId: WalletService.generateTransactionId(),
        type: 'deposit',
        amount: amount,
        chargeAmount: chargeAmount,
        netAmount: netAmount,
        balanceBefore: currentBalance,
        balanceAfter: newBalance,
        status: 'completed',
        paymentMethod: paymentMethod,
        customerPhone: customerPhone,
        customerName: customerName,
        referenceId: referenceId,
        description: description ?? 'Mobile money deposit',
        metadata: {
          'payment_method': paymentMethod,
          'customer_phone': customerPhone,
          'customer_name': customerName,
        },
      );

      await _walletDb.createTransaction(transaction);
      await _walletDb.updateWalletBalance(wallet.value!.id!, newBalance);

      // Update local wallet
      wallet.value = wallet.value!.copyWith(balance: newBalance);

      // Reload transactions
      await loadTransactions();
      await loadStatistics();

      Get.snackbar(
        'Success',
        'Deposit of ${WalletService.formatCurrency(netAmount)} processed successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      error.value = 'Failed to process deposit: $e';
      Get.snackbar(
        'Error',
        'Failed to process deposit: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== WITHDRAWAL MANAGEMENT ====================

  Future<void> loadWithdrawalRequests() async {
    if (wallet.value == null) return;

    try {
      final requests = await _walletDb.getWithdrawalRequestsByWalletId(
        wallet.value!.id!,
      );
      withdrawalRequests.value = requests;
    } catch (e) {
      error.value = 'Failed to load withdrawal requests: $e';
    }
  }

  Future<bool> requestWithdrawal({
    required double amount,
    required String withdrawalMethod,
    required Map<String, dynamic> accountDetails,
    String? requestedBy,
    String? notes,
  }) async {
    if (wallet.value == null || !isEnabled.value) {
      Get.snackbar(
        'Error',
        'KalooMoney wallet is not enabled',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    // Validate withdrawal amount
    final validationError = WalletService.validateWithdrawalAmount(
      amount: amount,
      walletBalance: wallet.value!.balance,
    );

    if (validationError != null) {
      Get.snackbar(
        'Error',
        validationError,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      isLoading.value = true;

      final request = WithdrawalRequestModel(
        walletId: wallet.value!.id!,
        businessId: businessId,
        requestId: WalletService.generateRequestId(),
        amount: amount,
        withdrawalMethod: withdrawalMethod,
        accountDetails: accountDetails,
        status: 'pending',
        requestedBy: requestedBy,
        notes: notes,
      );

      await _walletDb.createWithdrawalRequest(request);
      await loadWithdrawalRequests();

      Get.snackbar(
        'Success',
        'Withdrawal request of ${WalletService.formatCurrency(amount)} has been submitted',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      error.value = 'Failed to request withdrawal: $e';
      Get.snackbar(
        'Error',
        'Failed to request withdrawal: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> processWithdrawal(WithdrawalRequestModel request) async {
    if (wallet.value == null) return;

    try {
      isLoading.value = true;

      final currentBalance = wallet.value!.balance;
      final newBalance = currentBalance - request.amount;

      // Create withdrawal transaction
      final transaction = WalletTransactionModel(
        walletId: wallet.value!.id!,
        businessId: businessId,
        transactionId: WalletService.generateTransactionId(),
        type: 'withdrawal',
        amount: request.amount,
        chargeAmount: 0.0,
        netAmount: request.amount,
        balanceBefore: currentBalance,
        balanceAfter: newBalance,
        status: 'completed',
        description: 'Withdrawal to ${request.withdrawalMethod}',
        metadata: {
          'withdrawal_request_id': request.requestId,
          'withdrawal_method': request.withdrawalMethod,
          'account_details': request.accountDetails,
        },
      );

      final createdTransaction = await _walletDb.createTransaction(transaction);
      await _walletDb.updateWalletBalance(wallet.value!.id!, newBalance);
      await _walletDb.updateWithdrawalRequestStatus(
        request.requestId,
        'completed',
        processedBy: 'System',
        transactionId: createdTransaction.id,
      );

      // Update local wallet
      wallet.value = wallet.value!.copyWith(balance: newBalance);

      await loadTransactions();
      await loadWithdrawalRequests();
      await loadStatistics();

      Get.snackbar(
        'Success',
        'Withdrawal processed successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Failed to process withdrawal: $e';
      Get.snackbar(
        'Error',
        'Failed to process withdrawal: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== STATISTICS ====================

  Future<void> loadStatistics() async {
    if (wallet.value == null) return;

    try {
      final stats = await _walletDb.getTransactionStats(wallet.value!.id!);

      totalDeposits.value = (stats['deposits']['total'] as num).toDouble();
      depositCount.value = stats['deposits']['count'] as int;

      totalWithdrawals.value = (stats['withdrawals']['total'] as num)
          .toDouble();
      withdrawalCount.value = stats['withdrawals']['count'] as int;

      totalCharges.value = (stats['charges']['total'] as num).toDouble();
    } catch (e) {
      error.value = 'Failed to load statistics: $e';
    }
  }

  // ==================== GETTERS ====================

  bool get hasWallet => wallet.value != null;
  double get currentBalance => wallet.value?.balance ?? 0.0;
  bool get isWalletActive => wallet.value?.isActive ?? false;
  int get totalTransactions => transactions.length;
  int get pendingWithdrawals =>
      withdrawalRequests.where((r) => r.isPending).length;
}
