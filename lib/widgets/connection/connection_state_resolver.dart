library;

import '../../providers/app_provider.dart';
import 'connection_button_builder.dart';

class ConnectionStateResolver {
  final AppProvider provider;

  const ConnectionStateResolver(this.provider);

  static bool _aetherHealthy(String status) {
    final s = status.toLowerCase();
    if (s.contains('unverified')) return false;
    if (s.contains('healthy')) return true;
    if (s.contains('upstream') && s.contains('running')) return true;
    return false;
  }

  /// Aether وضعیت متصل را از خود هسته می‌گیرد. `isAetherTunnelReady` یعنی
  /// هسته خط «tunnel validated / socks5 server listening» را چاپ کرده و
  /// SOCKS واقعاً ترافیک می‌دهد؛ حتی اگر probe سطح بالای اپ (که ممکن است
  /// هدف‌هایش بلاک شده باشند) تأییدش نکرده باشد. متن status فقط fallback است.
  static bool aetherConnected({
    required bool isRunning,
    required bool tunnelReady,
    required bool isBusy,
    required String status,
  }) =>
      isRunning && !isBusy && (tunnelReady || _aetherHealthy(status));

  ConnectionButtonData resolveAether(ConnectionButtonBuilder builder) {
    final ps = provider.processService;
    final aetherBusy = provider.isAutoTesting;
    final aetherOn = aetherConnected(
      isRunning: ps.isAetherRunning,
      tunnelReady: ps.isAetherTunnelReady,
      isBusy: aetherBusy,
      status: provider.aetherStatus,
    );
    final aetherRunningForButton = ps.isAetherRunning || aetherBusy;
    return builder.forAether(
      isRunning: aetherRunningForButton,
      isConnected: aetherOn,
      isBusy: aetherBusy,
      progress: null,
    );
  }

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

  ConnectionButtonData resolveGeph(ConnectionButtonBuilder builder) {
    final ps = provider.processService;
    final gephOn = ps.isGephConnected;
    final gephBusy = provider.isGephBusy && !ps.isGephRunning;
    final gephRunningForButton =
        ps.isGephRunning || (provider.isGephBusy && !gephOn);

    return builder.forSstp(
      isRunning: gephRunningForButton,
      isConnected: gephOn,
      isBusy: gephBusy,
    );
  }

  ConnectionButtonData resolveNpv(ConnectionButtonBuilder builder) {
    final ps = provider.processService;
    final npvOn = ps.isNpvConnected;
    final npvBusy = provider.isNpvBusy || (ps.isNpvRunning && !npvOn);
    final npvRunningForButton =
        ps.isNpvRunning || (provider.isNpvBusy && !npvOn);

    return builder.forSstp(
      isRunning: npvRunningForButton,
      isConnected: npvOn,
      isBusy: npvBusy,
    );
  }
}
