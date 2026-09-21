part of '../profile_performance_store.dart';

/// ═══════════════════════════════════════════════════════════════
///  خواندن رکوردهای cache.
/// ═══════════════════════════════════════════════════════════════
extension ProfilePerformanceStoreQuery on ProfilePerformanceStore {
  /// امتیاز موفقیت یک ترکیب (0..1) در شبکهٔ فعلی.
  Future<double> successRate({
    required String profile,
    required String protocol,
    required String masqueOption,
    required String networkType,
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
      if (rows.isEmpty) return -1.0;
      final s = (rows.first[DatabaseSchema.colSuccessCount] as int?) ?? 0;
      final f = (rows.first[DatabaseSchema.colFailureCount] as int?) ?? 0;
      if (s + f == 0) return -1.0;
      return s / (s + f);
    } catch (_) {
      return -1.0;
    }
  }

  /// بهترین پروتکل‌ها برای یک profile + network type.
  Future<List<({String protocol, String masque, double rate, int latency})>>
  bestProtocols({
    required String profile,
    required String networkType,
    int limit = 5,
  }) async {
    try {
      final db = await GatewayDatabase.instance();
      final rows = await db.query(
        DatabaseSchema.tableProfilePerformance,
        where:
            '${DatabaseSchema.colProfile} = ? AND ${DatabaseSchema.colNetworkType} = ?',
        whereArgs: [profile, networkType],
      );

      final results =
          <({String protocol, String masque, double rate, int latency})>[];
      for (final r in rows) {
        final s = (r[DatabaseSchema.colSuccessCount] as int?) ?? 0;
        final f = (r[DatabaseSchema.colFailureCount] as int?) ?? 0;
        if (s + f < 2) continue;
        results.add((
          protocol: (r[DatabaseSchema.colProtocol] as String?) ?? '',
          masque: (r[DatabaseSchema.colMasqueOption] as String?) ?? '',
          rate: s / (s + f),
          latency: (r[DatabaseSchema.colAvgLatencyMs] as int?) ?? 0,
        ));
      }

      results.sort((a, b) {
        final byRate = b.rate.compareTo(a.rate);
        if (byRate != 0) return byRate;
        return a.latency.compareTo(b.latency);
      });

      return results.take(limit).toList();
    } catch (e) {
      logInternal('⚠ bestProtocols failed: $e');
      return [];
    }
  }

  /// شمارش کل رکوردها.
  Future<int> count() async {
    try {
      final db = await GatewayDatabase.instance();
      final r = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM ${DatabaseSchema.tableProfilePerformance}',
      );
      return (r.first['c'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// همهٔ رکوردها (برای دیباگ).
  Future<List<Map<String, Object?>>> getAllRaw() async {
    try {
      final db = await GatewayDatabase.instance();
      return await db.query(
        DatabaseSchema.tableProfilePerformance,
        orderBy: '${DatabaseSchema.colUpdatedAt} DESC',
      );
    } catch (e) {
      logInternal('⚠ getAllRaw failed: $e');
      return [];
    }
  }
}
