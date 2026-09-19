library;

/// ═══════════════════════════════════════════════════════════════
///  مدل‌های داده‌ای برای Internet Diagnostic Service
/// ═══════════════════════════════════════════════════════════════

/// کیفیت کلی اینترنت.
enum InternetQuality {
  excellent,
  good,
  degraded,
  unstable,
  dead,
  unknown,
}

/// وضعیت یک metric تکی (DNS/TCP/HTTPS/...).
enum MetricStatus {
  ok,
  slow,
  partial,
  failing,
  unknown,
}

/// نتیجه‌ی یک بخش از diagnostic (مثلاً DNS).
class DiagnosticMetric {
  final MetricStatus status;
  final int successCount;
  final int totalCount;
  final int avgLatencyMs;
  final int minLatencyMs;
  final int maxLatencyMs;
  final int medianLatencyMs;
  final int p95LatencyMs;
  final int jitterMs;
  final String message;

  const DiagnosticMetric({
    required this.status,
    required this.successCount,
    required this.totalCount,
    required this.avgLatencyMs,
    required this.minLatencyMs,
    required this.maxLatencyMs,
    required this.medianLatencyMs,
    required this.p95LatencyMs,
    required this.jitterMs,
    this.message = '',
  });

  static const DiagnosticMetric unknown = DiagnosticMetric(
    status: MetricStatus.unknown,
    successCount: 0,
    totalCount: 0,
    avgLatencyMs: 0,
    minLatencyMs: 0,
    maxLatencyMs: 0,
    medianLatencyMs: 0,
    p95LatencyMs: 0,
    jitterMs: 0,
  );

  double get successRate => totalCount == 0 ? 0 : successCount / totalCount;

  bool get isOk => status == MetricStatus.ok;
  bool get isSlow => status == MetricStatus.slow;
  bool get isFailing =>
      status == MetricStatus.failing || status == MetricStatus.partial;
}

/// نتیجه‌ی کامل diagnostic.
class InternetDiagnosticResult {
  final InternetQuality overall;
  final DiagnosticMetric dns;
  final DiagnosticMetric tcp;
  final DiagnosticMetric https;
  final DiagnosticMetric directQuality;
  final DiagnosticMetric tunnelQuality;
  final String probableCause;
  final List<String> evidence;
  final DateTime timestamp;
  final int totalDurationMs;

  const InternetDiagnosticResult({
    required this.overall,
    required this.dns,
    required this.tcp,
    required this.https,
    required this.directQuality,
    required this.tunnelQuality,
    required this.probableCause,
    required this.evidence,
    required this.timestamp,
    required this.totalDurationMs,
  });

  InternetDiagnosticResult copyWith({
    InternetQuality? overall,
    DiagnosticMetric? dns,
    DiagnosticMetric? tcp,
    DiagnosticMetric? https,
    DiagnosticMetric? directQuality,
    DiagnosticMetric? tunnelQuality,
    String? probableCause,
    List<String>? evidence,
    DateTime? timestamp,
    int? totalDurationMs,
  }) {
    return InternetDiagnosticResult(
      overall: overall ?? this.overall,
      dns: dns ?? this.dns,
      tcp: tcp ?? this.tcp,
      https: https ?? this.https,
      directQuality: directQuality ?? this.directQuality,
      tunnelQuality: tunnelQuality ?? this.tunnelQuality,
      probableCause: probableCause ?? this.probableCause,
      evidence: evidence ?? this.evidence,
      timestamp: timestamp ?? this.timestamp,
      totalDurationMs: totalDurationMs ?? this.totalDurationMs,
    );
  }
}

/// یک نمونه‌ی probe تکی.
class ProbeSample {
  final int index;
  final bool success;
  final int latencyMs;
  final String target;
  final DateTime timestamp;

  const ProbeSample({
    required this.index,
    required this.success,
    required this.latencyMs,
    required this.target,
    required this.timestamp,
  });
}

/// سطح مانیتورینگ پس‌زمینه.
enum MonitoringLevel {
  idle,
  light,
  normal,
  deep,
}
