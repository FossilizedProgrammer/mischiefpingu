import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../widgets/settings_tile_base.dart';
import 'tor/tor_transport_tile.dart';

class TorSettingsTile extends StatelessWidget {
  const TorSettingsTile({super.key});

  static const _exitCountries = [
    '',
    'DE',
    'US',
    'NL',
    'FR',
    'CH',
    'SE',
    'NO',
    'FI',
    'IS',
    'AT',
    'BE',
    'DK',
    'IE',
    'IT',
    'ES',
    'PT',
    'CZ',
    'PL',
    'RO',
    'RS',
    'SG',
  ];

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
      title: l10n.torSettings,
      icon: Icons.shield_outlined,
      iconBackgroundColor: theme.colorScheme.secondary,
      initiallyExpanded: false,
      children: [
        TorTransportTile(
          theme: theme,
          transportLabel: l10n.torConnection,
          torTransport: s.torTransport,
          onTransportChanged: (v) {
            s.torTransport = v ?? 'direct';
            save();
          },
          torExitCountry: s.torExitCountry,
          onExitCountryChanged: (v) {
            s.torExitCountry = (v ?? '').toLowerCase();
            save();
          },
          torBridges: s.torBridges,
          onBridgesChanged: (v) {
            s.torBridges = v;
            provider.saveSettings();
          },
          torSocksPort: s.torSocksPort,
          onSocksPortChanged: (v) {
            final p = int.tryParse(v.trim());
            if (p != null && p > 0 && p < 65536) {
              s.torSocksPort = p;
              save();
            }
          },
          torHttpPort: s.torHttpPort,
          onHttpPortChanged: (v) {
            final p = int.tryParse(v.trim());
            if (p != null && p > 0 && p < 65536) {
              s.torHttpPort = p;
              save();
            }
          },
          torExitCountries: _exitCountries,
          torShareLan: s.torShareLan,
          onShareLanChanged: (v) {
            s.torShareLan = v;
            save();
          },
          autoReconnectTor: s.autoReconnectTor,
          onAutoReconnectChanged: (v) {
            s.autoReconnectTor = v;
            save();
          },
          torProxyType: s.torProxyType,
          onProxyTypeChanged: (v) {
            s.torProxyType = v;
            save();
          },
          torProxyIp: s.torProxyIp,
          onProxyIpChanged: (v) {
            s.torProxyIp = v.trim();
            save();
          },
          torProxyPort: s.torProxyPort,
          onProxyPortChanged: (v) {
            final p = int.tryParse(v.trim());
            if (p != null && p > 0 && p < 65536) {
              s.torProxyPort = p;
              save();
            }
          },
          torProxyUser: s.torProxyUser,
          onProxyUserChanged: (v) {
            s.torProxyUser = v.trim();
            save();
          },
          torProxyPass: s.torProxyPass,
          onProxyPassChanged: (v) {
            s.torProxyPass = v;
            save();
          },
        ),
      ],
    );
  }
}
