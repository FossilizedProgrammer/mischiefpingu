part of '../gateway_reconnect_orchestrator.dart';

/// ═══════════════════════════════════════════════════════════════
///  Phase 2: تلاش با Ranked Candidates از DecisionEngine.
/// ═══════════════════════════════════════════════════════════════
extension GatewayReconnectPhase2 on GatewayReconnectOrchestrator {
  Future<List<RankedCandidate>> getRankedCandidates({
    GatewayRecord? exclude,
    required bool Function() isCancelRequested,
  }) async {
    final engine = decisionEngine;
    if (engine == null) {
      logMessage(
        '→ Smart reconnect: DecisionEngine not available — skipping phase 2',
      );
      return const [];
    }

    try {
      final all = await engine.buildRankedCandidates();

      // فیلتر: حذف کاندید بدون امتیاز + حذف gateway مرحله 1
      final excludeKey = exclude?.uniqueKey;
      final filtered = <RankedCandidate>[];
      for (final c in all) {
        if (c.score < GatewayReconnectOrchestrator.minSecondaryScore) continue;
        if (excludeKey != null && c.endpoint.isNotEmpty) {
          // اگر endpoint مشابه بود، رد کن
          if (excludeKey.contains(c.endpoint)) continue;
        }
        filtered.add(c);
        if (filtered.length >=
            GatewayReconnectOrchestrator.maxSecondaryAttempts) {
          break;
        }
      }
      return filtered;
    } catch (e) {
      logMessage('⚠ Smart reconnect: ranked candidates failed: $e');
      return const [];
    }
  }

  Future<bool> tryRankedCandidate({
    required RankedCandidate candidate,
    required int port,
    required bool Function() isCancelRequested,
  }) async {
    if (isCancelRequested()) return false;

    // اگر endpoint مشخص است، مثل tryGateway عمل کن
    if (candidate.endpoint.isNotEmpty) {
      return tryCandidateWithEndpoint(
        candidate: candidate,
        port: port,
        isCancelRequested: isCancelRequested,
      );
    }

    // اگر endpoint خالی است، از args معمولی استفاده کن (اسکن)
    if (processService.isAetherRunning) {
      await processService.stopAether();
      await Future.delayed(const Duration(milliseconds: 400));
    }

    final args = buildReconnectArgs(
      protocol: candidate.protocol,
      masque: candidate.masque,
      endpoint: '',
      port: port,
    );

    final started = await processService.startAether(args);
    if (!started) return false;

    final prober = SocksProber(processService, isCancelled: isCancelRequested);
    final diag = await prober.waitForHealthy(
      port,
      timeout: const Duration(seconds: 45),
    );

    if (diag != SocksDiag.healthy) {
      await processService.stopAether();
      return false;
    }

    logMessage('★ Smart reconnect: connected via ${candidate.label}');
    return true;
  }

  Future<bool> tryCandidateWithEndpoint({
    required RankedCandidate candidate,
    required int port,
    required bool Function() isCancelRequested,
  }) async {
    if (processService.isAetherRunning) {
      await processService.stopAether();
      await Future.delayed(const Duration(milliseconds: 400));
    }

    final args = buildReconnectArgs(
      protocol: candidate.protocol,
      masque: candidate.masque,
      endpoint: candidate.endpoint,
      port: port,
    );

    final started = await processService.startAether(args);
    if (!started) return false;

    final prober = SocksProber(processService, isCancelled: isCancelRequested);
    final diag = await prober.waitForHealthy(
      port,
      timeout: const Duration(seconds: 45),
    );

    if (diag != SocksDiag.healthy) {
      await processService.stopAether();
      return false;
    }

    logMessage('★ Smart reconnect: connected via ${candidate.endpoint}');
    return true;
  }
}
