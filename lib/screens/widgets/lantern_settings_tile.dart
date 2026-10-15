// lib/screens/widgets/lantern_settings_tile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../widgets/settings_tile_base.dart';
import 'lantern/lantern_connection_section.dart';
import 'lantern/lantern_tools_section.dart';
import 'lantern/lantern_upstream_section.dart';

/// ═══════════════════════════════════════════════════════════════
///  LanternSettingsTile — تنظیمات تونل لنترن (headless):
///    • پورت‌های SOCKS/HTTP
///    • آپ‌استریم `--upstream-proxy` (دستی / Psiphon / Tor / SSTP / WireGuard)
///    • ابزارهای CLI: servers / update / auth
/// ═══════════════════════════════════════════════════════════════
class LanternSettingsTile extends StatelessWidget {
  const LanternSettingsTile({super.key});

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
      title: l10n.lanternSettings,
      icon: Icons.lightbulb_outline_rounded,
      iconBackgroundColor: theme.colorScheme.primary,
      initiallyExpanded: false,
      children: [
        LanternConnectionSection(
          s: s,
          theme: theme,
          l10n: l10n,
          onSave: save,
        ),
        const Divider(height: 28),
        LanternUpstreamSection(s: s, theme: theme, l10n: l10n, onSave: save),
        const Divider(height: 28),
        LanternToolsSection(s: s, theme: theme, l10n: l10n, onSave: save),
      ],
    );
  }
}
