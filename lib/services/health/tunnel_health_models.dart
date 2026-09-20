library;

import 'package:meta/meta.dart';

/// ═══════════════════════════════════════════════════════════════
///  TunnelKind — نوع تونل.
/// ═══════════════════════════════════════════════════════════════
enum TunnelKind {
  psiphon,
  aether,
  tor,
  sstp;

  String get displayName {
    switch (this) {
      case TunnelKind.psiphon:
        return 'Psiphon';
      case TunnelKind.aether:
        return 'Aether';
      case TunnelKind.tor:
        return 'Tor';
      case TunnelKind.sstp:
        return 'SSTP';
    }
  }

  String get id => name;
}

/// ═══════════════════════════════════════════════════════════════
///  HealthTrend — روند کیفیت.
/// ═══════════════════════════════════════════════════════════════
enum HealthTrend {
  improving,
  stable,
  degrading;

  String get label {
    switch (this) {
      case HealthTrend.improving:
        return '↑ improving';
      case HealthTrend.stable:
        return '→ stable';
      case HealthTrend.degrading:
        return '↓ degrading';
    }
  }
}

/// ═══════════════════════════════════════════════════════════════
///  HealthLevel — سطح کیفیت.
/// ═══════════════════════════════════════════════════════════════
enum HealthLevel {
  excellent, // >= 80
  good, // >= 60
  fair, // >= 40
  degraded, // >= 20
  failing; // < 20

  static HealthLevel fromScore(double score) {
    if (score >= 80) return HealthLevel.excellent;
    if (score >= 60) return HealthLevel.good;
    if (score >= 40) return HealthLevel.fair;
    if (score >= 20) return HealthLevel.degraded;
    return HealthLevel.failing;
  }

  int get colorHex {
    switch (this) {
      case HealthLevel.excellent:
        return 0xFF10B981;
      case HealthLevel.good:
        return 0xFF22C55E;
      case HealthLevel.fair:
        return 0xFFF59E0B;
      case HealthLevel.degraded:
        return 0xFFF97316;
      case HealthLevel.failing:
        return 0xFFEF4444;
    }
  }
}

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
  ///
  /// reportهایی که هیچ نمونه‌ای ندارن یا score=0 دارن، معتبر نیستن.
  bool get isValid => totalSamples > 0 && score > 0;

  /// آیا تونل زنده است ولی داده عبور نمی‌کنه؟
  ///
  /// این حالت وقتی رخ می‌ده که SOCKS/port باز است ولی probeها fail می‌شن.
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

/// ═══════════════════════════════════════════════════════════════
///  HealthSnapshot — مجموعه‌ای از reportهای همهٔ تونل‌ها.
///
///  برای UI مشترک استفاده می‌شه.
/// ═══════════════════════════════════════════════════════════════
class HealthSnapshot {
  final Map<TunnelKind, TunnelHealthReport> reports;
  final DateTime timestamp;

  const HealthSnapshot({
    required this.reports,
    required this.timestamp,
  });

  TunnelHealthReport? forTunnel(TunnelKind kind) => reports[kind];

  bool get hasAnyValid => reports.values.any((r) => r.isValid);

  int get healthyCount => reports.values
      .where((r) => r.isValid && r.level.index <= HealthLevel.good.index)
      .length;

  @override
  String toString() => 'HealthSnapshot(${reports.length} tunnels, '
      'healthy=$healthyCount, timestamp=$timestamp)';
}
