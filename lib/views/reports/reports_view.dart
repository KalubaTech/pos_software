import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/reports_controller.dart';
import '../../controllers/appearance_controller.dart';
import '../../models/transaction_model.dart';
import '../../utils/colors.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/responsive.dart';
import 'transactions_list_view.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final transactionController = Get.put(TransactionController());
    final dashboardController = Get.put(DashboardController());
    final reportsController = Get.put(ReportsController());
    final appearanceController = Get.find<AppearanceController>();

    return Obx(() {
      final isDark = appearanceController.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[100],
        body: SingleChildScrollView(
          padding: EdgeInsets.all(context.isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                context,
                transactionController,
                dashboardController,
                reportsController,
                isDark,
              ),
              SizedBox(height: context.isMobile ? 16 : 24),
              _buildStatsRow(dashboardController, reportsController, isDark),
              SizedBox(height: context.isMobile ? 16 : 24),
              context.isMobile
                  ? Column(
                      children: [
                        _buildSalesChart(dashboardController, isDark),
                        SizedBox(height: 16),
                        _buildCategoryBreakdown(reportsController, isDark),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildSalesChart(dashboardController, isDark),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: _buildCategoryBreakdown(
                            reportsController,
                            isDark,
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: context.isMobile ? 16 : 24),
              _buildTransactionsTable(transactionController, isDark),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(
    BuildContext context,
    TransactionController transactionController,
    DashboardController dashboardController,
    ReportsController reportsController,
    bool isDark,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = context.isMobile;

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reports',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Sales performance',
                style: TextStyle(
                  color: AppColors.getTextSecondary(isDark),
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectDateRange(context),
                      icon: Icon(
                        Iconsax.calendar,
                        size: 18,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                      label: Text(
                        _selectedDateRange != null
                            ? '${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)}'
                            : 'This Month',
                        style: TextStyle(
                          color: AppColors.getTextPrimary(isDark),
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.getDivider(isDark)),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _exportReport(
                        context,
                        transactionController,
                        dashboardController,
                        reportsController,
                      ),
                      icon: Icon(Iconsax.document_download, size: 18),
                      label: Text('Export', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reports & Analytics',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'View your sales performance and insights',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _selectDateRange(context),
                  icon: Icon(
                    Iconsax.calendar,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                  label: Text(
                    _selectedDateRange != null
                        ? '${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)}'
                        : 'This Month',
                    style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _exportReport(
                    context,
                    transactionController,
                    dashboardController,
                    reportsController,
                  ),
                  icon: Icon(Iconsax.document_download),
                  label: Text('Export'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.darkPrimary
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsRow(
    DashboardController controller,
    ReportsController reportsController,
    bool isDark,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = context.isMobile;

        final stats = [
          Obx(() {
            final growth = reportsController.getRevenueGrowth(
              controller.monthSales.value,
            );
            return _buildStatCard(
              context,
              'Total Revenue',
              Obx(
                () => Text(
                  CurrencyFormatter.format(controller.monthSales.value),
                  style: TextStyle(
                    fontSize: context.isMobile ? 20 : 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ),
              Iconsax.dollar_circle,
              isDark ? AppColors.darkPrimary : AppColors.primary,
              reportsController.formatGrowth(growth),
              reportsController.getGrowthColor(growth),
              isDark,
            );
          }),
          Obx(() {
            final growth = reportsController.getTransactionGrowth(
              controller.monthTransactions.value,
            );
            return _buildStatCard(
              context,
              'Transactions',
              Obx(
                () => Text(
                  '${controller.monthTransactions.value}',
                  style: TextStyle(
                    fontSize: context.isMobile ? 20 : 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ),
              Iconsax.receipt_2_1,
              Colors.blue,
              reportsController.formatGrowth(growth),
              reportsController.getGrowthColor(growth),
              isDark,
            );
          }),
          _buildStatCard(
            context,
            'Average Order',
            Obx(() {
              final avg = controller.monthTransactions.value > 0
                  ? controller.monthSales.value /
                        controller.monthTransactions.value
                  : 0.0;
              return Text(
                CurrencyFormatter.format(avg),
                style: TextStyle(
                  fontSize: context.isMobile ? 20 : 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              );
            }),
            Iconsax.chart_21,
            Colors.orange,
            'Average per transaction',
            AppColors.getTextSecondary(isDark),
            isDark,
          ),
        ];

        if (isMobile) {
          return Column(
            children: [
              for (int i = 0; i < stats.length; i++) ...[
                stats[i],
                if (i < stats.length - 1) SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: stats[0]),
            SizedBox(width: 16),
            Expanded(child: stats[1]),
            SizedBox(width: 16),
            Expanded(child: stats[2]),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    Widget valueWidget,
    IconData icon,
    Color color,
    String change,
    Color changeColor,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(context.isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getDivider(isDark), width: 1),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
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
                padding: EdgeInsets.all(context.isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.25 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: context.isMobile ? 20 : 24,
                ),
              ),
              Spacer(),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.isMobile ? 6 : 8,
                    vertical: context.isMobile ? 3 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: changeColor.withOpacity(isDark ? 0.25 : 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: changeColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      fontSize: context.isMobile ? 10 : 11,
                      color: changeColor,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.isMobile ? 12 : 16),
          Text(
            title,
            style: TextStyle(
              color: AppColors.getTextSecondary(isDark),
              fontSize: context.isMobile ? 12 : 14,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          SizedBox(height: 4),
          valueWidget,
        ],
      ),
    );
  }

  Widget _buildSalesChart(DashboardController controller, bool isDark) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getDivider(isDark), width: 1),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: Obx(() {
              if (controller.salesChartData.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                );
              }

              return LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.getDivider(isDark),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Obx(
                            () => Text(
                              CurrencyFormatter.format(value),
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.getTextSecondary(isDark),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() <
                                  controller.salesChartData.length) {
                            final date =
                                controller.salesChartData[value.toInt()]['date']
                                    as DateTime;
                            return Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat('MMM d').format(date),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.getTextSecondary(isDark),
                                ),
                              ),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        controller.salesChartData.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          controller.salesChartData[index]['sales'].toDouble(),
                        ),
                      ),
                      isCurved: true,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                            strokeWidth: 2,
                            strokeColor: AppColors.getSurfaceColor(isDark),
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color:
                            (isDark ? AppColors.darkPrimary : AppColors.primary)
                                .withOpacity(isDark ? 0.15 : 0.1),
                      ),
                    ),
                  ],
                  minY: 0,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(ReportsController controller, bool isDark) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getDivider(isDark), width: 1),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          SizedBox(height: 24),
          Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                ),
              );
            }

            if (controller.categoryBreakdown.isEmpty) {
              return Center(
                child: Text(
                  'No category data available',
                  style: TextStyle(color: AppColors.getTextSecondary(isDark)),
                ),
              );
            }

            final colors = isDark
                ? [
                    AppColors.darkPrimary,
                    AppColors.darkSecondary,
                    Colors.deepOrangeAccent,
                    Colors.purpleAccent,
                    Colors.cyanAccent,
                  ]
                : [
                    AppColors.primary,
                    Colors.blue,
                    Colors.orange,
                    Colors.purple,
                    Colors.teal,
                  ];

            return Column(
              children: controller.categoryBreakdown.asMap().entries.map((
                entry,
              ) {
                final index = entry.key;
                final item = entry.value;
                final color = colors[index % colors.length];

                return _buildCategoryItem(
                  item['category'],
                  item['percentage'].toDouble(),
                  color,
                  CurrencyFormatter.format(item['revenue']),
                  isDark,
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    String name,
    double percentage,
    Color color,
    String revenue,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            revenue,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: isDark
                ? AppColors.darkSurfaceVariant
                : Colors.grey[200],
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTable(
    TransactionController controller,
    bool isDark,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceColor(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.getDivider(isDark), width: 1),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      Get.to(() => TransactionsListView());
                    },
                    icon: Icon(
                      Iconsax.arrow_right_3,
                      size: 16,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                    label: Text(
                      'View All',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  );
                }

                final transactions = controller.filteredTransactions
                    .take(10)
                    .toList();

                if (transactions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No transactions found',
                        style: TextStyle(
                          color: AppColors.getTextSecondary(isDark),
                        ),
                      ),
                    ),
                  );
                }

                // Mobile view: Card-based list
                if (context.isMobile) {
                  return _buildMobileTransactionsList(
                    context,
                    transactions,
                    isDark,
                  );
                }

                // Desktop view: Table
                return _buildDesktopTransactionsTable(transactions, isDark);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopTransactionsTable(
    List<TransactionModel> transactions,
    bool isDark,
  ) {
    return Table(
      columnWidths: {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
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
          ],
        ),
        ...transactions.map((transaction) {
          return TableRow(
            children: [
              _buildTableCell(transaction.id, isDark),
              _buildTableCell(
                DateFormat('MMM dd, HH:mm').format(transaction.transactionDate),
                isDark,
              ),
              _buildTableCell(transaction.customerName ?? 'Guest', isDark),
              _buildTableCell(
                transaction.paymentMethod.name.toUpperCase(),
                isDark,
              ),
              Obx(
                () => _buildTableCell(
                  CurrencyFormatter.format(transaction.total),
                  isDark,
                  bold: true,
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMobileTransactionsList(
    BuildContext context,
    List<TransactionModel> transactions,
    bool isDark,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return GestureDetector(
          onTap: () => _showTransactionDetails(context, transaction, isDark),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.getDivider(isDark), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: ID and Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
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
                          const SizedBox(width: 8),
                          _buildMobilePaymentBadge(
                            transaction.paymentMethod.name.toUpperCase(),
                            isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      CurrencyFormatter.format(transaction.total),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Customer name
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
                // Date and time
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
      },
    );
  }

  Widget _buildMobilePaymentBadge(String method, bool isDark) {
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(isDark ? 0.25 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: badgeColor),
          SizedBox(width: 4),
          Text(
            method,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format transaction ID for mobile display
  String _formatTransactionId(String id) {
    // If ID is short enough, show it all
    if (id.length <= 8) return '#$id';

    // Otherwise show first 4 and last 4 characters with ellipsis
    final first = id.substring(0, 4);
    final last = id.substring(id.length - 4);
    return '#$first...$last';
  }

  void _showTransactionDetails(
    BuildContext context,
    TransactionModel transaction,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.getSurfaceColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: context.isMobile ? double.infinity : 500,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                      // Transaction Info
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
                      // Items
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
              // Footer buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Get.back(),
                        icon: Icon(Iconsax.close_square, size: 18),
                        label: Text('Close'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: AppColors.getDivider(isDark)),
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
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
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
          const SizedBox(width: 12),
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
                const SizedBox(height: 2),
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

  Future<void> _exportReport(
    BuildContext context,
    TransactionController transactionController,
    DashboardController dashboardController,
    ReportsController reportsController,
  ) async {
    try {
      // Show loading dialog
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating report...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Generate CSV content
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final transactions = transactionController.filteredTransactions.toList();

      StringBuffer csvContent = StringBuffer();

      // Header
      csvContent.writeln('DYNAMOS POS - SALES REPORT');
      csvContent.writeln(
        'Generated: ${DateFormat('MMM dd, yyyy - HH:mm').format(now)}',
      );
      csvContent.writeln(
        'Period: ${DateFormat('MMM dd, yyyy').format(startOfMonth)} - ${DateFormat('MMM dd, yyyy').format(now)}',
      );
      csvContent.writeln('');

      // Summary Stats
      csvContent.writeln('SUMMARY');
      csvContent.writeln(
        'Total Revenue,${CurrencyFormatter.format(dashboardController.monthSales.value)}',
      );
      csvContent.writeln(
        'Total Transactions,${dashboardController.monthTransactions.value}',
      );
      final avgOrder = dashboardController.monthTransactions.value > 0
          ? dashboardController.monthSales.value /
                dashboardController.monthTransactions.value
          : 0.0;
      csvContent.writeln('Average Order,${CurrencyFormatter.format(avgOrder)}');
      csvContent.writeln('');

      // Category Breakdown
      csvContent.writeln('TOP CATEGORIES');
      csvContent.writeln('Category,Revenue,Percentage');
      for (var category in reportsController.categoryBreakdown) {
        csvContent.writeln(
          '${category['category']},${CurrencyFormatter.format(category['revenue'])},${category['percentage'].toStringAsFixed(1)}%',
        );
      }
      csvContent.writeln('');

      // Transactions
      csvContent.writeln('TRANSACTIONS');
      csvContent.writeln(
        'ID,Date,Time,Customer,Payment Method,Items,Subtotal,Tax,Discount,Total',
      );

      for (var transaction in transactions) {
        final date = DateFormat(
          'MMM dd, yyyy',
        ).format(transaction.transactionDate);
        final time = DateFormat('HH:mm').format(transaction.transactionDate);
        final customer = transaction.customerName ?? 'Guest';
        final payment = transaction.paymentMethod.name.toUpperCase();
        final itemCount = transaction.items.length;

        csvContent.writeln(
          '${transaction.id},$date,$time,$customer,$payment,$itemCount,${CurrencyFormatter.format(transaction.subtotal)},${CurrencyFormatter.format(transaction.tax)},${CurrencyFormatter.format(transaction.discount)},${CurrencyFormatter.format(transaction.total)}',
        );
      }

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'sales_report_${DateFormat('yyyyMMdd_HHmmss').format(now)}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvContent.toString());

      // Close loading dialog
      Get.back();

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Sales Report - ${DateFormat('MMM yyyy').format(now)}',
        text: 'Sales report generated from Dynamos POS',
      );

      Get.snackbar(
        'Success',
        'Report exported successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to export report: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  Widget _buildTableHeader(String text, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
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

  Future<void> _selectDateRange(BuildContext context) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          _selectedDateRange ?? DateTimeRange(start: startOfMonth, end: now),
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

      Get.snackbar(
        'Info',
        'Date range selected: ${DateFormat('MMM dd').format(picked.start)} - ${DateFormat('MMM dd').format(picked.end)}',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    }
  }
}
