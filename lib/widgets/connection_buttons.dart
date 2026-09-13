import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'connection/connection_button_builder.dart';
import 'connection/circle_connect_button.dart';

class ConnectionButtons extends StatelessWidget {
  const ConnectionButtons({super.key});

  static bool _aetherHealthy(String status) {
    final s = status.toLowerCase();
    if (s.contains('unverified')) return false;
    if (s.contains('healthy')) return true;
    if (s.contains('upstream') && s.contains('running')) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final ps = provider.processService;
    final theme = Theme.of(context);
    final builder =
        ConnectionButtonBuilder(primaryColor: theme.colorScheme.primary);

    // ═══════════════════════════════════════════
    //  Aether
    // ═══════════════════════════════════════════
    final aetherBusy = provider.isAutoTesting;
    final aetherHealthy = ps.isAetherRunning &&
        !aetherBusy &&
        _aetherHealthy(provider.aetherStatus);
    final aetherRunningForButton = ps.isAetherRunning || aetherBusy;
    final aetherData = builder.forAether(
      isRunning: aetherRunningForButton,
      isConnected: aetherHealthy,
      isBusy: aetherBusy,
      progress: null,
    );

    // ═══════════════════════════════════════════
    //  Psiphon
    // ═══════════════════════════════════════════
    final psiphonOn = ps.isPsiphonConnected;
    final psiphonBusy = provider.isPsiphonBusy && !ps.isPsiphonRunning;
    final psiphonRunningForButton =
        ps.isPsiphonRunning || (provider.isPsiphonBusy && !psiphonOn);
    final psiphonData = builder.forPsiphon(
      isRunning: psiphonRunningForButton,
      isConnected: psiphonOn,
      isBusy: psiphonBusy,
    );

    // ═══════════════════════════════════════════
    //  Tor — با progress در bootstrap
    // ═══════════════════════════════════════════
    final torOn = ps.isTorConnected;
    final torBootstrapping = ps.isTorRunning && !torOn;
    final torStarting = provider.isTorBusy && !ps.isTorRunning;

    final torBusy = torBootstrapping || torStarting;
    final torRunningForButton = ps.isTorRunning || torStarting;

    final int torProgress = ps.torBootstrapProgress;
    final bool showTorProgress =
        torBusy && !torOn && torProgress > 0 && torProgress < 100;

    final torData = builder.forTor(
      isRunning: torRunningForButton,
      isConnected: torOn,
      isBusy: torBusy,
      progress: showTorProgress ? torProgress : null,
    );

    // ═══════════════════════════════════════════
    //  SSTP
    // ═══════════════════════════════════════════
    final sstpOn = ps.isSstpConnected;
    final sstpBusy = provider.isSstpBusy && !ps.isSstpRunning;
    final sstpRunningForButton =
        ps.isSstpRunning || (provider.isSstpBusy && !sstpOn);
    final sstpData = builder.forSstp(
      isRunning: sstpRunningForButton,
      isConnected: sstpOn,
      isBusy: sstpBusy,
    );

    final onSurface = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircleConnectButton(
            title: 'Aether',
            actionLabel: aetherData.state.actionLabel,
            icon: aetherData.state.icon,
            color: aetherData.state.color,
            busy: aetherData.state.busy,
            connected: aetherData.state.connected,
            onTap: () => provider.connectAether(),
            statusText: aetherData.state.statusText(aetherData.progress),
            statusColor: aetherData.state
                .statusColor(theme.colorScheme.primary, onSurface),
          ),
          CircleConnectButton(
            title: 'Psiphon',
            actionLabel: psiphonData.state.actionLabel,
            icon: psiphonData.state.icon,
            color: psiphonData.state.color,
            busy: psiphonData.state.busy,
            connected: psiphonData.state.connected,
            onTap: () => provider.connectPsiphon(),
            statusText: psiphonData.state.statusText(psiphonData.progress),
            statusColor: psiphonData.state
                .statusColor(theme.colorScheme.primary, onSurface),
          ),
          CircleConnectButton(
            title: 'Tor',
            actionLabel: torData.state.actionLabel,
            icon: torData.state.icon,
            color: torData.state.color,
            busy: torData.state.busy,
            connected: torData.state.connected,
            onTap: () => provider.connectTor(),
            progress: torData.progress,
            statusText: torData.state.statusText(torData.progress),
            statusColor: torData.state
                .statusColor(theme.colorScheme.primary, onSurface),
          ),
          CircleConnectButton(
            title: 'SSTP',
            actionLabel: sstpData.state.actionLabel,
            icon: sstpData.state.icon,
            color: sstpData.state.color,
            busy: sstpData.state.busy,
            connected: sstpData.state.connected,
            onTap: () => provider.connectSstp(),
            statusText: sstpData.state.statusText(sstpData.progress),
            statusColor: sstpData.state
                .statusColor(theme.colorScheme.primary, onSurface),
          ),
        ],
      ),
    );
  }
}
