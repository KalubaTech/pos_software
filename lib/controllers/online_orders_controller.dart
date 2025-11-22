import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pos_software/models/online_order_model.dart';
import 'package:pos_software/services/online_orders_service.dart';

/// Controller for managing online orders from Dynamos Market
class OnlineOrdersController extends GetxController {
  final OnlineOrdersService _ordersService = Get.put(OnlineOrdersService());
  final GetStorage _storage = GetStorage();

  // Observable lists
  final allOrders = <OnlineOrderModel>[].obs;
  final pendingOrders = <OnlineOrderModel>[].obs;
  final activeOrders = <OnlineOrderModel>[].obs;

  // Loading states
  final isLoading = false.obs;
  final isInitialized = false.obs;

  // Statistics
  final orderStats = <String, int>{}.obs;
  final totalRevenue = 0.0.obs;

  // Selected order for details view
  final Rx<OnlineOrderModel?> selectedOrder = Rx<OnlineOrderModel?>(null);

  // Notification badge count
  final newOrdersCount = 0.obs;

  // Stream subscriptions
  StreamSubscription? _allOrdersSubscription;
  StreamSubscription? _pendingOrdersSubscription;
  StreamSubscription? _activeOrdersSubscription;

  String? _businessId;

  // Public getter to check if business is configured
  bool get hasBusinessId => _businessId != null && _businessId!.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  /// Initialize the controller with business ID
  Future<void> _initializeController() async {
    try {
      // Get business ID from storage (only if not already set)
      if (_businessId == null || _businessId!.isEmpty) {
        _businessId =
            _storage.read('business_id') ?? _storage.read('businessId');
      }

      if (_businessId == null || _businessId!.isEmpty) {
        print('⚠️ No business ID found, waiting for login...');
        isInitialized.value =
            true; // Mark as initialized even without businessId
        return;
      }

      print(
        '🔄 Initializing Online Orders Controller for business: $_businessId',
      );

      // Start listening to orders
      _listenToOrders();

      // Load statistics
      await loadStatistics();

      isInitialized.value = true;
      print('✅ Online Orders Controller initialized');
    } catch (e) {
      print('❌ Error initializing Online Orders Controller: $e');
      isInitialized.value = true; // Mark as initialized even on error
    }
  }

  /// Start listening to order streams
  void _listenToOrders() {
    if (_businessId == null) return;

    // Listen to all orders
    _allOrdersSubscription = _ordersService
        .getBusinessOrdersStream(_businessId!)
        .listen(
          (orders) {
            allOrders.value = orders;
            print('📦 Loaded ${orders.length} total orders');
          },
          onError: (error) {
            print('❌ Error listening to all orders: $error');
          },
        );

    // Listen to pending orders
    _pendingOrdersSubscription = _ordersService
        .getPendingOrdersStream(_businessId!)
        .listen(
          (orders) {
            final previousCount = pendingOrders.length;
            pendingOrders.value = orders;

            // Check for new orders
            if (orders.length > previousCount && isInitialized.value) {
              newOrdersCount.value = orders.length - previousCount;
              _showNewOrderNotification(orders.first);
            }

            print('⏳ ${orders.length} pending orders');
          },
          onError: (error) {
            print('❌ Error listening to pending orders: $error');
          },
        );

    // Listen to active orders
    _activeOrdersSubscription = _ordersService
        .getActiveOrdersStream(_businessId!)
        .listen(
          (orders) {
            activeOrders.value = orders;
            print('🔄 ${orders.length} active orders');
          },
          onError: (error) {
            print('❌ Error listening to active orders: $error');
          },
        );
  }

  /// Show notification for new order
  void _showNewOrderNotification(OnlineOrderModel order) {
    Get.snackbar(
      '🛒 New Online Order!',
      'Order #${order.id.substring(0, 8)} from ${order.customerName}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      isDismissible: true,
      mainButton: TextButton(
        onPressed: () {
          selectOrder(order);
          Get.back(); // Close snackbar
        },
        child: const Text(
          'View',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    // Play sound or vibration here if needed
    print('🔔 New order notification shown');
  }

  /// Load order statistics
  Future<void> loadStatistics() async {
    if (_businessId == null) return;

    try {
      final stats = await _ordersService.getOrderStatistics(_businessId!);
      orderStats.value = stats;

      final revenue = await _ordersService.getTotalRevenue(_businessId!);
      totalRevenue.value = revenue;

      print(
        '📊 Statistics loaded: ${stats['total']} total orders, Revenue: $revenue',
      );
    } catch (e) {
      print('❌ Error loading statistics: $e');
    }
  }

  /// Confirm an order
  Future<bool> confirmOrder(OnlineOrderModel order) async {
    try {
      isLoading.value = true;

      final success = await _ordersService.confirmOrder(_businessId!, order.id);

      if (success) {
        Get.snackbar(
          '✅ Order Confirmed',
          'Order #${order.id.substring(0, 8)} has been confirmed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh statistics
        await loadStatistics();
        return true;
      } else {
        Get.snackbar(
          '❌ Error',
          'Failed to confirm order',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print('❌ Error confirming order: $e');
      Get.snackbar(
        '❌ Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Mark order as preparing
  Future<bool> markAsPreparing(OnlineOrderModel order) async {
    try {
      isLoading.value = true;

      final success = await _ordersService.markAsPreparing(
        _businessId!,
        order.id,
      );

      if (success) {
        Get.snackbar(
          '👨‍🍳 Order Preparing',
          'Order #${order.id.substring(0, 8)} is now being prepared',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error marking as preparing: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Mark order as out for delivery
  Future<bool> markAsOutForDelivery(
    OnlineOrderModel order, {
    String? trackingNumber,
  }) async {
    try {
      isLoading.value = true;

      final success = await _ordersService.markAsOutForDelivery(
        _businessId!,
        order.id,
        trackingNumber: trackingNumber,
      );

      if (success) {
        Get.snackbar(
          '🚚 Out for Delivery',
          'Order #${order.id.substring(0, 8)} is out for delivery',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error marking as out for delivery: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Mark order as delivered
  Future<bool> markAsDelivered(OnlineOrderModel order) async {
    try {
      isLoading.value = true;

      final success = await _ordersService.markAsDelivered(
        _businessId!,
        order.id,
      );

      if (success) {
        Get.snackbar(
          '📦 Order Delivered',
          'Order #${order.id.substring(0, 8)} has been delivered',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh statistics
        await loadStatistics();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error marking as delivered: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Cancel an order
  Future<bool> cancelOrder(OnlineOrderModel order, String reason) async {
    try {
      isLoading.value = true;

      final success = await _ordersService.cancelOrder(
        _businessId!,
        order.id,
        reason,
      );

      if (success) {
        Get.snackbar(
          '❌ Order Cancelled',
          'Order #${order.id.substring(0, 8)} has been cancelled',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        // Refresh statistics
        await loadStatistics();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error cancelling order: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update payment status
  Future<bool> updatePaymentStatus(
    OnlineOrderModel order,
    PaymentStatus newStatus,
  ) async {
    try {
      isLoading.value = true;

      final success = await _ordersService.updatePaymentStatus(
        businessId: _businessId!,
        orderId: order.id,
        newStatus: newStatus,
      );

      if (success) {
        Get.snackbar(
          '💰 Payment Updated',
          'Payment status updated to ${newStatus.displayText}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error updating payment status: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Add notes to an order
  Future<bool> addNotes(OnlineOrderModel order, String notes) async {
    try {
      final success = await _ordersService.addOrderNotes(
        _businessId!,
        order.id,
        notes,
      );

      if (success) {
        Get.snackbar(
          '📝 Notes Added',
          'Notes added to order',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error adding notes: $e');
      return false;
    }
  }

  /// Select an order for viewing details
  void selectOrder(OnlineOrderModel order) {
    selectedOrder.value = order;
  }

  /// Clear selected order
  void clearSelectedOrder() {
    selectedOrder.value = null;
  }

  /// Clear new orders badge
  void clearNewOrdersBadge() {
    newOrdersCount.value = 0;
  }

  /// Get orders by status
  List<OnlineOrderModel> getOrdersByStatus(OrderStatus status) {
    return allOrders.where((order) => order.status == status).toList();
  }

  /// Search orders
  List<OnlineOrderModel> searchOrders(String query) {
    final lowerQuery = query.toLowerCase();
    return allOrders.where((order) {
      return order.id.toLowerCase().contains(lowerQuery) ||
          order.customerName.toLowerCase().contains(lowerQuery) ||
          order.customerPhone.contains(query);
    }).toList();
  }

  /// Reinitialize with new business ID (called after login)
  Future<void> reinitialize(String businessId) async {
    _businessId = businessId;
    await _initializeController();
  }

  @override
  void onClose() {
    _allOrdersSubscription?.cancel();
    _pendingOrdersSubscription?.cancel();
    _activeOrdersSubscription?.cancel();
    super.onClose();
  }
}
