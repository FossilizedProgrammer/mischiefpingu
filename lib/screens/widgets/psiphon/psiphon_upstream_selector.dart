library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'psiphon_manual_proxy_section.dart';

class PsiphonUpstreamSelector extends StatelessWidget {
  final int upstreamType;
  final ValueChanged<int?> onUpstreamTypeChanged;
  final bool autoReconnectPsiphon;
  final ValueChanged<bool> onAutoReconnectChanged;

  const PsiphonUpstreamSelector({
    super.key,
    required this.upstreamType,
    required this.onUpstreamTypeChanged,
    required this.autoReconnectPsiphon,
    required this.onAutoReconnectChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 28),
        DropdownButtonFormField<int>(
          initialValue: upstreamType == 4 ? 0 : upstreamType,
          decoration: InputDecoration(labelText: l10n.upstream, isDense: true),
          items: [
            DropdownMenuItem(value: 0, child: Text(l10n.directNoUpstream)),
            DropdownMenuItem(value: 1, child: Text(l10n.manualProxy)),
            DropdownMenuItem(value: 2, child: Text(l10n.aetherSocksUpstream)),
            DropdownMenuItem(value: 3, child: Text(l10n.conduitWebrtc)),
            DropdownMenuItem(value: 4, child: Text(l10n.torSocksUpstream)),
            DropdownMenuItem(value: 5, child: Text(l10n.sstpSocksUpstream)),
          ],
          onChanged: onUpstreamTypeChanged,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.autoReconnectPsiphon),
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
