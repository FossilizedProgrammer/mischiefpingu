// lib/screens/widgets/sstp_fetcher_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../providers/sstp_fetcher_provider.dart';
import '../../services/vpngate_scraper_service.dart';
import '../../widgets/settings_tile_base.dart';
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

  Future<void> _applyServer(SstpServer s) async {
    final app = context.read<AppProvider>();
    if (app.processService.isSstpRunning) {
      await app.connectSstp();
      await Future.delayed(const Duration(milliseconds: 400));
    }
    app.settings.sstpServer = s.ip;
    app.settings.sstpPort = s.port;
    await app.saveSettings();
    app.touch();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'SSTP → ${s.ip}:${s.port}'
          '${s.country.isNotEmpty ? ' (${s.country})' : ''}',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _clearAll(SstpFetcherProvider fetcher) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${l10n.clearAll}?'),
        content: Text('${fetcher.servers.length}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelBtn),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.clearAll),
          ),
        ],
      ),
    );
    if (confirm == true) await fetcher.clearAll();
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
                : () => _clearAll(fetcher),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text(l10n.clearAll),
          ),
        ),
        const SizedBox(height: 4),
        SstpFetcherStatus(fetcher: fetcher, theme: theme),
        SstpServerList(
          fetcher: fetcher,
          theme: theme,
          onApply: _applyServer,
          onClearAll: _clearAll,
        ),
      ],
    );
  }
}
