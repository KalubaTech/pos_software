import 'package:get/get.dart';
import '../services/database_service.dart';
import '../models/transaction_model.dart';

class DashboardController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();

  var isLoading = false.obs;
  var todaySales = 0.0.obs;
  var todayTransactions = 0.obs;
  var monthSales = 0.0.obs;
  var monthTransactions = 0.obs;
  var totalCustomers = 0.obs;
  var totalProducts = 0.obs;
  var lowStockItems = 0.obs;

  var salesChartData = <Map<String, dynamic>>[].obs;
  var topSellingProducts = <Map<String, dynamic>>[].obs;
  var recentTransactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      // Calculate stats from database
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Today's transactions
      final todayTransactionsList = await _dbService.getTransactionsByDate(
        startOfToday,
        now,
      );
      todayTransactions.value = todayTransactionsList.length;
      todaySales.value = todayTransactionsList.fold(
        0.0,
        (sum, t) => sum + t.total,
      );

      // Month's transactions
      final monthTransactionsList = await _dbService.getTransactionsByDate(
        startOfMonth,
        now,
      );
      monthTransactions.value = monthTransactionsList.length;
      monthSales.value = monthTransactionsList.fold(
        0.0,
        (sum, t) => sum + t.total,
      );

      // Total customers
      final customers = await _dbService.getAllCustomers();
      totalCustomers.value = customers.length;

      // Total products and low stock
      final products = await _dbService.getAllProducts();
      totalProducts.value = products.length;
      lowStockItems.value = products.where((p) => p.isLowStock).length;

      // Sales chart data (last 7 days)
      salesChartData.value = await _calculateSalesChartData(7);

      // Recent transactions
      final allTransactions = await _dbService.getAllTransactions();
      recentTransactions.value = allTransactions.take(10).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> _calculateSalesChartData(int days) async {
    final List<Map<String, dynamic>> chartData = [];
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final nextDate = DateTime(now.year, now.month, now.day - i + 1);

      final transactions = await _dbService.getTransactionsByDate(
        date,
        nextDate,
      );
      final total = transactions.fold(0.0, (sum, t) => sum + t.total);

      chartData.add({
        'date': date,
        'day': _getDayName(date.weekday),
        'sales': total,
      });
    }

    return chartData;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  Future<void> refresh() async {
    await loadDashboardData();
  }
}
