import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../services/watchdog/watchdog_network_profile.dart';
import 'settings_tile_base.dart';

class WatchdogSettingsTile extends StatelessWidget {
  const WatchdogSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final s = provider.settings;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final currentProfile = WatchdogNetworkProfile.fromId(
      s.watchdogNetworkProfile,
    );

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
        const SizedBox(height: 8),
        // ─── انتخاب پروفایل شبکه ───
        Opacity(
          opacity: s.watchdogEnabled ? 1.0 : 0.5,
          child: IgnorePointer(
            ignoring: !s.watchdogEnabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.watchdogNetworkProfile,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.watchdogNetworkProfileSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                SegmentedButton<WatchdogNetworkProfile>(
                  segments: [
                    ButtonSegment(
                      value: WatchdogNetworkProfile.stable,
                      label: Text(l10n.watchdogProfileStable),
                      icon: const Icon(Icons.speed, size: 16),
                    ),
                    ButtonSegment(
                      value: WatchdogNetworkProfile.normal,
                      label: Text(l10n.watchdogProfileNormal),
                      icon: const Icon(Icons.balance, size: 16),
                    ),
                    ButtonSegment(
                      value: WatchdogNetworkProfile.harsh,
                      label: Text(l10n.watchdogProfileHarsh),
                      icon: const Icon(Icons.shield_outlined, size: 16),
                    ),
                  ],
                  selected: {currentProfile},
                  onSelectionChanged: (set) {
                    if (set.isEmpty) return;
                    s.watchdogNetworkProfile = set.first.id;
                    save();
                  },
                  showSelectedIcon: false,
                ),
                const SizedBox(height: 8),
                Text(
                  _descriptionFor(currentProfile, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _descriptionFor(
    WatchdogNetworkProfile p,
    AppLocalizations l10n,
  ) {
    switch (p) {
      case WatchdogNetworkProfile.stable:
        return l10n.watchdogProfileStableDesc;
      case WatchdogNetworkProfile.normal:
        return l10n.watchdogProfileNormalDesc;
      case WatchdogNetworkProfile.harsh:
        return l10n.watchdogProfileHarshDesc;
    }
  }
}
