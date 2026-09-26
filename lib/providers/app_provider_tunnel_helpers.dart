part of 'app_provider.dart';

extension AppProviderTunnelHelpers on AppProvider {
  void setCurrentActiveCandidate(RankedCandidate? candidate) {
    _currentActiveCandidate = candidate;
  }

  void clearCurrentActiveCandidate() {
    _currentActiveCandidate = null;
  }

  Future<ProtocolStats> computeStats24h() => _statsService.computeLast24h();

  Future<ProtocolStats> computeStats7d() => _statsService.computeLast7d();

  TunnelHealthReport? healthReportFor(TunnelKind kind) {
    if (kind == TunnelKind.aether) {
      final h = _currentHealth;
      if (h == null || !h.isValid) return null;
      return TunnelHealthReport(
        kind: TunnelKind.aether,
        timestamp: DateTime.now(),
        score: h.score,
        latencyMs: h.latencyMs,
        jitterMs: h.jitterMs,
        packetLossPct: h.packetLossPct,
        uptime: h.uptime,
        reconnectCount: h.reconnectCount,
        errorCount: h.errorCount,
        trend: h.trend,
        successCount: 1,
        totalSamples: 1,
        extra: const {},
      );
    }
    return _healthRegistry.reportFor(kind);
  }

  HealthSnapshot healthSnapshot() {
    final reports = <TunnelKind, TunnelHealthReport>{};
    final aetherReport = healthReportFor(TunnelKind.aether);
    if (aetherReport != null) {
      reports[TunnelKind.aether] = aetherReport;
    }
    for (final kind in [TunnelKind.psiphon, TunnelKind.tor, TunnelKind.sstp]) {
      final r = _healthRegistry.reportFor(kind);
      if (r != null) reports[kind] = r;
    }
    return HealthSnapshot(reports: reports, timestamp: DateTime.now());
  }

  void recordTunnelReconnect(TunnelKind kind) {
    if (kind == TunnelKind.aether) return;
    _healthRegistry.recordReconnect(kind);
  }

  void recordTunnelError(TunnelKind kind) {
    if (kind == TunnelKind.aether) return;
    _healthRegistry.recordError(kind);
  }

  String _tunnelDisplayName(String key) {
    switch (key.toLowerCase()) {
      case 'psiphon': return 'Psiphon';
      case 'aether': return 'Aether';
      case 'tor': return 'Tor';
      case 'sstp': return 'SSTP';
      default: return key;
    }
  }

  String cleanIp(String ip) => ip.replaceAll(r'\', '').trim();

  List<String> cleanIpList(List<String> list) =>
      list.map(cleanIp).where((e) => e.isNotEmpty).toSet().toList();
}
