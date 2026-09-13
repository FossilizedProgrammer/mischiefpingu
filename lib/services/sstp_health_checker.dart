// lib/services/sstp_health_checker.dart
library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'sstp/tls_client_hello_builder.dart';

enum SstpHealth {
  unknown,
  checking,
  alive,
  tcpOnly,
  dead,
}

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
  static const Duration firstByteTimeout = Duration(seconds: 4);

  Future<SstpHealthResult> check(String ip, int port) async {
    final sw = Stopwatch()..start();
    Socket? sock;

    // ─── TCP connect ───
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

    // ─── ارسال TLS ClientHello ───
    try {
      sock.add(TlsClientHelloBuilder.build());
      await sock.flush();
    } catch (e) {
      sw.stop();
      try {
        sock.destroy();
      } catch (_) {}
      return SstpHealthResult(
        status: SstpHealth.dead,
        latencyMs: tcpLatency,
        message: 'failed to send TLS hello: ${_short(e)}',
      );
    }

    // ─── منتظر پاسخ ───
    final completer = Completer<_ProbeOutcome>();
    StreamSubscription<Uint8List>? sub;
    Timer? timer;

    void finish(_ProbeOutcome outcome) {
      if (completer.isCompleted) return;
      completer.complete(outcome);
    }

    try {
      sub = sock.listen(
        (data) {
          if (data.isNotEmpty) {
            finish(_ProbeOutcome.gotData(data.length));
          }
        },
        onError: (Object e) => finish(_ProbeOutcome.error(e)),
        onDone: () => finish(_ProbeOutcome.closed()),
        cancelOnError: true,
      );

      timer = Timer(firstByteTimeout, () {
        finish(_ProbeOutcome.stillOpen());
      });

      final outcome = await completer.future;
      sw.stop();

      switch (outcome.kind) {
        case _ProbeKind.gotData:
          return SstpHealthResult(
            status: SstpHealth.alive,
            latencyMs: tcpLatency,
            message: 'alive (TLS responded with ${outcome.dataLength}B)',
          );
        case _ProbeKind.stillOpen:
          return SstpHealthResult(
            status: SstpHealth.tcpOnly,
            latencyMs: tcpLatency,
            message: 'TCP open, no TLS response',
          );
        case _ProbeKind.closed:
          return SstpHealthResult(
            status: SstpHealth.tcpOnly,
            latencyMs: tcpLatency,
            message: 'TCP open, closed without TLS response',
          );
        case _ProbeKind.error:
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
    } catch (e) {
      sw.stop();
      return SstpHealthResult(
        status: SstpHealth.dead,
        latencyMs: tcpLatency,
        message: _short(e),
      );
    } finally {
      timer?.cancel();
      try {
        await sub?.cancel();
      } catch (_) {}
      try {
        sock.destroy();
      } catch (_) {}
    }
  }

  String _short(Object e) {
    final s = e.toString();
    return s.length > 80 ? '${s.substring(0, 80)}…' : s;
  }
}

enum _ProbeKind { gotData, stillOpen, closed, error }

class _ProbeOutcome {
  final _ProbeKind kind;
  final int dataLength;
  final Object? error;

  const _ProbeOutcome._(this.kind, {this.dataLength = 0, this.error});

  factory _ProbeOutcome.gotData(int length) =>
      _ProbeOutcome._(_ProbeKind.gotData, dataLength: length);
  factory _ProbeOutcome.stillOpen() =>
      const _ProbeOutcome._(_ProbeKind.stillOpen);
  factory _ProbeOutcome.closed() => const _ProbeOutcome._(_ProbeKind.closed);
  factory _ProbeOutcome.error(Object e) =>
      _ProbeOutcome._(_ProbeKind.error, error: e);
}
