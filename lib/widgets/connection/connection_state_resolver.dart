// lib/widgets/connection/connection_state_resolver.dart
//
// ═══════════════════════════════════════════════════════════════
//  ConnectionStateResolver — محاسبهٔ state هر دکمه از ProcessService
//  (تفکیک شده از connection_buttons.dart)
// ═══════════════════════════════════════════════════════════════
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

  ConnectionButtonData resolveAether(ConnectionButtonBuilder builder) {
    final ps = provider.processService;
    final aetherBusy = provider.isAutoTesting;
    final aetherHealthy = ps.isAetherRunning &&
        !aetherBusy &&
        _aetherHealthy(provider.aetherStatus);
    final aetherRunningForButton = ps.isAetherRunning || aetherBusy;
    return builder.forAether(
      isRunning: aetherRunningForButton,
      isConnected: aetherHealthy,
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
}
