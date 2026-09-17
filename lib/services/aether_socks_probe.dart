// lib/services/aether_socks_probe.dart
library;

import 'dart:async';
import 'dart:io';

import 'aether_probe_fallbacks.dart';
import 'process_service.dart';

enum SocksDiag {
  healthy,
  appListenerBaselineFailed,
  connectRefused,
  connectTimeout,
  notSocks,
  tunnelDead,
}

/// Probes the local Aether SOCKS port and waits until it is healthy.
class SocksProber {
  final ProcessService processService;

  /// polled while waiting; when true the wait aborts early.
  final bool Function() isCancelled;

  late final AetherProbeFallbacks _fallbacks = AetherProbeFallbacks(
    processService: processService,
  );

  SocksProber(this.processService, {required this.isCancelled});

  // ═══════════════════════════════════════════
  //  تشخیص وضعیت SOCKS
  // ═══════════════════════════════════════════
  Future<SocksDiag> diagnoseSocks(int port) async {
    var baselineOk = true;
    ServerSocket? base;
    try {
      base = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final c = await Socket.connect(
        '127.0.0.1',
        base.port,
        timeout: const Duration(seconds: 2),
      );
      c.destroy();
    } catch (_) {
      baselineOk = false;
      processService.addLog('⚠ DIAG baseline: loopback listener test failed.');
    } finally {
      try {
        await base?.close();
      } catch (_) {}
    }

    Socket? sock;
    try {
      sock = await Socket.connect(
        '127.0.0.1',
        port,
        timeout: const Duration(seconds: 4),
      );
    } on SocketException catch (e) {
      final code = e.osError?.errorCode ?? 0;
      final refused = code == 111 || code == 61;
      return refused ? SocksDiag.connectRefused : SocksDiag.connectTimeout;
    } catch (_) {
      return SocksDiag.connectTimeout;
    }

    try {
      sock.add([0x05, 0x01, 0x00]);
      final greet = await sock.timeout(const Duration(seconds: 8)).first;
      if (greet.isEmpty) return SocksDiag.notSocks;
      if (greet[0] != 0x05) {
        processService.addLog(
          '→ probe got non-SOCKS reply (${greet.take(8).toList()})',
        );
        return SocksDiag.notSocks;
      }
      try {
        sock.add(<int>[0x05, 0x01, 0x00, 0x01, 1, 1, 1, 1, 0x01, 0xBB]);
        final resp = await sock.timeout(const Duration(seconds: 10)).first;
        processService.addLog(
          (resp.length >= 2 && resp[1] == 0x00)
              ? '→ probe: tunnel CONNECT :443 OK'
              : '→ probe: tunnel CONNECT :443 refused by proxy',
        );
      } catch (_) {
        processService.addLog(
          '→ probe: tunnel CONNECT :443 blocked (treated as OK)',
        );
      }
      if (!baselineOk) {
        processService.addLog(
          '★ DIAG: SOCKS5 greeting OK despite blocked app loopback',
        );
      }
      return SocksDiag.healthy;
    } on TimeoutException {
      return SocksDiag.notSocks;
    } catch (_) {
      return SocksDiag.notSocks;
    } finally {
      try {
        sock.destroy();
      } catch (_) {}
    }
  }

  String diagText(SocksDiag d, int port) {
    switch (d) {
      case SocksDiag.healthy:
        return '✓ DIAG: TCP connect OK → SOCKS5 greeting OK';
      case SocksDiag.appListenerBaselineFailed:
        return '✗ DIAG: even our own loopback listener test failed';
      case SocksDiag.connectRefused:
        return '✗ DIAG: TCP connect to 127.0.0.1:$port REFUSED';
      case SocksDiag.connectTimeout:
        return '✗ DIAG: TCP connect to 127.0.0.1:$port TIMED OUT';
      case SocksDiag.notSocks:
        return '✗ DIAG: port accepts TCP but does NOT answer SOCKS5';
      case SocksDiag.tunnelDead:
        return '✗ DIAG: SOCKS5 greeting OK but tunnel data-plane dead';
    }
  }

  // ═══════════════════════════════════════════
  //  انتظار برای سلامت SOCKS
  // ═══════════════════════════════════════════
  Future<SocksDiag> waitForHealthy(
    int port, {
    required Duration timeout,
  }) async {
    final deadline = DateTime.now().add(timeout);
    SocksDiag last = SocksDiag.connectTimeout;
    while (DateTime.now().isBefore(deadline)) {
      if (isCancelled()) return last;
      if (!processService.isAetherRunning) return SocksDiag.connectRefused;

      last = await diagnoseSocks(port);
      if (last == SocksDiag.healthy) return SocksDiag.healthy;

      if (await _fallbacks.curlProbe(port)) return SocksDiag.healthy;

      if (_fallbacks.coreSaysReady(port)) {
        processService.addLog(
          '✗ Loopback probes blocked. Aether log shows tunnel validated + '
          'SOCKS on :$port.',
        );
        return SocksDiag.healthy;
      }

      await Future.delayed(const Duration(seconds: 3));
    }
    return last;
  }
}
