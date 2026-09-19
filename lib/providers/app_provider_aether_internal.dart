part of 'app_provider.dart';

extension AppProviderAetherInternal on AppProvider {
  /// ═══════════════════════════════════════════════════════════════
  ///  _startAetherInternal — start یا restart داخلی.
  ///
  ///  این متد هرگز userStoppedAether را true نمی‌کند.
  /// ═══════════════════════════════════════════════════════════════
  Future<void> _startAetherInternal({
    required bool fromAutoReconnect,
  }) async {
    const src = LogSource.aether;

    if (!fromAutoReconnect) {
      _reconnectManager.cancelAetherTimer();
    }

    if (fromAutoReconnect && userStoppedAether) {
      processService.addLog(
        '→ Aether auto-reconnect skipped (stopped by user)',
        source: src,
      );
      return;
    }

    if (fromAutoReconnect && isAutoTesting) {
      processService.addLog(
        '→ Aether auto-reconnect skipped (already auto-testing)',
        source: src,
      );
      return;
    }

    if (processService.isAetherRunning && !fromAutoReconnect) {
      processService.addLog(
        '→ Aether is already running — ignoring redundant start',
        source: src,
      );
      return;
    }

    if (!await _preflightAetherBinary(src)) return;
    if (!await _preflightAetherPtDir(src)) return;
    if (!await _preflightAetherPort(src)) return;

    if (!fromAutoReconnect) {
      userStoppedAether = false;
    }

    touch();

    final wasRunning = processService.isAetherRunning;

    try {
      aetherStatus = settings.aetherProtocol == 'auto'
          ? 'Aether: Auto-testing protocols…'
          : 'Aether: Starting…';
      touch();

      isAutoTesting = true;
      final ok = await _aetherTestService.ensureHealthy(showUi: true);
      isAutoTesting = false;

      if (ok) {
        aetherStatus = 'Aether: Healthy';
      } else if (wasRunning && processService.isAetherRunning) {
        aetherStatus = 'Aether: Running (unverified but stable)';
        processService.addLog(
          '⚠ Auto-test failed but Aether was already running — '
          'keeping it alive',
          source: src,
        );
      } else if (processService.isAetherRunning) {
        aetherStatus = 'Aether: Running (unverified)';
      } else {
        aetherStatus = 'Aether: Auto-test failed';
      }
    } catch (e) {
      processService.addLog('✗ connectAether error: $e', source: src);
      aetherStatus = 'Aether: Error';
    }

    await AppDataService.fixDataDirOwnership();
    touch();
  }

  /// restartAetherInternal — برای استفاده watchdog.
  Future<void> restartAetherInternal({required String reason}) async {
    const src = LogSource.aether;

    if (userStoppedAether || isShuttingDown) {
      processService.addLog(
        '→ restartAetherInternal skipped '
        '(userStopped=$userStoppedAether, shutdown=$isShuttingDown)',
        source: src,
      );
      return;
    }

    if (restartingAether) {
      processService.addLog(
        '→ restartAetherInternal skipped (already restarting)',
        source: src,
      );
      return;
    }

    restartingAether = true;
    try {
      processService.addLog(
        '↻ Restarting Aether — reason: $reason',
        source: src,
      );
      processService.setSadNotification('Aether');

      _reconnectManager.cancelAetherTimer();
      nextAetherGeneration();

      await processService.stopAether();
      await Future.delayed(const Duration(seconds: 3));

      if (!userStoppedAether && !isShuttingDown) {
        await _startAetherInternal(fromAutoReconnect: true);
      }
    } finally {
      restartingAether = false;
    }
  }
}
