import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/settings_tile_base.dart';
import 'psiphon/psiphon_ports_region_tile.dart';
import 'psiphon/psiphon_fronting_tile.dart';

class PsiphonSettingsTile extends StatefulWidget {
  const PsiphonSettingsTile({super.key});

  @override
  State<PsiphonSettingsTile> createState() => _PsiphonSettingsTileState();
}

class _PsiphonSettingsTileState extends State<PsiphonSettingsTile> {
  static const _regions = [
    '',
    'AT',
    'AU',
    'BE',
    'CA',
    'CH',
    'CZ',
    'DE',
    'DK',
    'ES',
    'FI',
    'FR',
    'GB',
    'ID',
    'IE',
    'IN',
    'IT',
    'JP',
    'LT',
    'NL',
    'NO',
    'PL',
    'RO',
    'RS',
    'SE',
    'SG',
    'US',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final s = provider.settings;
    final theme = Theme.of(context);

    void save() {
      provider.saveSettings();
      provider.touch();
    }

    // ✅ نام‌ها بدون _ (چون local هستن)
    void handleFrontedChanged(bool value) {
      setState(() => s.isFronted = value);
      if (value) {
        s.useSunAndLion = true;
      } else {
        s.useSunAndLion = false;
      }
      save();
    }

    void handleUpstreamTypeChanged(int? value) {
      setState(() => s.upstreamType = value ?? 0);
      if (value == 3) {
        s.useSunAndLion = false;
      }
      save();
    }

    void handleAutoReconnectChanged(bool value) {
      setState(() => s.autoReconnectPsiphon = value);
      save();
    }

    return SettingsTile(
      title: 'Psiphon Settings',
      icon: Icons.security,
      iconBackgroundColor: theme.colorScheme.secondary,
      initiallyExpanded: false,
      children: [
        PsiphonPortsRegionTile(
          theme: theme,
          regions: _regions,
          socksPort: s.socksPort,
          onSocksPortChanged: (v) {
            final p = int.tryParse(v.trim());
            if (p != null && p > 0 && p < 65536) {
              s.socksPort = p;
              save();
            }
          },
          httpPort: s.httpPort,
          onHttpPortChanged: (v) {
            final p = int.tryParse(v.trim());
            if (p != null && p > 0 && p < 65536) {
              s.httpPort = p;
              save();
            }
          },
          egressRegion: s.egressRegion,
          onEgressRegionChanged: (v) {
            s.egressRegion = v ?? '';
            save();
          },
          psiphonShareLan: s.psiphonShareLan,
          onShareLanChanged: (v) {
            s.psiphonShareLan = v;
            save();
          },
        ),
        const SizedBox(height: 8),
        PsiphonFrontingTile(
          theme: theme,
          provider: provider,
          isFronted: s.isFronted,
          onFrontedChanged: handleFrontedChanged,
          upstreamType: s.upstreamType,
          onUpstreamTypeChanged: handleUpstreamTypeChanged,
          autoReconnectPsiphon: s.autoReconnectPsiphon,
          onAutoReconnectChanged: handleAutoReconnectChanged,
        ),
      ],
    );
  }
}
