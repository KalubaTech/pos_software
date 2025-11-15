import 'package:sqflite/sqflite.dart';
import '../models/sync_models.dart';
import '../services/database_service.dart';
import 'package:get/get.dart';

/// Repository for managing sync records in local database
class SyncRepository {
  final DatabaseService _dbService = Get.find<DatabaseService>();

  /// Initialize sync records table
  Future<void> initializeSyncTable() async {
    final db = await _dbService.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_records (
        id TEXT PRIMARY KEY,
        entityId TEXT NOT NULL,
        entityType TEXT NOT NULL,
        businessId TEXT NOT NULL,
        status TEXT NOT NULL,
        lastAttempt TEXT NOT NULL,
        lastSuccess TEXT,
        retryCount INTEGER DEFAULT 0,
        errorMessage TEXT,
        data TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create indexes for better query performance
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sync_status ON sync_records(status)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sync_business ON sync_records(businessId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sync_entity ON sync_records(entityType)',
    );
  }

  /// Add a new sync record
  Future<void> addSyncRecord(SyncRecord record) async {
    final db = await _dbService.database;
    final now = DateTime.now().toIso8601String();

    await db.insert('sync_records', {
      'id': record.id,
      'entityId': record.entityId,
      'entityType': record.entityType.name,
      'businessId': record.businessId,
      'status': record.status.name,
      'lastAttempt': record.lastAttempt.toIso8601String(),
      'lastSuccess': record.lastSuccess?.toIso8601String(),
      'retryCount': record.retryCount,
      'errorMessage': record.errorMessage,
      'data': _encodeData(record.data),
      'createdAt': now,
      'updatedAt': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Update sync record status
  Future<void> updateSyncRecord(SyncRecord record) async {
    final db = await _dbService.database;

    await db.update(
      'sync_records',
      {
        'status': record.status.name,
        'lastAttempt': record.lastAttempt.toIso8601String(),
        'lastSuccess': record.lastSuccess?.toIso8601String(),
        'retryCount': record.retryCount,
        'errorMessage': record.errorMessage,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  /// Get all pending sync records
  Future<List<SyncRecord>> getPendingRecords({
    String? businessId,
    SyncEntityType? entityType,
  }) async {
    final db = await _dbService.database;

    String where = 'status = ?';
    List<dynamic> whereArgs = [SyncStatus.pending.name];

    if (businessId != null) {
      where += ' AND businessId = ?';
      whereArgs.add(businessId);
    }

    if (entityType != null) {
      where += ' AND entityType = ?';
      whereArgs.add(entityType.name);
    }

    final results = await db.query(
      'sync_records',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'createdAt ASC',
    );

    return results.map((map) => _recordFromMap(map)).toList();
  }

  /// Get failed sync records
  Future<List<SyncRecord>> getFailedRecords({
    String? businessId,
    int? maxRetries,
  }) async {
    final db = await _dbService.database;

    String where = 'status = ?';
    List<dynamic> whereArgs = [SyncStatus.failed.name];

    if (businessId != null) {
      where += ' AND businessId = ?';
      whereArgs.add(businessId);
    }

    if (maxRetries != null) {
      where += ' AND retryCount < ?';
      whereArgs.add(maxRetries);
    }

    final results = await db.query(
      'sync_records',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'lastAttempt ASC',
    );

    return results.map((map) => _recordFromMap(map)).toList();
  }

  /// Get sync statistics
  Future<SyncStats> getSyncStats({String? businessId}) async {
    final db = await _dbService.database;

    String whereClause = businessId != null ? 'WHERE businessId = ?' : '';
    List<dynamic> whereArgs = businessId != null ? [businessId] : [];

    final results = await db.rawQuery('''
      SELECT 
        status,
        entityType,
        COUNT(*) as count,
        MAX(lastSuccess) as lastSync
      FROM sync_records
      $whereClause
      GROUP BY status, entityType
    ''', whereArgs);

    int totalPending = 0;
    int totalSynced = 0;
    int totalFailed = 0;
    DateTime? lastSyncTime;
    Map<SyncEntityType, int> pendingByType = {};

    for (var row in results) {
      final status = row['status'] as String;
      final count = row['count'] as int;

      if (status == SyncStatus.pending.name) {
        totalPending += count;
        final entityType = SyncEntityType.values.firstWhere(
          (e) => e.name == row['entityType'],
        );
        pendingByType[entityType] = count;
      } else if (status == SyncStatus.synced.name) {
        totalSynced += count;
      } else if (status == SyncStatus.failed.name) {
        totalFailed += count;
      }

      final lastSyncStr = row['lastSync'] as String?;
      if (lastSyncStr != null) {
        final syncTime = DateTime.parse(lastSyncStr);
        if (lastSyncTime == null || syncTime.isAfter(lastSyncTime)) {
          lastSyncTime = syncTime;
        }
      }
    }

    return SyncStats(
      totalPending: totalPending,
      totalSynced: totalSynced,
      totalFailed: totalFailed,
      lastSyncTime: lastSyncTime,
      pendingByType: pendingByType,
    );
  }

  /// Delete synced records older than specified days
  Future<int> cleanupOldRecords({
    required int olderThanDays,
    String? businessId,
  }) async {
    final db = await _dbService.database;
    final cutoffDate = DateTime.now()
        .subtract(Duration(days: olderThanDays))
        .toIso8601String();

    String where = 'status = ? AND lastSuccess < ?';
    List<dynamic> whereArgs = [SyncStatus.synced.name, cutoffDate];

    if (businessId != null) {
      where += ' AND businessId = ?';
      whereArgs.add(businessId);
    }

    return await db.delete('sync_records', where: where, whereArgs: whereArgs);
  }

  /// Get sync record by entity ID
  Future<SyncRecord?> getRecordByEntityId({
    required String entityId,
    required SyncEntityType entityType,
  }) async {
    final db = await _dbService.database;

    final results = await db.query(
      'sync_records',
      where: 'entityId = ? AND entityType = ?',
      whereArgs: [entityId, entityType.name],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return _recordFromMap(results.first);
  }

  /// Delete sync record
  Future<void> deleteRecord(String id) async {
    final db = await _dbService.database;
    await db.delete('sync_records', where: 'id = ?', whereArgs: [id]);
  }

  /// Reset failed records for retry
  Future<void> resetFailedRecords({String? businessId}) async {
    final db = await _dbService.database;

    String where = 'status = ?';
    List<dynamic> whereArgs = [SyncStatus.failed.name];

    if (businessId != null) {
      where += ' AND businessId = ?';
      whereArgs.add(businessId);
    }

    await db.update(
      'sync_records',
      {
        'status': SyncStatus.pending.name,
        'retryCount': 0,
        'errorMessage': null,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: where,
      whereArgs: whereArgs,
    );
  }

  // Helper methods
  String _encodeData(Map<String, dynamic> data) {
    return data.toString(); // Use json.encode in production
  }

  Map<String, dynamic> _decodeData(String data) {
    // Simple parsing - use json.decode in production
    return {}; // Placeholder
  }

  SyncRecord _recordFromMap(Map<String, dynamic> map) {
    return SyncRecord(
      id: map['id'],
      entityId: map['entityId'],
      entityType: SyncEntityType.values.firstWhere(
        (e) => e.name == map['entityType'],
      ),
      businessId: map['businessId'],
      status: SyncStatus.values.firstWhere((e) => e.name == map['status']),
      lastAttempt: DateTime.parse(map['lastAttempt']),
      lastSuccess: map['lastSuccess'] != null
          ? DateTime.parse(map['lastSuccess'])
          : null,
      retryCount: map['retryCount'],
      errorMessage: map['errorMessage'],
      data: _decodeData(map['data']),
    );
  }
}
