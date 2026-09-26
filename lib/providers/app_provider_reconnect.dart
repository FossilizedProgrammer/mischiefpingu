part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderReconnect — مدیریت auto-reconnect و status.
///
///  ⚠️ بازآرایی:
///  منطق مشترک schedule برای هر تونل به فایل جداگانه منتقل شد:
///    • app_provider_reconnect_scheduler.dart
///        → _scheduleReconnectFor (helper مشترک)
///
///  این فایل حالا فقط orchestrator است: برای هر تونل صدا می‌زنه
///  و statusها رو آپدیت می‌کنه.
///
///  ⚠️ این متد فقط از `handleProcessServiceChange` صدا زده می‌شود،
///  و آن هم فقط وقتی state واقعی تغییر کرده باشد.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderReconnect on AppProvider {
  void checkAutoReconnects() {
    // ═══════════════════════════════════════════════════════════
    //  Psiphon
    // ═══════════════════════════════════════════════════════════
    _scheduleReconnectFor(
      tunnel: 'psiphon',
      isRunning: processService.isPsiphonRunning,
      isBusy: isPsiphonBusy,
      isLoading: isLoading,
      hasPid: processService.psiphonPid != null,
      userStopped: userStoppedPsiphon,
      autoReconnectEnabled: settings.autoReconnectPsiphon,
      isAutoTesting: isAutoTesting,
      isRestarting: restartingPsiphon,
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
    );

    // ═══════════════════════════════════════════════════════════
    //  Aether
    // ═══════════════════════════════════════════════════════════
    _scheduleReconnectFor(
      tunnel: 'aether',
      isRunning: processService.isAetherRunning,
      isBusy: isAutoTesting,
      isLoading: false,
      hasPid: processService.aetherPid != null,
      userStopped: userStoppedAether,
      autoReconnectEnabled: settings.autoReconnectAether,
      isAutoTesting: isAutoTesting,
      isRestarting: restartingAether,
      shouldReconnect: () =>
          !processService.isAetherRunning &&
          !isAutoTesting &&
          processService.aetherPid == null &&
          !userStoppedAether &&
          settings.autoReconnectAether &&
          !restartingAether &&
          !isShuttingDown,
      onReconnect: () => connectAether(fromAutoReconnect: true),
    );

    // ═══════════════════════════════════════════════════════════
    //  Tor
    // ═══════════════════════════════════════════════════════════
    _scheduleReconnectFor(
      tunnel: 'tor',
      isRunning: processService.isTorRunning,
      isBusy: isTorBusy,
      isLoading: false,
      hasPid: processService.torPid != null,
      userStopped: userStoppedTor,
      autoReconnectEnabled: settings.autoReconnectTor,
      isAutoTesting: isAutoTesting,
      isRestarting: restartingTor,
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
    );

    // ═══════════════════════════════════════════════════════════
    //  SSTP
    // ═══════════════════════════════════════════════════════════
    _scheduleReconnectFor(
      tunnel: 'sstp',
      isRunning: processService.isSstpRunning,
      isBusy: isSstpBusy,
      isLoading: false,
      hasPid: processService.sstpPid != null,
      userStopped: userStoppedSstp,
      autoReconnectEnabled: settings.autoReconnectSstp,
      isAutoTesting: isAutoTesting,
      isRestarting: restartingSstp,
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
    );

    // ═══════════════════════════════════════════════════════════
    //  WireGuard
    // ═══════════════════════════════════════════════════════════
    _scheduleReconnectFor(
      tunnel: 'wireguard',
      isRunning: processService.isWireGuardRunning,
      isBusy: isWireGuardBusy,
      isLoading: false,
      hasPid: processService.wireGuardPid != null,
      userStopped: userStoppedWireGuard,
      autoReconnectEnabled: settings.wireguardAutoReconnect,
      isAutoTesting: isAutoTesting,
      isRestarting: restartingWireGuard,
      shouldReconnect: () =>
          !processService.isWireGuardRunning &&
          !isWireGuardBusy &&
          processService.wireGuardPid == null &&
          !userStoppedWireGuard &&
          settings.wireguardAutoReconnect &&
          !isAutoTesting &&
          !restartingWireGuard &&
          !isShuttingDown,
      onReconnect: () => connectWireGuard(fromAutoReconnect: true),
    );
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
