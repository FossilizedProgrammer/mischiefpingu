library;

/// ═══════════════════════════════════════════════════════════════
///  TunnelProbeResult — نتیجه یک probe دستی روی SOCKS یک تونل.
///
///  این مدل برای دکمه «تست مجدد» استفاده می‌شه. جدا از مدل
///  TunnelHealthReport هست چون این یکی فقط نتیجه یک probe
///  لحظه‌ای رو نشون می‌ده، نه health کل تونل.
/// ═══════════════════════════════════════════════════════════════
class TunnelProbeResult {
  /// آیا probe موفق بود؟
  final bool success;

  /// latency به میلی‌ثانیه (فقط اگه موفق بود).
  final int latencyMs;

  /// پیام خطا (اگه موفق نبود).
  final String? error;

  /// زمان اجرای probe.
  final DateTime timestamp;

  const TunnelProbeResult({
    required this.success,
    required this.latencyMs,
    this.error,
    required this.timestamp,
  });

  factory TunnelProbeResult.success({required int latencyMs}) =>
      TunnelProbeResult(
        success: true,
        latencyMs: latencyMs,
        timestamp: DateTime.now(),
      );

  factory TunnelProbeResult.failure({required String error}) =>
      TunnelProbeResult(
        success: false,
        latencyMs: 0,
        error: error,
        timestamp: DateTime.now(),
      );

  @override
  String toString() => success
      ? 'TunnelProbeResult.success(${latencyMs}ms)'
      : 'TunnelProbeResult.failure($error)';
}
