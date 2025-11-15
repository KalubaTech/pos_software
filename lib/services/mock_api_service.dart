import 'dart:async';
import 'dart:math';
import '../models/sync_models.dart';

/// Mock API Service for simulating external database API calls
/// Replace this with real HTTP client implementation for production
class MockApiService {
  final String baseUrl;
  final String apiKey;
  final Random _random = Random();

  MockApiService({required this.baseUrl, required this.apiKey});

  /// Simulates network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
  }

  /// Simulates random failures (10% failure rate)
  bool _shouldFail() {
    return _random.nextInt(10) == 0;
  }

  /// Mock: Sync product to external database
  Future<ApiResponse<Map<String, dynamic>>> syncProduct({
    required String businessId,
    required Map<String, dynamic> productData,
  }) async {
    await _simulateDelay();

    if (_shouldFail()) {
      return ApiResponse(
        success: false,
        message: 'Network error: Failed to sync product',
        statusCode: 500,
        errors: {'error': 'Connection timeout'},
      );
    }

    // Add business ID to product data
    final enrichedData = {
      ...productData,
      'businessId': businessId,
      'syncedAt': DateTime.now().toIso8601String(),
      'externalId': 'ext_prod_${_random.nextInt(100000)}',
    };

    return ApiResponse(
      success: true,
      message: 'Product synced successfully',
      data: enrichedData,
      statusCode: 200,
    );
  }

  /// Mock: Sync transaction to external database
  Future<ApiResponse<Map<String, dynamic>>> syncTransaction({
    required String businessId,
    required Map<String, dynamic> transactionData,
  }) async {
    await _simulateDelay();

    if (_shouldFail()) {
      return ApiResponse(
        success: false,
        message: 'Network error: Failed to sync transaction',
        statusCode: 500,
        errors: {'error': 'Server unavailable'},
      );
    }

    final enrichedData = {
      ...transactionData,
      'businessId': businessId,
      'syncedAt': DateTime.now().toIso8601String(),
      'externalId': 'ext_txn_${_random.nextInt(100000)}',
      'serverTimestamp': DateTime.now().toIso8601String(),
    };

    return ApiResponse(
      success: true,
      message: 'Transaction synced successfully',
      data: enrichedData,
      statusCode: 200,
    );
  }

  /// Mock: Sync stock update to external database
  Future<ApiResponse<Map<String, dynamic>>> syncStock({
    required String businessId,
    required Map<String, dynamic> stockData,
  }) async {
    await _simulateDelay();

    if (_shouldFail()) {
      return ApiResponse(
        success: false,
        message: 'Failed to sync stock update',
        statusCode: 500,
      );
    }

    final enrichedData = {
      ...stockData,
      'businessId': businessId,
      'syncedAt': DateTime.now().toIso8601String(),
      'inventoryId': 'ext_inv_${_random.nextInt(100000)}',
    };

    return ApiResponse(
      success: true,
      message: 'Stock synced successfully',
      data: enrichedData,
      statusCode: 200,
    );
  }

  /// Mock: Sync customer data
  Future<ApiResponse<Map<String, dynamic>>> syncCustomer({
    required String businessId,
    required Map<String, dynamic> customerData,
  }) async {
    await _simulateDelay();

    if (_shouldFail()) {
      return ApiResponse(
        success: false,
        message: 'Failed to sync customer',
        statusCode: 500,
      );
    }

    final enrichedData = {
      ...customerData,
      'businessId': businessId,
      'syncedAt': DateTime.now().toIso8601String(),
      'externalCustomerId': 'ext_cust_${_random.nextInt(100000)}',
    };

    return ApiResponse(
      success: true,
      message: 'Customer synced successfully',
      data: enrichedData,
      statusCode: 200,
    );
  }

  /// Mock: Sync cashier/employee data
  Future<ApiResponse<Map<String, dynamic>>> syncCashier({
    required String businessId,
    required Map<String, dynamic> cashierData,
  }) async {
    await _simulateDelay();

    if (_shouldFail()) {
      return ApiResponse(
        success: false,
        message: 'Failed to sync cashier',
        statusCode: 500,
      );
    }

    final enrichedData = {
      ...cashierData,
      'businessId': businessId,
      'syncedAt': DateTime.now().toIso8601String(),
      'externalEmployeeId': 'ext_emp_${_random.nextInt(100000)}',
    };

    return ApiResponse(
      success: true,
      message: 'Cashier synced successfully',
      data: enrichedData,
      statusCode: 200,
    );
  }

  /// Mock: Sync business settings
  Future<ApiResponse<Map<String, dynamic>>> syncBusinessSettings({
    required String businessId,
    required Map<String, dynamic> settingsData,
  }) async {
    await _simulateDelay();

    if (_shouldFail()) {
      return ApiResponse(
        success: false,
        message: 'Failed to sync business settings',
        statusCode: 500,
      );
    }

    final enrichedData = {
      ...settingsData,
      'businessId': businessId,
      'syncedAt': DateTime.now().toIso8601String(),
    };

    return ApiResponse(
      success: true,
      message: 'Business settings synced successfully',
      data: enrichedData,
      statusCode: 200,
    );
  }

  /// Mock: Batch sync multiple records
  Future<ApiResponse<Map<String, dynamic>>> batchSync({
    required String businessId,
    required List<Map<String, dynamic>> records,
  }) async {
    await _simulateDelay();

    if (_shouldFail()) {
      return ApiResponse(
        success: false,
        message: 'Batch sync failed',
        statusCode: 500,
        errors: {'error': 'Partial failure in batch'},
      );
    }

    final results = {
      'totalRecords': records.length,
      'successCount': records.length,
      'failureCount': 0,
      'syncedAt': DateTime.now().toIso8601String(),
      'businessId': businessId,
    };

    return ApiResponse(
      success: true,
      message: 'Batch synced successfully',
      data: results,
      statusCode: 200,
    );
  }

  /// Mock: Fetch data from external database
  Future<ApiResponse<List<Map<String, dynamic>>>> fetchData({
    required String businessId,
    required String entityType,
    DateTime? since,
  }) async {
    await _simulateDelay();

    if (_shouldFail()) {
      return ApiResponse(
        success: false,
        message: 'Failed to fetch data',
        statusCode: 500,
      );
    }

    // Mock empty data
    return ApiResponse(
      success: true,
      message: 'Data fetched successfully',
      data: [],
      statusCode: 200,
    );
  }

  /// Mock: Health check
  Future<ApiResponse<Map<String, dynamic>>> healthCheck() async {
    await Future.delayed(Duration(milliseconds: 200));

    return ApiResponse(
      success: true,
      message: 'API is healthy',
      data: {
        'status': 'online',
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      },
      statusCode: 200,
    );
  }

  /// Mock: Authenticate/validate API key
  Future<ApiResponse<Map<String, dynamic>>> validateAuth({
    required String businessId,
  }) async {
    await Future.delayed(Duration(milliseconds: 300));

    return ApiResponse(
      success: true,
      message: 'Authentication valid',
      data: {
        'businessId': businessId,
        'authenticated': true,
        'expiresAt': DateTime.now().add(Duration(days: 30)).toIso8601String(),
      },
      statusCode: 200,
    );
  }
}
