library;

import 'dart:async';
import 'dart:io';

import '../aether_probe_fallbacks.dart';
import '../process_service.dart';
import 'socks_diag.dart';

/// یک diagnose کامل روی پورت SOCKS.
class SocksDiagnoser {
  final ProcessService processService;
  final AetherProbeFallbacks fallbacks;

  const SocksDiagnoser({
    required this.processService,
    required this.fallbacks,
  });

  Future<SocksDiag> diagnose(int port) async {
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
      processService.addLog(
        '⚠ DIAG baseline: loopback listener test failed.',
      );
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
        sock.add(<int>[0x05, 0x01, 0x00, 0x01, 1, 1, 1, 1, 0x00, 0x50]);
        final resp = await sock.timeout(const Duration(seconds: 10)).first;
        if (resp.length < 2 || resp[1] != 0x00) {
          processService.addLog(
            '→ probe: tunnel CONNECT :80 refused by proxy '
            '(code=${resp.length >= 2 ? resp[1] : "?"})',
          );
          return SocksDiag.tunnelDead;
        }
      } catch (e) {
        processService.addLog(
          '→ probe: tunnel CONNECT :80 failed: $e',
        );
        return SocksDiag.tunnelDead;
      }

      final dataOk = await _probeDataPlane(sock);
      if (!dataOk) return SocksDiag.tunnelDead;

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

  Future<bool> _probeDataPlane(Socket sock) async {
    try {
      sock.add(
        <int>[
          0x47,
          0x45,
          0x54,
          0x20,
          0x2F,
          0x63,
          0x64,
          0x6E,
          0x2D,
          0x63,
          0x67,
          0x69,
          0x2F,
          0x74,
          0x72,
          0x61,
          0x63,
          0x65,
          0x20,
          0x48,
          0x54,
          0x54,
          0x50,
          0x2F,
          0x31,
          0x2E,
          0x30,
          0x0D,
          0x0A,
          0x48,
          0x6F,
          0x73,
          0x74,
          0x3A,
          0x20,
          0x31,
          0x2E,
          0x31,
          0x2E,
          0x31,
          0x2E,
          0x31,
          0x0D,
          0x0A,
          0x43,
          0x6F,
          0x6E,
          0x6E,
          0x65,
          0x63,
          0x74,
          0x69,
          0x6F,
          0x6E,
          0x3A,
          0x20,
          0x63,
          0x6C,
          0x6F,
          0x73,
          0x65,
          0x0D,
          0x0A,
          0x0D,
          0x0A,
        ],
      );
      await sock.flush();

      final buffer = <int>[];
      await for (final chunk in sock.timeout(const Duration(seconds: 6))) {
        buffer.addAll(chunk);
        if (buffer.length >= 16) break;
        if (buffer.length >= 12) break;
      }

      if (buffer.isEmpty) {
        processService.addLog(
          '✗ probe: data-plane returned 0 bytes — tunnel DEAD',
        );
        return false;
      }

      final head = String.fromCharCodes(buffer.take(20));
      if (!head.startsWith('HTTP/')) {
        processService.addLog(
          '✗ probe: non-HTTP response — tunnel DEAD '
          '(${buffer.take(12).toList()})',
        );
        return false;
      }

      final statusOk = head.contains(' 200 ') ||
          head.contains(' 204 ') ||
          head.contains(' 301 ') ||
          head.contains(' 302 ') ||
          head.contains(' 304 ');

      if (!statusOk) {
        processService.addLog(
          '✗ probe: HTTP status not OK — tunnel DEAD '
          '(${head.split("\r\n").first})',
        );
        return false;
      }

      processService.addLog(
        '→ probe: tunnel data-plane CONFIRMED alive',
      );
      return true;
    } catch (e) {
      processService.addLog(
        '✗ probe: data-plane exception — tunnel DEAD: $e',
      );
      return false;
    }
  }
}
