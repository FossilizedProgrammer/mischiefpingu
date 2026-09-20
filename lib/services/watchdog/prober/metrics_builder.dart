part of '../watchdog_prober.dart';

/// ═══════════════════════════════════════════════════════════════
///  ساخت WatchdogQualityMetrics + jitter.
/// ═══════════════════════════════════════════════════════════════
extension WatchdogProberMetricsBuilder on WatchdogProber {
  WatchdogQualityMetrics buildMetrics({
    required int latencyMs,
    required bool tcpOk,
    required bool greetOk,
    required bool connectOk,
    required bool httpRespOk,
    required bool httpStatusOk,
  }) {
    int jitter = 0;
    if (lastLatencyMs > 0 && tcpOk && greetOk && connectOk) {
      final diff = latencyMs - lastLatencyMs;
      jitter = diff.abs();
    }
    if (tcpOk && greetOk && connectOk) {
      lastLatencyMs = latencyMs;
    }

    return WatchdogQualityMetrics(
      latencyMs: latencyMs,
      jitterMs: jitter,
      tcpOk: tcpOk,
      socksGreetingOk: greetOk,
      socksConnectOk: connectOk,
      httpResponseOk: httpRespOk,
      httpStatusOk: httpStatusOk,
    );
  }
}
