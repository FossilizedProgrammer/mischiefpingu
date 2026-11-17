import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import 'connection/connection_button_builder.dart';
import 'connection/connection_state_resolver.dart';
import 'connection/connection_pill_button.dart';

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
    final wireGuardData = resolver.resolveWireGuard(builder);
    final ffvpnData = resolver.resolveFfvpn(builder);
    final lanternData = resolver.resolveLantern(builder);
    final gephData = resolver.resolveGeph(builder);
    final npvData = resolver.resolveNpv(builder);
    final cumulusData = resolver.resolveCumulus(builder);

    final onSurface = theme.colorScheme.onSurface;

    // دکمه‌ها در دو ردیف پنج‌تایی می‌نشینند. هر اسلات به‌طور مساوی تقسیم
    // می‌شود تا در پنجره‌های باریک فشرده و مرتب بمانند.
    Widget slot(ConnectionPillButton button) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: button,
          ),
        );

    final buttons = <ConnectionPillButton>[
      ConnectionPillButton(
        title: 'Aether',
        actionLabel: aetherData.state.actionLabel,
        icon: aetherData.state.icon,
        color: aetherData.state.color,
        busy: aetherData.state.busy,
        connected: aetherData.state.connected,
        onTap: () => provider.connectAether(),
        statusText: aetherData.state.statusText(aetherData.progress, l10n),
        statusColor: aetherData.state.statusColor(
          theme.colorScheme.primary,
          onSurface,
        ),
      ),
      ConnectionPillButton(
        title: 'Psiphon',
        actionLabel: psiphonData.state.actionLabel,
        icon: psiphonData.state.icon,
        color: psiphonData.state.color,
        busy: psiphonData.state.busy,
        connected: psiphonData.state.connected,
        onTap: () => provider.connectPsiphon(),
        statusText: psiphonData.state.statusText(
          psiphonData.progress,
          l10n,
        ),
        statusColor: psiphonData.state.statusColor(
          theme.colorScheme.primary,
          onSurface,
        ),
      ),
      ConnectionPillButton(
        title: 'Tor',
        actionLabel: torData.state.actionLabel,
        icon: torData.state.icon,
        color: torData.state.color,
        busy: torData.state.busy,
        connected: torData.state.connected,
        onTap: () => provider.connectTor(),
        progress: torData.progress,
        statusText: torData.state.statusText(torData.progress, l10n),
        statusColor: torData.state.statusColor(
          theme.colorScheme.primary,
          onSurface,
        ),
      ),
      ConnectionPillButton(
        title: 'SSTP',
        actionLabel: sstpData.state.actionLabel,
        icon: sstpData.state.icon,
        color: sstpData.state.color,
        busy: sstpData.state.busy,
        connected: sstpData.state.connected,
        onTap: () => provider.connectSstp(),
        statusText: sstpData.state.statusText(sstpData.progress, l10n),
        statusColor: sstpData.state.statusColor(
          theme.colorScheme.primary,
          onSurface,
        ),
      ),
      ConnectionPillButton(
        title: 'WireGuard',
        actionLabel: wireGuardData.state.actionLabel,
        icon: wireGuardData.state.icon,
        color: wireGuardData.state.color,
        busy: wireGuardData.state.busy,
        connected: wireGuardData.state.connected,
        onTap: () => provider.connectWireGuard(),
        statusText: wireGuardData.state.statusText(
          wireGuardData.progress,
          l10n,
        ),
        statusColor: wireGuardData.state.statusColor(
          theme.colorScheme.primary,
          onSurface,
        ),
      ),
      ConnectionPillButton(
        title: 'Firefox VPN',
        actionLabel: ffvpnData.state.actionLabel,
        icon: ffvpnData.state.icon,
        color: ffvpnData.state.color,
        busy: ffvpnData.state.busy,
        connected: ffvpnData.state.connected,
        onTap: () => provider.connectFfvpn(),
        statusText: ffvpnData.state.statusText(ffvpnData.progress, l10n),
        statusColor: ffvpnData.state.statusColor(
          theme.colorScheme.primary,
          onSurface,
        ),
      ),
      ConnectionPillButton(
        title: 'Lantern',
        actionLabel: lanternData.state.actionLabel,
        icon: lanternData.state.icon,
        color: lanternData.state.color,
        busy: lanternData.state.busy,
        connected: lanternData.state.connected,
        onTap: () => provider.connectLantern(),
        statusText: lanternData.state.statusText(
          lanternData.progress,
          l10n,
        ),
        statusColor: lanternData.state.statusColor(
          theme.colorScheme.primary,
          onSurface,
        ),
      ),
      ConnectionPillButton(
        title: 'Geph',
        actionLabel: gephData.state.actionLabel,
        icon: gephData.state.icon,
        color: gephData.state.color,
        busy: gephData.state.busy,
        connected: gephData.state.connected,
        onTap: () => provider.connectGeph(),
        statusText: gephData.state.statusText(
          gephData.progress,
          l10n,
        ),
        statusColor: gephData.state.statusColor(
          theme.colorScheme.primary,
          onSurface,
        ),
      ),
      ConnectionPillButton(
        title: 'Cumulus',
        actionLabel: cumulusData.state.actionLabel,
        icon: cumulusData.state.icon,
        color: cumulusData.state.color,
        busy: cumulusData.state.busy,
        connected: cumulusData.state.connected,
        onTap: () => provider.connectCumulus(),
        statusText: cumulusData.state.statusText(cumulusData.progress, l10n),
        statusColor: cumulusData.state.statusColor(
          theme.colorScheme.primary,
          onSurface,
        ),
      ),
      ConnectionPillButton(
        title: 'NPV',
        actionLabel: npvData.state.actionLabel,
        icon: npvData.state.icon,
        color: npvData.state.color,
        busy: npvData.state.busy,
        connected: npvData.state.connected,
        onTap: () => provider.connectNpv(),
        statusText: npvData.state.statusText(npvData.progress, l10n),
        statusColor: npvData.state.statusColor(
          theme.colorScheme.primary,
          onSurface,
        ),
      ),
    ];

    const perRow = 5;
    final rows = <Widget>[];
    for (var start = 0; start < buttons.length; start += perRow) {
      final end =
          start + perRow < buttons.length ? start + perRow : buttons.length;
      final rowButtons = buttons.sublist(start, end);
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 6));
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...rowButtons.map(slot),
            // ردیف آخرِ ناقص هم همان عرض اسلات‌های ردیف بالا را نگه می‌دارد.
            for (var i = rowButtons.length; i < perRow; i++)
              const Expanded(child: SizedBox()),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(children: rows),
    );
  }
}
