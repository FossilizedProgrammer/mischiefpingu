library;

import 'dart:math' as math;

import 'tunnel_health_models.dart';

/// ═══════════════════════════════════════════════════════════════
///  TunnelHealthScoreCalculator — محاسبه امتیاز سلامت (0..100).
///
///  این نسخه از GatewayScoreCalculator الهام گرفته ولی:
///    • برای همهٔ تونل‌ها کار می‌کنه (نه فقط Aether)
///    • فرمول عمومی‌تر و قابل تنظیمه
///
///  امتیاز ترکیبی از ۷ مؤلفه:
///    • latency            → 25%
///    • jitter             → 15%
///    • success rate       → 25%
///    • packet loss        → 15%
///    • uptime stability   → 10%
///    • reconnect penalty  →  5%
///    • error penalty      →  5%
///
///  هر مؤلفه یک score بین 0..100 تولید می‌کنه، بعد با وزن خودش
///  ضرب و جمع می‌شه. نتیجهٔ نهایی بین 0..100 clamp می‌شه.
/// ═══════════════════════════════════════════════════════════════
class TunnelHealthScoreCalculator {
  TunnelHealthScoreCalculator._();

  // ═══════════════════════════════════════════════════════════════
  //  وزن‌ها — مجموع = 1.0
  // ═══════════════════════════════════════════════════════════════
  static const double weightLatency = 0.25;
  static const double weightJitter = 0.15;
  static const double weightSuccessRate = 0.25;
  static const double weightPacketLoss = 0.15;
  static const double weightUptime = 0.10;
  static const double weightReconnect = 0.05;
  static const double weightError = 0.05;

  /// محاسبهٔ امتیاز نهایی.
  ///
  /// همهٔ ورودی‌ها اختیاری هستن — مقادیر پیش‌فرض محافظه‌کارانه‌ان.
  static double compute({
    required int latencyMs,
    required int jitterMs,
    required double packetLossPct,
    required int successCount,
    required int totalSamples,
    required Duration uptime,
    int reconnectCount = 0,
    int errorCount = 0,
  }) {
    final latencyScore = _latencyScore(latencyMs);
    final jitterScore = _jitterScore(jitterMs);
    final successScore = _successRateScore(successCount, totalSamples);
    final lossScore = _packetLossScore(packetLossPct);
    final uptimeScore = _uptimeScore(uptime);
    final reconnectScore = _reconnectScore(reconnectCount, totalSamples);
    final errorScore = _errorScore(errorCount, totalSamples);

    final total =
        latencyScore * weightLatency +
        jitterScore * weightJitter +
        successScore * weightSuccessRate +
        lossScore * weightPacketLoss +
        uptimeScore * weightUptime +
        reconnectScore * weightReconnect +
        errorScore * weightError;

    return double.parse(total.clamp(0.0, 100.0).toStringAsFixed(2));
  }

  // ═══════════════════════════════════════════════════════════════
  //  مؤلفه‌ها
  // ═══════════════════════════════════════════════════════════════

  /// latency: 100ms → 100، 1500ms → 0. خطی.
  static double _latencyScore(int ms) {
    if (ms <= 100) return 100.0;
    if (ms >= 1500) return 0.0;
    return 100.0 * (1.0 - (ms - 100) / 1400.0);
  }

  /// jitter: 20ms → 100، 300ms → 0. خطی.
  static double _jitterScore(int ms) {
    if (ms <= 20) return 100.0;
    if (ms >= 300) return 0.0;
    return 100.0 * (1.0 - (ms - 20) / 280.0);
  }

  /// نرخ موفقیت با Laplace smoothing.
  ///
  /// اگر نمونه‌ای نباشه، 50 برمی‌گردونه (ناشناخته = محافظه‌کارانه).
  static double _successRateScore(int success, int total) {
    if (total <= 0) return 50.0;
    final rate = success / total;
    final smoothed = (success + 1) / (total + 2);
    return ((rate + smoothed) / 2.0) * 100.0;
  }

  /// packet loss: 0% → 100، 30% → 0. خطی.
  static double _packetLossScore(double pct) {
    if (pct <= 0) return 100.0;
    if (pct >= 30.0) return 0.0;
    return 100.0 * (1.0 - pct / 30.0);
  }

  /// uptime: 0s → 0، 30min → 100. لگاریتمی با گرم‌کردن.
  ///
  ///    • 0-30s:      خطی از 0 به 20
  ///    • 30s-30min:  لگاریتمی از 20 به 100
  ///    • ≥ 30min:    100
  static double _uptimeScore(Duration uptime) {
    final s = uptime.inSeconds;
    if (s <= 0) return 0.0;
    if (s >= 1800) return 100.0;
    if (s < 30) return (s / 30.0) * 20.0;

    final logMin = math.log(s / 30.0);
    final logMax = math.log(1800.0 / 30.0);
    final normalized = (logMin / logMax).clamp(0.0, 1.0);
    return 20.0 + normalized * 80.0;
  }

  /// reconnect penalty: هرچه reconnect بیشتر، امتیاز کمتر.
  ///
  /// نسبت reconnect به total sample:
  ///    • 0.0  → 100
  ///    • 0.5+ → 0
  static double _reconnectScore(int reconnectCount, int totalSamples) {
    if (totalSamples <= 0) return 50.0;
    if (reconnectCount <= 0) return 100.0;
    final rate = reconnectCount / totalSamples;
    if (rate >= 0.5) return 0.0;
    return (1.0 - rate * 2.0).clamp(0.0, 1.0) * 100.0;
  }

  /// error penalty: هرچه error بیشتر، امتیاز کمتر.
  static double _errorScore(int errorCount, int totalSamples) {
    if (totalSamples <= 0) return 100.0;
    if (errorCount <= 0) return 100.0;
    final rate = errorCount / totalSamples;
    if (rate >= 0.3) return 0.0;
    return (1.0 - rate * 3.33).clamp(0.0, 1.0) * 100.0;
  }

  /// تشخیص trend از روی چند report اخیر.
  ///
  /// اگر score نهایی در 3 report اخیر بیش از 5 واحد بالا رفته باشه
  /// → improving
  /// اگر بیش از 5 واحد پایین رفته باشه → degrading
  /// در غیر این صورت → stable
  static HealthTrend computeTrend(List<TunnelHealthReport> recent) {
    if (recent.length < 3) return HealthTrend.stable;
    final last3 = recent.sublist(recent.length - 3);
    final first = last3.first.score;
    final last = last3.last.score;
    final delta = last - first;
    if (delta > 5) return HealthTrend.improving;
    if (delta < -5) return HealthTrend.degrading;
    return HealthTrend.stable;
  }
}
