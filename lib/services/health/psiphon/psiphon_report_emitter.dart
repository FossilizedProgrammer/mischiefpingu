part of '../psiphon_health_source.dart';

/// ═══════════════════════════════════════════════════════════════
///  PsiphonReportEmitter — ساخت و ارسال report دوره‌ای.
///
///  هر ۱۰ ثانیه metricهای جمع‌آوری‌شده را به monitor می‌فرستد.
/// ═══════════════════════════════════════════════════════════════
class PsiphonReportEmitter {
  final PsiphonHealthSource source;

  Timer? _reportTimer;

  static const Duration _interval = Duration(seconds: 10);

  // ⚠️ دیگر `const` نیست چون `_reportTimer` یک فیلد non-final است.
  PsiphonReportEmitter({required this.source});

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
        ? (source.consecutiveFailures / source.totalSamples) * 100.0
        : 0.0;

    final bytesPerSec = _computeBytesPerSec();

    source.onReport(
      latencyMs: latency,
      jitterMs: jitter,
      packetLossPct: lossPct.clamp(0.0, 100.0),
      successCount: source.successCount,
      totalSamples: source.totalSamples,
      extra: {
        'protocol': source.currentProtocol ?? 'unknown',
        'failures': source.totalFailures,
        'consecutiveFailures': source.consecutiveFailures,
        'bytesUp': source.lastUpstreamBytes,
        'bytesDown': source.lastDownstreamBytes,
        'bytesPerSec': bytesPerSec,
      },
    );
  }

  int _computeBytesPerSec() {
    final now = DateTime.now();
    final lastAt = source.lastBytesSampleAt;
    if (lastAt == null) {
      source.lastBytesSampleAt = now;
      return 0;
    }
    final elapsedSec = now.difference(lastAt).inSeconds;
    if (elapsedSec <= 0) return 0;
    final total = source.lastUpstreamBytes + source.lastDownstreamBytes;
    source.lastBytesSampleAt = now;
    return total ~/ elapsedSec;
  }
}
