// lib/screens/widgets/tor/tor_switches_section.dart
import 'package:flutter/material.dart';

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
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Share on LAN (bind 0.0.0.0)'),
          value: torShareLan,
          onChanged: onShareLanChanged,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Auto-reconnect Tor'),
          value: autoReconnectTor,
          onChanged: onAutoReconnectChanged,
        ),
      ],
    );
  }
}
