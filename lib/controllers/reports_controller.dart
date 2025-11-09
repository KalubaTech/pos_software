import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/database_service.dart';
import '../models/transaction_model.dart';

class ReportsController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();

  var isLoading = false.obs;
  var categoryBreakdown = <Map<String, dynamic>>[].obs;
  var previousMonthSales = 0.0.obs;
  var previousMonthTransactions = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadReportsData();
  }

  Future<void> loadReportsData() async {
    try {
      isLoading.value = true;

      // Calculate category breakdown
      await calculateCategoryBreakdown();

      // Calculate previous month stats for comparison
      await calculatePreviousMonthStats();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load reports data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> calculateCategoryBreakdown() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Get all transactions for current month
      final transactions = await _dbService.getTransactionsByDate(
        startOfMonth,
        now,
      );

      // Count sales by category
      final Map<String, double> categoryTotals = {};
      final Map<String, int> categoryCount = {};
      double totalRevenue = 0.0;

      for (var transaction in transactions) {
        for (var item in transaction.items) {
          final category = item.product.category;
          final itemTotal = item.subtotal;

          categoryTotals[category] =
              (categoryTotals[category] ?? 0.0) + itemTotal;
          categoryCount[category] =
              (categoryCount[category] ?? 0) + item.quantity;
          totalRevenue += itemTotal;
        }
      }

      // Convert to list and calculate percentages
      List<Map<String, dynamic>> breakdown = [];

      categoryTotals.forEach((category, total) {
        final percentage = totalRevenue > 0
            ? (total / totalRevenue * 100)
            : 0.0;
        breakdown.add({
          'category': category,
          'revenue': total,
          'count': categoryCount[category] ?? 0,
          'percentage': percentage,
        });
      });

      // Sort by revenue descending
      breakdown.sort(
        (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double),
      );

      // Take top 5 categories
      categoryBreakdown.value = breakdown.take(5).toList();
    } catch (e) {
      print('Error calculating category breakdown: $e');
    }
  }

  Future<void> calculatePreviousMonthStats() async {
    try {
      final now = DateTime.now();
      final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
      final endOfLastMonth = DateTime(now.year, now.month, 1);

      final transactions = await _dbService.getTransactionsByDate(
        startOfLastMonth,
        endOfLastMonth,
      );

      previousMonthTransactions.value = transactions.length;
      previousMonthSales.value = transactions.fold(
        0.0,
        (sum, t) => sum + t.total,
      );
    } catch (e) {
      print('Error calculating previous month stats: $e');
    }
  }

  double getRevenueGrowth(double currentRevenue) {
    if (previousMonthSales.value == 0) return 0.0;
    return ((currentRevenue - previousMonthSales.value) /
        previousMonthSales.value *
        100);
  }

  double getTransactionGrowth(int currentTransactions) {
    if (previousMonthTransactions.value == 0) return 0.0;
    return ((currentTransactions - previousMonthTransactions.value) /
        previousMonthTransactions.value *
        100);
  }

  String formatGrowth(double growth) {
    final sign = growth >= 0 ? '+' : '';
    return '$sign${growth.toStringAsFixed(1)}% from last month';
  }

  Color getGrowthColor(double growth) {
    return growth >= 0 ? Colors.green : Colors.red;
  }

  Future<void> refresh() async {
    await loadReportsData();
  }

  // Get product performance data
  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 5}) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final transactions = await _dbService.getTransactionsByDate(
        startOfMonth,
        now,
      );

      // Count product sales
      final Map<String, Map<String, dynamic>> productStats = {};

      for (var transaction in transactions) {
        for (var item in transaction.items) {
          final productId = item.product.id;

          if (!productStats.containsKey(productId)) {
            productStats[productId] = {
              'product': item.product,
              'quantity': 0,
              'revenue': 0.0,
            };
          }

          productStats[productId]!['quantity'] =
              (productStats[productId]!['quantity'] as int) + item.quantity;
          productStats[productId]!['revenue'] =
              (productStats[productId]!['revenue'] as double) + item.subtotal;
        }
      }

      // Convert to list and sort by revenue
      List<Map<String, dynamic>> topProducts = productStats.values.toList();
      topProducts.sort(
        (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double),
      );

      return topProducts.take(limit).toList();
    } catch (e) {
      print('Error getting top products: $e');
      return [];
    }
  }

  // Get payment method breakdown
  Future<Map<String, dynamic>> getPaymentMethodBreakdown() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final transactions = await _dbService.getTransactionsByDate(
        startOfMonth,
        now,
      );

      final Map<String, int> methodCount = {};
      final Map<String, double> methodRevenue = {};

      for (var transaction in transactions) {
        final method = transaction.paymentMethod.name;
        methodCount[method] = (methodCount[method] ?? 0) + 1;
        methodRevenue[method] =
            (methodRevenue[method] ?? 0.0) + transaction.total;
      }

      return {'count': methodCount, 'revenue': methodRevenue};
    } catch (e) {
      print('Error getting payment method breakdown: $e');
      return {'count': {}, 'revenue': {}};
    }
  }
}
