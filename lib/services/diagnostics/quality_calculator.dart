library;

import 'dart:math' as math;

import 'diagnostic_models.dart';

/// ═══════════════════════════════════════════════════════════════
///  محاسبه‌ی quality از روی samples
/// ═══════════════════════════════════════════════════════════════

class QualityCalculator {
  QualityCalculator._();

  /// محاسبه‌ی metric از روی لیست نمونه‌ها.
  static DiagnosticMetric compute({
    required List<ProbeSample> samples,
    required String message,
  }) {
    if (samples.isEmpty) {
      return DiagnosticMetric.unknown;
    }

    final total = samples.length;
    final successful = samples.where((s) => s.success).toList();
    final successCount = successful.length;

    if (successCount == 0) {
      return DiagnosticMetric(
        status: MetricStatus.failing,
        successCount: 0,
        totalCount: total,
        avgLatencyMs: 0,
        minLatencyMs: 0,
        maxLatencyMs: 0,
        medianLatencyMs: 0,
        p95LatencyMs: 0,
        jitterMs: 0,
        message: message.isEmpty ? 'all probes failed' : message,
      );
    }

    final lats = successful.map((s) => s.latencyMs).toList()..sort();
    final sum = lats.fold<int>(0, (a, b) => a + b);
    final avg = (sum / lats.length).round();
    final minL = lats.first;
    final maxL = lats.last;
    final median = lats[lats.length ~/ 2];
    final p95 = lats[(lats.length * 0.95).floor().clamp(0, lats.length - 1)];

    final variance =
        lats.map((l) => math.pow(l - avg, 2)).fold<double>(0, (a, b) => a + b) /
        lats.length;
    final jitter = math.sqrt(variance).round();

    MetricStatus status;
    final successRate = successCount / total;
    if (successRate >= 0.95 && avg < 300 && jitter < 100) {
      status = MetricStatus.ok;
    } else if (successRate >= 0.7) {
      status = MetricStatus.slow;
    } else if (successRate > 0) {
      status = MetricStatus.partial;
    } else {
      status = MetricStatus.failing;
    }

    return DiagnosticMetric(
      status: status,
      successCount: successCount,
      totalCount: total,
      avgLatencyMs: avg,
      minLatencyMs: minL,
      maxLatencyMs: maxL,
      medianLatencyMs: median,
      p95LatencyMs: p95,
      jitterMs: jitter,
      message: message,
    );
  }

  /// کیفیت کلی از روی metric‌های مختلف.
  static InternetQuality classify(InternetDiagnosticResult r) {
    if (r.dns.status == MetricStatus.failing &&
        r.tcp.status == MetricStatus.failing) {
      return InternetQuality.dead;
    }

    if (r.dns.status == MetricStatus.ok &&
        r.tcp.status == MetricStatus.failing) {
      return InternetQuality.degraded;
    }

    if (r.tcp.status == MetricStatus.failing) {
      return InternetQuality.dead;
    }

    if (r.https.status == MetricStatus.failing &&
        r.tcp.status == MetricStatus.ok) {
      return InternetQuality.degraded;
    }

    final q = r.directQuality;
    if (q.status == MetricStatus.ok) {
      return InternetQuality.excellent;
    }
    if (q.status == MetricStatus.slow) {
      return InternetQuality.good;
    }
    if (q.status == MetricStatus.partial) {
      return InternetQuality.unstable;
    }
    if (q.status == MetricStatus.failing) {
      return InternetQuality.degraded;
    }

    return InternetQuality.unknown;
  }
}
