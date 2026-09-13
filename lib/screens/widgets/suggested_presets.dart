// lib/screens/widgets/suggested_presets.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/settings_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/settings_tile_base.dart';
import 'preset_radio_tile.dart';

class SuggestedPresets extends StatelessWidget {
  const SuggestedPresets({super.key});

  int _currentGroup(AppSettings s) {
    if (s.useSunAndLion && s.isFronted) return 1;
    if (s.upstreamType == 2) return 2;
    if (s.upstreamType == 3) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final s = provider.settings;
    final theme = Theme.of(context);

    return SettingsTile(
      title: 'Psiphon connection mode',
      icon: Icons.tune,
      iconBackgroundColor: theme.colorScheme.primary,
      children: [
        RadioGroup<int>(
          groupValue: _currentGroup(s),
          onChanged: (int? value) {
            if (value != null) {
              provider.applySetting(value);
            }
          },
          child: const Column(
            children: [
              PresetRadioTile(
                value: 1,
                title: '1 · Fronting (CDN). Best for heavy censorship.',
                subtitle:
                    'Uses the SunAndLion Psiphon Tunnel Core (Unofficial fork of Psiphon tunnel core).',
              ),
              PresetRadioTile(
                value: 2,
                title:
                    '2 · Aether traffic as upstream. Suitable when Aether works.',
                subtitle:
                    'Uses official Psiphon Tunnel Core with Aether upstream.',
              ),
              PresetRadioTile(
                value: 3,
                title:
                    '3 · Conduit (WebRTC Inproxy). Decentralized peer relays.',
                subtitle:
                    'Uses Psiphon INPROXY-WEBRTC protocols via volunteer stations.',
              ),
              PresetRadioTile(
                value: 4,
                title: '4 · Direct connection. Suitable for mild censorship.',
                subtitle: 'Uses the official Psiphon Tunnel Core directly.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
