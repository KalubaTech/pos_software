/// Sync metadata for tracking sync status and conflict resolution
class SyncMetadata {
  final String id;
  final DateTime lastModified;
  final String? modifiedBy;
  final String? deviceId;
  final SyncStatus status;
  final int version;
  final DateTime? lastSyncedAt;

  SyncMetadata({
    required this.id,
    required this.lastModified,
    this.modifiedBy,
    this.deviceId,
    this.status = SyncStatus.pending,
    this.version = 1,
    this.lastSyncedAt,
  });

  SyncMetadata copyWith({
    String? id,
    DateTime? lastModified,
    String? modifiedBy,
    String? deviceId,
    SyncStatus? status,
    int? version,
    DateTime? lastSyncedAt,
  }) {
    return SyncMetadata(
      id: id ?? this.id,
      lastModified: lastModified ?? this.lastModified,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      deviceId: deviceId ?? this.deviceId,
      status: status ?? this.status,
      version: version ?? this.version,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lastModified': lastModified.toIso8601String(),
      'modifiedBy': modifiedBy,
      'deviceId': deviceId,
      'status': status.name,
      'version': version,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  factory SyncMetadata.fromMap(Map<String, dynamic> map) {
    return SyncMetadata(
      id: map['id'],
      lastModified: DateTime.parse(map['lastModified']),
      modifiedBy: map['modifiedBy'],
      deviceId: map['deviceId'],
      status: SyncStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SyncStatus.pending,
      ),
      version: map['version'] ?? 1,
      lastSyncedAt: map['lastSyncedAt'] != null
          ? DateTime.parse(map['lastSyncedAt'])
          : null,
    );
  }
}

/// Sync status enumeration
enum SyncStatus {
  pending, // Waiting to sync
  syncing, // Currently syncing
  synced, // Successfully synced
  conflict, // Conflict detected
  error, // Sync failed
}

extension SyncStatusExtension on SyncStatus {
  String get displayName {
    switch (this) {
      case SyncStatus.pending:
        return 'Pending';
      case SyncStatus.syncing:
        return 'Syncing';
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.conflict:
        return 'Conflict';
      case SyncStatus.error:
        return 'Error';
    }
  }

  bool get isSuccessful => this == SyncStatus.synced;
  bool get needsSync => this == SyncStatus.pending || this == SyncStatus.error;
  bool get hasIssue => this == SyncStatus.conflict || this == SyncStatus.error;
}
