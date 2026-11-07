part of '../gateway_history_store.dart';

/// ═══════════════════════════════════════════════════════════════
///  خواندن رکوردها.
/// ═══════════════════════════════════════════════════════════════
extension GatewayHistoryStoreQuery on GatewayHistoryStore {
  Future<List<GatewayRecord>> getTopGateways({
    int limit = 10,
    String? protocol,
    double minScore = 0.0,
  }) async {
    try {
      final db = await GatewayDatabase.instance();
      final where = <String>['${DatabaseSchema.colScore} >= ?'];
      final args = <Object?>[minScore];

      if (protocol != null && protocol.isNotEmpty) {
        where.add('${DatabaseSchema.colProtocol} = ?');
        args.add(protocol);
      }

      final rows = await db.query(
        DatabaseSchema.tableGatewayHistory,
        where: where.join(' AND '),
        whereArgs: args,
        orderBy: '${DatabaseSchema.colScore} DESC',
        limit: limit,
      );
      return rows.map(GatewayRecord.fromMap).toList();
    } catch (e) {
      _log('⚠ getTopGateways failed: $e');
      return [];
    }
  }

  Future<GatewayRecord?> getLastSuccessful({String? protocol}) async {
    try {
      final db = await GatewayDatabase.instance();
      final where = <String>['${DatabaseSchema.colLastSuccessAt} IS NOT NULL'];
      final args = <Object?>[];

      if (protocol != null && protocol.isNotEmpty) {
        where.add('${DatabaseSchema.colProtocol} = ?');
        args.add(protocol);
      }

      final rows = await db.query(
        DatabaseSchema.tableGatewayHistory,
        where: where.join(' AND '),
        whereArgs: args,
        orderBy: '${DatabaseSchema.colLastSuccessAt} DESC',
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return GatewayRecord.fromMap(rows.first);
    } catch (e) {
      _log('⚠ getLastSuccessful failed: $e');
      return null;
    }
  }

  Future<GatewayRecord?> getByKey(String uniqueKey) async {
    try {
      final db = await GatewayDatabase.instance();
      return await findRecordByKey(db, uniqueKey);
    } catch (e) {
      _log('⚠ getByKey failed: $e');
      return null;
    }
  }

  Future<List<GatewayRecord>> getAll() async {
    try {
      final db = await GatewayDatabase.instance();
      final rows = await db.query(
        DatabaseSchema.tableGatewayHistory,
        orderBy: '${DatabaseSchema.colUpdatedAt} DESC',
      );
      return rows.map(GatewayRecord.fromMap).toList();
    } catch (e) {
      _log('⚠ getAll failed: $e');
      return [];
    }
  }
}
