library;

import '../../providers/app_provider.dart';
import 'connection_button_builder.dart';

class ConnectionStateResolver {
  final AppProvider provider;

  const ConnectionStateResolver(this.provider);

  ConnectionButtonData resolvePsiphon(ConnectionButtonBuilder builder) {
    final ps = provider.processService;
    final psiphonOn = ps.isPsiphonConnected;
    final psiphonBusy = provider.isPsiphonBusy && !ps.isPsiphonRunning;
    final psiphonRunningForButton =
        ps.isPsiphonRunning || (provider.isPsiphonBusy && !psiphonOn);
    return builder.forPsiphon(
      isRunning: psiphonRunningForButton,
      isConnected: psiphonOn,
      isBusy: psiphonBusy,
    );
  }

  ConnectionButtonData resolveTor(ConnectionButtonBuilder builder) {
    final ps = provider.processService;
    final torOn = ps.isTorConnected;
    final torBootstrapping = ps.isTorRunning && !torOn;
    final torStarting = provider.isTorBusy && !ps.isTorRunning;

    final torBusy = torBootstrapping || torStarting;
    final torRunningForButton = ps.isTorRunning || torStarting;

    final int torProgress = ps.torBootstrapProgress;
    final bool showTorProgress =
        torBusy && !torOn && torProgress > 0 && torProgress < 100;

    return builder.forTor(
      isRunning: torRunningForButton,
      isConnected: torOn,
      isBusy: torBusy,
      progress: showTorProgress ? torProgress : null,
    );
  }

  ConnectionButtonData resolveSstp(ConnectionButtonBuilder builder) {
    final ps = provider.processService;
    final sstpOn = ps.isSstpConnected;
    final sstpBusy = provider.isSstpBusy && !ps.isSstpRunning;
    final sstpRunningForButton =
        ps.isSstpRunning || (provider.isSstpBusy && !sstpOn);
    return builder.forSstp(
      isRunning: sstpRunningForButton,
      isConnected: sstpOn,
      isBusy: sstpBusy,
    );
  }

  ConnectionButtonData resolveWireGuard(ConnectionButtonBuilder builder) {
    final ps = provider.processService;
    final wgConnected = ps.isWireGuardConnected;
    final wgBusy = provider.isWireGuardBusy && !ps.isWireGuardRunning;
    final wgRunningForButton =
        ps.isWireGuardRunning || (provider.isWireGuardBusy && !wgConnected);

    return builder.forSstp(
      isRunning: wgRunningForButton,
      isConnected: wgConnected,
      isBusy: wgBusy,
    );
  }

  ConnectionButtonData resolveFfvpn(ConnectionButtonBuilder builder) {
    final ps = provider.processService;
    final ffvpnOn = ps.isFfvpnConnected;
    final ffvpnBusy = provider.isFfvpnBusy && !ps.isFfvpnRunning;
    final ffvpnRunningForButton =
        ps.isFfvpnRunning || (provider.isFfvpnBusy && !ffvpnOn);

    return builder.forSstp(
      isRunning: ffvpnRunningForButton,
      isConnected: ffvpnOn,
      isBusy: ffvpnBusy,
    );
  }

  ConnectionButtonData resolveLantern(ConnectionButtonBuilder builder) {
    final ps = provider.processService;
    final lanternOn = ps.isLanternConnected;
    final lanternBusy = provider.isLanternBusy && !ps.isLanternRunning;
    final lanternRunningForButton =
        ps.isLanternRunning || (provider.isLanternBusy && !lanternOn);

    return builder.forSstp(
      isRunning: lanternRunningForButton,
      isConnected: lanternOn,
      isBusy: lanternBusy,
    );
  }
}
