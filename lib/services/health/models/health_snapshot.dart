library;

import 'tunnel_health_report.dart';
import 'tunnel_kind.dart';

/// ═══════════════════════════════════════════════════════════════
///  HealthSnapshot — مجموعه‌ای از reportهای همهٔ تونل‌ها.
///
///  برای UI مشترک استفاده می‌شه.
/// ═══════════════════════════════════════════════════════════════
class HealthSnapshot {
  final Map<TunnelKind, TunnelHealthReport> reports;
  final DateTime timestamp;

  const HealthSnapshot({required this.reports, required this.timestamp});

  TunnelHealthReport? forTunnel(TunnelKind kind) => reports[kind];

  bool get hasAnyValid => reports.values.any((r) => r.isValid);

  int get healthyCount => reports.values
      .where((r) => r.isValid && r.level.index <= 2) // excellent, good, fair
      .length;

  @override
  String toString() =>
      'HealthSnapshot(${reports.length} tunnels, '
      'healthy=$healthyCount, timestamp=$timestamp)';
}
