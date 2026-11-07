library;

import '../providers/app_provider.dart';
import 'process_service.dart';
import 'watchdog/tunnel_watchdog.dart';
import 'watchdog/watchdog_network_profile.dart';
import 'watchdog/watchdog_params.dart';
import 'tunnel_watchdog_manager.dart';

class TunnelWatchdogFactory {
  TunnelWatchdogFactory._();

  static TunnelWatchdogManager build({
    required AppProvider provider,
    required ProcessService processService,
    required Future<void> Function() restartPsiphon,
    required Future<void> Function() restartAether,
    required Future<void> Function() restartTor,
    required Future<void> Function() restartSstp,
    required Future<void> Function() restartWireGuard,
    Future<bool> Function()? isInternetAlive,
    Future<RecoveryLeaseResult> Function()? acquirePsiphonLease,
    Future<RecoveryLeaseResult> Function()? acquireAetherLease,
    Future<RecoveryLeaseResult> Function()? acquireTorLease,
    Future<RecoveryLeaseResult> Function()? acquireSstpLease,
    Future<RecoveryLeaseResult> Function()? acquireWireGuardLease,
  }) {
    final log = processService.addLog;

    // ═══════════════════════════════════════════════════════════
    //  خواندن پروفایل سراسری از settings.
    //  همه تونل‌ها از همان پروفایل استفاده می‌کنند (حتی Aether).
    // ═══════════════════════════════════════════════════════════
    final profile = WatchdogNetworkProfile.fromId(
      provider.settings.watchdogNetworkProfile,
    );

    final psiphon = TunnelWatchdog(
      params: WatchdogParams.fromProfile(
        name: 'Psiphon',
        socksPort: provider.settings.socksPort,
        profile: profile,
      ),
      isConnected: () => processService.isPsiphonConnected,
      isUserStopped: () => provider.userStoppedPsiphon,
      isBusy: () => provider.isPsiphonBusy || provider.isAutoTesting,
      onRestart: restartPsiphon,
      log: log,
      logSource: LogSource.psiphon,
      isInternetAlive: isInternetAlive,
      acquireRecoveryLease: acquirePsiphonLease,
    );

    final aether = TunnelWatchdog(
      params: WatchdogParams.fromProfile(
        name: 'Aether',
        socksPort: provider.settings.aetherLocalPort,
        profile: profile,
      ),
      isConnected: () => processService.isAetherRunning,
      isUserStopped: () => provider.userStoppedAether,
      isBusy: () => provider.isAutoTesting,
      onRestart: restartAether,
      log: log,
      logSource: LogSource.aether,
      isInternetAlive: isInternetAlive,
      acquireRecoveryLease: acquireAetherLease,
    );

    final tor = TunnelWatchdog(
      params: WatchdogParams.fromProfile(
        name: 'Tor',
        socksPort: provider.settings.torSocksPort,
        profile: profile,
      ),
      isConnected: () => processService.isTorConnected,
      isUserStopped: () => provider.userStoppedTor,
      isBusy: () => provider.isTorBusy,
      onRestart: restartTor,
      log: log,
      logSource: LogSource.tor,
      isInternetAlive: isInternetAlive,
      acquireRecoveryLease: acquireTorLease,
    );

    final sstp = TunnelWatchdog(
      params: WatchdogParams.fromProfile(
        name: 'SSTP',
        socksPort: provider.settings.sstpSocksPort,
        profile: profile,
      ),
      isConnected: () => processService.isSstpConnected,
      isUserStopped: () => provider.userStoppedSstp,
      isBusy: () => provider.isSstpBusy,
      onRestart: restartSstp,
      log: log,
      logSource: LogSource.sstp,
      isInternetAlive: isInternetAlive,
      acquireRecoveryLease: acquireSstpLease,
    );

    final wireguard = TunnelWatchdog(
      params: WatchdogParams.fromProfile(
        name: 'WireGuard',
        socksPort: provider.settings.wireguardSocksPort,
        profile: profile,
      ),
      isConnected: () => processService.isWireGuardConnected,
      isUserStopped: () => provider.userStoppedWireGuard,
      isBusy: () => provider.isWireGuardBusy,
      onRestart: restartWireGuard,
      log: log,
      logSource: LogSource.wireguard,
      isInternetAlive: isInternetAlive,
      acquireRecoveryLease: acquireWireGuardLease,
    );

    log(
      '→ Watchdog built with profile=${profile.id} '
      '(interval=${psiphon.interval.inSeconds}s, '
      'maxFailures=${psiphon.maxFailures})',
      source: LogSource.app,
    );

    return TunnelWatchdogManager(
      psiphon: psiphon,
      aether: aether,
      tor: tor,
      sstp: sstp,
      wireguard: wireguard,
    );
  }
}
