import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/settings_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/settings_tile_base.dart';
import 'preset_radio_tile.dart';

class SuggestedPresets extends StatelessWidget {
  const SuggestedPresets({super.key});

  int _currentGroup(AppSettings s) {
    if (s.useSunAndLion && s.isFronted && s.upstreamType == 0) return 1;
    if (s.upstreamType == 3) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final s = provider.settings;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final current = _currentGroup(s);

    return SettingsTile(
      title: l10n.psiphonConnectionMode,
      icon: Icons.tune,
      iconBackgroundColor: theme.colorScheme.primary,
      children: [
        RadioGroup<int>(
          groupValue: current,
          onChanged: (v) {
            if (v != null) provider.applySetting(v);
          },
          child: Column(
            children: [
              PresetRadioTile(
                value: 1,
                title: l10n.preset1Title,
                subtitle: l10n.preset1Subtitle,
              ),
              PresetRadioTile(
                value: 2,
                title: l10n.preset3Title,
                subtitle: l10n.preset3Subtitle,
              ),
              PresetRadioTile(
                value: 3,
                title: l10n.preset4Title,
                subtitle: l10n.preset4Subtitle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
