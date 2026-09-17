import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../providers/cdn_scanner_provider.dart';
import 'cdn_clipboard_actions.dart';

class CdnScannerResults extends StatelessWidget {
  final CdnScannerProvider scan;
  final ThemeData theme;

  const CdnScannerResults({
    super.key,
    required this.scan,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (scan.good.isEmpty) return const SizedBox.shrink();

    final app = context.read<AppProvider>();
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              l10n.usableIps,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy_all, size: 20),
              tooltip: l10n.copy,
              onPressed: () => CdnClipboardActions.copyAllUsable(context, scan),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.table_chart_outlined, size: 20),
              tooltip: l10n.copyAllCsv,
              onPressed: () =>
                  CdnClipboardActions.copyAllDetailed(context, scan),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            itemCount: scan.good.length,
            itemBuilder: (ctx, i) {
              final r = scan.good[i];
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  r.ip,
                  style: const TextStyle(
                      fontFamily: 'monospace', fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Score ${r.score} · Rel ${r.reliability}/5 · ${r.latencyMs}ms · ${r.sni}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      tooltip: l10n.copy,
                      visualDensity: VisualDensity.compact,
                      onPressed: () =>
                          CdnClipboardActions.copySingle(context, r.ip, 'IP'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copyright_outlined, size: 18),
                      tooltip: 'IP + SNI',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => CdnClipboardActions.copySingle(
                        context,
                        '${r.ip} | ${r.sni}',
                        'IP + SNI',
                      ),
                    ),
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 18),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () async {
                  final top5 = scan.good.take(5).map((e) => e.ip).toList();
                  await app.applyScannerResults(
                      ips: top5, tlsSni: scan.bestSni);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.appliedTop5Ips)),
                    );
                  }
                },
                icon: const Icon(Icons.filter_list),
                label: Text(l10n.applyTop5),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: () async {
                  await app.applyScannerResults(
                      ips: scan.topIps, tlsSni: scan.bestSni);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.appliedTop20Ips),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.security),
                label: Text(l10n.applyTop20),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
