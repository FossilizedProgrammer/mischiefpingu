library;

/// ═══════════════════════════════════════════════════════════════
///  PerformanceSample — یک نمونه اندازه‌گیری عملکرد.
///
///  هر نمونه شامل latency، موفقیت/شکست و هدف probe است.
///  نتیجه‌ی کل (packetLoss, jitter, avgLatency) از روی این
///  نمونه‌ها محاسبه می‌شود.
/// ═══════════════════════════════════════════════════════════════
class PerformanceSample {
  /// ایندکس نمونه (0..N-1).
  final int index;

  /// آیا این probe موفق بود؟
  final bool success;

  /// latency بر حسب میلی‌ثانیه. اگر شکست خورده باشد، مقدار نامعتبر است.
  final int latencyMs;

  /// زمان دقیق اندازه‌گیری.
  final DateTime timestamp;

  /// آدرس هدف probe (مثل `1.1.1.1:443`).
  final String target;

  /// پیام خطا در صورت شکست (اختیاری).
  final String? errorMessage;

  const PerformanceSample({
    required this.index,
    required this.success,
    required this.latencyMs,
    required this.timestamp,
    required this.target,
    this.errorMessage,
  });

  @override
  String toString() =>
      'PerformanceSample(#$index, success=$success, ${latencyMs}ms, $target)';
}

/// ═══════════════════════════════════════════════════════════════
///  PerformanceReport — نتیجه‌ی نهایی محاسبه‌شده از نمونه‌ها.
///
///  این ساختار مستقیماً به GatewayHistoryStore پاس داده می‌شود.
/// ═══════════════════════════════════════════════════════════════
class PerformanceReport {
  /// تعداد کل نمونه‌ها.
  final int totalSamples;

  /// تعداد نمونه‌های موفق.
  final int successCount;

  /// درصد افت بسته (0..100).
  final double packetLossPct;

  /// میانگین latency نمونه‌های موفق (ms). اگر موفقیت صفر باشد = 0.
  final int avgLatencyMs;

  /// انحراف معیار latency (ms). اگر موفقیت کمتر از 2 باشد = 0.
  final int jitterMs;

  /// کمترین latency موفق.
  final int minLatencyMs;

  /// بیشترین latency موفق.
  final int maxLatencyMs;

  /// زمان شروع اندازه‌گیری.
  final DateTime startedAt;

  /// زمان پایان اندازه‌گیری.
  final DateTime finishedAt;

  /// آیا report معتبر است؟ (حداقل یک نمونه موفق)
  bool get isValid => successCount > 0;

  /// مدت زمان کل اندازه‌گیری.
  Duration get duration => finishedAt.difference(startedAt);

  const PerformanceReport({
    required this.totalSamples,
    required this.successCount,
    required this.packetLossPct,
    required this.avgLatencyMs,
    required this.jitterMs,
    required this.minLatencyMs,
    required this.maxLatencyMs,
    required this.startedAt,
    required this.finishedAt,
  });

  /// Report خالی (برای cancel).
  static PerformanceReport empty() {
    final now = DateTime.now();
    return PerformanceReport(
      totalSamples: 0,
      successCount: 0,
      packetLossPct: 0,
      avgLatencyMs: 0,
      jitterMs: 0,
      minLatencyMs: 0,
      maxLatencyMs: 0,
      startedAt: now,
      finishedAt: now,
    );
  }

  @override
  String toString() =>
      'PerformanceReport(samples=$totalSamples, success=$successCount, '
      'loss=${packetLossPct.toStringAsFixed(1)}%, '
      'avg=${avgLatencyMs}ms, jitter=${jitterMs}ms, '
      'min=${minLatencyMs}ms, max=${maxLatencyMs}ms, '
      'duration=${duration.inSeconds}s)';
}

/// ═══════════════════════════════════════════════════════════════
///  محاسبه‌گر report از روی نمونه‌ها.
///
///  فرمول‌ها:
///    - packetLossPct = (totalSamples - successCount) / totalSamples * 100
///    - avgLatencyMs = میانگین ساده‌ی نمونه‌های موفق
///    - jitterMs = انحراف معیار نمونه‌های موفق
/// ═══════════════════════════════════════════════════════════════
class PerformanceReportCalculator {
  PerformanceReportCalculator._();

  static PerformanceReport compute({
    required List<PerformanceSample> samples,
    required DateTime startedAt,
    required DateTime finishedAt,
  }) {
    if (samples.isEmpty) {
      return PerformanceReport(
        totalSamples: 0,
        successCount: 0,
        packetLossPct: 100.0,
        avgLatencyMs: 0,
        jitterMs: 0,
        minLatencyMs: 0,
        maxLatencyMs: 0,
        startedAt: startedAt,
        finishedAt: finishedAt,
      );
    }

    final successful = samples.where((s) => s.success).toList();
    final successCount = successful.length;
    final total = samples.length;
    final lossPct = (total - successCount) / total * 100.0;

    if (successCount == 0) {
      return PerformanceReport(
        totalSamples: total,
        successCount: 0,
        packetLossPct: 100.0,
        avgLatencyMs: 0,
        jitterMs: 0,
        minLatencyMs: 0,
        maxLatencyMs: 0,
        startedAt: startedAt,
        finishedAt: finishedAt,
      );
    }

    final lats = successful.map((s) => s.latencyMs).toList()..sort();
    final sum = lats.fold<int>(0, (a, b) => a + b);
    final avg = (sum / lats.length).round();
    final minL = lats.first;
    final maxL = lats.last;

    int jitter = 0;
    if (lats.length >= 2) {
      final variance =
          lats.map((l) => (l - avg) * (l - avg)).fold<int>(0, (a, b) => a + b) /
              lats.length;
      jitter = _sqrt(variance.round());
    }

    return PerformanceReport(
      totalSamples: total,
      successCount: successCount,
      packetLossPct: lossPct,
      avgLatencyMs: avg,
      jitterMs: jitter,
      minLatencyMs: minL,
      maxLatencyMs: maxL,
      startedAt: startedAt,
      finishedAt: finishedAt,
    );
  }

  /// جذر مربع بدون import ریاضی (برای سادگی).
  static int _sqrt(int n) {
    if (n <= 0) return 0;
    var x = n;
    var y = (x + 1) ~/ 2;
    while (y < x) {
      x = y;
      y = (x + n ~/ x) ~/ 2;
    }
    return x;
  }
}
