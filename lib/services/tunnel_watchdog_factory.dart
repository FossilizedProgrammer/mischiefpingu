library;

import '../providers/app_provider.dart';
import 'process_service.dart';
import 'watchdog/tunnel_watchdog.dart';
import 'tunnel_watchdog_manager.dart';
import 'watchdog/watchdog_config.dart';
import 'watchdog/watchdog_params.dart';

class TunnelWatchdogFactory {
  TunnelWatchdogFactory._();

  static TunnelWatchdogManager build({
    required AppProvider provider,
    required ProcessService processService,
    required Future<void> Function() restartPsiphon,
    required Future<void> Function() restartAether,
    required Future<void> Function() restartTor,
    required Future<void> Function() restartSstp,
  }) {
    final log = processService.addLog;

    final psiphon = TunnelWatchdog(
      params: WatchdogParams(
        name: 'Psiphon',
        socksPort: provider.settings.socksPort,
        interval: WatchdogConfig.psiphonInterval,
        doHttpProbe: true,
        probeHost: '8.8.8.8',
        probePort: 80,
      ),
      isConnected: () => processService.isPsiphonConnected,
      isUserStopped: () => provider.userStoppedPsiphon,
      isBusy: () => provider.isPsiphonBusy || provider.isAutoTesting,
      onRestart: restartPsiphon,
      log: log,
      logSource: LogSource.psiphon,
    );

    final aether = TunnelWatchdog(
      params: WatchdogParams(
        name: 'Aether',
        socksPort: provider.settings.aetherLocalPort,
        interval: WatchdogConfig.aetherInterval,
        doHttpProbe: false,
        probeHost: '8.8.8.8',
        probePort: 80,
      ),
      isConnected: () => processService.isAetherRunning,
      isUserStopped: () => provider.userStoppedAether,
      isBusy: () => provider.isAutoTesting,
      onRestart: restartAether,
      log: log,
      logSource: LogSource.aether,
    );

    final tor = TunnelWatchdog(
      params: WatchdogParams(
        name: 'Tor',
        socksPort: provider.settings.torSocksPort,
        interval: WatchdogConfig.torInterval,
        doHttpProbe: true,
        probeHost: '8.8.8.8',
        probePort: 80,
      ),
      isConnected: () => processService.isTorConnected,
      isUserStopped: () => provider.userStoppedTor,
      isBusy: () => provider.isTorBusy,
      onRestart: restartTor,
      log: log,
      logSource: LogSource.tor,
    );

    final sstp = TunnelWatchdog(
      params: WatchdogParams(
        name: 'SSTP',
        socksPort: provider.settings.sstpSocksPort,
        interval: WatchdogConfig.sstpInterval,
        doHttpProbe: true,
        probeHost: '8.8.8.8',
        probePort: 80,
      ),
      isConnected: () => processService.isSstpConnected,
      isUserStopped: () => provider.userStoppedSstp,
      isBusy: () => provider.isSstpBusy,
      onRestart: restartSstp,
      log: log,
      logSource: LogSource.sstp,
    );

    return TunnelWatchdogManager(
      psiphon: psiphon,
      aether: aether,
      tor: tor,
      sstp: sstp,
    );
  }
}
