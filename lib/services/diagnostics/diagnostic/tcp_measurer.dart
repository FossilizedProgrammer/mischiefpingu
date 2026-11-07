library;

import 'dart:io';

import '../diagnostic_models.dart';
import '../quality_calculator.dart';
import 'diagnostic_config.dart';

class TcpMeasurer {
  final void Function(String message)? log;

  const TcpMeasurer({this.log});

  Future<DiagnosticMetric> measure() async {
    log?.call(
      '→ TCP: probing ${DiagnosticConfig.tcpTargets.length} targets '
      '× ${DiagnosticConfig.samplesPerMetric} samples',
    );

    final samples = <ProbeSample>[];
    var idx = 0;

    for (var round = 0; round < DiagnosticConfig.samplesPerMetric; round++) {
      for (final target in DiagnosticConfig.tcpTargets) {
        final r = await probeOne(target.ip, target.port);
        samples.add(
          ProbeSample(
            index: idx++,
            success: r.success,
            latencyMs: r.latencyMs,
            target: '${target.ip}:${target.port}',
            timestamp: DateTime.now(),
          ),
        );
        await Future.delayed(DiagnosticConfig.sampleInterval);
      }
    }

    final metric = QualityCalculator.compute(
      samples: samples,
      message: 'TCP connectivity',
    );
    log?.call(
      '→ TCP: ${metric.successCount}/${metric.totalCount} ok, '
      'avg=${metric.avgLatencyMs}ms, jitter=${metric.jitterMs}ms',
    );
    return metric;
  }

  /// فقط TCP connectivity — سریع.
  Future<bool> isAlive() async {
    for (final target in DiagnosticConfig.tcpTargets.take(2)) {
      final ok = await probeOne(target.ip, target.port);
      if (ok.success) return true;
    }
    return false;
  }

  Future<({bool success, int latencyMs})> probeOne(String ip, int port) async {
    final sw = Stopwatch()..start();
    Socket? sock;
    try {
      sock = await Socket.connect(
        ip,
        port,
        timeout: DiagnosticConfig.tcpTimeout,
      );
      sw.stop();
      return (success: true, latencyMs: sw.elapsedMilliseconds);
    } catch (_) {
      sw.stop();
      return (success: false, latencyMs: sw.elapsedMilliseconds);
    } finally {
      try {
        sock?.destroy();
      } catch (_) {}
    }
  }
}
