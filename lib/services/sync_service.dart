import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/sync/sync_queue_item.dart';
import './subscription_service.dart';

/// Main synchronization service
/// Handles bidirectional sync between local SQLite and Firestore
class SyncService extends GetxController {
  static SyncService get instance => Get.find();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable state
  final isOnline = false.obs;
  final isSyncing = false.obs;
  final lastSyncTime = Rx<DateTime?>(null);
  final syncProgress = 0.0.obs;
  final syncErrors = <String>[].obs;

  // Business and device info
  String? businessId;
  String? deviceId;
  String? userId;

  // Connectivity
  StreamSubscription? _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();

  // Sync listeners
  final Map<String, StreamSubscription> _syncSubscriptions = {};

  // Sync queue for offline operations
  final List<SyncQueueItem> _syncQueue = [];

  @override
  void onInit() {
    super.onInit();
    _setupConnectivityListener();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _cancelAllSubscriptions();
    super.onClose();
  }

  /// Initialize sync service
  Future<void> initialize(String businessId) async {
    try {
      this.businessId = businessId;
      this.deviceId = await _getDeviceId();
      this.userId = _auth.currentUser?.uid;

      print('🔄 Initializing SyncService...');
      print('   Business ID: $businessId');
      print('   Device ID: $deviceId');
      print('   User ID: $userId');

      // Enable offline persistence
      await _enableOfflinePersistence();

      // Check initial connectivity
      await _checkConnectivity();

      print('✅ SyncService initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize SyncService: $e');
      syncErrors.add('Initialization failed: $e');
    }
  }

  /// Setup connectivity listener
  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      ConnectivityResult result,
    ) {
      final wasOnline = isOnline.value;
      isOnline.value = result != ConnectivityResult.none;

      print(
        '📡 Connectivity changed: ${isOnline.value ? "ONLINE" : "OFFLINE"}',
      );

      // If just came online, process sync queue
      if (!wasOnline && isOnline.value) {
        print('🔄 Device came online, processing sync queue...');
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

  /// Enable Firestore offline persistence
  Future<void> _enableOfflinePersistence() async {
    try {
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      print('💾 Firestore offline persistence enabled');
    } catch (e) {
      print('⚠️ Failed to enable offline persistence: $e');
    }
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
        return 'windows_${windowsInfo.deviceId}';
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        final macInfo = await deviceInfo.macOsInfo;
        return 'macos_${macInfo.systemGUID}';
      } else if (defaultTargetPlatform == TargetPlatform.linux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return 'linux_${linuxInfo.machineId}';
      }

      return 'unknown_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      print('⚠️ Failed to get device ID: $e');
      return 'unknown_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Start listening to a Firestore collection
  StreamSubscription startCollectionListener(
    String collection,
    Function(QuerySnapshot) onData,
  ) {
    if (businessId == null) {
      throw Exception('Business ID not set. Call initialize() first.');
    }

    final collectionRef = _firestore
        .collection('businesses')
        .doc(businessId)
        .collection(collection);

    final subscription = collectionRef.snapshots().listen(
      (snapshot) {
        print(
          '📥 Received ${snapshot.docChanges.length} changes from $collection',
        );
        onData(snapshot);
      },
      onError: (error) {
        print('❌ Error listening to $collection: $error');
        syncErrors.add('Listener error ($collection): $error');
      },
    );

    _syncSubscriptions[collection] = subscription;
    return subscription;
  }

  /// Stop listening to a collection
  void stopCollectionListener(String collection) {
    _syncSubscriptions[collection]?.cancel();
    _syncSubscriptions.remove(collection);
    print('🛑 Stopped listening to $collection');
  }

  /// Cancel all subscriptions
  void _cancelAllSubscriptions() {
    for (var subscription in _syncSubscriptions.values) {
      subscription.cancel();
    }
    _syncSubscriptions.clear();
    print('🛑 Cancelled all sync subscriptions');
  }

  /// Push data to Firestore
  Future<bool> pushToCloud({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    if (businessId == null) {
      throw Exception('Business ID not set. Call initialize() first.');
    }

    try {
      // Add sync metadata
      final enrichedData = {
        ...data,
        'lastModified': FieldValue.serverTimestamp(),
        'modifiedBy': userId,
        'deviceId': deviceId,
      };

      final docRef = _firestore
          .collection('businesses')
          .doc(businessId)
          .collection(collection)
          .doc(documentId);

      if (isOnline.value) {
        // Online: Push immediately
        await docRef.set(enrichedData, SetOptions(merge: merge));
        print('✅ Pushed $collection/$documentId to cloud');
        return true;
      } else {
        // Offline: Add to queue
        _addToSyncQueue(
          SyncQueueItem(
            id: '${collection}_${documentId}_${DateTime.now().millisecondsSinceEpoch}',
            operation: merge ? SyncOperation.update : SyncOperation.create,
            collection: collection,
            documentId: documentId,
            data: enrichedData,
            queuedAt: DateTime.now(),
          ),
        );
        print('📦 Queued $collection/$documentId for sync (offline)');
        return false;
      }
    } catch (e) {
      print('❌ Failed to push $collection/$documentId: $e');
      syncErrors.add('Push failed ($collection/$documentId): $e');

      // Add to queue for retry
      _addToSyncQueue(
        SyncQueueItem(
          id: '${collection}_${documentId}_${DateTime.now().millisecondsSinceEpoch}',
          operation: merge ? SyncOperation.update : SyncOperation.create,
          collection: collection,
          documentId: documentId,
          data: data,
          queuedAt: DateTime.now(),
          error: e.toString(),
        ),
      );

      return false;
    }
  }

  /// Delete document from Firestore
  Future<bool> deleteFromCloud({
    required String collection,
    required String documentId,
  }) async {
    if (businessId == null) {
      throw Exception('Business ID not set. Call initialize() first.');
    }

    try {
      final docRef = _firestore
          .collection('businesses')
          .doc(businessId)
          .collection(collection)
          .doc(documentId);

      if (isOnline.value) {
        await docRef.delete();
        print('🗑️ Deleted $collection/$documentId from cloud');
        return true;
      } else {
        // Offline: Add to queue
        _addToSyncQueue(
          SyncQueueItem(
            id: '${collection}_${documentId}_delete_${DateTime.now().millisecondsSinceEpoch}',
            operation: SyncOperation.delete,
            collection: collection,
            documentId: documentId,
            data: {},
            queuedAt: DateTime.now(),
          ),
        );
        print('📦 Queued delete $collection/$documentId (offline)');
        return false;
      }
    } catch (e) {
      print('❌ Failed to delete $collection/$documentId: $e');
      syncErrors.add('Delete failed ($collection/$documentId): $e');
      return false;
    }
  }

  /// Add item to sync queue
  void _addToSyncQueue(SyncQueueItem item) {
    _syncQueue.add(item);
    print(
      '📦 Added to sync queue: ${item.collection}/${item.documentId} (${item.operation.name})',
    );
  }

  /// Process sync queue
  Future<void> _processSyncQueue() async {
    if (_syncQueue.isEmpty) {
      print('📭 Sync queue is empty');
      return;
    }

    if (!isOnline.value) {
      print('📡 Cannot process sync queue: offline');
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

    isSyncing.value = true;
    print('🔄 Processing ${_syncQueue.length} items in sync queue...');

    final itemsToProcess = List<SyncQueueItem>.from(_syncQueue);
    _syncQueue.clear();

    for (var item in itemsToProcess) {
      try {
        final docRef = _firestore
            .collection('businesses')
            .doc(businessId)
            .collection(item.collection)
            .doc(item.documentId);

        switch (item.operation) {
          case SyncOperation.create:
          case SyncOperation.update:
            await docRef.set(item.data, SetOptions(merge: true));
            print('✅ Synced ${item.collection}/${item.documentId}');
            break;
          case SyncOperation.delete:
            await docRef.delete();
            print('🗑️ Deleted ${item.collection}/${item.documentId}');
            break;
        }
      } catch (e) {
        print('❌ Failed to sync ${item.collection}/${item.documentId}: $e');

        // Retry with limit
        if (item.retryCount < 3) {
          _syncQueue.add(
            item.copyWith(retryCount: item.retryCount + 1, error: e.toString()),
          );
        } else {
          syncErrors.add(
            'Max retries exceeded for ${item.collection}/${item.documentId}',
          );
        }
      }
    }

    lastSyncTime.value = DateTime.now();
    isSyncing.value = false;
    print('✅ Sync queue processing complete');
  }

  /// Manual sync trigger
  Future<void> syncNow() async {
    print('🔄 Manual sync triggered');

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

  /// Clear sync errors
  void clearErrors() {
    syncErrors.clear();
  }

  /// Get sync statistics
  Map<String, dynamic> getSyncStats() {
    return {
      'isOnline': isOnline.value,
      'isSyncing': isSyncing.value,
      'lastSyncTime': lastSyncTime.value,
      'queuedItems': _syncQueue.length,
      'errors': syncErrors.length,
      'activeListeners': _syncSubscriptions.length,
    };
  }
}
