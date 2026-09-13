import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/cdn_scanner_provider.dart';

class CdnScannerResults extends StatelessWidget {
  final CdnScannerProvider scan;
  final ThemeData theme;

  const CdnScannerResults({
    super.key,
    required this.scan,
    required this.theme,
  });

  Future<void> _copySingle(BuildContext context, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied: $text'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _copyAllUsable(BuildContext context) async {
    if (scan.good.isEmpty) return;
    final lines = scan.good.map((r) => r.ip).join('\n');
    await Clipboard.setData(ClipboardData(text: lines));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${scan.good.length} IP(s) copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _copyAllDetailed(BuildContext context) async {
    if (scan.good.isEmpty) return;
    final buffer = StringBuffer();
    buffer.writeln('ip,sni,latency_ms,reliability,score');
    for (final r in scan.good) {
      buffer.writeln('${r.ip},${r.sni},${r.latencyMs},${r.reliability},${r.score}');
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${scan.good.length} IP(s) copied (CSV format)'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (scan.good.isEmpty) return const SizedBox.shrink();

    final app = context.read<AppProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Usable IPs (sorted by score)',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy_all, size: 20),
              tooltip: 'Copy all IPs (plain)',
              onPressed: () => _copyAllUsable(context),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.table_chart_outlined, size: 20),
              tooltip: 'Copy all (CSV with details)',
              onPressed: () => _copyAllDetailed(context),
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
                      tooltip: 'Copy IP',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _copySingle(context, r.ip, 'IP'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copyright_outlined, size: 18),
                      tooltip: 'Copy IP + SNI',
                      visualDensity: VisualDensity.compact,
                      onPressed: () =>
                          _copySingle(context, '${r.ip} | ${r.sni}', 'IP + SNI'),
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
                      const SnackBar(
                          content: Text('Applied Top 5 IPs + SNI')),
                    );
                  }
                },
                icon: const Icon(Icons.filter_list),
                label: const Text('Apply Top 5'),
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
                        content: Text(
                          'Applied ${scan.topIps.length} IPs${scan.bestSni != null ? ' + SNI ${scan.bestSni}' : ''}',
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.security),
                label: const Text('Apply Top 20'),
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
