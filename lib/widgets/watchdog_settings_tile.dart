import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import 'settings_tile_base.dart';

class WatchdogSettingsTile extends StatelessWidget {
  const WatchdogSettingsTile({super.key});

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
      title: l10n.watchdogSettings,
      icon: Icons.monitor_heart_outlined,
      iconBackgroundColor: theme.colorScheme.tertiary,
      initiallyExpanded: false,
      trailingText: s.watchdogEnabled ? null : l10n.obfOff,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.watchdogEnabled),
          subtitle: Text(
            l10n.watchdogEnabledSubtitle,
            style: const TextStyle(fontSize: 11),
          ),
          value: s.watchdogEnabled,
          onChanged: (v) {
            s.watchdogEnabled = v;
            save();
          },
        ),
      ],
    );
  }
}
