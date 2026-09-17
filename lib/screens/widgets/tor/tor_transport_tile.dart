import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'tor_transport_selector.dart';
import 'tor_ports_section.dart';
import 'tor_exit_country_section.dart';
import 'tor_bridges_section.dart';
import 'tor_switches_section.dart';

class TorTransportTile extends StatelessWidget {
  final ThemeData theme;
  final String transportLabel;
  final String torTransport;
  final ValueChanged<String?> onTransportChanged;
  final String torBridges;
  final ValueChanged<String> onBridgesChanged;
  final String torExitCountry;
  final ValueChanged<String?> onExitCountryChanged;
  final int torSocksPort;
  final ValueChanged<String> onSocksPortChanged;
  final int torHttpPort;
  final ValueChanged<String> onHttpPortChanged;
  final List<String> torExitCountries;
  final bool torShareLan;
  final ValueChanged<bool> onShareLanChanged;
  final bool autoReconnectTor;
  final ValueChanged<bool> onAutoReconnectChanged;

  const TorTransportTile({
    super.key,
    required this.theme,
    required this.transportLabel,
    required this.torTransport,
    required this.onTransportChanged,
    required this.torBridges,
    required this.onBridgesChanged,
    required this.torExitCountry,
    required this.onExitCountryChanged,
    required this.torSocksPort,
    required this.onSocksPortChanged,
    required this.torHttpPort,
    required this.onHttpPortChanged,
    required this.torExitCountries,
    required this.torShareLan,
    required this.onShareLanChanged,
    required this.autoReconnectTor,
    required this.onAutoReconnectChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TorTransportSelector(
          transportLabel: transportLabel,
          torTransport: torTransport,
          onTransportChanged: onTransportChanged,
        ),
        const SizedBox(height: 16),
        TorPortsSection(
          torSocksPort: torSocksPort,
          onSocksPortChanged: onSocksPortChanged,
          torHttpPort: torHttpPort,
          onHttpPortChanged: onHttpPortChanged,
        ),
        const SizedBox(height: 16),
        TorExitCountrySection(
          torExitCountry: torExitCountry,
          onExitCountryChanged: onExitCountryChanged,
          torExitCountries: torExitCountries,
        ),
        const SizedBox(height: 16),
        TorSwitchesSection(
          torShareLan: torShareLan,
          onShareLanChanged: onShareLanChanged,
          autoReconnectTor: autoReconnectTor,
          onAutoReconnectChanged: onAutoReconnectChanged,
        ),
        const Divider(height: 28),
        if (torTransport != 'direct') ...[
          TorBridgesSection(
            theme: theme,
            torTransport: torTransport,
            torBridges: torBridges,
            onBridgesChanged: onBridgesChanged,
            onTransportChanged: onTransportChanged,
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            l10n.torDirect,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
