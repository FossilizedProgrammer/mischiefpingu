library;

/// ═══════════════════════════════════════════════════════════════
///  WatchdogQualityMetrics — معیارهای کیفی یک probe.
///
///  این کلاس نتیجه‌ی خام probe را از دید کیفیت توصیف می‌کند.
/// ═══════════════════════════════════════════════════════════════
class WatchdogQualityMetrics {
  /// زمان کل probe (اتصال SOCKS + greeting + CONNECT + HTTP) به ms.
  final int latencyMs;

  /// jitter نسبت به probe قبلی (ms). اگر probe اول باشد = 0.
  final int jitterMs;

  /// آیا اتصال TCP به SOCKS برقرار شد؟
  final bool tcpOk;

  /// آیا SOCKS5 greeting موفق بود؟
  final bool socksGreetingOk;

  /// آیا SOCKS5 CONNECT موفق بود؟
  final bool socksConnectOk;

  /// آیا پاسخ HTTP دریافت شد؟
  final bool httpResponseOk;

  /// آیا پاسخ HTTP status 2xx/3xx داشت؟
  final bool httpStatusOk;

  const WatchdogQualityMetrics({
    required this.latencyMs,
    this.jitterMs = 0,
    this.tcpOk = false,
    this.socksGreetingOk = false,
    this.socksConnectOk = false,
    this.httpResponseOk = false,
    this.httpStatusOk = false,
  });

  /// آیا probe کاملاً موفق بود؟
  bool get isFullyAlive =>
      tcpOk && socksGreetingOk && socksConnectOk && httpStatusOk;

  /// کیفیت کلی probe:
  ///   - excellent: latency < 800ms و کامل موفق
  ///   - good: latency < 1500ms و کامل موفق
  ///   - degraded: latency < highLatencyMs ولی کامل موفق
  ///   - failing: latency ≥ highLatencyMs
  QualityLevel classify({int highLatencyMs = 3000}) {
    if (!isFullyAlive) return QualityLevel.failing;
    if (latencyMs >= highLatencyMs) return QualityLevel.failing;
    if (latencyMs >= 1500) return QualityLevel.degraded;
    if (latencyMs >= 800) return QualityLevel.good;
    return QualityLevel.excellent;
  }

  @override
  String toString() =>
      'QualityMetrics(lat=${latencyMs}ms, jitter=${jitterMs}ms, '
      'tcp=$tcpOk, greet=$socksGreetingOk, connect=$socksConnectOk, '
      'resp=$httpResponseOk, status=$httpStatusOk)';
}

/// سطح کیفیت probe.
enum QualityLevel { excellent, good, degraded, failing }
