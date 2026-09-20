part of 'app_provider.dart';

extension AppProviderSstp on AppProvider {
  /// ═══════════════════════════════════════════════════════════════
  ///  connectSstp — entry point عمومی
  /// ═══════════════════════════════════════════════════════════════
  Future<void> connectSstp({bool fromAutoReconnect = false}) async {
    if (fromAutoReconnect) {
      await startSstpInternal(fromAutoReconnect: true);
      return;
    }

    final isCurrentlyActive = processService.isSstpRunning || isSstpBusy;

    if (isCurrentlyActive) {
      await stopSstpByUser();
    } else {
      await startSstpInternal(fromAutoReconnect: false);
    }
  }

  Future<void> stopSstpByUser() async {
    const src = LogSource.sstp;

    userStoppedSstp = true;
    _reconnectManager.cancelSstpTimer();
    _reconnectManager.resetRetries('sstp');
    _aetherTestService.requestCancel();
    _recoveryCoordinator.releaseLeaseByTunnel('SSTP');

    nextSstpGeneration();

    try {
      await processService.stopSstp();
    } catch (e) {
      processService.addLog('⚠ SSTP stop error: $e', source: src);
    }

    isSstpBusy = false;
    sstpStatus = 'SSTP: Stopped';
    watchdogManager?.sstp.resetGracePeriod();
    watchdogManager?.sstp.resetCircuitBreaker();

    await AppDataService.fixDataDirOwnership();
    touch();
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  restartSstpInternal — برای watchdog و health degradation.
  ///
  ///  ⚠️ در این نسخه reconnect در TunnelHealthRegistry ثبت می‌شود.
  /// ═══════════════════════════════════════════════════════════════
  Future<void> restartSstpInternal({required String reason}) async {
    const src = LogSource.sstp;

    if (userStoppedSstp || isShuttingDown) {
      processService.addLog(
        '→ restartSstpInternal skipped '
        '(userStopped=$userStoppedSstp, shutdown=$isShuttingDown)',
        source: src,
      );
      return;
    }

    if (restartingSstp) {
      processService.addLog(
        '→ restartSstpInternal skipped (already restarting)',
        source: src,
      );
      return;
    }

    restartingSstp = true;
    try {
      processService.addLog('↻ Restarting SSTP — reason: $reason', source: src);
      processService.setSadNotification('SSTP');

      // ═══════════════════════════════════════════════════════════
      //  ثبت reconnect در Health Registry
      // ═══════════════════════════════════════════════════════════
      recordTunnelReconnect(TunnelKind.sstp);

      _reconnectManager.cancelSstpTimer();

      nextSstpGeneration();

      await processService.stopSstp();
      await Future.delayed(const Duration(seconds: 3));

      if (!userStoppedSstp && !isShuttingDown) {
        await startSstpInternal(fromAutoReconnect: true);
      }
    } finally {
      restartingSstp = false;
    }
  }
}
