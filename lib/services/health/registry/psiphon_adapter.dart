part of '../tunnel_health_registry.dart';

/// ═══════════════════════════════════════════════════════════════
///  PsiphonAdapter — اتصال PsiphonHealthSource به TunnelHealthMonitor.
///
///  این adapter:
///    • یک instance از PsiphonHealthSource می‌سازه
///    • callback آن را به monitor وصل می‌کنه
///    • lifecycle (start/stop/reset) را مدیریت می‌کنه
/// ═══════════════════════════════════════════════════════════════
class PsiphonAdapter {
  final void Function(String message, {String source}) log;
  final TunnelHealthMonitor monitor;

  late final PsiphonHealthSource _source;

  PsiphonAdapter({required this.log, required this.monitor}) {
    _source = PsiphonHealthSource(
      log: log,
      onReport:
          ({
            required int latencyMs,
            required int jitterMs,
            required double packetLossPct,
            required int successCount,
            required int totalSamples,
            required Map<String, dynamic> extra,
          }) {
            monitor.ingestReport(
              latencyMs: latencyMs,
              jitterMs: jitterMs,
              packetLossPct: packetLossPct,
              successCount: successCount,
              totalSamples: totalSamples,
              extra: extra,
            );
          },
    );
  }

  void start() => _source.start();
  void feed(String line) => _source.feed(line);
  void reset() => _source.reset();

  void dispose() => _source.dispose();
}
