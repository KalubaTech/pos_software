import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/reports_controller.dart';
import '../../utils/colors.dart';
import '../../utils/currency_formatter.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionController = Get.put(TransactionController());
    final dashboardController = Get.put(DashboardController());
    final reportsController = Get.put(ReportsController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 24),
            _buildStatsRow(dashboardController, reportsController),
            SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildSalesChart(dashboardController)),
                SizedBox(width: 24),
                Expanded(child: _buildCategoryBreakdown(reportsController)),
              ],
            ),
            SizedBox(height: 24),
            _buildTransactionsTable(transactionController),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reports & Analytics',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'View your sales performance and insights',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Iconsax.calendar),
              label: Text('This Month'),
            ),
            SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Iconsax.document_download),
              label: Text('Export'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(
    DashboardController controller,
    ReportsController reportsController,
  ) {
    return Row(
      children: [
        Expanded(
          child: Obx(() {
            final growth = reportsController.getRevenueGrowth(
              controller.monthSales.value,
            );
            return _buildStatCard(
              'Total Revenue',
              Obx(
                () => Text(
                  CurrencyFormatter.format(controller.monthSales.value),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              Iconsax.dollar_circle,
              AppColors.primary,
              reportsController.formatGrowth(growth),
              reportsController.getGrowthColor(growth),
            );
          }),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Obx(() {
            final growth = reportsController.getTransactionGrowth(
              controller.monthTransactions.value,
            );
            return _buildStatCard(
              'Transactions',
              Obx(
                () => Text(
                  '${controller.monthTransactions.value}',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              Iconsax.receipt_2_1,
              Colors.blue,
              reportsController.formatGrowth(growth),
              reportsController.getGrowthColor(growth),
            );
          }),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Average Order',
            Obx(() {
              final avg = controller.monthTransactions.value > 0
                  ? controller.monthSales.value /
                        controller.monthTransactions.value
                  : 0.0;
              return Text(
                CurrencyFormatter.format(avg),
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              );
            }),
            Iconsax.chart_21,
            Colors.orange,
            'Average per transaction',
            Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    Widget valueWidget,
    IconData icon,
    Color color,
    String change,
    Color changeColor,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
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
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 11,
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          SizedBox(height: 4),
          valueWidget,
        ],
      ),
    );
  }

  Widget _buildSalesChart(DashboardController controller) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: Obx(() {
              if (controller.salesChartData.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              return LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Obx(
                            () => Text(
                              CurrencyFormatter.format(value),
                              style: TextStyle(fontSize: 10),
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
                                style: TextStyle(fontSize: 10),
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
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.1),
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

  Widget _buildCategoryBreakdown(ReportsController controller) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          Obx(() {
            if (controller.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }

            if (controller.categoryBreakdown.isEmpty) {
              return Center(
                child: Text(
                  'No category data available',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            }

            final colors = [
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
                  style: TextStyle(fontWeight: FontWeight.w600),
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
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTable(TransactionController controller) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
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
              Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Iconsax.arrow_right_3),
                label: Text('View All'),
              ),
            ],
          ),
          SizedBox(height: 16),
          Obx(() {
            if (controller.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }

            final transactions = controller.filteredTransactions
                .take(10)
                .toList();

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
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  children: [
                    _buildTableHeader('ID'),
                    _buildTableHeader('Date & Time'),
                    _buildTableHeader('Customer'),
                    _buildTableHeader('Payment'),
                    _buildTableHeader('Total'),
                  ],
                ),
                ...transactions.map((transaction) {
                  return TableRow(
                    children: [
                      _buildTableCell(transaction.id),
                      _buildTableCell(
                        DateFormat(
                          'MMM dd, HH:mm',
                        ).format(transaction.transactionDate),
                      ),
                      _buildTableCell(transaction.customerName ?? 'Guest'),
                      _buildTableCell(
                        transaction.paymentMethod.name.toUpperCase(),
                      ),
                      Obx(
                        () => _buildTableCell(
                          CurrencyFormatter.format(transaction.total),
                          bold: true,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
