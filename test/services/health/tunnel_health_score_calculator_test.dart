import 'package:flutter_test/flutter_test.dart';
import 'package:mischiefpingu/services/health/tunnel_health_models.dart';
import 'package:mischiefpingu/services/health/tunnel_health_score_calculator.dart';

void main() {
  group('TunnelHealthScoreCalculator.compute', () {
    test('perfect health → high score', () {
      final score = TunnelHealthScoreCalculator.compute(
        latencyMs: 50,
        jitterMs: 5,
        packetLossPct: 0,
        successCount: 100,
        totalSamples: 100,
        uptime: const Duration(hours: 2),
        reconnectCount: 0,
        errorCount: 0,
      );
      expect(score, greaterThan(90));
    });

    test('dead tunnel → low score', () {
      final score = TunnelHealthScoreCalculator.compute(
        latencyMs: 5000,
        jitterMs: 500,
        packetLossPct: 100,
        successCount: 0,
        totalSamples: 10,
        uptime: Duration.zero,
        reconnectCount: 10,
        errorCount: 10,
      );
      expect(score, lessThan(20));
    });

    test('no samples → middling score (neutral)', () {
      final score = TunnelHealthScoreCalculator.compute(
        latencyMs: 0,
        jitterMs: 0,
        packetLossPct: 0,
        successCount: 0,
        totalSamples: 0,
        uptime: const Duration(minutes: 1),
      );
      // با totalSamples=0، successRate = 50
      // latency=0 → 100، jitter=0 → 100
      // در نتیجه score خیلی بالا نمی‌شه ولی بالا هست
      expect(score, greaterThanOrEqualTo(40));
      expect(score, lessThanOrEqualTo(100));
    });

    test('longer uptime raises score', () {
      final short = TunnelHealthScoreCalculator.compute(
        latencyMs: 100,
        jitterMs: 10,
        packetLossPct: 0,
        successCount: 10,
        totalSamples: 10,
        uptime: const Duration(seconds: 5),
      );
      final long = TunnelHealthScoreCalculator.compute(
        latencyMs: 100,
        jitterMs: 10,
        packetLossPct: 0,
        successCount: 10,
        totalSamples: 10,
        uptime: const Duration(hours: 1),
      );
      expect(long, greaterThan(short));
    });

    test('reconnects lower score', () {
      final stable = TunnelHealthScoreCalculator.compute(
        latencyMs: 100,
        jitterMs: 10,
        packetLossPct: 0,
        successCount: 10,
        totalSamples: 10,
        uptime: const Duration(minutes: 10),
        reconnectCount: 0,
      );
      final flappy = TunnelHealthScoreCalculator.compute(
        latencyMs: 100,
        jitterMs: 10,
        packetLossPct: 0,
        successCount: 10,
        totalSamples: 10,
        uptime: const Duration(minutes: 10),
        reconnectCount: 5,
      );
      expect(stable, greaterThan(flappy));
    });

    test('score clamped to 0..100', () {
      final extreme = TunnelHealthScoreCalculator.compute(
        latencyMs: -1,
        jitterMs: -1,
        packetLossPct: -1,
        successCount: 999999,
        totalSamples: 999999,
        uptime: const Duration(days: 365),
      );
      expect(extreme, lessThanOrEqualTo(100));
      expect(extreme, greaterThanOrEqualTo(0));
    });
  });

  group('TunnelHealthScoreCalculator.computeTrend', () {
    TunnelHealthReport makeReport(double score, {int? minutesAgo}) {
      return TunnelHealthReport(
        kind: TunnelKind.aether,
        timestamp: DateTime.now().subtract(Duration(minutes: minutesAgo ?? 0)),
        score: score,
        latencyMs: 100,
        jitterMs: 10,
        packetLossPct: 0,
        uptime: const Duration(minutes: 10),
        reconnectCount: 0,
        errorCount: 0,
        trend: HealthTrend.stable,
        successCount: 10,
        totalSamples: 10,
      );
    }

    test('less than 3 reports → stable', () {
      expect(
        TunnelHealthScoreCalculator.computeTrend([
          makeReport(50),
          makeReport(60),
        ]),
        HealthTrend.stable,
      );
    });

    test('rising scores → improving', () {
      expect(
        TunnelHealthScoreCalculator.computeTrend([
          makeReport(40, minutesAgo: 3),
          makeReport(50, minutesAgo: 2),
          makeReport(70, minutesAgo: 1),
        ]),
        HealthTrend.improving,
      );
    });

    test('falling scores → degrading', () {
      expect(
        TunnelHealthScoreCalculator.computeTrend([
          makeReport(80, minutesAgo: 3),
          makeReport(60, minutesAgo: 2),
          makeReport(40, minutesAgo: 1),
        ]),
        HealthTrend.degrading,
      );
    });

    test('flat scores → stable', () {
      expect(
        TunnelHealthScoreCalculator.computeTrend([
          makeReport(50, minutesAgo: 3),
          makeReport(51, minutesAgo: 2),
          makeReport(50, minutesAgo: 1),
        ]),
        HealthTrend.stable,
      );
    });
  });
}
