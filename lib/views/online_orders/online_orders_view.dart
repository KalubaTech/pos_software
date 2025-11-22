import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos_software/controllers/online_orders_controller.dart';
import 'package:pos_software/models/online_order_model.dart';
import 'package:pos_software/utils/responsive.dart';
import 'package:pos_software/utils/colors.dart';
import 'package:pos_software/controllers/appearance_controller.dart';

class OnlineOrdersView extends StatelessWidget {
  const OnlineOrdersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnlineOrdersController());
    final appearanceController = Get.find<AppearanceController>();

    return Obx(() {
      final isDark = appearanceController.isDarkMode.value;

      if (!controller.isInitialized.value) {
        return Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      // Show message if no business is configured
      if (!controller.hasBusinessId) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.shop,
                  size: 80,
                  color: AppColors.primary.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'No Business Configured',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please log in with your business account\nto view and manage online orders',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.getTextSecondary(isDark),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return Container(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        child: Column(
          children: [
            // Modern Header with gradient
            _buildModernHeader(controller, context, isDark),

            // Content area
            Expanded(child: _buildContent(controller, context, isDark)),
          ],
        ),
      );
    });
  }

  Widget _buildModernHeader(
    OnlineOrdersController controller,
    BuildContext context,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with notification badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Iconsax.shopping_cart5,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Online Orders',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dynamos Market Orders',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Obx(() {
                    if (controller.newOrdersCount.value > 0) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Iconsax.notification_bing5,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${controller.newOrdersCount.value} New',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // Statistics cards in header
              Obx(() => _buildHeaderStats(controller, context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStats(
    OnlineOrdersController controller,
    BuildContext context,
  ) {
    final stats = controller.orderStats;
    final isMobile = Responsive.isMobile(context);

    return SingleChildScrollView(
      scrollDirection: isMobile ? Axis.horizontal : Axis.vertical,
      child: Row(
        children: [
          _buildModernStatCard(
            label: 'Pending',
            value: '${stats['pending'] ?? 0}',
            icon: Iconsax.clock5,
            color: Colors.orange,
            gradient: [Colors.orange.shade400, Colors.orange.shade600],
          ),
          const SizedBox(width: 12),
          _buildModernStatCard(
            label: 'Active',
            value: '${controller.activeOrders.length}',
            icon: Iconsax.truck,
            color: Colors.blue,
            gradient: [Colors.blue.shade400, Colors.blue.shade600],
          ),
          const SizedBox(width: 12),
          _buildModernStatCard(
            label: 'Delivered',
            value: '${stats['delivered'] ?? 0}',
            icon: Iconsax.tick_circle5,
            color: Colors.green,
            gradient: [Colors.green.shade400, Colors.green.shade600],
          ),
          const SizedBox(width: 12),
          _buildModernStatCard(
            label: 'Revenue',
            value: 'K ${controller.totalRevenue.value.toStringAsFixed(0)}',
            icon: Iconsax.dollar_square,
            color: Colors.purple,
            gradient: [Colors.purple.shade400, Colors.purple.shade600],
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    OnlineOrdersController controller,
    BuildContext context,
    bool isDark,
  ) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          // Modern tab bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceColor(isDark),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.getTextSecondary(isDark),
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.clock, size: 18),
                      const SizedBox(width: 8),
                      const Text('Pending'),
                      const SizedBox(width: 8),
                      Obx(() {
                        final count = controller.pendingOrders.length;
                        if (count > 0) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.truck_fast, size: 18),
                      const SizedBox(width: 8),
                      const Text('Active'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.tick_circle, size: 18),
                      const SizedBox(width: 8),
                      const Text('Completed'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.menu_board, size: 18),
                      const SizedBox(width: 8),
                      const Text('All'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              children: [
                _buildModernOrdersList(
                  controller,
                  controller.pendingOrders,
                  context,
                  isDark,
                ),
                _buildModernOrdersList(
                  controller,
                  controller.activeOrders,
                  context,
                  isDark,
                ),
                _buildModernOrdersList(
                  controller,
                  controller.allOrders
                      .where(
                        (o) =>
                            o.status == OrderStatus.delivered ||
                            o.status == OrderStatus.cancelled,
                      )
                      .toList()
                      .obs,
                  context,
                  isDark,
                ),
                _buildModernOrdersList(
                  controller,
                  controller.allOrders,
                  context,
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernOrdersList(
    OnlineOrdersController controller,
    RxList<OnlineOrderModel> orders,
    BuildContext context,
    bool isDark,
  ) {
    return Obx(() {
      if (orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.shopping_bag,
                  size: 64,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No orders found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Orders will appear here when customers place them',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getTextSecondary(isDark),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildModernOrderCard(order, controller, context, isDark);
        },
      );
    });
  }

  Widget _buildModernOrderCard(
    OnlineOrderModel order,
    OnlineOrdersController controller,
    BuildContext context,
    bool isDark,
  ) {
    final statusColor = _getStatusColor(order.status);
    final statusGradient = _getStatusGradient(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showOrderDetails(order, controller),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with order number and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: statusGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getStatusIcon(order.status),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order #${order.id.substring(0, 10).toUpperCase()}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.getTextPrimary(isDark),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDateTime(order.createdAt),
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
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: statusGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _getStatusText(order.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Customer info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Iconsax.user,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.customerName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getTextPrimary(isDark),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Iconsax.call,
                                  size: 14,
                                  color: AppColors.getTextSecondary(isDark),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  order.customerPhone,
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
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Items summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.shopping_bag,
                        color: Colors.orange.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                      ),
                      Text(
                        'K ${order.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showOrderDetails(order, controller),
                        icon: const Icon(Iconsax.eye, size: 18),
                        label: const Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.getTextPrimary(isDark),
                          side: BorderSide(
                            color: AppColors.getTextSecondary(
                              isDark,
                            ).withOpacity(0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    if (order.status == OrderStatus.pending) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmOrder(order, controller),
                          icon: const Icon(Iconsax.tick_circle, size: 18),
                          label: const Text('Accept'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return Colors.red;
    }
  }

  List<Color> _getStatusGradient(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return [Colors.orange.shade400, Colors.orange.shade600];
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        return [Colors.blue.shade400, Colors.blue.shade600];
      case OrderStatus.outForDelivery:
        return [Colors.purple.shade400, Colors.purple.shade600];
      case OrderStatus.delivered:
        return [Colors.green.shade400, Colors.green.shade600];
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return [Colors.red.shade400, Colors.red.shade600];
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Iconsax.clock;
      case OrderStatus.confirmed:
        return Iconsax.tick_circle;
      case OrderStatus.preparing:
        return Iconsax.box;
      case OrderStatus.outForDelivery:
        return Iconsax.truck;
      case OrderStatus.delivered:
        return Iconsax.tick_square;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return Iconsax.close_circle;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.confirmed:
        return 'CONFIRMED';
      case OrderStatus.preparing:
        return 'PREPARING';
      case OrderStatus.outForDelivery:
        return 'OUT FOR DELIVERY';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
      case OrderStatus.refunded:
        return 'REFUNDED';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }

  void _confirmOrder(
    OnlineOrderModel order,
    OnlineOrdersController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Order'),
        content: Text('Accept order #${order.id.substring(0, 8)}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              controller.confirmOrder(order);
              Get.back();
              Get.snackbar(
                'Success',
                'Order confirmed successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        break;
      case OrderStatus.confirmed:
        color = Colors.blue;
        break;
      case OrderStatus.preparing:
        color = Colors.purple;
        break;
      case OrderStatus.outForDelivery:
        color = Colors.indigo;
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        break;
      case OrderStatus.refunded:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(status.icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            status.displayText,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(
    OnlineOrderModel order,
    OnlineOrdersController controller,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildStatusBadge(order.status),
                const Divider(height: 32),

                // Customer details
                _buildDetailSection('Customer Information', [
                  _buildDetailRow('Name', order.customerName),
                  _buildDetailRow('Phone', order.customerPhone),
                  if (order.customerEmail.isNotEmpty)
                    _buildDetailRow('Email', order.customerEmail),
                ]),
                const SizedBox(height: 24),

                // Delivery address
                _buildDetailSection('Delivery Address', [
                  _buildDetailRow('Address', order.deliveryAddress.fullAddress),
                  if (order.deliveryAddress.province != null)
                    _buildDetailRow(
                      'Province',
                      order.deliveryAddress.province!,
                    ),
                  if (order.deliveryAddress.instructions != null)
                    _buildDetailRow(
                      'Instructions',
                      order.deliveryAddress.instructions!,
                    ),
                ]),
                const SizedBox(height: 24),

                // Order items
                _buildDetailSection(
                  'Order Items',
                  order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (item.variant != null)
                                  Text(
                                    'Variant: ${item.variant!.name}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text('x${item.quantity}'),
                          const SizedBox(width: 16),
                          Text(
                            'K ${item.total.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const Divider(),
                _buildDetailRow(
                  'Subtotal',
                  'K ${order.subtotal.toStringAsFixed(2)}',
                ),
                _buildDetailRow(
                  'Delivery Fee',
                  'K ${order.deliveryFee.toStringAsFixed(2)}',
                ),
                _buildDetailRow(
                  'Total',
                  'K ${order.total.toStringAsFixed(2)}',
                  bold: true,
                ),
                const SizedBox(height: 24),

                // Payment info
                _buildDetailSection('Payment Information', [
                  _buildDetailRow('Method', order.paymentMethod.toUpperCase()),
                  _buildDetailRow('Status', order.paymentStatus.displayText),
                ]),

                if (order.notes != null) ...[
                  const SizedBox(height: 24),
                  _buildDetailSection('Notes', [Text(order.notes!)]),
                ],

                const SizedBox(height: 24),

                // Action buttons
                _buildOrderActions(order, controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderActions(
    OnlineOrderModel order,
    OnlineOrdersController controller,
  ) {
    final actions = <Widget>[];

    if (order.status == OrderStatus.pending) {
      actions.add(
        ElevatedButton.icon(
          onPressed: () {
            controller.confirmOrder(order);
            Get.back();
          },
          icon: const Icon(Icons.check),
          label: const Text('Confirm Order'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      );
    }

    if (order.status == OrderStatus.confirmed) {
      actions.add(
        ElevatedButton.icon(
          onPressed: () {
            controller.markAsPreparing(order);
            Get.back();
          },
          icon: const Icon(Icons.restaurant),
          label: const Text('Mark as Preparing'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      );
    }

    if (order.status == OrderStatus.preparing) {
      actions.add(
        ElevatedButton.icon(
          onPressed: () {
            controller.markAsOutForDelivery(order);
            Get.back();
          },
          icon: const Icon(Icons.local_shipping),
          label: const Text('Mark as Out for Delivery'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      );
    }

    if (order.status == OrderStatus.outForDelivery) {
      actions.add(
        ElevatedButton.icon(
          onPressed: () {
            controller.markAsDelivered(order);
            Get.back();
          },
          icon: const Icon(Icons.check_circle),
          label: const Text('Mark as Delivered'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      );
    }

    if (order.canBeCancelled) {
      actions.add(const SizedBox(height: 12));
      actions.add(
        OutlinedButton.icon(
          onPressed: () {
            Get.back();
            _showCancelDialog(order, controller);
          },
          icon: const Icon(Icons.cancel),
          label: const Text('Cancel Order'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      );
    }

    return Column(children: actions);
  }

  void _showCancelDialog(
    OnlineOrderModel order,
    OnlineOrdersController controller,
  ) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to cancel this order?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Cancellation Reason',
                hintText: 'Enter reason for cancellation',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No, Keep Order'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please provide a cancellation reason',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              controller.cancelOrder(order, reasonController.text.trim());
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel Order'),
          ),
        ],
      ),
    );
  }
}
