// lib/screens/widgets/npv_settings_tile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../widgets/settings_tile_base.dart';
import 'npv/npv_config_section.dart';
import 'npv/npv_connection_section.dart';
import 'npv/npv_servers_section.dart';

/// ═══════════════════════════════════════════════════════════════
///  NpvSettingsTile — تنظیمات تونل NPV (باینری npv از پروژهٔ npv-go):
///    • فایل .npvs که رمزگشایی و سنجیده می‌شود
///    • فهرست کانفیگ‌های فایل، با ترتیب سرعت و دلیل خطا
///    • پورت‌های SOCKS/HTTP محلی و پارامترهای سنجش
///
///  کانفیگ سرویس‌شده را یا خود npv انتخاب می‌کند (سریع‌ترین زنده) یا
///  کاربر از بخش «Servers in this file» با یک ضربه انتخاب می‌کند.
/// ═══════════════════════════════════════════════════════════════
class NpvSettingsTile extends StatelessWidget {
  const NpvSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final s = provider.settings;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    void save() {
      provider.saveSettings();
      provider.touch();
    }

    return SettingsTile(
      title: l10n.npvSettings,
      icon: Icons.portable_wifi_off_rounded,
      iconBackgroundColor: theme.colorScheme.tertiary,
      initiallyExpanded: false,
      trailingWidget: Text(
        provider.npvStatus,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      children: [
        NpvConfigSection(s: s, theme: theme, l10n: l10n, onSave: save),
        const Divider(height: 28),
        NpvServersSection(s: s, theme: theme, l10n: l10n, onSave: save),
        const Divider(height: 28),
        NpvConnectionSection(s: s, theme: theme, l10n: l10n, onSave: save),
        if (provider.isNpvBusy || provider.processService.isNpvRunning) ...[
          const SizedBox(height: 10),
          Text(
            provider.npvStatus,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}
