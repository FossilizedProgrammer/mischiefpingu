library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/app_provider.dart';
import '../../../providers/sstp_fetcher_provider.dart';
import '../../../services/vpngate_scraper_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  عملیات SstpFetcherSection: apply server + clear all.
///
///  این منطق قبلاً توی widget بود. حالا جدا شده تا widget فقط
///  UI بمونه.
/// ═══════════════════════════════════════════════════════════════
class SstpFetcherActions {
  SstpFetcherActions._();

  /// اعمال یک سرور SSTP به عنوان سرور فعلی.
  static Future<void> applyServer(BuildContext context, SstpServer s) async {
    final app = context.read<AppProvider>();
    if (app.processService.isSstpRunning) {
      await app.connectSstp();
      await Future.delayed(const Duration(milliseconds: 400));
    }
    app.settings.sstpServer = s.ip;
    app.settings.sstpPort = s.port;
    await app.saveSettings();
    app.touch();
    if (!context.mounted) return;
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

  /// پاک کردن همه سرورها با تایید کاربر.
  static Future<void> clearAll(
    BuildContext context,
    SstpFetcherProvider fetcher,
  ) async {
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
}
