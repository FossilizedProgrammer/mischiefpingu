library;

import 'dart:async';
import 'dart:io';
import 'sstp/sstp_tls_probe.dart';

enum SstpHealth { unknown, checking, alive, tcpOnly, dead }

class SstpHealthResult {
  final SstpHealth status;
  final int latencyMs;
  final String message;

  const SstpHealthResult({
    required this.status,
    required this.latencyMs,
    required this.message,
  });

  static const unknown = SstpHealthResult(
    status: SstpHealth.unknown,
    latencyMs: 0,
    message: '',
  );
}

class SstpHealthChecker {
  static const Duration tcpTimeout = Duration(seconds: 5);

  Future<SstpHealthResult> check(String ip, int port) async {
    final sw = Stopwatch()..start();
    Socket? sock;

    try {
      sock = await Socket.connect(ip, port, timeout: tcpTimeout);
    } on SocketException catch (e) {
      sw.stop();
      return SstpHealthResult(
        status: SstpHealth.dead,
        latencyMs: sw.elapsedMilliseconds,
        message: e.osError?.message ?? 'connect failed',
      );
    } catch (e) {
      sw.stop();
      return SstpHealthResult(
        status: SstpHealth.dead,
        latencyMs: sw.elapsedMilliseconds,
        message: _short(e),
      );
    }

    final tcpLatency = sw.elapsedMilliseconds;

    try {
      final outcome = await SstpTlsProbe.sendClientHello(sock);
      sw.stop();
      return _interpret(outcome, tcpLatency);
    } catch (e) {
      sw.stop();
      return SstpHealthResult(
        status: SstpHealth.dead,
        latencyMs: tcpLatency,
        message: _short(e),
      );
    } finally {
      try {
        sock.destroy();
      } catch (_) {}
    }
  }

  SstpHealthResult _interpret(SstpProbeOutcome outcome, int tcpLatency) {
    switch (outcome.kind) {
      case SstpProbeKind.gotData:
        return SstpHealthResult(
          status: SstpHealth.alive,
          latencyMs: tcpLatency,
          message: 'alive (TLS responded with ${outcome.dataLength}B)',
        );
      case SstpProbeKind.stillOpen:
        return SstpHealthResult(
          status: SstpHealth.tcpOnly,
          latencyMs: tcpLatency,
          message: 'TCP open, no TLS response',
        );
      case SstpProbeKind.closed:
        return SstpHealthResult(
          status: SstpHealth.tcpOnly,
          latencyMs: tcpLatency,
          message: 'TCP open, closed without TLS response',
        );
      case SstpProbeKind.error:
        final errStr = outcome.error?.toString() ?? '';
        if (errStr.contains('reset') || errStr.contains('Connection')) {
          return SstpHealthResult(
            status: SstpHealth.alive,
            latencyMs: tcpLatency,
            message: 'alive (connection reset - server active)',
          );
        }
        return SstpHealthResult(
          status: SstpHealth.dead,
          latencyMs: tcpLatency,
          message: _short(outcome.error ?? 'unknown error'),
        );
    }
  }

  String _short(Object e) {
    final s = e.toString();
    return s.length > 80 ? '${s.substring(0, 80)}…' : s;
  }
}
