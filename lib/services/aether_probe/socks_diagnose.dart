library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../aether_probe_fallbacks.dart';
import '../process_service.dart';
import 'socks_diag.dart';

part 'socks/https_probe.dart';

/// ═══════════════════════════════════════════════════════════════
///  diagnose کامل روی پورت SOCKS.
///
///  ⚠️ نسخهٔ نهایی — دقیقاً مثل `curl --socks5-hostname`:
///    • SOCKS CONNECT با hostname (ATYP=0x03)، نه IP خام
///    • DNS از طریق خود SOCKS resolve می‌شه (socks5h)
///    • TLS handshake با SNI همون hostname
///    • پورت ۴۴۳ (HTTPS)، نه ۸۰
///
///  منطق probe یک هدف در `socks/https_probe.dart`.
/// ═══════════════════════════════════════════════════════════════
class SocksDiagnoser {
  final ProcessService processService;
  final AetherProbeFallbacks fallbacks;

  const SocksDiagnoser({required this.processService, required this.fallbacks});

  /// هدف‌های probe — hostname + پورت ۴۴۳.
  static const List<({String host, int port})> probeTargets = [
    (host: 'www.cloudflare.com', port: 443),
    (host: 'www.google.com', port: 443),
    (host: 'www.microsoft.com', port: 443),
    (host: 'www.wikipedia.org', port: 443),
    (host: 'www.apple.com', port: 443),
  ];

  static const Duration socksConnectTimeout = Duration(seconds: 10);
  static const Duration socksReadTimeout = Duration(seconds: 15);
  static const Duration tlsTimeout = Duration(seconds: 12);
  static const Duration httpReadTimeout = Duration(seconds: 10);
  static const int minTargetsOk = 1;

  Future<SocksDiag> diagnose(int port) async {
    // ─── چک اولیه: SOCKS greeting ───
    Socket? testSock;
    try {
      testSock = await Socket.connect(
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
      testSock.add([0x05, 0x01, 0x00]);
      final greet = await testSock.timeout(const Duration(seconds: 8)).first;
      if (greet.isEmpty) return SocksDiag.notSocks;
      if (greet[0] != 0x05) {
        processService.addLog(
          '→ probe got non-SOCKS reply (${greet.take(8).toList()})',
        );
        return SocksDiag.notSocks;
      }
      if (greet.length >= 2 && greet[1] != 0x00) {
        return SocksDiag.notSocks;
      }
    } finally {
      try {
        testSock.destroy();
      } catch (_) {}
    }

    // ─── امتحان چند هدف HTTPS ───
    var targetsAttempted = 0;
    var targetsOk = 0;
    final failures = <String>[];

    for (final target in probeTargets) {
      targetsAttempted++;
      final ok = await probeOneHttpsTarget(port, target);
      if (ok) {
        targetsOk++;
        if (targetsOk >= minTargetsOk) break;
      } else {
        failures.add(target.host);
      }
    }

    if (targetsOk >= minTargetsOk) {
      processService.addLog(
        '→ DIAG: $targetsOk/$targetsAttempted HTTPS probes succeeded',
      );
      return SocksDiag.healthy;
    }

    processService.addLog(
      '⚠ DIAG: SOCKS5 alive but all $targetsAttempted HTTPS targets '
      'failed (${failures.join(", ")}) — suspecting network block',
    );
    return SocksDiag.allTargetsFailed;
  }
}
