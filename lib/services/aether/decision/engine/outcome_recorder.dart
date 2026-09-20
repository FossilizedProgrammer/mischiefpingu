part of '../aether_decision_engine.dart';

/// ═══════════════════════════════════════════════════════════════
///  ثبت نتیجهٔ یک candidate — success / failure / session end.
/// ═══════════════════════════════════════════════════════════════
extension AetherDecisionEngineOutcomeRecorder on AetherDecisionEngine {
  Future<void> recordOutcomeImpl({
    required RankedCandidate candidate,
    required bool success,
    required int latencyMs,
    String errorMessage = '',
  }) async {
    if (success) {
      logger.connectionSuccess(
        settings: settings,
        protocol: candidate.protocol,
        masque: candidate.masque,
        endpoint: candidate.endpoint,
        durationMs: latencyMs,
        latencyMs: latencyMs,
      );
    } else {
      logger.connectionFailed(
        settings: settings,
        protocol: candidate.protocol,
        masque: candidate.masque,
        endpoint: candidate.endpoint,
        error: errorMessage.isEmpty ? 'unknown' : errorMessage,
        durationMs: latencyMs,
      );
    }

    // ignore: discarded_futures
    profileStore.record(
      profile: settings.aetherProfile,
      protocol: candidate.protocol,
      masqueOption: candidate.masque,
      networkType: settings.ipType,
      success: success,
      latencyMs: latencyMs,
    );

    final ep = _parseEndpoint(candidate.endpoint);
    if (ep == null) return;

    try {
      if (success) {
        await historyStore.recordSuccess(
          ip: ep.$1,
          port: ep.$2,
          protocol: candidate.protocol,
          masqueOption: candidate.masque,
          sni: settings.tlsSni,
          endpoint: candidate.endpoint,
          latencyMs: latencyMs,
          networkType: settings.ipType,
        );
      } else {
        await historyStore.recordFailure(
          ip: ep.$1,
          port: ep.$2,
          protocol: candidate.protocol,
          masqueOption: candidate.masque,
          sni: settings.tlsSni,
        );
      }
    } catch (e) {
      logInternal(
        '⚠ DecisionEngine: history record failed: $e',
      );
    }
  }

  Future<void> recordSessionEndImpl({
    required RankedCandidate candidate,
    required Duration uptime,
    required bool wasCleanDisconnect,
    int reconnectCount = 0,
  }) async {
    final ep = _parseEndpoint(candidate.endpoint);
    if (ep == null) return;

    try {
      await historyStore.recordSessionEnd(
        ip: ep.$1,
        port: ep.$2,
        protocol: candidate.protocol,
        masqueOption: candidate.masque,
        sni: settings.tlsSni,
        sessionUptime: uptime,
        wasCleanDisconnect: wasCleanDisconnect,
      );

      if (reconnectCount > 0) {
        await historyStore.recordReconnectEvent(
          ip: ep.$1,
          port: ep.$2,
          protocol: candidate.protocol,
          masqueOption: candidate.masque,
          sni: settings.tlsSni,
        );
      }
    } catch (e) {
      logInternal(
        '⚠ DecisionEngine: session end record failed: $e',
      );
    }
  }

  (String, int)? _parseEndpoint(String endpoint) {
    if (endpoint.isEmpty) return null;
    final idx = endpoint.lastIndexOf(':');
    if (idx <= 0) return null;
    final ip = endpoint.substring(0, idx);
    final port = int.tryParse(endpoint.substring(idx + 1));
    if (port == null || port < 1 || port > 65535) return null;
    return (ip, port);
  }
}
