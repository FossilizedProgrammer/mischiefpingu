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
    } else {
      await startPsiphonInternal(fromAutoReconnect: false);
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  stopPsiphonByUser — تنها جایی که userStoppedPsiphon=true می‌شود.
  /// ═══════════════════════════════════════════════════════════════
  Future<void> stopPsiphonByUser() async {
    const src = LogSource.psiphon;

    userStoppedPsiphon = true;
    _reconnectManager.cancelPsiphonTimer();
    _reconnectManager.resetRetries('psiphon');
    _aetherTestService.requestCancel();
    _recoveryCoordinator.releaseLeaseByTunnel('Psiphon');

    nextPsiphonGeneration();

    try {
      await processService.stopPsiphon();
    } catch (e) {
      processService.addLog('⚠ Psiphon stop error: $e', source: src);
    }

    isPsiphonBusy = false;
    isLoading = false;
    watchdogManager?.psiphon.resetGracePeriod();
    watchdogManager?.psiphon.resetCircuitBreaker();

    await AppDataService.fixDataDirOwnership();
    touch();
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  restartPsiphonInternal — برای watchdog و health degradation.
  ///
  ///  ⚠️ در این نسخه reconnect در TunnelHealthRegistry ثبت می‌شود
  ///  تا Health Score penalty بگیرد.
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

      // ═══════════════════════════════════════════════════════════
      //  ثبت reconnect در Health Registry
      //
      //  این باعث می‌شه:
      //    • reconnectCount در health report افزایش پیدا کنه
      //    • امتیاز health penalty بگیره
      //    • trend احتمالاً به degrading بره
      // ═══════════════════════════════════════════════════════════
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
