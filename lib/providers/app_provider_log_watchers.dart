part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderLogWatchers — feed کردن log watcherها.
///
///  ⚠️ منطق verify + restart به
///  `app_provider_log_watchers_verify.dart` منتقل شد.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderLogWatchers on AppProvider {
  /// این متد از logStream صدا زده می‌شود — هر خط جدید.
  void feedLogWatchers(String line) {
    if (isShuttingDown) return;
    // ═══════════════════════════════════════════════════════════
    //  Health registry feed
    // ═══════════════════════════════════════════════════════════
    try {
      _healthRegistry.feedLog(line);
    } catch (e) {
      processService.addLog(
        '⚠ health registry feed failed: $e',
        source: LogSource.app,
      );
    }
    // ─── Psiphon ───
    if (processService.isPsiphonConnected && !restartingPsiphon) {
      final dead = psiphonLog.feed(line);
      if (dead && !userStoppedPsiphon && !isShuttingDown) {
        _verifyAndRestartPsiphon();
      }
    } else if (!processService.isPsiphonConnected) {
      psiphonLog.reset();
    }
    // ─── Tor ───
    if (processService.isTorRunning && !restartingTor) {
      final dead = torLog.feed(line);
      if (dead && !userStoppedTor && !isShuttingDown) {
        _verifyAndRestartTor();
      }
    } else if (!processService.isTorRunning) {
      torLog.reset();
    }
    // ─── SSTP ───
    if (processService.isSstpRunning && !restartingSstp) {
      final dead = sstpLog.feed(line);
      if (dead && !userStoppedSstp && !isShuttingDown) {
        _verifyAndRestartSstp();
      }
    } else if (!processService.isSstpRunning) {
      sstpLog.reset();
    }
    // ─── WireGuard ───
    if (processService.isWireGuardRunning && !restartingWireGuard) {
      final dead = _wireGuardLog.feed(line);
      if (dead && !userStoppedWireGuard && !isShuttingDown) {
        _verifyAndRestartWireGuard();
      }
    } else if (!processService.isWireGuardRunning) {
      _wireGuardLog.reset();
    }
  }
}
