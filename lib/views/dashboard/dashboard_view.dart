import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/appearance_controller.dart';
import '../../utils/colors.dart';
import '../../utils/currency_formatter.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final appearanceController = Get.find<AppearanceController>();
    final ScrollController scrollController = ScrollController();

    return Obx(() {
      final isDark = appearanceController.isDarkMode.value;

      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
        body: Stack(
          children: [
            // Background gradient
            Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.getGradientColors(isDark),
                ),
              ),
            ),
            // Main content
            RefreshIndicator.adaptive(
              onRefresh: controller.refresh,
              child: CustomScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Glassmorphic Header
                  SliverAppBar(
                    expandedHeight: 200,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildGlassmorphicHeader(controller, isDark),
                    ),
                  ),
                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildStatsCards(controller, isDark),
                        const SizedBox(height: 32),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildSalesChart(controller, isDark),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildTopProducts(controller, isDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildRecentTransactions(controller, isDark),
                        const SizedBox(height: 24),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildGlassmorphicHeader(DashboardController controller, bool isDark) {
    final appearanceController = Get.find<AppearanceController>();

    return Container(
      padding: const EdgeInsets.fromLTRB(32, 50, 32, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.getGlassBackground(
                    isDark,
                  ).withOpacity(isDark ? 0.2 : 0.2),
                  AppColors.getGlassBackground(
                    isDark,
                  ).withOpacity(isDark ? 0.1 : 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.getGlassBorder(isDark),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Iconsax.chart_215,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.calendar,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat(
                                'EEEE, MMMM d, y',
                              ).format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.95),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    // Epic Theme Toggle Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            appearanceController.toggleTheme();
                            Get.snackbar(
                              isDark ? '☀️ Light Mode' : '🌙 Dark Mode',
                              isDark
                                  ? 'Switched to light theme'
                                  : 'Switched to dark theme',
                              snackPosition: SnackPosition.BOTTOM,
                              duration: Duration(seconds: 2),
                              backgroundColor: isDark
                                  ? AppColors.primary
                                  : AppColors.darkPrimary,
                              colorText: Colors.white,
                              margin: EdgeInsets.all(16),
                              borderRadius: 12,
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return RotationTransition(
                                  turns: animation,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Icon(
                                isDark ? Iconsax.sun_1 : Iconsax.moon,
                                key: ValueKey(isDark),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Refresh Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => controller.refresh(),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.refresh,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Refresh',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(DashboardController controller, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.5,
      children: [
        Obx(
          () => _buildStatCard(
            'Today\'s Sales',
            CurrencyFormatter.format(controller.todaySales.value),
            Iconsax.dollar_circle,
            isDark ? AppColors.darkPrimary : AppColors.primary,
            '${controller.todayTransactions.value} transactions',
            isDark
                ? AppColors.darkPrimary.withOpacity(0.2)
                : AppColors.primary.withOpacity(0.1),
            isDark,
          ),
        ),
        Obx(
          () => _buildStatCard(
            'Month Sales',
            CurrencyFormatter.format(controller.monthSales.value),
            Iconsax.chart_21,
            isDark ? AppColors.darkSecondary : AppColors.secondary,
            '${controller.monthTransactions.value} transactions',
            isDark
                ? AppColors.darkSecondary.withOpacity(0.2)
                : AppColors.secondary.withOpacity(0.1),
            isDark,
          ),
        ),
        Obx(
          () => _buildStatCard(
            'Total Customers',
            '${controller.totalCustomers.value}',
            Iconsax.profile_2user,
            isDark ? AppColors.darkPrimaryVariant : AppColors.primaryVariant,
            'All time',
            isDark
                ? AppColors.darkPrimaryVariant.withOpacity(0.2)
                : AppColors.primaryVariant.withOpacity(0.1),
            isDark,
          ),
        ),
        Obx(
          () => _buildStatCard(
            'Total Products',
            '${controller.totalProducts.value}',
            Iconsax.box,
            isDark
                ? AppColors.darkSecondaryVariant
                : AppColors.secondaryVariant,
            '${controller.lowStockItems.value} low stock',
            isDark
                ? AppColors.darkSecondaryVariant.withOpacity(0.2)
                : AppColors.secondaryVariant.withOpacity(0.1),
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
    Color backgroundColor,
    bool isDark,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.darkSurface.withOpacity(0.95),
                      AppColors.darkSurface.withOpacity(0.85),
                    ]
                  : [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.4)
                    : color.withOpacity(0.15),
                blurRadius: isDark ? 20 : 24,
                offset: const Offset(0, 10),
                spreadRadius: 0,
              ),
              if (!isDark)
                BoxShadow(
                  color: Colors.white.withOpacity(0.6),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
            ],
          ),
          child: Stack(
            children: [
              // Background decoration with glassmorphic circle
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        color.withOpacity(0.15),
                        color.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.getTextSecondary(isDark),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                color.withOpacity(isDark ? 0.25 : 0.2),
                                color.withOpacity(isDark ? 0.15 : 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: color.withOpacity(isDark ? 0.4 : 0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(icon, color: color, size: 24),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextPrimary(isDark),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color.withOpacity(0.15),
                                color.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: color.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildSalesChart(DashboardController controller, bool isDark) {
    return Container(
      height: 420,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sales Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last 7 Days Performance',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getTextSecondary(isDark),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                      .withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                        .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.trend_up,
                      size: 16,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Weekly',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Expanded(
            child: Obx(() {
              if (controller.salesChartData.isEmpty) {
                return const Center(child: Text('No data available'));
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
                          if (value == meta.max || value == meta.min) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              NumberFormat.compact().format(value),
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.getTextTertiary(isDark),
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() <
                                  controller.salesChartData.length) {
                            final date =
                                controller.salesChartData[value.toInt()]['date']
                                    as DateTime;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat('E')
                                    .format(date)
                                    .substring(0, 1), // "M" for Monday
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getTextSecondary(isDark),
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
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
                      barWidth: 4,
                      isStrokeCapRound: true,
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
                        gradient: LinearGradient(
                          colors: [
                            (isDark ? AppColors.darkPrimary : AppColors.primary)
                                .withOpacity(isDark ? 0.2 : 0.3),
                            (isDark ? AppColors.darkPrimary : AppColors.primary)
                                .withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  minY: 0,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            CurrencyFormatter.format(spot.y),
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProducts(DashboardController controller, bool isDark) {
    return Container(
      height: 420,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (isDark ? AppColors.darkPrimary : AppColors.primary)
                          .withOpacity(isDark ? 0.25 : 0.2),
                      (isDark ? AppColors.darkPrimary : AppColors.primary)
                          .withOpacity(isDark ? 0.15 : 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                        .withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  Iconsax.medal_star,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark),
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Best sellers',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextSecondary(isDark),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (controller.topSellingProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.box,
                        size: 48,
                        color: AppColors.getTextTertiary(isDark),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No sales data yet',
                        style: TextStyle(
                          color: AppColors.getTextSecondary(isDark),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: controller.topSellingProducts.length > 5
                    ? 5
                    : controller.topSellingProducts.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 24, color: AppColors.getDivider(isDark)),
                itemBuilder: (context, index) {
                  final item = controller.topSellingProducts[index];
                  final product = item['product'];
                  final quantity = item['quantity'];
                  final revenue = item['revenue'];

                  // Color for ranking
                  final rankColor = index == 0
                      ? (isDark ? Color(0xFFFFD700) : Colors.amber.shade600)
                      : index == 1
                      ? (isDark ? Color(0xFFC0C0C0) : Colors.grey.shade400)
                      : index == 2
                      ? (isDark ? Color(0xFFCD7F32) : Colors.brown.shade400)
                      : (isDark ? AppColors.darkPrimary : AppColors.primary);

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.grey.shade100,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                rankColor.withOpacity(isDark ? 0.3 : 0.2),
                                rankColor.withOpacity(isDark ? 0.2 : 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: rankColor.withOpacity(0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '#${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: rankColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.getTextPrimary(isDark),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          (isDark
                                                  ? AppColors.darkPrimary
                                                  : AppColors.primary)
                                              .withOpacity(isDark ? 0.2 : 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color:
                                            (isDark
                                                    ? AppColors.darkPrimary
                                                    : AppColors.primary)
                                                .withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      '$quantity sold',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.darkPrimary
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    CurrencyFormatter.format(revenue),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(DashboardController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (isDark ? AppColors.darkPrimary : AppColors.primary)
                              .withOpacity(isDark ? 0.25 : 0.2),
                          (isDark ? AppColors.darkPrimary : AppColors.primary)
                              .withOpacity(isDark ? 0.15 : 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            (isDark ? AppColors.darkPrimary : AppColors.primary)
                                .withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      Iconsax.receipt_text,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimary(isDark),
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Latest activity',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextSecondary(isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  // TODO: Navigate to full transactions view
                },
                icon: Icon(Iconsax.arrow_right_3, size: 16),
                label: Text('View All'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Obx(() {
            if (controller.recentTransactions.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    children: [
                      Icon(
                        Iconsax.receipt_disscount,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions yet',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.grey.shade100,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                  5: IntrinsicColumnWidth(),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    children: [
                      _buildTableHeader('ID', isDark),
                      _buildTableHeader('Date & Time', isDark),
                      _buildTableHeader('Customer', isDark),
                      _buildTableHeader('Method', isDark),
                      _buildTableHeader('Total', isDark),
                      _buildTableHeader('', isDark),
                    ],
                  ),
                  ...controller.recentTransactions.map((transaction) {
                    return TableRow(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.getDivider(isDark),
                            width: 1,
                          ),
                        ),
                      ),
                      children: [
                        _buildTableCell(transaction.id, isDark),
                        _buildTableCell(
                          DateFormat(
                            'MMM dd, hh:mm a',
                          ).format(transaction.transactionDate),
                          isDark,
                        ),
                        _buildTableCell(
                          transaction.customerName ?? 'Guest',
                          isDark,
                        ),
                        _buildTableCellWithBadge(
                          transaction.paymentMethod.name.toUpperCase(),
                          isDark,
                        ),
                        _buildTableCell(
                          CurrencyFormatter.format(transaction.total),
                          isDark,
                          bold: true,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 8.0,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Iconsax.eye,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              // TODO: Implement view transaction details action
                            },
                            tooltip: 'View Details',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: AppColors.getTextSecondary(isDark),
          letterSpacing: 0.5,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, bool isDark, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          color: bold
              ? AppColors.getTextPrimary(isDark)
              : AppColors.getTextSecondary(isDark),
        ),
      ),
    );
  }

  Widget _buildTableCellWithBadge(String text, bool isDark) {
    Color badgeColor;
    switch (text.toUpperCase()) {
      case 'CASH':
        badgeColor = isDark ? AppColors.darkSecondary : AppColors.secondary;
        break;
      case 'CARD':
        badgeColor = isDark ? AppColors.darkPrimary : AppColors.primary;
        break;
      case 'MOBILE':
        badgeColor = isDark
            ? AppColors.darkSecondaryVariant
            : AppColors.secondaryVariant;
        break;
      default:
        badgeColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: badgeColor.withOpacity(isDark ? 0.4 : 0.3),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: badgeColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
