part of '../gateway_history_store.dart';

/// ═══════════════════════════════════════════════════════════════
///  نگهداری: شمارش، پاک‌سازی، prune.
/// ═══════════════════════════════════════════════════════════════
extension GatewayHistoryStoreMaintenance on GatewayHistoryStore {
  Future<int> count() async {
    try {
      final db = await GatewayDatabase.instance();
      final r = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM ${DatabaseSchema.tableGatewayHistory}',
      );
      return (r.first['c'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> pruneWeakGateways({
    double minScore = 10.0,
    int minFailures = 3,
    int maxAgeDays = 30,
  }) async {
    try {
      final db = await GatewayDatabase.instance();
      final cutoff = DateTime.now()
          .subtract(Duration(days: maxAgeDays))
          .millisecondsSinceEpoch;

      final deleted = await db.delete(
        DatabaseSchema.tableGatewayHistory,
        where: '${DatabaseSchema.colScore} < ? '
            'AND ${DatabaseSchema.colFailureCount} >= ? '
            'AND (${DatabaseSchema.colLastSuccessAt} IS NULL '
            'OR ${DatabaseSchema.colLastSuccessAt} < ?)',
        whereArgs: [minScore, minFailures, cutoff],
      );

      if (deleted > 0) {
        _log('→ Pruned $deleted weak gateway record(s)');
      }
      return deleted;
    } catch (e) {
      _log('⚠ pruneWeakGateways failed: $e');
      return 0;
    }
  }

  Future<void> clearAll() async {
    try {
      final db = await GatewayDatabase.instance();
      await db.delete(DatabaseSchema.tableGatewayHistory);
      _log('→ Gateway history cleared');
    } catch (e) {
      _log('⚠ clearAll failed: $e');
    }
  }
}
