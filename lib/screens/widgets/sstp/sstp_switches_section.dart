// lib/screens/widgets/sstp/sstp_switches_section.dart
//
// ═══════════════════════════════════════════════════════════════
//  بخش Switches (Share LAN / Auto-reconnect / Verbose) برای SSTP
//  (تفکیک شده از sstp_settings_tile.dart)
// ═══════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../../../models/settings_model.dart';

class SstpSwitchesSection extends StatelessWidget {
  final AppSettings settings;
  final VoidCallback onSave;

  const SstpSwitchesSection({
    super.key,
    required this.settings,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Share on LAN (bind 0.0.0.0)'),
          value: settings.sstpShareLan,
          onChanged: (v) {
            settings.sstpShareLan = v;
            onSave();
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Auto-reconnect SSTP'),
          value: settings.autoReconnectSstp,
          onChanged: (v) {
            settings.autoReconnectSstp = v;
            onSave();
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Verbose logging'),
          subtitle: const Text(
            'Enable detailed debug output from sstp-proxy',
            style: TextStyle(fontSize: 11),
          ),
          value: settings.sstpVerbose,
          onChanged: (v) {
            settings.sstpVerbose = v;
            onSave();
          },
        ),
      ],
    );
  }
}
