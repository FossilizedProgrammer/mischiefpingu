part of '../gateway_history_store.dart';

/// ═══════════════════════════════════════════════════════════════
///  helpers خصوصی مشترک بین record/query/maintenance.
///
///  توجه: این extension در فایل‌های part دیگر هم قابل استفاده است.
/// ═══════════════════════════════════════════════════════════════
extension GatewayHistoryStoreInternal on GatewayHistoryStore {
  Future<GatewayRecord?> findRecordByKey(Database db, String key) async {
    final rows = await db.query(
      DatabaseSchema.tableGatewayHistory,
      where: '${DatabaseSchema.colUniqueKey} = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return GatewayRecord.fromMap(rows.first);
  }

  int movingAverage(int oldAvg, int oldCount, int newValue) {
    if (oldCount == 0) return newValue;
    final weight = oldCount < 5
        ? 1
        : oldCount < 20
            ? 2
            : 4;
    return ((oldAvg * weight + newValue) / (weight + 1)).round();
  }

  double computeScore(
    GatewayRecord rec, {
    List<DateTime>? recentSuccesses,
  }) {
    return GatewayScoreCalculator.compute(
      avgLatencyMs: rec.avgLatencyMs,
      avgJitterMs: rec.avgJitterMs,
      packetLossPct: rec.packetLossPct,
      successCount: rec.successCount,
      failureCount: rec.failureCount,
      lastSuccessAt: rec.lastSuccessAt,
      avgSessionUptimeSec: rec.avgSessionUptimeSec,
      reconnectCount: rec.reconnectCount,
      totalAttempts: rec.totalAttempts,
      recentSuccesses: recentSuccesses,
    );
  }

  Future<List<DateTime>> loadRecentSuccesses(
    Database db,
    String ip,
    int port,
    String protocol,
  ) async {
    try {
      final rows = await db.query(
        DatabaseSchema.tableAetherEvents,
        where: '${DatabaseSchema.colEventType} = ? AND '
            '${DatabaseSchema.colProtocol} = ?',
        whereArgs: ['connection_success', protocol],
        orderBy: '${DatabaseSchema.colTimestamp} DESC',
        limit: 20,
      );
      return rows
          .map((r) => DateTime.fromMillisecondsSinceEpoch(
                (r[DatabaseSchema.colTimestamp] as int?) ?? 0,
              ))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// ساخت unique key از فیلدها.
  String buildRecordKey({
    required String ip,
    required int port,
    required String protocol,
    String masqueOption = '',
    String sni = '',
  }) =>
      GatewayRecord.buildKey(
        ip: ip,
        port: port,
        protocol: protocol,
        masqueOption: masqueOption,
        sni: sni,
      );
}
