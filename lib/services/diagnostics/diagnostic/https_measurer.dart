library;

import 'dart:io';

import '../diagnostic_models.dart';
import '../quality_calculator.dart';
import 'diagnostic_config.dart';

class HttpsMeasurer {
  final void Function(String message)? log;

  const HttpsMeasurer({this.log});

  Future<DiagnosticMetric> measure() async {
    log?.call(
      '→ HTTPS: probing ${DiagnosticConfig.httpsTargets.length} hostnames '
      '× ${DiagnosticConfig.samplesPerMetric} samples (with SNI)',
    );

    final samples = <ProbeSample>[];
    var idx = 0;

    for (var round = 0; round < DiagnosticConfig.samplesPerMetric; round++) {
      for (final host in DiagnosticConfig.httpsTargets) {
        final r = await probeOne(host);
        samples.add(ProbeSample(
          index: idx++,
          success: r.success,
          latencyMs: r.latencyMs,
          target: host,
          timestamp: DateTime.now(),
        ));
        await Future.delayed(DiagnosticConfig.sampleInterval);
      }
    }

    final metric = QualityCalculator.compute(
      samples: samples,
      message: 'HTTPS round-trip (with SNI)',
    );
    log?.call(
      '→ HTTPS: ${metric.successCount}/${metric.totalCount} ok, '
      'avg=${metric.avgLatencyMs}ms, jitter=${metric.jitterMs}ms',
    );
    return metric;
  }

  /// probe HTTPS با SNI معتبر.
  Future<({bool success, int latencyMs})> probeOne(String host) async {
    final sw = Stopwatch()..start();
    HttpClient? client;
    try {
      client = HttpClient();
      client.connectionTimeout = DiagnosticConfig.httpsTimeout;
      client.badCertificateCallback = (_, __, ___) => true;

      final uri = Uri.https(host, '/');

      final req = await client.getUrl(uri).timeout(
            DiagnosticConfig.httpsTimeout,
          );
      req.headers.set('User-Agent', DiagnosticConfig.httpsUserAgent);
      req.headers.set('Accept', 'text/html,application/xhtml+xml,*/*');
      req.headers.set('Accept-Language', 'en-US,en;q=0.9');

      final res = await req.close().timeout(DiagnosticConfig.httpsTimeout);
      await res.drain<void>().timeout(DiagnosticConfig.httpsTimeout);
      sw.stop();
      return (
        success: res.statusCode >= 200 && res.statusCode < 500,
        latencyMs: sw.elapsedMilliseconds,
      );
    } catch (_) {
      sw.stop();
      return (success: false, latencyMs: sw.elapsedMilliseconds);
    } finally {
      client?.close(force: true);
    }
  }
}
