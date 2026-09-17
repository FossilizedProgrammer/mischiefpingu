// lib/widgets/connection_buttons.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import 'connection/connection_button_builder.dart';
import 'connection/connection_state_resolver.dart';
import 'connection/circle_connect_button.dart';

class ConnectionButtons extends StatelessWidget {
  const ConnectionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final builder = ConnectionButtonBuilder(
      primaryColor: theme.colorScheme.primary,
      l10n: l10n,
    );
    final resolver = ConnectionStateResolver(provider);

    final aetherData = resolver.resolveAether(builder);
    final psiphonData = resolver.resolvePsiphon(builder);
    final torData = resolver.resolveTor(builder);
    final sstpData = resolver.resolveSstp(builder);

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
            statusText: aetherData.state.statusText(aetherData.progress, l10n),
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
            statusText:
                psiphonData.state.statusText(psiphonData.progress, l10n),
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
            statusText: torData.state.statusText(torData.progress, l10n),
            statusColor:
                torData.state.statusColor(theme.colorScheme.primary, onSurface),
          ),
          CircleConnectButton(
            title: 'SSTP',
            actionLabel: sstpData.state.actionLabel,
            icon: sstpData.state.icon,
            color: sstpData.state.color,
            busy: sstpData.state.busy,
            connected: sstpData.state.connected,
            onTap: () => provider.connectSstp(),
            statusText: sstpData.state.statusText(sstpData.progress, l10n),
            statusColor: sstpData.state
                .statusColor(theme.colorScheme.primary, onSurface),
          ),
        ],
      ),
    );
  }
}
