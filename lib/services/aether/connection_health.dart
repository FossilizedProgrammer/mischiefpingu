library;

import 'package:meta/meta.dart';

import '../health/tunnel_health_models.dart';

/// ═══════════════════════════════════════════════════════════════
///  ConnectionHealth — امتیاز لحظه‌ای سلامت اتصال Aether.
///
///  ⚠️ توجه: HealthTrend از لایهٔ مشترک
///  (`tunnel_health_models.dart`) import می‌شود.
/// ═══════════════════════════════════════════════════════════════
@immutable
class ConnectionHealth {
  /// امتیاز نهایی (0..100).
  final double score;

  /// میانگین latency آخرین probeها.
  final int latencyMs;

  /// jitter آخرین probe.
  final int jitterMs;

  /// درصد افت بسته.
  final double packetLossPct;

  /// مدت زمان اتصال فعلی.
  final Duration uptime;

  /// تعداد reconnectها در این session.
  final int reconnectCount;

  /// تعداد خطاهای ثبت‌شده.
  final int errorCount;

  /// روند کلی کیفیت.
  final HealthTrend trend;

  const ConnectionHealth({
    required this.score,
    required this.latencyMs,
    required this.jitterMs,
    required this.packetLossPct,
    required this.uptime,
    required this.reconnectCount,
    required this.errorCount,
    required this.trend,
  });

  /// وضعیت ناشناخته (وقتی هنوز probe‌ای انجام نشده).
  static const ConnectionHealth unknown = ConnectionHealth(
    score: 0,
    latencyMs: 0,
    jitterMs: 0,
    packetLossPct: 0,
    uptime: Duration.zero,
    reconnectCount: 0,
    errorCount: 0,
    trend: HealthTrend.stable,
  );

  /// آیا این امتیاز معتبر است؟
  bool get isValid => score > 0;

  /// رنگ پیشنهادی برای UI.
  int get colorHex {
    if (score >= 80) return 0xFF10B981; // green
    if (score >= 60) return 0xFF22C55E; // light green
    if (score >= 40) return 0xFFF59E0B; // amber
    if (score >= 20) return 0xFFF97316; // orange
    return 0xFFEF4444; // red
  }

  @override
  String toString() =>
      'ConnectionHealth(score=${score.toStringAsFixed(1)}, '
      'lat=${latencyMs}ms, jitter=${jitterMs}ms, '
      'loss=${packetLossPct.toStringAsFixed(1)}%, '
      'uptime=${uptime.inMinutes}min, trend=${trend.name})';
}
