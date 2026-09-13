// lib/screens/widgets/sstp_fetcher/sstp_actions.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../providers/sstp_fetcher_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  اکشن‌های کپی کلیپ‌بورد برای لیست SSTP
/// ═══════════════════════════════════════════════════════════════
class SstpClipboardActions {
  SstpClipboardActions._();

  static Future<void> copySingle(
    BuildContext context,
    String text,
    String label,
  ) async {
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

  static Future<void> copyAllServers(
    BuildContext context,
    SstpFetcherProvider fetcher,
  ) async {
    final visible = fetcher.visibleServers;
    if (visible.isEmpty) return;
    final lines = visible.map((s) => '${s.ip}:${s.port}').join('\n');
    await Clipboard.setData(ClipboardData(text: lines));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${visible.length} server(s) copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<void> copyAllDetailed(
    BuildContext context,
    SstpFetcherProvider fetcher,
  ) async {
    final visible = fetcher.visibleServers;
    if (visible.isEmpty) return;

    final buffer = StringBuffer();
    buffer.writeln(
        'ip,port,country,country_code,ping_ms,speed_mbps,operator,health');
    for (final s in visible) {
      final h = fetcher.healthOf(s);
      buffer.writeln(
          '${s.ip},${s.port},"${s.country}",${s.countryShort},${s.ping},${s.speed},"${s.operator}",${h.status.name}');
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${visible.length} server(s) copied (CSV format)'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
