import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';

class PsiphonPortsRegionTile extends StatelessWidget {
  final ThemeData theme;
  final List<String> regions;
  final int socksPort;
  final ValueChanged<String> onSocksPortChanged;
  final int httpPort;
  final ValueChanged<String> onHttpPortChanged;
  final String egressRegion;
  final ValueChanged<String?> onEgressRegionChanged;
  final bool psiphonShareLan;
  final ValueChanged<bool> onShareLanChanged;

  const PsiphonPortsRegionTile({
    super.key,
    required this.theme,
    required this.regions,
    required this.socksPort,
    required this.onSocksPortChanged,
    required this.httpPort,
    required this.onHttpPortChanged,
    required this.egressRegion,
    required this.onEgressRegionChanged,
    required this.psiphonShareLan,
    required this.onShareLanChanged,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final providerS = provider.settings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: providerS.socksPort.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'SOCKS port',
                  isDense: true,
                ),
                onChanged: onSocksPortChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: providerS.httpPort.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'HTTP port',
                  isDense: true,
                ),
                onChanged: onHttpPortChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: providerS.egressRegion.isNotEmpty &&
                  regions.contains(providerS.egressRegion)
              ? providerS.egressRegion
              : '',
          decoration: const InputDecoration(
            labelText: 'Egress region',
            isDense: true,
          ),
          items: regions
              .map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(r.isEmpty ? 'Any' : r),
                  ))
              .toList(),
          onChanged: onEgressRegionChanged,
        ),
        const Divider(height: 28),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Share on LAN (bind 0.0.0.0)'),
          subtitle: const Text(
            'Forward SOCKS & HTTP ports on all interfaces via Dart',
            style: TextStyle(fontSize: 11),
          ),
          value: psiphonShareLan,
          onChanged: onShareLanChanged,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('IPv4 only'),
          value: providerS.onlyIpv4,
          onChanged: (v) {
            provider.settings.onlyIpv4 = v;
            provider.saveSettings();
            provider.touch();
          },
        ),
      ],
    );
  }
}
