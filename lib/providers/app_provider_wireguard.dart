part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderWireGuard — entry point + stop + restart.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderWireGuard on AppProvider {
  /// connectWireGuard — entry point عمومی.
  Future<void> connectWireGuard({bool fromAutoReconnect = false}) async {
    if (fromAutoReconnect) {
      await _startWireGuardInternal(fromAutoReconnect: true);
      return;
    }

    final isCurrentlyActive =
        processService.isWireGuardRunning || isWireGuardBusy;

    if (isCurrentlyActive) {
      await stopWireGuardByUser();
      return;
    }

    await _startWireGuardInternal(fromAutoReconnect: false);
  }

  /// توقف کامل WireGuard.
  Future<void> stopWireGuardByUser() async {
    const src = LogSource.wireguard;

    userStoppedWireGuard = true;
    _reconnectManager.cancelWireGuardTimer();
    _reconnectManager.resetRetries('wireguard');
    _recoveryCoordinator.releaseLeaseByTunnel('WireGuard');

    nextWireGuardGeneration();

    try {
      await processService.stopWireGuard();
    } catch (e) {
      processService.addLog('⚠ WireGuard stop error: $e', source: src);
    }

    isWireGuardBusy = false;
    wireGuardStatus = 'WireGuard: Stopped';
    watchdogManager?.wireguard.resetGracePeriod();
    watchdogManager?.wireguard.resetCircuitBreaker();

    await AppDataService.fixDataDirOwnership();
    touch();
  }

  /// restartWireGuardInternal — برای watchdog و health degradation.
  Future<void> restartWireGuardInternal({required String reason}) async {
    const src = LogSource.wireguard;

    if (userStoppedWireGuard || isShuttingDown) {
      processService.addLog(
        '→ restartWireGuardInternal skipped '
        '(userStopped=$userStoppedWireGuard, shutdown=$isShuttingDown)',
        source: src,
      );
      return;
    }

    if (restartingWireGuard) {
      processService.addLog(
        '→ restartWireGuardInternal skipped (already restarting)',
        source: src,
      );
      return;
    }

    restartingWireGuard = true;
    try {
      processService.addLog(
        '↻ Restarting WireGuard — reason: $reason',
        source: src,
      );
      processService.setSadNotification('WireGuard');

      recordTunnelReconnect(TunnelKind.wireguard);

      _reconnectManager.cancelWireGuardTimer();
      nextWireGuardGeneration();

      await processService.stopWireGuard();
      await Future.delayed(const Duration(seconds: 3));

      if (!userStoppedWireGuard && !isShuttingDown) {
        await _startWireGuardInternal(fromAutoReconnect: true);
      }
    } finally {
      restartingWireGuard = false;
    }
  }
}
