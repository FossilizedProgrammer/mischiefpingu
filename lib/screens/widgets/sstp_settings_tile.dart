// lib/screens/widgets/sstp_settings_tile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/settings_tile_base.dart';
import 'sstp/sstp_server_section.dart';
import 'sstp/sstp_upstream_section.dart';
import 'sstp/sstp_fronting_section.dart';
import 'sstp/sstp_ports_section.dart';
import 'sstp/sstp_switches_section.dart';

class SstpSettingsTile extends StatelessWidget {
  const SstpSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final s = provider.settings;
    final theme = Theme.of(context);

    void save() {
      provider.saveSettings();
      provider.touch();
    }

    return SettingsTile(
      title: 'SSTP Settings',
      icon: Icons.vpn_lock_outlined,
      iconBackgroundColor: theme.colorScheme.tertiary,
      initiallyExpanded: false,
      children: [
        SstpServerSection(
          theme: theme,
          sstpServer: s.sstpServer,
          onServerChanged: (v) {
            s.sstpServer = v.trim();
            save();
          },
          sstpPort: s.sstpPort,
          onPortChanged: (v) {
            final p = int.tryParse(v.trim());
            if (p != null && p > 0 && p < 65536) {
              s.sstpPort = p;
              save();
            }
          },
          sstpUser: s.sstpUser,
          onUserChanged: (v) {
            s.sstpUser = v.trim();
            save();
          },
          sstpPass: s.sstpPass,
          onPassChanged: (v) {
            s.sstpPass = v;
            save();
          },
        ),
        const SizedBox(height: 16),
        SstpPortsSection(
          settings: s,
          theme: theme,
          onSave: save,
        ),
        const SizedBox(height: 16),
        SstpUpstreamSection(
          theme: theme,
          sstpUpstreamType: s.sstpUpstreamType,
          onUpstreamTypeChanged: (v) {
            s.sstpUpstreamType = v;
            save();
          },
          sstpProxyType: s.sstpProxyType,
          onProxyTypeChanged: (v) {
            s.sstpProxyType = v;
            save();
          },
          sstpProxyIp: s.sstpProxyIp,
          onProxyIpChanged: (v) {
            s.sstpProxyIp = v.trim();
            save();
          },
          sstpProxyPort: s.sstpProxyPort,
          onProxyPortChanged: (v) {
            final p = int.tryParse(v.trim());
            if (p != null && p > 0 && p < 65536) {
              s.sstpProxyPort = p;
              save();
            }
          },
          sstpProxyUser: s.sstpProxyUser,
          onProxyUserChanged: (v) {
            s.sstpProxyUser = v.trim();
            save();
          },
          sstpProxyPass: s.sstpProxyPass,
          onProxyPassChanged: (v) {
            s.sstpProxyPass = v;
            save();
          },
          aetherLocalPort: s.aetherLocalPort,
        ),
        const Divider(height: 28),
        SstpFrontingSection(
          theme: theme,
          sstpSni: s.sstpSni,
          onSniChanged: (v) {
            s.sstpSni = v.trim();
            save();
          },
          sstpFingerprint: s.sstpFingerprint,
          onFingerprintChanged: (v) {
            s.sstpFingerprint = v ?? '';
            save();
          },
        ),
        const SizedBox(height: 16),
        SstpSwitchesSection(settings: s, onSave: save),
      ],
    );
  }
}
