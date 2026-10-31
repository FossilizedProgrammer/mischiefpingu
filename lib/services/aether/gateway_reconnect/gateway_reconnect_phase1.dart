part of '../gateway_reconnect_orchestrator.dart';

/// ═══════════════════════════════════════════════════════════════
///  Phase 1: تلاش با آخرین Gateway موفق + endpoint خام.
/// ═══════════════════════════════════════════════════════════════
extension GatewayReconnectPhase1 on GatewayReconnectOrchestrator {
  Future<GatewayRecord?> getLastSuccessfulGateway() async {
    try {
      final last = await historyStore.getLastSuccessful();
      if (last != null && _isOnFailureRest(last)) {
        logMessage(
          '→ Last gateway ${last.uniqueKey} is resting after repeated '
          'failures — skipping fast-path',
        );
        return null;
      }
      return last;
    } catch (e) {
      logMessage('⚠ getLastSuccessful failed: $e');
      return null;
    }
  }

  /// دو شکست پیاپی در پنج دقیقهٔ گذشته و بدون موفقیت بعد از آن‌ها، یعنی این
  /// gateway فعلاً جواب نمی‌دهد؛ پنج دقیقه کنار گذاشته می‌شود تا fast-path
  /// هر بار روی همان endpoint مرده وقت نسوزاند. با اولین موفقیت، شمارش
  /// شکست‌ها بی‌اثر می‌شود.
  bool _isOnFailureRest(GatewayRecord record) {
    final failedAt = record.lastFailureAt;
    if (failedAt == null || record.failureCount < 2) return false;
    final succeededSince =
        record.lastSuccessAt != null && record.lastSuccessAt!.isAfter(failedAt);
    if (succeededSince) return false;
    return DateTime.now().difference(failedAt) < const Duration(minutes: 5);
  }

  Future<bool> tryGateway({
    required GatewayRecord record,
    required int port,
    required bool Function() isCancelRequested,
  }) async {
    if (isCancelRequested()) return false;

    if (processService.isAetherRunning) {
      await processService.stopAether();
      await Future.delayed(const Duration(milliseconds: 400));
    }

    final endpoint = record.endpoint.trim();
    if (endpoint.isEmpty) {
      logMessage(
        '→ Smart reconnect: gateway has no saved endpoint '
        '(${record.uniqueKey}) — skipping',
      );
      return false;
    }

    final args = buildReconnectArgs(
      protocol: record.protocol,
      masque: record.masqueOption,
      endpoint: endpoint,
      port: port,
    );

    logMessage('→ Smart reconnect: starting Aether with $endpoint');
    final started = await processService.startAether(args);
    if (!started) {
      logMessage('✗ Smart reconnect: startAether failed');
      return false;
    }

    final prober = SocksProber(processService, isCancelled: isCancelRequested);

    final diag = await prober.waitForHealthy(
      port,
      timeout: const Duration(seconds: 45),
    );

    logMessage(prober.diagText(diag, port));

    if (diag != SocksDiag.healthy) {
      logMessage('✗ Smart reconnect: SOCKS not healthy (${diag.name})');
      await processService.stopAether();
      try {
        await historyStore.recordFailure(
          ip: record.ip,
          port: record.port,
          protocol: record.protocol,
          masqueOption: record.masqueOption,
          sni: record.sni,
        );
      } catch (_) {}
      return false;
    }

    logMessage('★ Smart reconnect: connected via ${record.uniqueKey}');

    try {
      await historyStore.recordSuccess(
        ip: record.ip,
        port: record.port,
        protocol: record.protocol,
        masqueOption: record.masqueOption,
        sni: record.sni,
        endpoint: endpoint,
      );
    } catch (_) {}

    startTrackerForGateway(record: record, port: port, endpoint: endpoint);
    return true;
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  tryEndpointDirect — تلاش مستقیم با یک endpoint خام.
  /// ═══════════════════════════════════════════════════════════════
  Future<bool> tryEndpointDirect({
    required String endpoint,
    required String protocol,
    required String masque,
    required int port,
    required bool Function() isCancelRequested,
  }) async {
    if (isCancelRequested()) return false;

    if (endpoint.trim().isEmpty) return false;

    if (processService.isAetherRunning) {
      await processService.stopAether();
      await Future.delayed(const Duration(milliseconds: 400));
    }

    final args = buildReconnectArgs(
      protocol: protocol,
      masque: masque,
      endpoint: endpoint,
      port: port,
    );

    logMessage('→ Fast-path: starting Aether with $endpoint');
    final started = await processService.startAether(args);
    if (!started) {
      logMessage('✗ Fast-path: startAether failed');
      return false;
    }

    final prober = SocksProber(processService, isCancelled: isCancelRequested);

    final diag = await prober.waitForHealthy(
      port,
      timeout: const Duration(seconds: 45),
    );

    logMessage(prober.diagText(diag, port));

    if (diag != SocksDiag.healthy) {
      logMessage('✗ Fast-path: SOCKS not healthy (${diag.name})');
      await processService.stopAether();
      final failed = EndpointParser.parse(endpoint);
      if (failed != null) {
        try {
          await historyStore.recordFailure(
            ip: failed.$1,
            port: failed.$2,
            protocol: protocol,
            masqueOption: masque,
          );
        } catch (_) {}
      }
      return false;
    }

    logMessage('★ Fast-path: connected via $endpoint');

    final parsed = EndpointParser.parse(endpoint);
    if (parsed != null) {
      try {
        await historyStore.recordSuccess(
          ip: parsed.$1,
          port: parsed.$2,
          protocol: protocol,
          masqueOption: masque,
          endpoint: endpoint,
        );
      } catch (_) {}
    }

    return true;
  }
}
