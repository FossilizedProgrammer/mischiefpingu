// lib/providers/app_provider_reconnect.dart
part of 'app_provider.dart';

extension AppProviderReconnect on AppProvider {
  void checkAutoReconnects() {
    // ─── Psiphon ───
    if (!processService.isPsiphonRunning &&
        !userStoppedPsiphon &&
        settings.autoReconnectPsiphon &&
        !isPsiphonBusy &&
        !isAutoTesting &&
        !restartingPsiphon) {
      // ← تغییر
      _reconnectManager.schedulePsiphonReconnect(
        shouldReconnect: () =>
            !processService.isPsiphonRunning &&
            !userStoppedPsiphon &&
            settings.autoReconnectPsiphon &&
            !isPsiphonBusy &&
            !isAutoTesting &&
            !restartingPsiphon && // ← تغییر
            !isShuttingDown,
        onReconnect: () => connectPsiphon(fromAutoReconnect: true),
        log: processService.addLog,
      );
    }

    // ─── Aether ───
    if (!processService.isAetherRunning &&
        !userStoppedAether &&
        !isAutoTesting &&
        settings.autoReconnectAether &&
        !isPsiphonBusy &&
        !restartingAether) {
      // ← تغییر
      _reconnectManager.scheduleAetherReconnect(
        shouldReconnect: () =>
            !processService.isAetherRunning &&
            !userStoppedAether &&
            settings.autoReconnectAether &&
            !isPsiphonBusy &&
            !isAutoTesting &&
            !restartingAether && // ← تغییر
            !isShuttingDown,
        onReconnect: () => connectAether(fromAutoReconnect: true),
        log: processService.addLog,
      );
    }

    // ─── Tor ───
    if (!processService.isTorRunning &&
        !userStoppedTor &&
        settings.autoReconnectTor &&
        !isTorBusy &&
        !isAutoTesting &&
        !restartingTor) {
      // ← تغییر
      _reconnectManager.scheduleTorReconnect(
        shouldReconnect: () =>
            !processService.isTorRunning &&
            !userStoppedTor &&
            settings.autoReconnectTor &&
            !isTorBusy &&
            !isAutoTesting &&
            !restartingTor && // ← تغییر
            !isShuttingDown,
        onReconnect: () => connectTor(fromAutoReconnect: true),
        log: processService.addLog,
      );
    }

    // ─── SSTP ───
    if (!processService.isSstpRunning &&
        !userStoppedSstp &&
        settings.autoReconnectSstp &&
        !isSstpBusy &&
        !isAutoTesting &&
        !restartingSstp) {
      // ← تغییر
      _reconnectManager.scheduleSstpReconnect(
        shouldReconnect: () =>
            !processService.isSstpRunning &&
            !userStoppedSstp &&
            settings.autoReconnectSstp &&
            !isSstpBusy &&
            !isAutoTesting &&
            !restartingSstp && // ← تغییر
            !isShuttingDown,
        onReconnect: () => connectSstp(fromAutoReconnect: true),
        log: processService.addLog,
      );
    }
  }

  void updateTunnelStatuses() {
    if (processService.isTorRunning) {
      if (processService.isTorConnected) {
        torStatus = 'Tor: Connected';
      } else if (torStatus == 'Tor: Ready' || torStatus == 'Tor: Stopped') {
        torStatus = 'Tor: Bootstrapping…';
      }
    }

    if (processService.isSstpRunning) {
      if (processService.isSstpConnected) {
        sstpStatus = 'SSTP: Connected';
      } else if (sstpStatus == 'SSTP: Ready' || sstpStatus == 'SSTP: Stopped') {
        sstpStatus = 'SSTP: Connecting…';
      }
    }
  }
}
