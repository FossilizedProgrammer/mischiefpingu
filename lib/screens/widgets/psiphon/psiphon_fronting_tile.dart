import 'package:flutter/material.dart';
import '../../../providers/app_provider.dart';
import '../../../widgets/editable_list_dropdown.dart';
import 'psiphon_manual_proxy_section.dart';

class PsiphonFrontingTile extends StatelessWidget {
  final ThemeData theme;
  final AppProvider provider;
  final bool isFronted;
  final ValueChanged<bool> onFrontedChanged;
  final int upstreamType;
  final ValueChanged<int?> onUpstreamTypeChanged;
  final bool autoReconnectPsiphon;
  final ValueChanged<bool> onAutoReconnectChanged;

  const PsiphonFrontingTile({
    super.key,
    required this.theme,
    required this.provider,
    required this.isFronted,
    required this.onFrontedChanged,
    required this.upstreamType,
    required this.onUpstreamTypeChanged,
    required this.autoReconnectPsiphon,
    required this.onAutoReconnectChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Use fronting (CDN)'),
          value: isFronted,
          onChanged: onFrontedChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<bool>(
          initialValue: provider.settings.useSunAndLion,
          decoration: const InputDecoration(
            labelText: 'Tunnel core',
            isDense: true,
          ),
          items: const [
            DropdownMenuItem(
              value: false,
              child: Text('official psiphon tunnel core'),
            ),
            DropdownMenuItem(
              value: true,
              child: Text('sunandlion psiphon tunnel core'),
            ),
          ],
          onChanged: (v) {
            provider.settings.useSunAndLion = v ?? false;
            provider.saveSettings();
            provider.touch();
          },
        ),
        if (isFronted) ...[
          const SizedBox(height: 12),
          EditableListDropdown(
            label: 'Fronting IP',
            value: provider.settings.ip,
            items: provider.ipList,
            onChanged: (v) {
              provider.settings.ip = v;
              provider.saveSettings();
              provider.touch();
            },
            onListChanged: (list) {
              provider.saveIpList(list);
            },
          ),
          const SizedBox(height: 12),
          EditableListDropdown(
            label: 'HTTP Host Header (e.g. aparat.com, snapp.ir)',
            value: provider.settings.httpHost,
            items: provider.httpHostList,
            onChanged: (v) {
              provider.settings.httpHost = v;
              provider.saveSettings();
              provider.touch();
            },
            onListChanged: (list) {
              provider.saveHttpHostList(list);
            },
          ),
          const SizedBox(height: 12),
          EditableListDropdown(
            label: 'TLS SNI (e.g. a248.e.akamai.net)',
            value: provider.settings.tlsSni,
            items: provider.tlsSniList,
            onChanged: (v) {
              provider.settings.tlsSni = v;
              provider.saveSettings();
              provider.touch();
            },
            onListChanged: (list) {
              provider.saveTlsSniList(list);
            },
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text('Auto-find IP & SNI'),
            value: provider.settings.autoFindIpAndSni,
            onChanged: (v) {
              provider.settings.autoFindIpAndSni = v;
              provider.saveSettings();
              provider.touch();
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text('Save found IPs & SNI automatically'),
            value: provider.settings.saveFoundIpsAndSni,
            onChanged: (v) {
              provider.settings.saveFoundIpsAndSni = v;
              provider.saveSettings();
              provider.touch();
            },
          ),
        ],
        const Divider(height: 28),
        DropdownButtonFormField<int>(
          initialValue: upstreamType == 4 ? 0 : upstreamType,
          decoration: const InputDecoration(
            labelText: 'Upstream',
            isDense: true,
          ),
          items: const [
            DropdownMenuItem(value: 0, child: Text('Direct (no upstream)')),
            DropdownMenuItem(value: 1, child: Text('Manual proxy')),
            DropdownMenuItem(value: 2, child: Text('Aether (SOCKS upstream)')),
            DropdownMenuItem(value: 3, child: Text('Conduit (WebRTC Inproxy)')),
            DropdownMenuItem(value: 4, child: Text('Tor (SOCKS upstream)')),
            DropdownMenuItem(value: 5, child: Text('SSTP (SOCKS upstream)')),
          ],
          onChanged: onUpstreamTypeChanged,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Auto-reconnect Psiphon'),
          value: autoReconnectPsiphon,
          onChanged: onAutoReconnectChanged,
        ),
        if (upstreamType == 1) ...[
          const SizedBox(height: 12),
          const PsiphonManualProxySection(),
        ],
      ],
    );
  }
}
