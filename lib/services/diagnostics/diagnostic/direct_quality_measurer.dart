library;

import '../diagnostic_models.dart';
import '../quality_calculator.dart';
import 'diagnostic_config.dart';
import 'tcp_measurer.dart';

class DirectQualityMeasurer {
  final TcpMeasurer tcp;
  final void Function(String message)? log;

  const DirectQualityMeasurer({required this.tcp, this.log});

  Future<DiagnosticMetric> measure() async {
    log?.call('→ Direct Quality: combined TCP measurement');
    final samples = <ProbeSample>[];
    var idx = 0;

    for (var round = 0; round < DiagnosticConfig.samplesPerMetric; round++) {
      final target = DiagnosticConfig
          .tcpTargets[round % DiagnosticConfig.tcpTargets.length];
      final r = await tcp.probeOne(target.ip, target.port);
      samples.add(ProbeSample(
        index: idx++,
        success: r.success,
        latencyMs: r.latencyMs,
        target: '${target.ip}:${target.port}',
        timestamp: DateTime.now(),
      ));
      await Future.delayed(DiagnosticConfig.sampleInterval);
    }

    return QualityCalculator.compute(
      samples: samples,
      message: 'Direct quality',
    );
  }
}
