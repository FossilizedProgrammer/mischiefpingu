// lib/screens/widgets/geph_settings_tile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../widgets/settings_tile_base.dart';
import 'geph/geph_connection_section.dart';
import 'geph/geph_tools_section.dart';
import 'geph/geph_upstream_section.dart';

/// ═══════════════════════════════════════════════════════════════
///  GephSettingsTile — تنظیمات تونل گف (geph5-proxy):
///    • پورت‌های SOCKS/HTTP و کشور خروجی
///    • آپ‌استریم `--upstream` (دستی / Psiphon / Tor / SSTP / WireGuard)
///    • ابزارهای CLI: signup / login / countries
/// ═══════════════════════════════════════════════════════════════
class GephSettingsTile extends StatelessWidget {
  const GephSettingsTile({super.key});

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
      title: l10n.gephSettings,
      icon: Icons.travel_explore_rounded,
      iconBackgroundColor: theme.colorScheme.primary,
      initiallyExpanded: false,
      children: [
        GephConnectionSection(
          s: s,
          theme: theme,
          l10n: l10n,
          onSave: save,
        ),
        const Divider(height: 28),
        GephUpstreamSection(s: s, theme: theme, l10n: l10n, onSave: save),
        const Divider(height: 28),
        GephToolsSection(s: s, theme: theme, l10n: l10n, onSave: save),
      ],
    );
  }
}
