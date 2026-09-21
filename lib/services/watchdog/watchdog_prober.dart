library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'watchdog_quality_metrics.dart';

part 'prober/metrics_builder.dart';
part 'prober/https_probe.dart';
part 'prober/socks_handshake.dart';
part 'prober/tls_probe.dart';

/// ═══════════════════════════════════════════════════════════════
///  WatchdogProber — probe SOCKS + HTTPS با metric کیفی.
///
///  ⚠️ نسخهٔ نهایی: hostname + HTTPS 443 + SNI معتبر.
///  ⚠️ از StreamIterator برای جلوگیری از "already listened" استفاده می‌شود.
///
///  منطق به چهار part جدا شده:
///    • ProberMetricsBuilder  → ساخت WatchdogQualityMetrics
///    • ProberHttpsProbe      → probe HTTPS (روی secure socket آماده)
///    • WatchdogProberSocksHandshake → مرحله 1+2+3 (TCP + greeting + CONNECT)
///    • WatchdogProberTlsProbe       → مرحله 4 (TLS + HTTPS)
/// ═══════════════════════════════════════════════════════════════
class WatchdogProber {
  final int socksPort;
  final String probeHost;
  final int probePort;
  final bool doHttpProbe;
  final Duration connectTimeout;
  final Duration socksTimeout;
  final Duration httpProbeTimeout;
  final void Function(String message, {String source}) log;
  final String logSource;

  int lastLatencyMs = 0;

  WatchdogProber({
    required this.socksPort,
    required this.probeHost,
    required this.probePort,
    required this.doHttpProbe,
    required this.connectTimeout,
    required this.socksTimeout,
    required this.httpProbeTimeout,
    required this.log,
    required this.logSource,
  });

  /// hostname برای probe (نه IP خام).
  static const String probeHostname = 'www.cloudflare.com';
  static const int probeHttpsPort = 443;

  Future<WatchdogQualityMetrics> probeWithMetrics() async {
    final sw = Stopwatch()..start();

    Socket? sock;
    SecureSocket? secure;
    StreamIterator<List<int>>? iter;

    bool tcpOk = false;
    bool greetOk = false;
    bool connectOk = false;
    bool httpRespOk = false;
    bool httpStatusOk = false;

    try {
      // ─── مرحله 1+2+3: SOCKS handshake ───
      final hs = await performSocksHandshake(sw: sw);

      sock = hs.sock;
      iter = hs.iter;
      tcpOk = hs.tcpOk;
      greetOk = hs.greetOk;
      connectOk = hs.connectOk;

      if (!hs.socksOk) {
        sw.stop();
        return buildMetrics(
          latencyMs: sw.elapsedMilliseconds,
          tcpOk: tcpOk,
          greetOk: greetOk,
          connectOk: connectOk,
          httpRespOk: false,
          httpStatusOk: false,
        );
      }

      // ─── مرحله 4: TLS + HTTPS ───
      if (doHttpProbe) {
        final tls = await performTlsAndHttps(sock: sock!, iter: iter);
        secure = tls.secure;
        httpRespOk = tls.httpRespOk;
        httpStatusOk = tls.httpStatusOk;
        iter = null; // iterator cancel شد
      } else {
        httpRespOk = true;
        httpStatusOk = true;
      }

      sw.stop();
      return buildMetrics(
        latencyMs: sw.elapsedMilliseconds,
        tcpOk: tcpOk,
        greetOk: greetOk,
        connectOk: connectOk,
        httpRespOk: httpRespOk,
        httpStatusOk: httpStatusOk,
      );
    } catch (e) {
      sw.stop();
      log('⚠ probe error: $e', source: logSource);
      return buildMetrics(
        latencyMs: sw.elapsedMilliseconds,
        tcpOk: tcpOk,
        greetOk: greetOk,
        connectOk: connectOk,
        httpRespOk: httpRespOk,
        httpStatusOk: httpStatusOk,
      );
    } finally {
      try {
        await iter?.cancel();
      } catch (_) {}
      try {
        await secure?.close();
      } catch (_) {}
      try {
        sock?.destroy();
      } catch (_) {}
    }
  }

  Future<bool> probeAlive() async {
    final m = await probeWithMetrics();
    return m.isFullyAlive;
  }
}
