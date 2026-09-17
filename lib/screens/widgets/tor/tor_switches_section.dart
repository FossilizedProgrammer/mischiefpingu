// lib/screens/widgets/tor/tor_switches_section.dart
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class TorSwitchesSection extends StatelessWidget {
  final bool torShareLan;
  final ValueChanged<bool> onShareLanChanged;
  final bool autoReconnectTor;
  final ValueChanged<bool> onAutoReconnectChanged;

  const TorSwitchesSection({
    super.key,
    required this.torShareLan,
    required this.onShareLanChanged,
    required this.autoReconnectTor,
    required this.onAutoReconnectChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.shareOnLan),
          value: torShareLan,
          onChanged: onShareLanChanged,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.autoReconnectTor),
          value: autoReconnectTor,
          onChanged: onAutoReconnectChanged,
        ),
      ],
    );
  }
}
