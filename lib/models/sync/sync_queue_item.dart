/// Represents a queued sync operation
class SyncQueueItem {
  final String id;
  final SyncOperation operation;
  final String collection;
  final String documentId;
  final Map<String, dynamic> data;
  final DateTime queuedAt;
  final int retryCount;
  final String? error;

  SyncQueueItem({
    required this.id,
    required this.operation,
    required this.collection,
    required this.documentId,
    required this.data,
    required this.queuedAt,
    this.retryCount = 0,
    this.error,
  });

  SyncQueueItem copyWith({
    String? id,
    SyncOperation? operation,
    String? collection,
    String? documentId,
    Map<String, dynamic>? data,
    DateTime? queuedAt,
    int? retryCount,
    String? error,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      collection: collection ?? this.collection,
      documentId: documentId ?? this.documentId,
      data: data ?? this.data,
      queuedAt: queuedAt ?? this.queuedAt,
      retryCount: retryCount ?? this.retryCount,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operation': operation.name,
      'collection': collection,
      'documentId': documentId,
      'data': data,
      'queuedAt': queuedAt.toIso8601String(),
      'retryCount': retryCount,
      'error': error,
    };
  }

  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      id: map['id'],
      operation: SyncOperation.values.firstWhere(
        (e) => e.name == map['operation'],
      ),
      collection: map['collection'],
      documentId: map['documentId'],
      data: Map<String, dynamic>.from(map['data']),
      queuedAt: DateTime.parse(map['queuedAt']),
      retryCount: map['retryCount'] ?? 0,
      error: map['error'],
    );
  }
}

/// Type of sync operation
enum SyncOperation { create, update, delete }

extension SyncOperationExtension on SyncOperation {
  String get displayName {
    switch (this) {
      case SyncOperation.create:
        return 'Create';
      case SyncOperation.update:
        return 'Update';
      case SyncOperation.delete:
        return 'Delete';
    }
  }
}
