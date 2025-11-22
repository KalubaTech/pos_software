import 'dart:async';
import 'package:firedart/firedart.dart';
import 'package:pos_software/models/online_order_model.dart';

class OnlineOrdersService {
  Firestore? get _firestore {
    try {
      return Firestore.instance;
    } catch (e) {
      print('⚠️ Firestore not initialized yet: $e');
      return null;
    }
  }

  /// Get stream of all orders for a business
  Stream<List<OnlineOrderModel>> getBusinessOrdersStream(String businessId) {
    final firestore = _firestore;
    if (firestore == null) {
      // Return empty stream if Firestore isn't initialized
      return Stream.value([]);
    }

    // Firedart stream returns all documents in the collection
    // Orders are stored in top-level 'orders' collection with businessId field
    return firestore.collection('orders').stream.map((documents) {
      // Filter by businessId and sort
      final businessOrders = documents
          .where((doc) => doc.map['businessId'] == businessId)
          .toList();

      final sortedDocs = List<Document>.from(businessOrders);

      // Sort by createdAt descending (newest first)
      sortedDocs.sort((a, b) {
        final aTime = a.map['createdAt'] ?? '';
        final bTime = b.map['createdAt'] ?? '';
        return bTime.compareTo(aTime); // Descending
      });

      return sortedDocs
          .map((doc) {
            try {
              return OnlineOrderModel.fromJson({'id': doc.id, ...doc.map});
            } catch (e) {
              print('Error parsing order ${doc.id}: $e');
              return null;
            }
          })
          .whereType<OnlineOrderModel>()
          .toList();
    });
  }

  /// Get stream of pending orders
  Stream<List<OnlineOrderModel>> getPendingOrdersStream(String businessId) {
    return getBusinessOrdersStream(businessId).map((orders) {
      return orders
          .where((order) => order.status == OrderStatus.pending)
          .toList();
    });
  }

  /// Get stream of active orders (confirmed, preparing, out for delivery)
  Stream<List<OnlineOrderModel>> getActiveOrdersStream(String businessId) {
    return getBusinessOrdersStream(businessId).map((orders) {
      return orders
          .where(
            (order) =>
                order.status == OrderStatus.confirmed ||
                order.status == OrderStatus.preparing ||
                order.status == OrderStatus.outForDelivery,
          )
          .toList();
    });
  }

  /// Get a single order by ID
  Future<OnlineOrderModel?> getOrderById(
    String businessId,
    String orderId,
  ) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return null;

      final doc = await firestore.collection('orders').document(orderId).get();

      // Verify it belongs to the business
      if (doc.map['businessId'] != businessId) {
        print('⚠️ Order $orderId does not belong to business $businessId');
        return null;
      }

      return OnlineOrderModel.fromJson({'id': doc.id, ...doc.map});
    } catch (e) {
      print('Error fetching order $orderId: $e');
      return null;
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(
    String businessId,
    String orderId,
    OrderStatus newStatus, {
    String? reason,
  }) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return false;

      final updates = <String, dynamic>{
        'status': newStatus.name,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Add specific timestamps based on status
      final now = DateTime.now().toIso8601String();
      switch (newStatus) {
        case OrderStatus.confirmed:
          updates['confirmedAt'] = now;
          break;
        case OrderStatus.preparing:
          updates['preparingAt'] = now;
          break;
        case OrderStatus.outForDelivery:
          updates['outForDeliveryAt'] = now;
          break;
        case OrderStatus.delivered:
          updates['deliveredAt'] = now;
          break;
        case OrderStatus.cancelled:
          updates['cancelledAt'] = now;
          if (reason != null) {
            updates['cancellationReason'] = reason;
          }
          break;
        default:
          break;
      }

      await firestore.collection('orders').document(orderId).update(updates);

      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  /// Confirm an order
  Future<bool> confirmOrder(String businessId, String orderId) async {
    return updateOrderStatus(businessId, orderId, OrderStatus.confirmed);
  }

  /// Mark order as preparing
  Future<bool> markAsPreparing(String businessId, String orderId) async {
    return updateOrderStatus(businessId, orderId, OrderStatus.preparing);
  }

  /// Mark order as out for delivery
  Future<bool> markAsOutForDelivery(
    String businessId,
    String orderId, {
    String? trackingNumber,
  }) async {
    // Note: trackingNumber logic would go here if we had a field for it
    return updateOrderStatus(businessId, orderId, OrderStatus.outForDelivery);
  }

  /// Mark order as delivered
  Future<bool> markAsDelivered(String businessId, String orderId) async {
    return updateOrderStatus(businessId, orderId, OrderStatus.delivered);
  }

  /// Cancel an order
  Future<bool> cancelOrder(
    String businessId,
    String orderId,
    String reason,
  ) async {
    return updateOrderStatus(
      businessId,
      orderId,
      OrderStatus.cancelled,
      reason: reason,
    );
  }

  /// Get order statistics
  Future<Map<String, int>> getOrderStatistics(String businessId) async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        return {
          'total': 0,
          'pending': 0,
          'active': 0,
          'delivered': 0,
          'cancelled': 0,
        };
      }

      // In Firedart, we have to fetch all and count
      final docs = await firestore.collection('orders').get();

      // Filter by businessId
      final businessDocs = docs
          .where((doc) => doc.map['businessId'] == businessId)
          .toList();

      int pending = 0;
      int active = 0;
      int delivered = 0;
      int cancelled = 0;

      for (var doc in businessDocs) {
        final statusStr = doc.map['status'] as String?;
        if (statusStr == null) continue;

        if (statusStr == OrderStatus.pending.name)
          pending++;
        else if (statusStr == OrderStatus.confirmed.name ||
            statusStr == OrderStatus.preparing.name ||
            statusStr == OrderStatus.outForDelivery.name)
          active++;
        else if (statusStr == OrderStatus.delivered.name)
          delivered++;
        else if (statusStr == OrderStatus.cancelled.name)
          cancelled++;
      }

      return {
        'total': businessDocs.length,
        'pending': pending,
        'active': active,
        'delivered': delivered,
        'cancelled': cancelled,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {
        'total': 0,
        'pending': 0,
        'active': 0,
        'delivered': 0,
        'cancelled': 0,
      };
    }
  }

  /// Get total revenue from delivered orders
  Future<double> getTotalRevenue(String businessId) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return 0.0;

      final docs = await firestore.collection('orders').get();

      // Filter by businessId
      final businessDocs = docs.where(
        (doc) => doc.map['businessId'] == businessId,
      );

      double total = 0.0;
      for (var doc in businessDocs) {
        final statusStr = doc.map['status'] as String?;
        if (statusStr == OrderStatus.delivered.name) {
          total += (doc.map['total'] as num?)?.toDouble() ?? 0.0;
        }
      }
      return total;
    } catch (e) {
      print('Error calculating revenue: $e');
      return 0.0;
    }
  }

  /// Update payment status
  Future<bool> updatePaymentStatus({
    required String businessId,
    required String orderId,
    required PaymentStatus newStatus,
  }) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return false;

      await firestore.collection('orders').document(orderId).update({
        'paymentStatus': newStatus.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating payment status: $e');
      return false;
    }
  }

  /// Add notes to an order
  Future<bool> addOrderNotes(
    String businessId,
    String orderId,
    String notes,
  ) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return false;

      await firestore.collection('orders').document(orderId).update({
        'notes': notes,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error adding notes: $e');
      return false;
    }
  }
}
