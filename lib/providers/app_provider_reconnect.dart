part of 'app_provider.dart';

extension AppProviderReconnect on AppProvider {
  void checkAutoReconnects() {
    if (!processService.isPsiphonRunning &&
        !userStoppedPsiphon &&
        settings.autoReconnectPsiphon &&
        !isPsiphonBusy &&
        !isAutoTesting &&
        !restartingPsiphon) {
      _reconnectManager.schedulePsiphonReconnect(
        shouldReconnect: () =>
            !processService.isPsiphonRunning &&
            !userStoppedPsiphon &&
            settings.autoReconnectPsiphon &&
            !isPsiphonBusy &&
            !isAutoTesting &&
            !restartingPsiphon &&
            !isShuttingDown,
        onReconnect: () => connectPsiphon(fromAutoReconnect: true),
        log: processService.addLog,
      );
    }

    if (!processService.isAetherRunning &&
        !userStoppedAether &&
        !isAutoTesting &&
        settings.autoReconnectAether &&
        !isPsiphonBusy &&
        !restartingAether) {
      _reconnectManager.scheduleAetherReconnect(
        shouldReconnect: () =>
            !processService.isAetherRunning &&
            !userStoppedAether &&
            settings.autoReconnectAether &&
            !isPsiphonBusy &&
            !isAutoTesting &&
            !restartingAether &&
            !isShuttingDown,
        onReconnect: () => connectAether(fromAutoReconnect: true),
        log: processService.addLog,
      );
    }

    if (!processService.isTorRunning &&
        !userStoppedTor &&
        settings.autoReconnectTor &&
        !isTorBusy &&
        !isAutoTesting &&
        !restartingTor) {
      _reconnectManager.scheduleTorReconnect(
        shouldReconnect: () =>
            !processService.isTorRunning &&
            !userStoppedTor &&
            settings.autoReconnectTor &&
            !isTorBusy &&
            !isAutoTesting &&
            !restartingTor &&
            !isShuttingDown,
        onReconnect: () => connectTor(fromAutoReconnect: true),
        log: processService.addLog,
      );
    }

    if (!processService.isSstpRunning &&
        !userStoppedSstp &&
        settings.autoReconnectSstp &&
        !isSstpBusy &&
        !isAutoTesting &&
        !restartingSstp) {
      _reconnectManager.scheduleSstpReconnect(
        shouldReconnect: () =>
            !processService.isSstpRunning &&
            !userStoppedSstp &&
            settings.autoReconnectSstp &&
            !isSstpBusy &&
            !isAutoTesting &&
            !restartingSstp &&
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
