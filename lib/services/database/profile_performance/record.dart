part of '../profile_performance_store.dart';

/// ═══════════════════════════════════════════════════════════════
///  ثبت یک نتیجه (success/failure) در cache.
/// ═══════════════════════════════════════════════════════════════
extension ProfilePerformanceStoreRecord on ProfilePerformanceStore {
  Future<void> record({
    required String profile,
    required String protocol,
    required String masqueOption,
    required String networkType,
    required bool success,
    int latencyMs = 0,
  }) async {
    try {
      final db = await GatewayDatabase.instance();
      final key = ProfilePerformanceStore.buildKey(
        profile,
        protocol,
        masqueOption,
        networkType,
      );

      final rows = await db.query(
        DatabaseSchema.tableProfilePerformance,
        where: '${DatabaseSchema.colUniqueKey} = ?',
        whereArgs: [key],
        limit: 1,
      );

      final now = DateTime.now().millisecondsSinceEpoch;

      if (rows.isEmpty) {
        await db.insert(DatabaseSchema.tableProfilePerformance, {
          DatabaseSchema.colUniqueKey: key,
          DatabaseSchema.colProfile: profile,
          DatabaseSchema.colProtocol: protocol,
          DatabaseSchema.colMasqueOption: masqueOption,
          DatabaseSchema.colNetworkType: networkType,
          DatabaseSchema.colSuccessCount: success ? 1 : 0,
          DatabaseSchema.colFailureCount: success ? 0 : 1,
          DatabaseSchema.colAvgLatencyMs: latencyMs,
          DatabaseSchema.colLastSuccessAt: success ? now : null,
          DatabaseSchema.colLastFailureAt: success ? null : now,
          DatabaseSchema.colUpdatedAt: now,
        });
        return;
      }

      final row = rows.first;
      final prevSuccess = (row[DatabaseSchema.colSuccessCount] as int?) ?? 0;
      final prevFailure = (row[DatabaseSchema.colFailureCount] as int?) ?? 0;
      final prevLatency = (row[DatabaseSchema.colAvgLatencyMs] as int?) ?? 0;

      final newSuccess = prevSuccess + (success ? 1 : 0);
      final newFailure = prevFailure + (success ? 0 : 1);
      final newLatency = (success && latencyMs > 0)
          ? ((prevLatency * prevSuccess + latencyMs) ~/ (prevSuccess + 1))
          : prevLatency;

      await db.update(
        DatabaseSchema.tableProfilePerformance,
        {
          DatabaseSchema.colSuccessCount: newSuccess,
          DatabaseSchema.colFailureCount: newFailure,
          DatabaseSchema.colAvgLatencyMs: newLatency,
          if (success) DatabaseSchema.colLastSuccessAt: now,
          if (!success) DatabaseSchema.colLastFailureAt: now,
          DatabaseSchema.colUpdatedAt: now,
        },
        where: '${DatabaseSchema.colUniqueKey} = ?',
        whereArgs: [key],
      );
    } catch (e) {
      logInternal('⚠ profile perf record failed: $e');
    }
  }
}
