import 'package:get/get.dart';
import '../models/product_model.dart';
import '../models/sync_models.dart';
import '../services/data_sync_service.dart';

/// Repository for product operations with sync support
class ProductRepository {
  final DataSyncService _syncService = Get.find<DataSyncService>();

  /// Add product with automatic sync queueing
  Future<void> addProduct({
    required ProductModel product,
    required String businessId,
  }) async {
    // Add businessId to product data
    final productData = {
      ...product.toJson(),
      'businessId': businessId,
      'action': 'create',
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Queue for sync
    await _syncService.queueForSync(
      entityId: product.id,
      entityType: SyncEntityType.product,
      data: productData,
    );

    print('✓ Product ${product.name} queued for sync');
  }

  /// Update product with automatic sync queueing
  Future<void> updateProduct({
    required ProductModel product,
    required String businessId,
  }) async {
    final productData = {
      ...product.toJson(),
      'businessId': businessId,
      'action': 'update',
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _syncService.queueForSync(
      entityId: product.id,
      entityType: SyncEntityType.product,
      data: productData,
    );

    print('✓ Product update queued for sync');
  }

  /// Delete product with automatic sync queueing
  Future<void> deleteProduct({
    required String productId,
    required String businessId,
  }) async {
    final productData = {
      'productId': productId,
      'businessId': businessId,
      'action': 'delete',
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _syncService.queueForSync(
      entityId: productId,
      entityType: SyncEntityType.product,
      data: productData,
    );

    print('✓ Product deletion queued for sync');
  }

  /// Batch update products
  Future<void> batchUpdateProducts({
    required List<ProductModel> products,
    required String businessId,
  }) async {
    for (var product in products) {
      await updateProduct(product: product, businessId: businessId);
    }

    print('✓ ${products.length} products queued for sync');
  }

  /// Update product stock
  Future<void> updateProductStock({
    required String productId,
    required int newStock,
    required String businessId,
    String? reason,
  }) async {
    final stockData = {
      'productId': productId,
      'businessId': businessId,
      'newStock': newStock,
      'reason': reason ?? 'manual_adjustment',
      'action': 'stock_update',
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _syncService.queueForSync(
      entityId: productId,
      entityType: SyncEntityType.stock,
      data: stockData,
    );

    print('✓ Stock update queued for sync');
  }

  /// Update variant stock
  Future<void> updateVariantStock({
    required String productId,
    required String variantId,
    required int newStock,
    required String businessId,
    String? reason,
  }) async {
    final stockData = {
      'productId': productId,
      'variantId': variantId,
      'businessId': businessId,
      'newStock': newStock,
      'reason': reason ?? 'manual_adjustment',
      'action': 'variant_stock_update',
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _syncService.queueForSync(
      entityId: '${productId}_${variantId}',
      entityType: SyncEntityType.stock,
      data: stockData,
    );

    print('✓ Variant stock update queued for sync');
  }

  /// Bulk stock adjustment
  Future<void> bulkStockAdjustment({
    required Map<String, int> stockChanges, // productId -> newStock
    required String businessId,
    String? reason,
  }) async {
    for (var entry in stockChanges.entries) {
      await updateProductStock(
        productId: entry.key,
        newStock: entry.value,
        businessId: businessId,
        reason: reason,
      );
    }

    print(
      '✓ Bulk stock adjustment queued for sync (${stockChanges.length} items)',
    );
  }
}
