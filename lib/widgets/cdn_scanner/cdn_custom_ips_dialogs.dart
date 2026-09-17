library;

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/cdn_scanner_provider.dart';

class CdnCustomIpsDialogs {
  CdnCustomIpsDialogs._();

  static Future<bool> confirmClear(
    BuildContext context,
    CdnScannerProvider scan,
  ) async {
    if (scan.customIps.isEmpty) return false;
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${l10n.clearAll}?'),
        content: Text('${scan.customIps.length}'),
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
    return ok == true;
  }

  static void showManage(
    BuildContext context,
    CdnScannerProvider scan,
  ) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final items = scan.customIps;
            return AlertDialog(
              title: Text('${l10n.customIps} (${items.length})'),
              content: SizedBox(
                width: double.maxFinite,
                height: 360,
                child: items.isEmpty
                    ? Center(child: Text(l10n.noCustomIpsSaved))
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
                  child: Text(l10n.close),
                ),
                TextButton(
                  onPressed: () async {
                    await scan.clearCustomIps();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: Text('✕  ${l10n.clearAll}'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
