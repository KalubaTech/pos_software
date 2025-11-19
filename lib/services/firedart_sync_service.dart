import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firedart/firedart.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/sync/sync_queue_item.dart';
import './subscription_service.dart';

/// Firedart-based sync service for Windows desktop
/// Uses pure Dart implementation - no C++ dependencies!
class FiredartSyncService extends GetxController {
  static FiredartSyncService get instance => Get.find();

  // Firedart instance
  late Firestore _firestore;

  // Observable state
  final isOnline = false.obs;
  final isSyncing = false.obs;
  final lastSyncTime = Rx<DateTime?>(null);
  final syncErrors = <String>[].obs;
  final syncQueue = <SyncQueueItem>[].obs;

  // Connectivity
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Current business ID
  String? _businessId;
  String? _deviceId;

  // Collection listeners
  final Map<String, StreamSubscription> _listeners = {};

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _listeners.forEach((key, subscription) {
      subscription.cancel();
    });
    super.onClose();
  }

  /// Initialize Firedart
  Future<void> _initialize() async {
    try {
      // Initialize Firedart with your Firebase project
      Firestore.initialize('dynamos-pos'); // Your project ID
      _firestore = Firestore.instance;

      // Get device ID
      _deviceId = await _getDeviceId();

      // Setup connectivity monitoring
      _setupConnectivityListener();
      await _checkConnectivity();

      print('✅ Firedart sync service initialized');
      print('📱 Device ID: $_deviceId');
    } catch (e) {
      print('❌ Failed to initialize Firedart: $e');
      syncErrors.add('Initialization failed: $e');
    }
  }

  /// Initialize with business ID to start syncing
  Future<void> initialize(String businessId) async {
    _businessId = businessId;
    print('🔄 Sync initialized for business: $businessId');

    // Start processing offline queue if online
    if (isOnline.value) {
      await _processSyncQueue();
    }
  }

  /// Setup connectivity listener
  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      ConnectivityResult result,
    ) {
      final wasOnline = isOnline.value;
      isOnline.value = result != ConnectivityResult.none;

      print('📡 Connectivity: ${isOnline.value ? "ONLINE" : "OFFLINE"}');

      if (!wasOnline && isOnline.value) {
        print('🔄 Device online, processing queue...');
        _processSyncQueue();
      }
    });
  }

  /// Check current connectivity
  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    isOnline.value = result != ConnectivityResult.none;
    print('📡 Initial connectivity: ${isOnline.value ? "ONLINE" : "OFFLINE"}');
  }

  /// Get unique device ID
  Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        return 'android_${androidInfo.id}';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return 'ios_${iosInfo.identifierForVendor}';
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return 'windows_${windowsInfo.computerName}_${windowsInfo.deviceId}';
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        final macInfo = await deviceInfo.macOsInfo;
        return 'mac_${macInfo.computerName}_${macInfo.systemGUID}';
      } else if (defaultTargetPlatform == TargetPlatform.linux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return 'linux_${linuxInfo.machineId}';
      }

      return 'unknown_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      print('⚠️ Failed to get device ID: $e');
      return 'fallback_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Push document to cloud
  Future<void> pushToCloud(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    if (_businessId == null) {
      print('⚠️ Business ID not set, cannot sync');
      return;
    }

    // Add sync metadata
    final syncData = {
      ...data,
      'syncMetadata': {
        'lastModified': DateTime.now().toIso8601String(),
        'modifiedBy': _deviceId,
        'deviceId': _deviceId,
        'version': 1,
      },
    };

    if (!isOnline.value) {
      _addToQueue(SyncOperation.create, collection, documentId, syncData);
      return;
    }

    try {
      isSyncing.value = true;

      final path = 'businesses/$_businessId/$collection';
      await _firestore.collection(path).document(documentId).set(syncData);

      lastSyncTime.value = DateTime.now();
      print('✅ Pushed $collection/$documentId to cloud');
    } catch (e) {
      print('❌ Failed to push to cloud: $e');
      syncErrors.add('Push failed: $e');
      _addToQueue(SyncOperation.create, collection, documentId, syncData);
    } finally {
      isSyncing.value = false;
    }
  }

  /// Delete document from cloud
  Future<void> deleteFromCloud(String collection, String documentId) async {
    if (_businessId == null) {
      print('⚠️ Business ID not set, cannot sync');
      return;
    }

    if (!isOnline.value) {
      _addToQueue(SyncOperation.delete, collection, documentId, {});
      return;
    }

    try {
      isSyncing.value = true;

      final path = 'businesses/$_businessId/$collection';
      await _firestore.collection(path).document(documentId).delete();

      lastSyncTime.value = DateTime.now();
      print('✅ Deleted $collection/$documentId from cloud');
    } catch (e) {
      print('❌ Failed to delete from cloud: $e');
      syncErrors.add('Delete failed: $e');
      _addToQueue(SyncOperation.delete, collection, documentId, {});
    } finally {
      isSyncing.value = false;
    }
  }

  /// Listen to collection changes
  Stream<List<Map<String, dynamic>>> listenToCollection(String collection) {
    if (_businessId == null) {
      throw Exception('Business ID not set');
    }

    final path = 'businesses/$_businessId/$collection';

    return _firestore.collection(path).stream.map((documents) {
      return documents.map((doc) {
        return {'id': doc.id, ...doc.map};
      }).toList();
    });
  }

  /// Add operation to offline queue
  void _addToQueue(
    SyncOperation operation,
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) {
    final queueItem = SyncQueueItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      operation: operation,
      collection: collection,
      documentId: documentId,
      data: data,
      queuedAt: DateTime.now(),
      retryCount: 0,
    );

    syncQueue.add(queueItem);
    print(
      '📝 Added to offline queue: ${operation.name} $collection/$documentId',
    );
  }

  /// Process offline queue
  Future<void> _processSyncQueue() async {
    if (syncQueue.isEmpty || !isOnline.value) {
      return;
    }

    // Check subscription access
    try {
      final subscriptionService = Get.find<SubscriptionService>();
      if (!subscriptionService.hasAccessToSync) {
        print('🔒 Sync blocked: Subscription required');
        return;
      }
    } catch (e) {
      print('⚠️ Subscription service not available: $e');
      return;
    }

    print('🔄 Processing ${syncQueue.length} queued operations...');
    final itemsToProcess = List<SyncQueueItem>.from(syncQueue);

    for (final item in itemsToProcess) {
      try {
        if (item.operation == SyncOperation.delete) {
          await deleteFromCloud(item.collection, item.documentId);
        } else {
          await pushToCloud(item.collection, item.documentId, item.data);
        }

        syncQueue.remove(item);
      } catch (e) {
        print('❌ Failed to process queue item: $e');

        // Increment retry count
        final updatedItem = SyncQueueItem(
          id: item.id,
          operation: item.operation,
          collection: item.collection,
          documentId: item.documentId,
          data: item.data,
          queuedAt: item.queuedAt,
          retryCount: item.retryCount + 1,
          error: e.toString(),
        );

        // Remove if max retries exceeded
        if (updatedItem.retryCount >= 3) {
          syncQueue.remove(item);
          syncErrors.add(
            'Max retries for ${item.collection}/${item.documentId}',
          );
        } else {
          final index = syncQueue.indexOf(item);
          if (index != -1) {
            syncQueue[index] = updatedItem;
          }
        }
      }
    }

    print('✅ Queue processing complete');
  }

  /// Manual sync trigger
  Future<void> syncNow() async {
    if (!isOnline.value) {
      print('⚠️ Cannot sync: Device offline');
      return;
    }

    // Check subscription access
    try {
      final subscriptionService = Get.find<SubscriptionService>();
      if (!subscriptionService.hasAccessToSync) {
        Get.snackbar(
          'Subscription Required',
          'Please upgrade your subscription to use cloud sync features.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
        return;
      }
    } catch (e) {
      print('⚠️ Subscription service not available: $e');
    }

    await _processSyncQueue();
  }

  /// Get sync statistics
  Map<String, dynamic> getSyncStats() {
    return {
      'isOnline': isOnline.value,
      'isSyncing': isSyncing.value,
      'lastSyncTime': lastSyncTime.value,
      'queueLength': syncQueue.length,
      'errorCount': syncErrors.length,
      'businessId': _businessId,
      'deviceId': _deviceId,
    };
  }

  /// Clear sync errors
  void clearErrors() {
    syncErrors.clear();
  }
}
