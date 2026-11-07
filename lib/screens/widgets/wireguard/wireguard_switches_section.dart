import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class WireGuardSwitchesSection extends StatelessWidget {
  final bool shareLan;
  final ValueChanged<bool> onShareLanChanged;
  final bool autoReconnect;
  final ValueChanged<bool> onAutoReconnectChanged;
  final AppLocalizations l10n;

  const WireGuardSwitchesSection({
    super.key,
    required this.shareLan,
    required this.onShareLanChanged,
    required this.autoReconnect,
    required this.onAutoReconnectChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.shareOnLan),
          value: shareLan,
          onChanged: onShareLanChanged,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.autoReconnectWireGuard),
          value: autoReconnect,
          onChanged: onAutoReconnectChanged,
        ),
      ],
    );
  }
}
