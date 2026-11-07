library;

import 'package:meta/meta.dart';

import 'health_level.dart';
import 'health_trend.dart';
import 'tunnel_kind.dart';

/// ═══════════════════════════════════════════════════════════════
///  TunnelHealthReport — یک snapshot از health یک تونل.
///
///  این مدل مشترک بین همهٔ تونل‌هاست. هر تونل یک adapter داره که
///  دادهٔ خام خودش رو به این مدل تبدیل می‌کنه.
/// ═══════════════════════════════════════════════════════════════
@immutable
class TunnelHealthReport {
  /// نوع تونل.
  final TunnelKind kind;

  /// زمان تولید این report.
  final DateTime timestamp;

  /// امتیاز نهایی (0..100). اگر 0 باشد یعنی معتبر نیست.
  final double score;

  /// میانگین latency آخرین probeها (ms).
  final int latencyMs;

  /// jitter آخرین probe (ms).
  final int jitterMs;

  /// درصد افت بسته (0..100).
  final double packetLossPct;

  /// مدت زمان اتصال فعلی.
  final Duration uptime;

  /// تعداد reconnectها در این session.
  final int reconnectCount;

  /// تعداد خطاهای ثبت‌شده.
  final int errorCount;

  /// روند کلی کیفیت.
  final HealthTrend trend;

  /// تعداد نمونه‌های موفق (برای اعتبارسنجی).
  final int successCount;

  /// تعداد کل نمونه‌ها.
  final int totalSamples;

  /// فیلدهای اختصاصی هر تونل.
  ///
  /// مثال:
  ///   • Psiphon: `{'protocol': 'FRONTED-MEEK-OSSH', 'bytesUp': 1234}`
  ///   • Tor: `{'circuitCount': 3, 'guardName': '...'}`
  ///   • SSTP: `{'assignedIp': '10.0.0.5'}`
  final Map<String, dynamic> extra;

  const TunnelHealthReport({
    required this.kind,
    required this.timestamp,
    required this.score,
    required this.latencyMs,
    required this.jitterMs,
    required this.packetLossPct,
    required this.uptime,
    required this.reconnectCount,
    required this.errorCount,
    required this.trend,
    required this.successCount,
    required this.totalSamples,
    this.extra = const {},
  });

  /// آیا این report معتبر است؟
  bool get isValid => totalSamples > 0 && score > 0;

  /// آیا تونل زنده است ولی داده عبور نمی‌کنه؟
  bool get isAliveButNoData =>
      totalSamples > 0 && successCount == 0 && uptime.inSeconds > 10;

  /// سطح کیفیت.
  HealthLevel get level => HealthLevel.fromScore(score);

  /// رنگ پیشنهادی.
  int get colorHex => level.colorHex;

  /// report خالی برای وقتی هنوز داده نداریم.
  static TunnelHealthReport empty(TunnelKind kind) {
    return TunnelHealthReport(
      kind: kind,
      timestamp: DateTime.now(),
      score: 0,
      latencyMs: 0,
      jitterMs: 0,
      packetLossPct: 0,
      uptime: Duration.zero,
      reconnectCount: 0,
      errorCount: 0,
      trend: HealthTrend.stable,
      successCount: 0,
      totalSamples: 0,
    );
  }

  TunnelHealthReport copyWith({
    TunnelKind? kind,
    DateTime? timestamp,
    double? score,
    int? latencyMs,
    int? jitterMs,
    double? packetLossPct,
    Duration? uptime,
    int? reconnectCount,
    int? errorCount,
    HealthTrend? trend,
    int? successCount,
    int? totalSamples,
    Map<String, dynamic>? extra,
  }) {
    return TunnelHealthReport(
      kind: kind ?? this.kind,
      timestamp: timestamp ?? this.timestamp,
      score: score ?? this.score,
      latencyMs: latencyMs ?? this.latencyMs,
      jitterMs: jitterMs ?? this.jitterMs,
      packetLossPct: packetLossPct ?? this.packetLossPct,
      uptime: uptime ?? this.uptime,
      reconnectCount: reconnectCount ?? this.reconnectCount,
      errorCount: errorCount ?? this.errorCount,
      trend: trend ?? this.trend,
      successCount: successCount ?? this.successCount,
      totalSamples: totalSamples ?? this.totalSamples,
      extra: extra ?? this.extra,
    );
  }

  @override
  String toString() => 'TunnelHealthReport(${kind.displayName}, '
      'score=${score.toStringAsFixed(1)}, level=${level.name}, '
      'lat=${latencyMs}ms, jitter=${jitterMs}ms, '
      'loss=${packetLossPct.toStringAsFixed(1)}%, '
      'uptime=${uptime.inMinutes}min, '
      'reconnects=$reconnectCount, trend=${trend.name})';
}
