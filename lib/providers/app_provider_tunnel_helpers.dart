part of 'app_provider.dart';

extension AppProviderTunnelHelpers on AppProvider {
  TunnelHealthReport? healthReportFor(TunnelKind kind) =>
      _healthRegistry.reportFor(kind);

  HealthSnapshot healthSnapshot() {
    final reports = <TunnelKind, TunnelHealthReport>{};
    for (final kind in [TunnelKind.psiphon, TunnelKind.tor, TunnelKind.sstp]) {
      final r = _healthRegistry.reportFor(kind);
      if (r != null) reports[kind] = r;
    }
    return HealthSnapshot(reports: reports, timestamp: DateTime.now());
  }

  void recordTunnelReconnect(TunnelKind kind) {
    _healthRegistry.recordReconnect(kind);
  }

  void recordTunnelError(TunnelKind kind) {
    _healthRegistry.recordError(kind);
  }

  String _tunnelDisplayName(String key) {
    switch (key.toLowerCase()) {
      case 'psiphon':
        return 'Psiphon';
      case 'tor':
        return 'Tor';
      case 'sstp':
        return 'SSTP';
      default:
        return key;
    }
  }

  String cleanIp(String ip) => ip.replaceAll(r'\', '').trim();

  List<String> cleanIpList(List<String> list) =>
      list.map(cleanIp).where((e) => e.isNotEmpty).toSet().toList();
}
