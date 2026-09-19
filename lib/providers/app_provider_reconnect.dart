part of 'app_provider.dart';

extension AppProviderReconnect on AppProvider {
  /// ⚠️ این متد فقط از `handleProcessServiceChange` صدا زده می‌شود،
  /// و آن هم فقط وقتی state واقعی تغییر کرده باشد.
  void checkAutoReconnects() {
    if (!processService.isPsiphonRunning &&
        !isPsiphonBusy &&
        !isLoading &&
        processService.psiphonPid == null &&
        !userStoppedPsiphon &&
        settings.autoReconnectPsiphon &&
        !isAutoTesting &&
        !restartingPsiphon) {
      _reconnectManager.schedulePsiphonReconnect(
        shouldReconnect: () =>
            !processService.isPsiphonRunning &&
            !isPsiphonBusy &&
            !isLoading &&
            processService.psiphonPid == null &&
            !userStoppedPsiphon &&
            settings.autoReconnectPsiphon &&
            !isAutoTesting &&
            !restartingPsiphon &&
            !isShuttingDown,
        onReconnect: () => connectPsiphon(fromAutoReconnect: true),
        log: processService.addLog,
      );
    } else if (processService.isPsiphonRunning ||
        isPsiphonBusy ||
        userStoppedPsiphon) {
      _reconnectManager.cancelPsiphonTimer();
    }

    if (!processService.isAetherRunning &&
        !isAutoTesting &&
        processService.aetherPid == null &&
        !userStoppedAether &&
        settings.autoReconnectAether &&
        !restartingAether) {
      _reconnectManager.scheduleAetherReconnect(
        shouldReconnect: () =>
            !processService.isAetherRunning &&
            !isAutoTesting &&
            processService.aetherPid == null &&
            !userStoppedAether &&
            settings.autoReconnectAether &&
            !restartingAether &&
            !isShuttingDown,
        onReconnect: () => connectAether(fromAutoReconnect: true),
        log: processService.addLog,
      );
    } else if (processService.isAetherRunning ||
        isAutoTesting ||
        userStoppedAether) {
      _reconnectManager.cancelAetherTimer();
    }

    if (!processService.isTorRunning &&
        !isTorBusy &&
        processService.torPid == null &&
        !userStoppedTor &&
        settings.autoReconnectTor &&
        !isAutoTesting &&
        !restartingTor) {
      _reconnectManager.scheduleTorReconnect(
        shouldReconnect: () =>
            !processService.isTorRunning &&
            !isTorBusy &&
            processService.torPid == null &&
            !userStoppedTor &&
            settings.autoReconnectTor &&
            !isAutoTesting &&
            !restartingTor &&
            !isShuttingDown,
        onReconnect: () => connectTor(fromAutoReconnect: true),
        log: processService.addLog,
      );
    } else if (processService.isTorRunning || isTorBusy || userStoppedTor) {
      _reconnectManager.cancelTorTimer();
    }

    if (!processService.isSstpRunning &&
        !isSstpBusy &&
        processService.sstpPid == null &&
        !userStoppedSstp &&
        settings.autoReconnectSstp &&
        !isAutoTesting &&
        !restartingSstp) {
      _reconnectManager.scheduleSstpReconnect(
        shouldReconnect: () =>
            !processService.isSstpRunning &&
            !isSstpBusy &&
            processService.sstpPid == null &&
            !userStoppedSstp &&
            settings.autoReconnectSstp &&
            !isAutoTesting &&
            !restartingSstp &&
            !isShuttingDown,
        onReconnect: () => connectSstp(fromAutoReconnect: true),
        log: processService.addLog,
      );
    } else if (processService.isSstpRunning || isSstpBusy || userStoppedSstp) {
      _reconnectManager.cancelSstpTimer();
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
