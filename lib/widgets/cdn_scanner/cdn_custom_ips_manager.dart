import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/cdn_scanner_provider.dart';
import 'cdn_custom_ips_dialogs.dart';

class CdnCustomIpsManager extends StatelessWidget {
  final CdnScannerProvider scan;
  final TextEditingController inputCtrl;
  final ThemeData theme;

  const CdnCustomIpsManager({
    super.key,
    required this.scan,
    required this.inputCtrl,
    required this.theme,
  });

  Future<void> _saveCurrentAsCustom(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final raw = inputCtrl.text.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.listIsEmpty)));
      return;
    }
    final lines = raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    await scan.addCustomIps(lines);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${lines.length} → ${scan.customIps.length}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = scan.customIps.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Text(
            '★',
            style: TextStyle(fontSize: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              count == 0 ? '${l10n.customIps}: 0' : '${l10n.customIps}: $count',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _saveCurrentAsCustom(context),
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: Text('💾  ${l10n.save}'),
          ),
          IconButton(
            tooltip: l10n.manageList,
            visualDensity: VisualDensity.compact,
            onPressed: () => CdnCustomIpsDialogs.showManage(context, scan),
            icon: const Text('☰', style: TextStyle(fontSize: 18)),
          ),
          IconButton(
            tooltip: l10n.clearAll,
            visualDensity: VisualDensity.compact,
            onPressed: count == 0
                ? null
                : () async {
                    final ok = await CdnCustomIpsDialogs.confirmClear(
                      context,
                      scan,
                    );
                    if (ok) await scan.clearCustomIps();
                  },
            icon: Text(
              '✕',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: count == 0
                    ? theme.disabledColor
                    : theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
