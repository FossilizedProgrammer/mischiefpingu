library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'watchdog_quality_metrics.dart';

part 'prober/metrics_builder.dart';
part 'prober/https_probe.dart';

/// ═══════════════════════════════════════════════════════════════
///  WatchdogProber — probe SOCKS + HTTPS با metric کیفی.
///
///  ⚠️ نسخهٔ نهایی: hostname + HTTPS 443 + SNI معتبر.
///  ⚠️ از StreamIterator برای جلوگیری از "already listened" استفاده می‌شود.
///
///  بخش‌های داخلی در `prober/` جدا شده‌اند:
///    • ProberMetricsBuilder → ساخت WatchdogQualityMetrics
///    • ProberHttpsProbe     → probe HTTPS (روی secure socket آماده)
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
      // ─── مرحله 1: TCP به SOCKS ───
      try {
        sock = await Socket.connect(
          '127.0.0.1',
          socksPort,
          timeout: connectTimeout,
        );
        tcpOk = true;
      } on SocketException {
        sw.stop();
        return buildMetrics(
          latencyMs: sw.elapsedMilliseconds,
          tcpOk: false,
          greetOk: false,
          connectOk: false,
          httpRespOk: false,
          httpStatusOk: false,
        );
      }

      iter = StreamIterator<List<int>>(sock.timeout(socksTimeout));

      // ─── مرحله 2: SOCKS5 greeting ───
      sock.add([0x05, 0x01, 0x00]);
      await sock.flush();

      if (!await iter.moveNext()) {
        sw.stop();
        return buildMetrics(
          latencyMs: sw.elapsedMilliseconds,
          tcpOk: tcpOk,
          greetOk: false,
          connectOk: false,
          httpRespOk: false,
          httpStatusOk: false,
        );
      }
      final greet = iter.current;
      if (greet.isEmpty || greet[0] != 0x05) {
        sw.stop();
        return buildMetrics(
          latencyMs: sw.elapsedMilliseconds,
          tcpOk: tcpOk,
          greetOk: false,
          connectOk: false,
          httpRespOk: false,
          httpStatusOk: false,
        );
      }
      if (greet.length >= 2 && greet[1] != 0x00) {
        sw.stop();
        return buildMetrics(
          latencyMs: sw.elapsedMilliseconds,
          tcpOk: tcpOk,
          greetOk: false,
          connectOk: false,
          httpRespOk: false,
          httpStatusOk: false,
        );
      }
      greetOk = true;

      // ─── مرحله 3: SOCKS5 CONNECT با hostname ───
      final hostBytes = utf8.encode(probeHostname);
      sock.add(<int>[
        0x05,
        0x01,
        0x00,
        0x03,
        hostBytes.length,
        ...hostBytes,
        (probeHttpsPort >> 8) & 0xFF,
        probeHttpsPort & 0xFF,
      ]);
      await sock.flush();

      if (!await iter.moveNext()) {
        sw.stop();
        return buildMetrics(
          latencyMs: sw.elapsedMilliseconds,
          tcpOk: tcpOk,
          greetOk: greetOk,
          connectOk: false,
          httpRespOk: false,
          httpStatusOk: false,
        );
      }
      final resp = iter.current;
      if (resp.length < 2 || resp[1] != 0x00) {
        sw.stop();
        return buildMetrics(
          latencyMs: sw.elapsedMilliseconds,
          tcpOk: tcpOk,
          greetOk: greetOk,
          connectOk: false,
          httpRespOk: false,
          httpStatusOk: false,
        );
      }
      connectOk = true;

      // ─── مرحله 4: TLS handshake ───
      if (doHttpProbe) {
        await iter.cancel();
        iter = null;

        try {
          secure = await SecureSocket.secure(
            sock,
            host: probeHostname,
            onBadCertificate: (_) => true,
          ).timeout(httpProbeTimeout);
        } catch (e) {
          log('✗ probe: TLS handshake failed: $e', source: logSource);
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

        final httpResult = await probeHttps(secure);
        httpRespOk = httpResult.responseOk;
        httpStatusOk = httpResult.statusOk;
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
