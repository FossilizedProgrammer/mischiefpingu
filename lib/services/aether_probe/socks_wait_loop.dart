library;

import 'dart:async';

import '../aether_probe_fallbacks.dart';
import '../process_service.dart';
import 'socks_diag.dart';
import 'socks_diagnose.dart';

/// loop انتظار برای healthy شدن Aether.
class SocksWaitLoop {
  final ProcessService processService;
  final SocksDiagnoser diagnoser;
  final AetherProbeFallbacks fallbacks;
  final bool Function() isCancelled;

  const SocksWaitLoop({
    required this.processService,
    required this.diagnoser,
    required this.fallbacks,
    required this.isCancelled,
  });

  Future<SocksDiag> run(int port, {required Duration timeout}) async {
    final deadline = DateTime.now().add(timeout);
    SocksDiag last = SocksDiag.connectTimeout;

    while (DateTime.now().isBefore(deadline)) {
      if (isCancelled()) return last;
      if (!processService.isAetherRunning) return SocksDiag.connectRefused;

      last = await diagnoser.diagnose(port);
      if (last == SocksDiag.healthy) return SocksDiag.healthy;

      if (last == SocksDiag.tunnelDead) {
        processService.addLog(
          '✗ DIAG: tunnel is dead (data-plane confirmed) — '
          'aborting wait, will retry endpoint',
        );
        return SocksDiag.tunnelDead;
      }

      if (await fallbacks.curlProbe(port)) return SocksDiag.healthy;

      if (last != SocksDiag.tunnelDead && fallbacks.coreSaysReady(port)) {
        processService.addLog(
          '✗ Loopback probes blocked. Aether log shows tunnel validated + '
          'SOCKS on :$port (using log-based fallback).',
        );
        return SocksDiag.healthy;
      }

      await Future.delayed(const Duration(seconds: 3));
    }
    return last;
  }
}
