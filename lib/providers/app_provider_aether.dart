part of 'app_provider.dart';

extension AppProviderAether on AppProvider {
  /// ═══════════════════════════════════════════════════════════════
  ///  connectAether — entry point عمومی.
  ///
  ///  فقط تصمیم می‌گیرد: user خواسته start کند یا stop؟
  ///
  ///  ⚠️ FIX: بعد از stop، حتماً return می‌کنیم تا وارد start نشه.
  /// ═══════════════════════════════════════════════════════════════
  Future<void> connectAether({bool fromAutoReconnect = false}) async {
    if (fromAutoReconnect) {
      await _startAetherInternal(fromAutoReconnect: true);
      return;
    }

    final isCurrentlyActive = processService.isAetherRunning || isAutoTesting;

    if (isCurrentlyActive) {
      await _stopAetherByUser();
      return; // ⚠️ FIX: بعد از stop، دیگه start نکن
    }

    await _startAetherInternal(fromAutoReconnect: false);
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  _stopAetherByUser — توقف کامل Aether.
  ///
  ///  ⚠️ FIX: isAutoTesting فوری ریست می‌شه تا دکمه گیر نکنه.
  /// ═══════════════════════════════════════════════════════════════
  Future<void> _stopAetherByUser() async {
    const src = LogSource.aether;

    userStoppedAether = true;
    _reconnectManager.cancelAetherTimer();
    _reconnectManager.resetRetries('aether');
    _aetherTestService.requestCancel();
    _recoveryCoordinator.releaseLeaseByTunnel('Aether');

    // ⚠️ FIX: ریست فوری flag — جلوگیری از گیر کردن دکمه در حالت Cancel
    isAutoTesting = false;
    restartingAether = false;
    touch();

    // ─── Cancel tracker ───
    try {
      await _aetherTestService.performanceTracker?.cancel();
    } catch (_) {}

    // ─── ثبت connection_lost (Structured Logging) ───
    if (lastAetherConnectedAt != null) {
      _aetherLogger.connectionLost(
        settings: settings,
        protocol: lastAetherConnectedProtocol ?? 'unknown',
        masque: settings.masqueOption,
        uptime: DateTime.now().difference(lastAetherConnectedAt!),
        reason: 'user_stop',
        reconnectCount: aetherReconnectCount,
      );
    }

    try {
      await processService.stopAether();
    } catch (e) {
      processService.addLog('⚠ Aether stop error: $e', source: src);
    }

    aetherStatus = 'Aether: Stopped';
    watchdogManager?.aether.resetGracePeriod();
    watchdogManager?.aether.resetCircuitBreaker();

    // ─── فاز ۶: reset session state ───
    lastAetherConnectedProtocol = null;
    lastAetherConnectedGatewayKey = null;
    lastAetherConnectedAt = null;
    aetherReconnectCount = 0;

    await AppDataService.fixDataDirOwnership();
    touch();
  }
}
