import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../providers/sstp_fetcher_provider.dart';
import '../../widgets/settings_tile_base.dart';
import 'sstp_fetcher/sstp_fetcher_actions.dart';
import 'sstp_fetcher/sstp_fetcher_controls.dart';
import 'sstp_fetcher/sstp_fetcher_status.dart';
import 'sstp_fetcher/sstp_server_list.dart';

class SstpFetcherSection extends StatefulWidget {
  const SstpFetcherSection({super.key});

  @override
  State<SstpFetcherSection> createState() => _SstpFetcherSectionState();
}

class _SstpFetcherSectionState extends State<SstpFetcherSection> {
  @override
  void initState() {
    super.initState();
    final app = context.read<AppProvider>();
    final fetcher = context.read<SstpFetcherProvider>();
    fetcher.bindPortGetters(
      psiphon: () => app.settings.socksPort,
      aether: () => app.settings.aetherLocalPort,
      tor: () => app.settings.torSocksPort,
      sstp: () => app.settings.sstpSocksPort,
    );
    fetcher.init();
  }

  @override
  Widget build(BuildContext context) {
    final fetcher = context.watch<SstpFetcherProvider>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final aliveCount = fetcher.aliveCount;

    return SettingsTile(
      title: l10n.vpngateServers,
      icon: Icons.public,
      iconBackgroundColor: theme.colorScheme.tertiary,
      trailingText: fetcher.servers.isNotEmpty
          ? '$aliveCount / ${fetcher.servers.length}'
          : null,
      initiallyExpanded: false,
      children: [
        SstpFetcherControls(fetcher: fetcher, theme: theme),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: fetcher.servers.isEmpty || fetcher.isLoading
                ? null
                : () => SstpFetcherActions.clearAll(context, fetcher),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text(l10n.clearAll),
          ),
        ),
        const SizedBox(height: 4),
        SstpFetcherStatus(fetcher: fetcher, theme: theme),
        SstpServerList(
          fetcher: fetcher,
          theme: theme,
          onApply: (s) => SstpFetcherActions.applyServer(context, s),
          onClearAll: (f) => SstpFetcherActions.clearAll(context, f),
        ),
      ],
    );
  }
}
