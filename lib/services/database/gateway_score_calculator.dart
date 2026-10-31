// lib/services/database/gateway_score_calculator.dart

library;

import 'dart:math' as math;

/// ═══════════════════════════════════════════════════════════════
///  GatewayScoreCalculator — محاسبه امتیاز Gateway (0..100).
///
///  ⚠️ تغییرات این نسخه:
///    • وزن‌ها متعادل‌تر شدن — تمرکز بیشتر روی عملکرد واقعی
///    • session stability وزن بیشتری گرفته
///    • consistency وزن کمتری گرفته (چون ممکنه گمراه‌کننده باشه)
/// ═══════════════════════════════════════════════════════════════
class GatewayScoreCalculator {
  GatewayScoreCalculator._();

  static const double weightLatency = 0.20;
  static const double weightJitter = 0.08;
  static const double weightSuccessRate = 0.22;
  static const double weightPacketLoss = 0.12;
  static const double weightRecency = 0.10;
  static const double weightStability = 0.15;
  static const double weightReconnect = 0.08;
  static const double weightConsistency = 0.05;

  static double compute({
    required int avgLatencyMs,
    required int avgJitterMs,
    required double packetLossPct,
    required int successCount,
    required int failureCount,
    required DateTime? lastSuccessAt,
    int avgSessionUptimeSec = 0,
    int reconnectCount = 0,
    int totalAttempts = 0,
    List<DateTime>? recentSuccesses,
  }) {
    final latencyScore = _latencyScore(avgLatencyMs);
    final jitterScore = _jitterScore(avgJitterMs);
    final successScore = _successRateScore(successCount, failureCount);
    final lossScore = _packetLossScore(packetLossPct);
    final recencyScore = _recencyScore(lastSuccessAt);
    final stabilityScore = _stabilityScore(avgSessionUptimeSec);
    final reconnectScore = _reconnectScore(reconnectCount, totalAttempts);
    final consistencyScore = _consistencyScore(recentSuccesses);

    final total = latencyScore * weightLatency +
        jitterScore * weightJitter +
        successScore * weightSuccessRate +
        lossScore * weightPacketLoss +
        recencyScore * weightRecency +
        stabilityScore * weightStability +
        reconnectScore * weightReconnect +
        consistencyScore * weightConsistency;

    return double.parse(total.clamp(0.0, 100.0).toStringAsFixed(2));
  }

  static double _latencyScore(int ms) {
    if (ms <= 0) return 100.0;
    if (ms >= 800) return 0.0;
    return 100.0 * (1.0 - ms / 800.0);
  }

  static double _jitterScore(int ms) {
    if (ms <= 0) return 100.0;
    if (ms >= 300) return 0.0;
    return 100.0 * (1.0 - ms / 300.0);
  }

  static double _successRateScore(int success, int failure) {
    final total = success + failure;
    if (total == 0) return 50.0;
    final rate = success / total;
    final smoothed = (success + 1) / (total + 2);
    return ((rate + smoothed) / 2.0) * 100.0;
  }

  static double _packetLossScore(double pct) {
    if (pct <= 0) return 100.0;
    if (pct >= 30.0) return 0.0;
    return 100.0 * (1.0 - pct / 30.0);
  }

  static double _recencyScore(DateTime? lastSuccessAt) {
    if (lastSuccessAt == null) return 0.0;
    final age = DateTime.now().difference(lastSuccessAt);
    if (age.isNegative) return 100.0;
    final ageMin = age.inSeconds / 60.0;
    if (ageMin <= 5) return 100.0;
    if (ageMin >= 1440) return 0.0;

    final logMin = math.log(ageMin / 5.0);
    final logMax = math.log(1440.0 / 5.0);
    final normalized = (logMin / logMax).clamp(0.0, 1.0);
    return 100.0 * (1.0 - normalized);
  }

  static double _stabilityScore(int uptimeSec) {
    if (uptimeSec <= 0) return 0.0;
    if (uptimeSec >= 1800) return 100.0;
    if (uptimeSec < 30) return (uptimeSec / 30.0) * 20.0;

    final logMin = math.log(uptimeSec / 30.0);
    final logMax = math.log(1800.0 / 30.0);
    final normalized = (logMin / logMax).clamp(0.0, 1.0);
    return 20.0 + normalized * 80.0;
  }

  static double _reconnectScore(int reconnectCount, int totalAttempts) {
    if (totalAttempts == 0) return 50.0;
    final rate = reconnectCount / totalAttempts;
    if (rate >= 0.5) return 0.0;
    return (1.0 - rate * 2.0).clamp(0.0, 1.0) * 100.0;
  }

  static double _consistencyScore(List<DateTime>? recentSuccesses) {
    if (recentSuccesses == null || recentSuccesses.isEmpty) return 0.0;
    final now = DateTime.now();
    final last24h =
        recentSuccesses.where((t) => now.difference(t).inHours < 24).length;
    if (last24h >= 5) return 100.0;
    return (last24h / 5.0) * 100.0;
  }

  static double decayFactor(DateTime timestamp) {
    final ageDays = DateTime.now().difference(timestamp).inDays;
    if (ageDays <= 0) return 1.0;
    return math.pow(0.5, ageDays / 7.0).toDouble();
  }
}
