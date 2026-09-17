// lib/services/watchdog/watchdog_prober.dart
//
// ═══════════════════════════════════════════════════════════════
//  WatchdogProber — probe SOCKS5 + HTTP برای تشخیص data-plane
//  (تفکیک شده از tunnel_watchdog.dart)
// ═══════════════════════════════════════════════════════════════
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'tunnel_watchdog.dart' show ProbeResult;

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

  const WatchdogProber({
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

  Future<ProbeResult> probe() async {
    Socket? sock;
    try {
      sock = await Socket.connect(
        '127.0.0.1',
        socksPort,
        timeout: connectTimeout,
      );

      // greeting
      sock.add([0x05, 0x01, 0x00]);
      await sock.flush();
      final greet = await sock.timeout(socksTimeout).first;
      if (greet.isEmpty || greet[0] != 0x05) {
        return ProbeResult.dead;
      }
      if (greet.length >= 2 && greet[1] != 0x00) {
        return ProbeResult.dead;
      }

      // CONNECT
      final ipBytes = _hostToBytes(probeHost);
      if (ipBytes == null) {
        final hostBytes = probeHost.codeUnits;
        sock.add(<int>[
          0x05,
          0x01,
          0x00,
          0x03,
          hostBytes.length,
          ...hostBytes,
          (probePort >> 8) & 0xFF,
          probePort & 0xFF,
        ]);
      } else {
        sock.add(<int>[
          0x05,
          0x01,
          0x00,
          0x01,
          ...ipBytes,
          (probePort >> 8) & 0xFF,
          probePort & 0xFF,
        ]);
      }
      await sock.flush();

      final resp = await sock.timeout(socksTimeout).first;
      if (resp.length < 2) return ProbeResult.dead;
      if (resp[1] != 0x00) return ProbeResult.dead;

      // data-plane check
      if (doHttpProbe) {
        try {
          final hostHeader = probePort == 80 || probePort == 443
              ? probeHost
              : '$probeHost:$probePort';
          sock.add(utf8.encode('GET /generate_204 HTTP/1.0\r\n'
              'Host: $hostHeader\r\n'
              'Connection: close\r\n'
              '\r\n'));
          await sock.flush();

          final data = await sock.timeout(httpProbeTimeout).first;
          if (data.isEmpty) {
            return ProbeResult.dead;
          }
          return ProbeResult.alive;
        } catch (_) {
          return ProbeResult.dead;
        }
      }

      return ProbeResult.alive;
    } on SocketException {
      return ProbeResult.dead;
    } catch (_) {
      return ProbeResult.dead;
    } finally {
      try {
        sock?.destroy();
      } catch (_) {}
    }
  }

  List<int>? _hostToBytes(String host) {
    final parts = host.split('.');
    if (parts.length != 4) return null;
    final out = <int>[];
    for (final p in parts) {
      final n = int.tryParse(p);
      if (n == null || n < 0 || n > 255) return null;
      out.add(n);
    }
    return out;
  }
}
