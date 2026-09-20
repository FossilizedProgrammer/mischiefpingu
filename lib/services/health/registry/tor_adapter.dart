part of '../tunnel_health_registry.dart';

/// ═══════════════════════════════════════════════════════════════
///  TorAdapter — اتصال TorHealthSource به TunnelHealthMonitor.
/// ═══════════════════════════════════════════════════════════════
class TorAdapter {
  final void Function(String message, {String source}) log;
  final TunnelHealthMonitor monitor;

  late final TorHealthSource _source;

  TorAdapter({
    required this.log,
    required this.monitor,
  }) {
    _source = TorHealthSource(
      log: log,
      onReport: ({
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
