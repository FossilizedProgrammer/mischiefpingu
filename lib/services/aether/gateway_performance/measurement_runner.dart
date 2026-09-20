part of '../gateway_performance_tracker.dart';

/// ═══════════════════════════════════════════════════════════════
///  منطق اندازه‌گیری عملکرد.
/// ═══════════════════════════════════════════════════════════════
extension GatewayPerformanceTrackerMeasurement on GatewayPerformanceTracker {
  Future<void> runMeasurement({
    required int generation,
    required int socksPort,
    required String uniqueKey,
    required String ip,
    required int port,
    required String protocol,
    required String masqueOption,
    required String sni,
    required String endpoint,
    required String networkType,
    required String networkName,
    required int sampleCount,
    required Duration interval,
    required Duration probeTimeout,
  }) async {
    final startedAt = DateTime.now();
    log(
      '→ Performance tracker: starting $sampleCount probes '
      '(${interval.inMilliseconds}ms interval) for $uniqueKey',
      source: LogSource.aether,
    );

    final samples = <PerformanceSample>[];
    var successCount = 0;

    for (var i = 0; i < sampleCount; i++) {
      if (cancelRequested || generation != currentGeneration) {
        log(
          '→ Performance tracker: cancelled at sample #$i',
          source: LogSource.aether,
        );
        break;
      }

      final result = await prober.probe(
        socksPort,
        targetIndex: i,
        timeout: probeTimeout,
      );

      if (cancelRequested || generation != currentGeneration) {
        break;
      }

      if (result.success) successCount++;

      samples.add(
        PerformanceSample(
          index: i,
          success: result.success,
          latencyMs: result.latencyMs,
          timestamp: DateTime.now(),
          target: result.target,
          errorMessage: result.error,
        ),
      );

      if (result.success) {
        log(
          '→ Perf sample #$i: OK (${result.latencyMs}ms) '
          '[${result.target}]',
          source: LogSource.aether,
        );
      } else {
        log(
          '→ Perf sample #$i: FAIL (${result.error ?? "unknown"})',
          source: LogSource.aether,
        );
      }

      if (i < sampleCount - 1 && !cancelRequested) {
        await Future.delayed(interval);
      }
    }

    final finishedAt = DateTime.now();

    if (samples.isEmpty) {
      log(
        '→ Performance tracker: no samples collected — aborting',
        source: LogSource.aether,
      );
      return;
    }

    final report = PerformanceReportCalculator.compute(
      samples: samples,
      startedAt: startedAt,
      finishedAt: finishedAt,
    );

    setLastReport(report);
    setLastMeasuredKey(uniqueKey);

    log(
      '★ Performance tracker done: '
      'success=$successCount/${samples.length}, '
      'loss=${report.packetLossPct.toStringAsFixed(1)}%, '
      'avg=${report.avgLatencyMs}ms, jitter=${report.jitterMs}ms, '
      'duration=${report.duration.inSeconds}s',
      source: LogSource.aether,
    );

    _safeNotifyReport(report);

    try {
      await store.recordPerformance(
        ip: ip,
        port: port,
        protocol: protocol,
        masqueOption: masqueOption,
        sni: sni,
        jitterMs: report.jitterMs,
        packetLossPct: report.packetLossPct,
      );
      if (report.successCount > 0 && report.avgLatencyMs > 0) {
        await store.recordSuccess(
          ip: ip,
          port: port,
          protocol: protocol,
          masqueOption: masqueOption,
          sni: sni,
          endpoint: endpoint,
          latencyMs: report.avgLatencyMs,
          networkType: networkType,
          networkName: networkName,
        );
      } else {
        await store.recordFailure(
          ip: ip,
          port: port,
          protocol: protocol,
          masqueOption: masqueOption,
          sni: sni,
        );
      }
    } catch (e) {
      log(
        '⚠ Performance tracker: failed to persist report: $e',
        source: LogSource.aether,
      );
    }
  }

  void _safeNotifyReport(PerformanceReport report) {
    final cb = onReport;
    if (cb == null) return;
    try {
      cb(report);
    } catch (e) {
      log(
        '⚠ Performance tracker: onReport callback threw: $e',
        source: LogSource.aether,
      );
    }
  }
}
