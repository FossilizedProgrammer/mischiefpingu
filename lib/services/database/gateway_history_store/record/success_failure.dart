part of '../../gateway_history_store.dart';

/// ═══════════════════════════════════════════════════════════════
///  ثبت موفقیت و شکست.
/// ═══════════════════════════════════════════════════════════════
extension GatewayHistoryStoreSuccessFailure on GatewayHistoryStore {
  Future<void> recordSuccess({
    required String ip,
    required int port,
    required String protocol,
    String masqueOption = '',
    String sni = '',
    String endpoint = '',
    int latencyMs = 0,
    String networkType = '',
    String networkName = '',
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
      final now = DateTime.now();

      final existing = await findRecordByKey(db, key);

      if (existing == null) {
        final rec = GatewayRecord(
          uniqueKey: key,
          ip: ip,
          port: port,
          protocol: protocol,
          masqueOption: masqueOption,
          sni: sni,
          endpoint: endpoint,
          lastSuccessAt: now,
          successCount: 1,
          totalAttempts: 1,
          avgLatencyMs: latencyMs,
          lastNetworkType: networkType,
          lastNetworkName: networkName,
          createdAt: now,
          updatedAt: now,
        );
        final withScore = rec.copyWith(score: computeScore(rec));
        await db.insert(DatabaseSchema.tableGatewayHistory, withScore.toMap());
        _log('★ Gateway recorded (new): $key score=${withScore.score}');
        return;
      }

      final newSuccess = existing.successCount + 1;
      final newAttempts = existing.totalAttempts + 1;
      final newLatency = movingAverage(
        existing.avgLatencyMs,
        existing.successCount,
        latencyMs,
      );

      final updated = existing.copyWith(
        lastSuccessAt: now,
        successCount: newSuccess,
        totalAttempts: newAttempts,
        avgLatencyMs: newLatency,
        endpoint: endpoint.isNotEmpty ? endpoint : existing.endpoint,
        lastNetworkType: networkType.isNotEmpty
            ? networkType
            : existing.lastNetworkType,
        lastNetworkName: networkName.isNotEmpty
            ? networkName
            : existing.lastNetworkName,
        updatedAt: now,
      );
      final withScore = updated.copyWith(score: computeScore(updated));

      await db.update(
        DatabaseSchema.tableGatewayHistory,
        withScore.toMap(),
        where: '${DatabaseSchema.colId} = ?',
        whereArgs: [existing.id],
      );
      _log(
        '★ Gateway success: $key (success=$newSuccess, '
        'lat=${newLatency}ms, score=${withScore.score})',
      );
    } catch (e) {
      _log('⚠ recordSuccess failed: $e');
    }
  }

  Future<void> recordFailure({
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
      final now = DateTime.now();
      final existing = await findRecordByKey(db, key);

      if (existing == null) {
        final rec = GatewayRecord(
          uniqueKey: key,
          ip: ip,
          port: port,
          protocol: protocol,
          masqueOption: masqueOption,
          sni: sni,
          lastFailureAt: now,
          failureCount: 1,
          totalAttempts: 1,
          createdAt: now,
          updatedAt: now,
        );
        final withScore = rec.copyWith(score: computeScore(rec));
        await db.insert(DatabaseSchema.tableGatewayHistory, withScore.toMap());
        _log('→ Gateway failure (new): $key');
        return;
      }

      final newFailure = existing.failureCount + 1;
      final newAttempts = existing.totalAttempts + 1;
      final updated = existing.copyWith(
        lastFailureAt: now,
        failureCount: newFailure,
        totalAttempts: newAttempts,
        updatedAt: now,
      );
      final withScore = updated.copyWith(score: computeScore(updated));

      await db.update(
        DatabaseSchema.tableGatewayHistory,
        withScore.toMap(),
        where: '${DatabaseSchema.colId} = ?',
        whereArgs: [existing.id],
      );
      _log(
        '→ Gateway failure: $key (failure=$newFailure, score=${withScore.score})',
      );
    } catch (e) {
      _log('⚠ recordFailure failed: $e');
    }
  }
}
