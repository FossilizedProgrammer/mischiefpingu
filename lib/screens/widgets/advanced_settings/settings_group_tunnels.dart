// lib/screens/widgets/advanced_settings/settings_group_tunnels.dart
library;

import 'package:flutter/material.dart';
import '../aether_settings_tile.dart';
import '../psiphon_settings_tile.dart';
import '../tor_settings_tile.dart';
import '../sstp_settings_tile.dart';
import '../wireguard_settings_tile.dart';

class SettingsGroupTunnels extends StatelessWidget {
  const SettingsGroupTunnels({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        AetherSettingsTile(),
        PsiphonSettingsTile(),
        TorSettingsTile(),
        SstpSettingsTile(),
        WireGuardSettingsTile(),
      ],
    );
  }
}
