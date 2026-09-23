part of 'app_provider.dart';

extension AppProviderPsiphon on AppProvider {
  /// ═══════════════════════════════════════════════════════════════
  ///  connectPsiphon — entry point عمومی
  /// ═══════════════════════════════════════════════════════════════
  Future<void> connectPsiphon({bool fromAutoReconnect = false}) async {
    if (fromAutoReconnect) {
      await startPsiphonInternal(fromAutoReconnect: true);
      return;
    }

    final isCurrentlyActive = processService.isPsiphonRunning || isPsiphonBusy;

    if (isCurrentlyActive) {
      await stopPsiphonByUser();
      return; // ⚠️ FIX: بعد از stop، دیگه start نکن
    }

    await startPsiphonInternal(fromAutoReconnect: false);
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  stopPsiphonByUser — تنها جایی که userStoppedPsiphon=true می‌شود.
  ///
  ///  ⚠️ FIX: flagهای busy رو اینجا ریست نمی‌کنیم — می‌ذاریم start
  ///  خودش در finally با generation check ریست کنه.
  /// ═══════════════════════════════════════════════════════════════
  Future<void> stopPsiphonByUser() async {
    const src = LogSource.psiphon;

    userStoppedPsiphon = true;
    _reconnectManager.cancelPsiphonTimer();
    _reconnectManager.resetRetries('psiphon');
    _aetherTestService.requestCancel();
    _recoveryCoordinator.releaseLeaseByTunnel('Psiphon');

    // ⚠️ FIX: generation رو عوض کن — start قبلی در finally دیگه flag ریست نمی‌کنه
    nextPsiphonGeneration();

    try {
      await processService.stopPsiphon();
    } catch (e) {
      processService.addLog('⚠ Psiphon stop error: $e', source: src);
    }

    // ⚠️ FIX: فوری ریست کن تا UI پاسخ بده
    isPsiphonBusy = false;
    isLoading = false;
    watchdogManager?.psiphon.resetGracePeriod();
    watchdogManager?.psiphon.resetCircuitBreaker();

    await AppDataService.fixDataDirOwnership();
    touch();
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  restartPsiphonInternal — برای watchdog و health degradation.
  /// ═══════════════════════════════════════════════════════════════
  Future<void> restartPsiphonInternal({required String reason}) async {
    const src = LogSource.psiphon;

    if (userStoppedPsiphon || isShuttingDown) {
      processService.addLog(
        '→ restartPsiphonInternal skipped '
        '(userStopped=$userStoppedPsiphon, shutdown=$isShuttingDown)',
        source: src,
      );
      return;
    }

    if (restartingPsiphon) {
      processService.addLog(
        '→ restartPsiphonInternal skipped (already restarting)',
        source: src,
      );
      return;
    }

    restartingPsiphon = true;
    try {
      processService.addLog(
        '↻ Restarting Psiphon — reason: $reason',
        source: src,
      );
      processService.setSadNotification('Psiphon');

      recordTunnelReconnect(TunnelKind.psiphon);

      _reconnectManager.cancelPsiphonTimer();

      nextPsiphonGeneration();

      await processService.stopPsiphon();
      await Future.delayed(const Duration(seconds: 3));

      if (!userStoppedPsiphon && !isShuttingDown) {
        await startPsiphonInternal(fromAutoReconnect: true);
      }
    } finally {
      restartingPsiphon = false;
    }
  }

  String buildPsiphonConfig() {
    final builder = PsiphonConfigBuilder(
      settings: settings,
      ipList: ipList,
      processService: processService,
    );
    return builder.build();
  }
}
