part of 'app_provider.dart';

extension AppProviderAether on AppProvider {
  /// ═══════════════════════════════════════════════════════════════
  ///  connectAether — entry point عمومی.
  ///
  ///  فقط تصمیم می‌گیرد: user خواسته start کند یا stop؟
  /// ═══════════════════════════════════════════════════════════════
  Future<void> connectAether({bool fromAutoReconnect = false}) async {
    if (fromAutoReconnect) {
      await _startAetherInternal(fromAutoReconnect: true);
      return;
    }

    final isCurrentlyActive = processService.isAetherRunning || isAutoTesting;

    if (isCurrentlyActive) {
      await _stopAetherByUser();
    } else {
      await _startAetherInternal(fromAutoReconnect: false);
    }
  }

  Future<void> _stopAetherByUser() async {
    const src = LogSource.aether;

    userStoppedAether = true;
    _reconnectManager.cancelAetherTimer();
    _reconnectManager.resetRetries('aether');
    _aetherTestService.requestCancel();
    _recoveryCoordinator.releaseLeaseByTunnel('Aether');

    try {
      await processService.stopAether();
    } catch (e) {
      processService.addLog('⚠ Aether stop error: $e', source: src);
    }

    aetherStatus = 'Aether: Stopped';
    watchdogManager?.aether.resetGracePeriod();
    watchdogManager?.aether.resetCircuitBreaker();

    await AppDataService.fixDataDirOwnership();
    touch();
  }
}
