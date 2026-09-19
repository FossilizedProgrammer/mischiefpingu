library;

import '../diagnostic_models.dart';

class ProbableCauseAnalyzer {
  const ProbableCauseAnalyzer();

  String analyze(InternetDiagnosticResult r, InternetQuality q) {
    if (r.dns.status == MetricStatus.failing &&
        r.tcp.status != MetricStatus.failing) {
      return 'DNS resolution is failing';
    }

    if (r.dns.status == MetricStatus.ok &&
        r.tcp.status == MetricStatus.failing) {
      return 'DNS works but TCP is blocked';
    }

    if (r.tcp.status == MetricStatus.ok &&
        r.https.status == MetricStatus.failing) {
      return 'TCP works but HTTPS/TLS is failing';
    }

    if (r.dns.status == MetricStatus.failing &&
        r.tcp.status == MetricStatus.failing &&
        r.https.status == MetricStatus.failing) {
      return 'Internet connection is down';
    }

    if (q == InternetQuality.unstable) {
      return 'Internet connection is unstable';
    }
    if (q == InternetQuality.degraded) {
      return 'Internet connection is degraded';
    }
    if (q == InternetQuality.excellent) {
      return 'Internet connection is healthy';
    }

    return '';
  }
}
