import 'package:flutter/material.dart';
import '../../providers/cdn_scanner_provider.dart';

/// بخش مدیریت IPهای کاستوم (ذخیره/حذف/پاک‌سازی).
///
/// ⚠️ به‌جای Icon از کاراکترهای یونیکد متنی استفاده می‌کنیم تا
/// مستقل از فونت Material Icons باشیم.
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
    final raw = inputCtrl.text.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('IP list is empty')),
      );
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
        content: Text(
          '${lines.length} line(s) saved to Custom (total: ${scan.customIps.length})',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    if (scan.customIps.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear custom IPs?'),
        content: Text(
          '${scan.customIps.length} saved line(s) will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await scan.clearCustomIps();
    }
  }

  void _showManageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final items = scan.customIps;
            return AlertDialog(
              title: Text('Custom IPs (${items.length})'),
              content: SizedBox(
                width: double.maxFinite,
                height: 360,
                child: items.isEmpty
                    ? const Center(child: Text('No custom IPs saved yet'))
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (ctx, i) {
                          final ip = items[i];
                          return ListTile(
                            dense: true,
                            title: Text(
                              ip,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                            trailing: TextButton(
                              onPressed: () async {
                                await scan.removeCustomIp(ip);
                                setDialogState(() {});
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                minimumSize: const Size(36, 36),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                '✕',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () async {
                    await scan.clearCustomIps();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('✕  Clear all'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          // ★ به‌جای Icons.bookmark_outline
          Text(
            '★',
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              count == 0
                  ? 'Custom IPs: none saved'
                  : 'Custom IPs: $count line(s) saved',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          // ↓ به‌جای Icons.save_outlined
          TextButton(
            onPressed: () => _saveCurrentAsCustom(context),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('💾  Save'),
          ),
          // ↓ به‌جای Icons.list_alt
          IconButton(
            tooltip: 'Manage saved IPs',
            visualDensity: VisualDensity.compact,
            onPressed: () => _showManageDialog(context),
            icon: const Text(
              '☰',
              style: TextStyle(fontSize: 18),
            ),
          ),
          // ↓ به‌جای Icons.delete_outline
          IconButton(
            tooltip: 'Clear all custom IPs',
            visualDensity: VisualDensity.compact,
            onPressed: count == 0 ? null : () => _confirmClear(context),
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
