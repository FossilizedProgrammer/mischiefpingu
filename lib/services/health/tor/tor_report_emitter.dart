part of '../tor_health_source.dart';

/// ═══════════════════════════════════════════════════════════════
///  TorReportEmitter — ساخت و ارسال report دوره‌ای.
///
///  هر ۱۵ ثانیه metricهای جمع‌آوری‌شده را به monitor می‌فرستد.
/// ═══════════════════════════════════════════════════════════════
class TorReportEmitter {
  final TorHealthSource source;

  Timer? _reportTimer;

  static const Duration _interval = Duration(seconds: 15);

  // ⚠️ دیگر `const` نیست چون `_reportTimer` یک فیلد non-final است.
  TorReportEmitter({required this.source});

  void start() {
    _reportTimer?.cancel();
    _reportTimer = Timer.periodic(_interval, (_) => emit());
  }

  void stop() {
    _reportTimer?.cancel();
    _reportTimer = null;
  }

  void emit() {
    if (source.totalSamples == 0) return;

    final latency = source.currentLatencyMs;
    final jitter = (source.currentLatencyMs - source.lastLatencyMs).abs();
    source.lastLatencyMs = source.currentLatencyMs;

    final lossPct = source.totalSamples > 0
        ? ((source.circuitsFailed + source.streamsFailed) /
                  source.totalSamples) *
              100.0
        : 0.0;

    source.onReport(
      latencyMs: latency,
      jitterMs: jitter,
      packetLossPct: lossPct.clamp(0.0, 100.0),
      successCount: source.successCount,
      totalSamples: source.totalSamples,
      extra: {
        'bootstrapProgress': source.bootstrapProgress,
        'circuitsEstablished': source.circuitsEstablished,
        'circuitsFailed': source.circuitsFailed,
        'streamsOpened': source.streamsOpened,
        'streamsFailed': source.streamsFailed,
      },
    );
  }
}
