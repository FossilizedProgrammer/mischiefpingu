part of '../tunnel_watchdog.dart';

/// ═══════════════════════════════════════════════════════════════
///  منطق اصلی _check().
/// ═══════════════════════════════════════════════════════════════
extension TunnelWatchdogCheckRunner on TunnelWatchdog {
  Future<void> runCheck() async {
    if (disposed || checkRunning || restartInProgress) return;

    if (circuit.isOpen()) {
      final remaining = circuit.timeUntilClose();
      log(
        '→ $name watchdog: circuit OPEN, '
        '${remaining.inSeconds}s remaining — skipping probe',
        source: logSource,
      );
      return;
    }

    if (circuit.wasJustClosed()) {
      log(
        '★ $name watchdog: circuit CLOSED — resuming probes',
        source: logSource,
      );
    }

    if (decider.isInGracePeriod()) {
      final remaining = decider.graceTimeRemaining();
      log(
        '→ $name watchdog: in grace period, '
        '${remaining.inSeconds}s remaining',
        source: logSource,
      );
      return;
    }

    if (!isConnected()) {
      failures = 0;
      qualityTracker.reset();
      return;
    }
    if (isUserStopped()) {
      failures = 0;
      qualityTracker.reset();
      return;
    }
    if (isBusy?.call() ?? false) {
      log('→ $name watchdog: busy, skipping probe', source: logSource);
      return;
    }

    checkRunning = true;
    try {
      final metrics = await prober.probeWithMetrics();
      if (disposed) return;

      // ─── مسیر 1: probe موفق ───
      if (metrics.isFullyAlive) {
        final level = qualityTracker.record(metrics);
        final isQualityBad =
            level == QualityLevel.degraded || level == QualityLevel.failing;

        if (isQualityBad) {
          log(
            '⚠ $name watchdog: probe alive but quality=$level '
            '(lat=${metrics.latencyMs}ms, jitter=${metrics.jitterMs}ms, '
            'streak=${qualityTracker.degradedStreak}/'
            '${WatchdogConfig.degradedConsecutiveLimit})',
            source: logSource,
          );

          if (WatchdogConfig.enableQualityBasedRestart &&
              qualityTracker.shouldRestartForQuality) {
            log(
              '⚠ $name watchdog: restarting due to sustained quality '
              'degradation (${qualityTracker.degradedStreak} consecutive '
              'degraded probes)',
              source: logSource,
            );
            await decider.attemptRestart();
            return;
          }
        } else {
          if (failures > 0) {
            log(
              '★ $name watchdog: tunnel recovered (was $failures/$maxFailures)',
              source: logSource,
            );
          }
          failures = 0;

          // لاگ سطح کیفیت برای شفافیت
          if (level == QualityLevel.excellent || level == QualityLevel.good) {
            log(
              '✓ $name watchdog: quality=$level (lat=${metrics.latencyMs}ms)',
              source: logSource,
            );
          }
        }
        return;
      }

      // ─── مسیر 2: probe شکست خورده (hard fail) ───
      qualityTracker.reset();
      failures = failures + 1;
      log(
        '⚠ $name watchdog: probe failed ($failures/$maxFailures) — '
        'tcp=${metrics.tcpOk}, greet=${metrics.socksGreetingOk}, '
        'connect=${metrics.socksConnectOk}, http=${metrics.httpStatusOk}',
        source: logSource,
      );

      if (failures >= maxFailures) {
        await decider.attemptRestart();
      }
    } catch (e) {
      log('⚠ $name watchdog error: $e', source: logSource);
    } finally {
      checkRunning = false;
    }
  }
}
