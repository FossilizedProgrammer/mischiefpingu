import 'package:flutter_test/flutter_test.dart';
import 'package:mischiefpingu/services/database/gateway_score_calculator.dart';

void main() {
  group('GatewayScoreCalculator.compute', () {
    test('perfect gateway gets high score', () {
      final score = GatewayScoreCalculator.compute(
        avgLatencyMs: 50,
        avgJitterMs: 5,
        packetLossPct: 0,
        successCount: 100,
        failureCount: 0,
        lastSuccessAt: DateTime.now(),
        avgSessionUptimeSec: 3600,
        reconnectCount: 0,
        totalAttempts: 100,
      );
      expect(score, greaterThan(80));
      expect(score, lessThanOrEqualTo(100));
    });

    test('dead gateway gets low score (below 40)', () {
      // توجه: latency=0 به معنی «هیچ‌وقت اندازه‌گیری نشده» است و
      // score پایه 22 می‌گیرد. برای همین انتظار < 40 داریم نه < 15.
      final score = GatewayScoreCalculator.compute(
        avgLatencyMs: 0,
        avgJitterMs: 0,
        packetLossPct: 100,
        successCount: 0,
        failureCount: 20,
        lastSuccessAt: DateTime.now().subtract(const Duration(days: 30)),
        avgSessionUptimeSec: 0,
        reconnectCount: 20,
        totalAttempts: 20,
      );
      expect(score, lessThan(40));
    });

    test('high latency gateway gets low score', () {
      // برای تست رفتار latency، باید latency > 0 بدیم
      final score = GatewayScoreCalculator.compute(
        avgLatencyMs: 700,
        avgJitterMs: 200,
        packetLossPct: 100,
        successCount: 0,
        failureCount: 20,
        lastSuccessAt: DateTime.now().subtract(const Duration(days: 30)),
        avgSessionUptimeSec: 0,
        reconnectCount: 20,
        totalAttempts: 20,
      );
      expect(score, lessThan(20));
    });

    test('fresh gateway with no data gets middling score', () {
      final score = GatewayScoreCalculator.compute(
        avgLatencyMs: 0,
        avgJitterMs: 0,
        packetLossPct: 0,
        successCount: 0,
        failureCount: 0,
        lastSuccessAt: null,
      );
      expect(score, greaterThanOrEqualTo(0));
      expect(score, lessThanOrEqualTo(60));
    });

    test('higher latency lowers score', () {
      final fast = GatewayScoreCalculator.compute(
        avgLatencyMs: 50,
        avgJitterMs: 10,
        packetLossPct: 0,
        successCount: 10,
        failureCount: 0,
        lastSuccessAt: DateTime.now(),
      );
      final slow = GatewayScoreCalculator.compute(
        avgLatencyMs: 700,
        avgJitterMs: 10,
        packetLossPct: 0,
        successCount: 10,
        failureCount: 0,
        lastSuccessAt: DateTime.now(),
      );
      expect(fast, greaterThan(slow));
    });

    test('higher packet loss lowers score', () {
      final clean = GatewayScoreCalculator.compute(
        avgLatencyMs: 100,
        avgJitterMs: 10,
        packetLossPct: 0,
        successCount: 10,
        failureCount: 0,
        lastSuccessAt: DateTime.now(),
      );
      final lossy = GatewayScoreCalculator.compute(
        avgLatencyMs: 100,
        avgJitterMs: 10,
        packetLossPct: 20,
        successCount: 10,
        failureCount: 0,
        lastSuccessAt: DateTime.now(),
      );
      expect(clean, greaterThan(lossy));
    });

    test('more reconnects lower score', () {
      final stable = GatewayScoreCalculator.compute(
        avgLatencyMs: 100,
        avgJitterMs: 10,
        packetLossPct: 0,
        successCount: 10,
        failureCount: 0,
        lastSuccessAt: DateTime.now(),
        totalAttempts: 10,
        reconnectCount: 0,
      );
      final flappy = GatewayScoreCalculator.compute(
        avgLatencyMs: 100,
        avgJitterMs: 10,
        packetLossPct: 0,
        successCount: 10,
        failureCount: 0,
        lastSuccessAt: DateTime.now(),
        totalAttempts: 10,
        reconnectCount: 5,
      );
      expect(stable, greaterThan(flappy));
    });

    test('score is always clamped to 0..100', () {
      final huge = GatewayScoreCalculator.compute(
        avgLatencyMs: 0,
        avgJitterMs: 0,
        packetLossPct: 0,
        successCount: 1000000,
        failureCount: 0,
        lastSuccessAt: DateTime.now(),
        avgSessionUptimeSec: 999999999,
        totalAttempts: 1000000,
      );
      expect(huge, lessThanOrEqualTo(100));

      final tiny = GatewayScoreCalculator.compute(
        avgLatencyMs: 99999,
        avgJitterMs: 99999,
        packetLossPct: 999,
        successCount: 0,
        failureCount: 99999,
        lastSuccessAt: DateTime.now().subtract(const Duration(days: 365)),
        totalAttempts: 99999,
        reconnectCount: 99999,
      );
      expect(tiny, greaterThanOrEqualTo(0));
    });
  });

  group('GatewayScoreCalculator.decayFactor', () {
    test('fresh timestamp → ~1.0', () {
      final factor = GatewayScoreCalculator.decayFactor(DateTime.now());
      expect((factor - 1.0).abs(), lessThan(0.01));
    });

    test('halves after 7 days', () {
      final factor = GatewayScoreCalculator.decayFactor(
        DateTime.now().subtract(const Duration(days: 7)),
      );
      expect((factor - 0.5).abs(), lessThan(0.02));
    });

    test('quarters after 14 days', () {
      final factor = GatewayScoreCalculator.decayFactor(
        DateTime.now().subtract(const Duration(days: 14)),
      );
      expect((factor - 0.25).abs(), lessThan(0.02));
    });

    test('future timestamp returns 1.0 (not >1)', () {
      final factor = GatewayScoreCalculator.decayFactor(
        DateTime.now().add(const Duration(days: 3)),
      );
      expect(factor, lessThanOrEqualTo(1.0));
    });
  });
}
