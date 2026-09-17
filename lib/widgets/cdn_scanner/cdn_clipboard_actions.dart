// lib/widgets/cdn_scanner/cdn_clipboard_actions.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/cdn_scanner_provider.dart';

class CdnClipboardActions {
  CdnClipboardActions._();

  static Future<void> copySingle(
    BuildContext context,
    String text,
    String label,
  ) async {
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.copiedToClipboard}: $text'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<void> copyAllUsable(
    BuildContext context,
    CdnScannerProvider scan,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (scan.good.isEmpty) return;
    final lines = scan.good.map((r) => r.ip).join('\n');
    await Clipboard.setData(ClipboardData(text: lines));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${scan.good.length} · ${l10n.copiedToClipboard}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<void> copyAllDetailed(
    BuildContext context,
    CdnScannerProvider scan,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (scan.good.isEmpty) return;
    final buffer = StringBuffer();
    buffer.writeln('ip,sni,latency_ms,reliability,score');
    for (final r in scan.good) {
      buffer.writeln(
          '${r.ip},${r.sni},${r.latencyMs},${r.reliability},${r.score}');
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${scan.good.length} · ${l10n.copiedToClipboard} (CSV)'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
