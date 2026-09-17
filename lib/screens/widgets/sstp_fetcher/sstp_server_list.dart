import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/app_provider.dart';
import '../../../providers/sstp_fetcher_provider.dart';
import '../../../services/vpngate_scraper_service.dart';
import 'sstp_actions.dart';
import 'sstp_server_tile.dart';

class SstpServerList extends StatelessWidget {
  final SstpFetcherProvider fetcher;
  final ThemeData theme;
  final Future<void> Function(SstpServer) onApply;
  final Future<void> Function(SstpFetcherProvider) onClearAll;

  const SstpServerList({
    super.key,
    required this.fetcher,
    required this.theme,
    required this.onApply,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final visible = fetcher.visibleServers;
    if (visible.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              '${l10n.allServers} (${visible.length})',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy_all, size: 20),
              tooltip: l10n.copyAllIpPort,
              onPressed: () =>
                  SstpClipboardActions.copyAllServers(context, fetcher),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.table_chart_outlined, size: 20),
              tooltip: l10n.copyAllCsv,
              onPressed: () =>
                  SstpClipboardActions.copyAllDetailed(context, fetcher),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 320,
          decoration: BoxDecoration(
            border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            itemCount: visible.length,
            itemBuilder: (ctx, i) {
              final s = visible[i];
              final app = context.watch<AppProvider>();
              final isCurrent = app.settings.sstpServer == s.ip &&
                  app.settings.sstpPort == s.port;
              final h = fetcher.healthOf(s);
              return SstpServerTile(
                server: s,
                isCurrent: isCurrent,
                health: h,
                onApply: () => onApply(s),
                onCopy: (text, label) =>
                    SstpClipboardActions.copySingle(context, text, label),
              );
            },
          ),
        ),
      ],
    );
  }
}
