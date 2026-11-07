part of '../../gateway_history_store.dart';

/// ═══════════════════════════════════════════════════════════════
///  ثبت عملکرد (jitter/loss) + session end + reconnect.
/// ═══════════════════════════════════════════════════════════════
extension GatewayHistoryStorePerformanceSession on GatewayHistoryStore {
  /// ثبت عملکرد (jitter و packet loss).
  Future<void> recordPerformance({
    required String ip,
    required int port,
    required String protocol,
    String masqueOption = '',
    String sni = '',
    required int jitterMs,
    required double packetLossPct,
  }) async {
    try {
      final db = await GatewayDatabase.instance();
      final key = buildRecordKey(
        ip: ip,
        port: port,
        protocol: protocol,
        masqueOption: masqueOption,
        sni: sni,
      );
      final existing = await findRecordByKey(db, key);
      if (existing == null) return;

      final newJitter = existing.avgJitterMs == 0
          ? jitterMs
          : ((existing.avgJitterMs * 3 + jitterMs) / 4).round();
      final newLoss = existing.packetLossPct == 0.0
          ? packetLossPct
          : (existing.packetLossPct * 0.7 + packetLossPct * 0.3);

      final updated = existing.copyWith(
        avgJitterMs: newJitter,
        packetLossPct: newLoss,
        updatedAt: DateTime.now(),
      );
      final withScore = updated.copyWith(score: computeScore(updated));

      await db.update(
        DatabaseSchema.tableGatewayHistory,
        withScore.toMap(),
        where: '${DatabaseSchema.colId} = ?',
        whereArgs: [existing.id],
      );
      _log(
        '★ Gateway perf: $key (jitter=${newJitter}ms, '
        'loss=${newLoss.toStringAsFixed(1)}%, score=${withScore.score})',
      );
    } catch (e) {
      _log('⚠ recordPerformance failed: $e');
    }
  }

  /// ثبت اتمام یک session (v4).
  Future<void> recordSessionEnd({
    required String ip,
    required int port,
    required String protocol,
    String masqueOption = '',
    String sni = '',
    required Duration sessionUptime,
    required bool wasCleanDisconnect,
  }) async {
    try {
      final db = await GatewayDatabase.instance();
      final key = buildRecordKey(
        ip: ip,
        port: port,
        protocol: protocol,
        masqueOption: masqueOption,
        sni: sni,
      );
      final existing = await findRecordByKey(db, key);
      if (existing == null) return;

      final samples = <int>[...existing.lastUptimeSamples];
      samples.add(sessionUptime.inSeconds);
      if (samples.length > 10) samples.removeAt(0);
      final avgUptime = samples.isEmpty
          ? 0
          : samples.reduce((a, b) => a + b) ~/ samples.length;

      final updated = existing.copyWith(
        avgSessionUptimeSec: avgUptime,
        lastUptimeSamples: samples,
        updatedAt: DateTime.now(),
      );
      final recent = await loadRecentSuccesses(db, ip, port, protocol);
      final withScore = updated.copyWith(
        score: computeScore(updated, recentSuccesses: recent),
      );

      await db.update(
        DatabaseSchema.tableGatewayHistory,
        withScore.toMap(),
        where: '${DatabaseSchema.colId} = ?',
        whereArgs: [existing.id],
      );

      _log(
        '★ Session ended: $key (uptime=${sessionUptime.inSeconds}s, '
        'avg=${avgUptime}s, clean=$wasCleanDisconnect, '
        'score=${withScore.score})',
      );
    } catch (e) {
      _log('⚠ recordSessionEnd failed: $e');
    }
  }

  /// ثبت یک reconnect (برای penalty).
  Future<void> recordReconnectEvent({
    required String ip,
    required int port,
    required String protocol,
    String masqueOption = '',
    String sni = '',
  }) async {
    try {
      final db = await GatewayDatabase.instance();
      final key = buildRecordKey(
        ip: ip,
        port: port,
        protocol: protocol,
        masqueOption: masqueOption,
        sni: sni,
      );
      final existing = await findRecordByKey(db, key);
      if (existing == null) return;

      final updated = existing.copyWith(
        reconnectCount: existing.reconnectCount + 1,
        updatedAt: DateTime.now(),
      );
      final withScore = updated.copyWith(score: computeScore(updated));

      await db.update(
        DatabaseSchema.tableGatewayHistory,
        withScore.toMap(),
        where: '${DatabaseSchema.colId} = ?',
        whereArgs: [existing.id],
      );
      _log(
        '→ Gateway reconnect: $key '
        '(total=${updated.reconnectCount}, score=${withScore.score})',
      );
    } catch (e) {
      _log('⚠ recordReconnectEvent failed: $e');
    }
  }
}
