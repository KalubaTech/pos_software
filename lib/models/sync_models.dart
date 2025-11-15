/// Sync-related models for data synchronization with external database

enum SyncStatus { pending, syncing, synced, failed }

enum SyncEntityType {
  product,
  transaction,
  stock,
  customer,
  cashier,
  businessSettings,
}

/// Tracks sync status for each entity
class SyncRecord {
  final String id;
  final String entityId;
  final SyncEntityType entityType;
  final String businessId;
  final SyncStatus status;
  final DateTime lastAttempt;
  final DateTime? lastSuccess;
  final int retryCount;
  final String? errorMessage;
  final Map<String, dynamic> data;

  SyncRecord({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.businessId,
    required this.status,
    required this.lastAttempt,
    this.lastSuccess,
    this.retryCount = 0,
    this.errorMessage,
    required this.data,
  });

  factory SyncRecord.fromJson(Map<String, dynamic> json) {
    return SyncRecord(
      id: json['id'],
      entityId: json['entityId'],
      entityType: SyncEntityType.values.firstWhere(
        (e) => e.name == json['entityType'],
      ),
      businessId: json['businessId'],
      status: SyncStatus.values.firstWhere((e) => e.name == json['status']),
      lastAttempt: DateTime.parse(json['lastAttempt']),
      lastSuccess: json['lastSuccess'] != null
          ? DateTime.parse(json['lastSuccess'])
          : null,
      retryCount: json['retryCount'] ?? 0,
      errorMessage: json['errorMessage'],
      data: json['data'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityId': entityId,
      'entityType': entityType.name,
      'businessId': businessId,
      'status': status.name,
      'lastAttempt': lastAttempt.toIso8601String(),
      'lastSuccess': lastSuccess?.toIso8601String(),
      'retryCount': retryCount,
      'errorMessage': errorMessage,
      'data': data,
    };
  }

  SyncRecord copyWith({
    String? id,
    String? entityId,
    SyncEntityType? entityType,
    String? businessId,
    SyncStatus? status,
    DateTime? lastAttempt,
    DateTime? lastSuccess,
    int? retryCount,
    String? errorMessage,
    Map<String, dynamic>? data,
  }) {
    return SyncRecord(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      businessId: businessId ?? this.businessId,
      status: status ?? this.status,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      lastSuccess: lastSuccess ?? this.lastSuccess,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
    );
  }
}

/// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : json['data'],
      errors: json['errors'],
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
      'statusCode': statusCode,
    };
  }
}

/// Sync configuration
class SyncConfig {
  final String businessId;
  final String apiBaseUrl;
  final String apiKey;
  final bool autoSync;
  final int syncIntervalMinutes;
  final int maxRetries;
  final bool syncOnlyOnWifi;

  SyncConfig({
    required this.businessId,
    required this.apiBaseUrl,
    required this.apiKey,
    this.autoSync = true,
    this.syncIntervalMinutes = 15,
    this.maxRetries = 3,
    this.syncOnlyOnWifi = false,
  });

  factory SyncConfig.fromJson(Map<String, dynamic> json) {
    return SyncConfig(
      businessId: json['businessId'],
      apiBaseUrl: json['apiBaseUrl'],
      apiKey: json['apiKey'],
      autoSync: json['autoSync'] ?? true,
      syncIntervalMinutes: json['syncIntervalMinutes'] ?? 15,
      maxRetries: json['maxRetries'] ?? 3,
      syncOnlyOnWifi: json['syncOnlyOnWifi'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessId': businessId,
      'apiBaseUrl': apiBaseUrl,
      'apiKey': apiKey,
      'autoSync': autoSync,
      'syncIntervalMinutes': syncIntervalMinutes,
      'maxRetries': maxRetries,
      'syncOnlyOnWifi': syncOnlyOnWifi,
    };
  }
}

/// Sync statistics
class SyncStats {
  final int totalPending;
  final int totalSynced;
  final int totalFailed;
  final DateTime? lastSyncTime;
  final Map<SyncEntityType, int> pendingByType;

  SyncStats({
    required this.totalPending,
    required this.totalSynced,
    required this.totalFailed,
    this.lastSyncTime,
    required this.pendingByType,
  });

  factory SyncStats.empty() {
    return SyncStats(
      totalPending: 0,
      totalSynced: 0,
      totalFailed: 0,
      pendingByType: {},
    );
  }
}
