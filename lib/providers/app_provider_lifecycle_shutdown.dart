part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderLifecycleShutdown — منطق shutdown کامل برنامه.
///
///  این extension از `app_provider_lifecycle.dart` جدا شده
///  تا فایل اصلی فقط startup رو نگه داره.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderLifecycleShutdown on AppProvider {
  Future<void> shutdownAllInternal() async {
    if (isShuttingDown) return;
    isShuttingDown = true;
    try {
      watchdogManager?.disposeAll();
    } catch (_) {}
    processService.addLog(
      '→ App is closing — disconnecting all active tunnels…',
      source: LogSource.app,
    );
    reconnectManager.cancelAll();
    try {
      aetherTestService.requestCancel();
    } catch (_) {}
    try {
      if (processService.isPsiphonRunning || isPsiphonBusy) {
        processService.addLog('→ Stopping Psiphon…', source: LogSource.app);
        await processService.stopPsiphon();
      }
    } catch (e) {
      processService.addLog(
        '⚠ Psiphon shutdown error: $e',
        source: LogSource.app,
      );
    }
    try {
      if (processService.isTorRunning || isTorBusy) {
        processService.addLog('→ Stopping Tor…', source: LogSource.app);
        await processService.stopTor();
      }
    } catch (e) {
      processService.addLog('⚠ Tor shutdown error: $e', source: LogSource.app);
    }
    try {
      if (processService.isSstpRunning || isSstpBusy) {
        processService.addLog('→ Stopping SSTP…', source: LogSource.app);
        await processService.stopSstp();
      }
    } catch (e) {
      processService.addLog('⚠ SSTP shutdown error: $e', source: LogSource.app);
    }
    try {
      if (processService.isAetherRunning || isAutoTesting) {
        processService.addLog('→ Stopping Aether…', source: LogSource.app);
        await processService.stopAether();
      }
    } catch (e) {
      processService.addLog(
        '⚠ Aether shutdown error: $e',
        source: LogSource.app,
      );
    }
    try {
      if (processService.isWireGuardRunning || isWireGuardBusy) {
        processService.addLog('→ Stopping WireGuard…', source: LogSource.app);
        await processService.stopWireGuard();
      }
    } catch (e) {
      processService.addLog(
        '⚠ WireGuard shutdown error: $e',
        source: LogSource.app,
      );
    }
    try {
      await processService.closeAllForwardSockets();
    } catch (_) {}
    // ─── بستن دیتابیس ───
    try {
      await GatewayDatabase.close();
      processService.addLog(
        '→ Gateway history database closed',
        source: LogSource.app,
      );
    } catch (e) {
      processService.addLog(
        '⚠ Failed to close gateway DB: $e',
        source: LogSource.app,
      );
    }
    await Future.delayed(const Duration(milliseconds: 300));
    processService.addLog(
      '★ All tunnels disconnected. Safe to exit.',
      source: LogSource.app,
    );
  }
}
