library;

import '../process/log_source.dart';
import 'diagnostic/diagnostic_config.dart';
import 'diagnostic/dns_measurer.dart';
import 'diagnostic/direct_quality_measurer.dart';
import 'diagnostic/https_measurer.dart';
import 'diagnostic/probable_cause_analyzer.dart';
import 'diagnostic/tcp_measurer.dart';
import 'diagnostic_models.dart';
import 'quality_calculator.dart';

class InternetDiagnosticService {
  final void Function(String message, {String source})? log;

  late final DnsMeasurer _dns = DnsMeasurer(log: _logSimple);
  late final TcpMeasurer _tcp = TcpMeasurer(log: _logSimple);
  late final HttpsMeasurer _https = HttpsMeasurer(log: _logSimple);
  late final DirectQualityMeasurer _direct =
      DirectQualityMeasurer(tcp: _tcp, log: _logSimple);
  late final ProbableCauseAnalyzer _cause = ProbableCauseAnalyzer();

  InternetDiagnosticService({this.log});

  Future<InternetDiagnosticResult> diagnose() async {
    final sw = Stopwatch()..start();
    _logSimple(
      '→ Starting full diagnostic '
      '(samples=${DiagnosticConfig.samplesPerMetric})',
    );

    final results = await Future.wait([
      _dns.measure(),
      _tcp.measure(),
      _https.measure(),
      _direct.measure(),
    ]);

    sw.stop();

    const tunnelQuality = DiagnosticMetric.unknown;

    var result = InternetDiagnosticResult(
      overall: InternetQuality.unknown,
      dns: results[0],
      tcp: results[1],
      https: results[2],
      directQuality: results[3],
      tunnelQuality: tunnelQuality,
      probableCause: '',
      evidence: const [],
      timestamp: DateTime.now(),
      totalDurationMs: sw.elapsedMilliseconds,
    );

    final overall = QualityCalculator.classify(result);
    final cause = _cause.analyze(result, overall);

    result = result.copyWith(
      overall: overall,
      probableCause: cause,
    );

    _logSimple(
      '★ Diagnostic done in ${sw.elapsedMilliseconds}ms — '
      'overall=${overall.name}, dns=${result.dns.status.name}, '
      'tcp=${result.tcp.status.name}, https=${result.https.status.name}',
    );

    return result;
  }

  Future<bool> isInternetAlive() => _tcp.isAlive();

  /// آداپتور — measurerها `void Function(String)` می‌خواهند،
  /// ولی callback اصلی ما `{String source}` هم دارد.
  void _logSimple(String message) {
    log?.call(message, source: LogSource.app);
  }
}
