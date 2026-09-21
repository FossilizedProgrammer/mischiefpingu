part of '../watchdog_prober.dart';

/// ═══════════════════════════════════════════════════════════════
///  probe HTTPS — خواندن پاسخ و بررسی status.
/// ═══════════════════════════════════════════════════════════════
extension WatchdogProberHttpsProbe on WatchdogProber {
  Future<({bool responseOk, bool statusOk})> probeHttps(
    SecureSocket secure,
  ) async {
    try {
      secure.write(
        'HEAD / HTTP/1.1\r\n'
        'Host: ${WatchdogProber.probeHostname}\r\n'
        'User-Agent: Mozilla/5.0\r\n'
        'Connection: close\r\n'
        '\r\n',
      );
      await secure.flush();

      final buffer = <int>[];
      await for (final chunk in secure.timeout(httpProbeTimeout)) {
        buffer.addAll(chunk);
        if (buffer.length >= 20) break;
      }

      if (buffer.isEmpty) {
        log('✗ probe: HTTPS returned 0 bytes (tunnel dead)', source: logSource);
        return (responseOk: false, statusOk: false);
      }

      final head = String.fromCharCodes(buffer.take(20));
      if (!head.startsWith('HTTP/')) {
        log(
          '✗ probe: non-HTTP response: ${buffer.take(12).toList()}',
          source: logSource,
        );
        return (responseOk: false, statusOk: false);
      }

      final statusOk =
          head.contains(' 200 ') ||
          head.contains(' 204 ') ||
          head.contains(' 301 ') ||
          head.contains(' 302 ') ||
          head.contains(' 304 ') ||
          head.contains(' 400 ') ||
          head.contains(' 403 ') ||
          head.contains(' 404 ');

      if (!statusOk) {
        log(
          '✗ probe: HTTPS status not OK: ${head.split("\r\n").first}',
          source: logSource,
        );
      }

      return (responseOk: true, statusOk: statusOk);
    } catch (e) {
      log('✗ probe: HTTPS failed: $e', source: logSource);
      return (responseOk: false, statusOk: false);
    }
  }
}
