part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  restartAetherInternal — برای watchdog و health degradation.
///
///  این متد:
///    • چک می‌کنه که user دستی stop نکرده باشه
///    • چک می‌کنه که parallel restart نباشه
///    • sad notification می‌فرسته
///    • performance tracker رو cancel می‌کنه
///    • stop + delay + start می‌کنه
///
///  ⚠️ نکته: این متد در `restartAetherInternal` عمومی هست و
///  توسط watchdog/health استفاده می‌شه.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderAetherRestart on AppProvider {
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

      _logConnectionLost(reason);

      aetherReconnectCount++;

      // ─── cancel performance tracker ───
      try {
        await _aetherTestService.performanceTracker?.cancel();
      } catch (_) {}

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

  /// لاگ connection_lost در EventStore.
  void _logConnectionLost(String reason) {
    if (lastAetherConnectedAt == null) return;

    _aetherLogger.connectionLost(
      settings: settings,
      protocol: lastAetherConnectedProtocol ?? 'unknown',
      masque: settings.masqueOption,
      uptime: DateTime.now().difference(lastAetherConnectedAt!),
      reason: reason,
      reconnectCount: aetherReconnectCount,
    );
  }
}
