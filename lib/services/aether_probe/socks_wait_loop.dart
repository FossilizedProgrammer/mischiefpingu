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
    int consecutiveAllFailed = 0;
    int consecutiveTunnelDead = 0;

    while (DateTime.now().isBefore(deadline)) {
      if (isCancelled()) return last;
      if (!processService.isAetherRunning) return SocksDiag.connectRefused;

      last = await diagnoser.diagnose(port);

      if (last == SocksDiag.healthy) return SocksDiag.healthy;

      if (last == SocksDiag.allTargetsFailed) {
        consecutiveAllFailed++;
        processService.addLog(
          '⚠ DIAG: all HTTPS targets failed (attempt #$consecutiveAllFailed) '
          '— continuing to wait, network may be blocking targets',
        );

        if (consecutiveAllFailed >= 3) {
          processService.addLog(
            '✗ DIAG: all-targets-failed sustained for 3 attempts — '
            'aborting wait',
          );
          return SocksDiag.allTargetsFailed;
        }
      } else {
        consecutiveAllFailed = 0;
      }

      if (last == SocksDiag.tunnelDead) {
        consecutiveTunnelDead++;

        if (consecutiveTunnelDead == 1) {
          processService.addLog(
            '⚠ DIAG: tunnel appears dead (attempt #1) — '
            're-probing once before declaring dead',
          );
          await Future.delayed(const Duration(seconds: 3));
          continue;
        }

        processService.addLog(
          '✗ DIAG: tunnel dead confirmed (2 consecutive checks) — '
          'aborting wait, will retry endpoint',
        );
        return SocksDiag.tunnelDead;
      } else {
        consecutiveTunnelDead = 0;
      }

      // ─── fallback: curl probe ───
      if (await fallbacks.curlProbe(port)) {
        processService.addLog('✓ DIAG: curl probe succeeded (fallback)');
        return SocksDiag.healthy;
      }

      // ─── fallback: log-based ───
      if (last != SocksDiag.tunnelDead &&
          last != SocksDiag.allTargetsFailed &&
          fallbacks.coreSaysReady(port)) {
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
