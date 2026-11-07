import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import 'settings_tile_base.dart';

class NotificationsSettingsTile extends StatelessWidget {
  const NotificationsSettingsTile({super.key});

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
      title: l10n.notifications,
      icon: Icons.notifications_outlined,
      iconBackgroundColor: theme.colorScheme.secondary,
      initiallyExpanded: false,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.muteSounds),
          subtitle: Text(
            l10n.muteSoundsSubtitle,
            style: const TextStyle(fontSize: 11),
          ),
          value: s.muted,
          onChanged: (v) {
            s.muted = v;
            save();
          },
        ),
      ],
    );
  }
}
