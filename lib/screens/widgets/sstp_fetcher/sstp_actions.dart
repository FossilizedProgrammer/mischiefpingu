import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/sstp_fetcher_provider.dart';

class SstpClipboardActions {
  SstpClipboardActions._();

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

  static Future<void> copyAllServers(
    BuildContext context,
    SstpFetcherProvider fetcher,
  ) async {
    final l10n = AppLocalizations.of(context);
    final visible = fetcher.visibleServers;
    if (visible.isEmpty) return;
    final lines = visible.map((s) => '${s.ip}:${s.port}').join('\n');
    await Clipboard.setData(ClipboardData(text: lines));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${visible.length} · ${l10n.copiedToClipboard}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<void> copyAllDetailed(
    BuildContext context,
    SstpFetcherProvider fetcher,
  ) async {
    final l10n = AppLocalizations.of(context);
    final visible = fetcher.visibleServers;
    if (visible.isEmpty) return;

    final buffer = StringBuffer();
    buffer.writeln(
      'ip,port,country,country_code,ping_ms,speed_mbps,operator,health',
    );
    for (final s in visible) {
      final h = fetcher.healthOf(s);
      buffer.writeln(
        '${s.ip},${s.port},"${s.country}",${s.countryShort},${s.ping},${s.speed},"${s.operator}",${h.status.name}',
      );
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${visible.length} · ${l10n.copiedToClipboard} (CSV)'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
