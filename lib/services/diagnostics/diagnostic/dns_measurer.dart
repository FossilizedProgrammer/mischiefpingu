library;

import 'dart:io';

import '../diagnostic_models.dart';
import '../quality_calculator.dart';
import 'diagnostic_config.dart';

class DnsMeasurer {
  final void Function(String message)? log;

  const DnsMeasurer({this.log});

  Future<DiagnosticMetric> measure() async {
    log?.call(
      '→ DNS: probing ${DiagnosticConfig.dnsTargets.length} hostnames '
      '× ${DiagnosticConfig.samplesPerMetric} samples',
    );

    final samples = <ProbeSample>[];
    var idx = 0;

    for (var round = 0; round < DiagnosticConfig.samplesPerMetric; round++) {
      for (final host in DiagnosticConfig.dnsTargets) {
        final sw = Stopwatch()..start();
        bool ok = false;
        try {
          final result = await InternetAddress.lookup(host)
              .timeout(DiagnosticConfig.dnsTimeout);
          ok = result.isNotEmpty;
        } catch (_) {
          ok = false;
        }
        sw.stop();
        samples.add(ProbeSample(
          index: idx++,
          success: ok,
          latencyMs: sw.elapsedMilliseconds,
          target: host,
          timestamp: DateTime.now(),
        ));
        await Future.delayed(DiagnosticConfig.sampleInterval);
      }
    }

    final metric = QualityCalculator.compute(
      samples: samples,
      message: 'DNS resolution',
    );
    log?.call(
      '→ DNS: ${metric.successCount}/${metric.totalCount} ok, '
      'avg=${metric.avgLatencyMs}ms, jitter=${metric.jitterMs}ms',
    );
    return metric;
  }
}
