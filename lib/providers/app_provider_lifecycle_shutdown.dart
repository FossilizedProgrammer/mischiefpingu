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
      if (processService.isFfvpnRunning || isFfvpnBusy) {
        processService.addLog(
          '→ Stopping Firefox VPN…',
          source: LogSource.app,
        );
        await processService.stopFfvpn();
      }
    } catch (e) {
      processService.addLog(
        '⚠ Firefox VPN shutdown error: $e',
        source: LogSource.app,
      );
    }
    try {
      await processService.closeAllForwardSockets();
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 300));
    processService.addLog(
      '★ All tunnels disconnected. Safe to exit.',
      source: LogSource.app,
    );
  }
}
