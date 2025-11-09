import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';

class TransactionController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();

  var transactions = <TransactionModel>[].obs;
  var filteredTransactions = <TransactionModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      isLoading.value = true;
      List<TransactionModel> result;

      if (startDate != null && endDate != null) {
        result = await _dbService.getTransactionsByDate(startDate, endDate);
      } else {
        result = await _dbService.getAllTransactions();
      }

      transactions.value = result;
      filteredTransactions.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load transactions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterByDateRange(DateTime startDate, DateTime endDate) {
    filteredTransactions.value = transactions.where((t) {
      return t.transactionDate.isAfter(startDate) &&
          t.transactionDate.isBefore(endDate.add(Duration(days: 1)));
    }).toList();
  }

  void searchTransactions(String query) {
    if (query.isEmpty) {
      filteredTransactions.value = transactions;
    } else {
      filteredTransactions.value = transactions
          .where(
            (t) =>
                t.id.toLowerCase().contains(query.toLowerCase()) ||
                (t.customerName?.toLowerCase().contains(query.toLowerCase()) ??
                    false),
          )
          .toList();
    }
  }

  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      return await _dbService.getTransactionById(id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load transaction: $e');
      return null;
    }
  }
}
