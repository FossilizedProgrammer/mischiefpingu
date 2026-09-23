part of 'app_provider.dart';

extension AppProviderTor on AppProvider {
  Future<int> _pickInternalPort(int publicPort) =>
      PortManager.internalFor(publicPort: publicPort);

  Future<void> connectTor({bool fromAutoReconnect = false}) async {
    if (fromAutoReconnect) {
      await startTorInternal(fromAutoReconnect: true);
      return;
    }

    final isCurrentlyActive = processService.isTorRunning || isTorBusy;

    if (isCurrentlyActive) {
      await stopTorByUser();
      return; // ⚠️ FIX: بعد از stop، دیگه start نکن
    }

    await startTorInternal(fromAutoReconnect: false);
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  stopTorByUser — توقف Tor.
  ///
  ///  ⚠️ FIX: generation رو عوض می‌کنیم تا start قبلی در finally
  ///  دیگه flag رو ریست نکنه. ولی خودمون فوری ریست می‌کنیم.
  /// ═══════════════════════════════════════════════════════════════
  Future<void> stopTorByUser() async {
    const src = LogSource.tor;

    userStoppedTor = true;
    _reconnectManager.cancelTorTimer();
    _reconnectManager.resetRetries('tor');
    _aetherTestService.requestCancel();
    _recoveryCoordinator.releaseLeaseByTunnel('Tor');

    nextTorGeneration();

    try {
      await processService.stopTor();
    } catch (e) {
      processService.addLog('⚠ Tor stop error: $e', source: src);
    }

    // ⚠️ FIX: فوری ریست کن
    isTorBusy = false;
    torStatus = 'Tor: Stopped';
    watchdogManager?.tor.resetGracePeriod();
    watchdogManager?.tor.resetCircuitBreaker();

    await AppDataService.fixDataDirOwnership();
    touch();
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  restartTorInternal — برای watchdog و health degradation.
  /// ═══════════════════════════════════════════════════════════════
  Future<void> restartTorInternal({required String reason}) async {
    const src = LogSource.tor;

    if (userStoppedTor || isShuttingDown) {
      processService.addLog(
        '→ restartTorInternal skipped '
        '(userStopped=$userStoppedTor, shutdown=$isShuttingDown)',
        source: src,
      );
      return;
    }

    if (restartingTor) {
      processService.addLog(
        '→ restartTorInternal skipped (already restarting)',
        source: src,
      );
      return;
    }

    restartingTor = true;
    try {
      processService.addLog('↻ Restarting Tor — reason: $reason', source: src);
      processService.setSadNotification('Tor');

      recordTunnelReconnect(TunnelKind.tor);

      _reconnectManager.cancelTorTimer();

      nextTorGeneration();

      await processService.stopTor();
      await Future.delayed(const Duration(seconds: 3));

      if (!userStoppedTor && !isShuttingDown) {
        await startTorInternal(fromAutoReconnect: true);
      }
    } finally {
      restartingTor = false;
    }
  }

  /// برای دسترسی از فایل `tor/tor_launch.dart`
  Future<int> pickInternalPort(int publicPort) => _pickInternalPort(publicPort);
}
