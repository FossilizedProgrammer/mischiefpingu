// lib/widgets/aether_protocol_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'aether/aether_dropdown_field.dart';
import 'aether/aether_masque_section.dart';
import 'aether/aether_connection_mode_section.dart';

class AetherProtocolCard extends StatelessWidget {
  const AetherProtocolCard({super.key});

  static const _protocols = [
    MapEntry('auto', 'Auto'),
    MapEntry('masque', 'MASQUE'),
    MapEntry('wireguard', 'WireGuard'),
    MapEntry('gool', 'Gool'),
  ];

  static const _scanModes = [
    MapEntry('turbo', 'Turbo'),
    MapEntry('balanced', 'Balanced'),
    MapEntry('thorough', 'Thorough'),
    MapEntry('stealth', 'Stealth'),
    MapEntry('ironclad', 'Ironclad'),
  ];

  static const _ipTypes = [
    MapEntry('ipv4', 'IPv4'),
    MapEntry('ipv6', 'IPv6'),
    MapEntry('both', 'Both'),
  ];

  static const _obfuscations = [
    MapEntry('off', 'Off'),
    MapEntry('light', 'Light'),
    MapEntry('balanced', 'Balanced'),
    MapEntry('aggressive', 'Aggressive'),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final s = provider.settings;
    final theme = Theme.of(context);
    final isRunning =
        provider.processService.isAetherRunning || provider.isAutoTesting;

    void save() {
      provider.saveSettings();
      provider.touch();
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hub_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Aether Settings',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            AetherDropdownField(
              label: 'Protocol',
              value: s.aetherProtocol,
              items: _protocols,
              enabled: !isRunning,
              onChanged: (v) {
                s.aetherProtocol = v;
                save();
              },
            ),
            if (s.aetherProtocol == 'masque' || s.aetherProtocol == 'auto') ...[
              const SizedBox(height: 12),
              AetherMasqueSection(isRunning: isRunning),
            ],
            const SizedBox(height: 16),
            AetherDropdownField(
              label: 'IP Type',
              value: s.ipType,
              items: _ipTypes,
              enabled: !isRunning,
              onChanged: (v) {
                s.ipType = v;
                save();
              },
            ),
            const SizedBox(height: 16),
            AetherDropdownField(
              label: 'Scan mode',
              value: s.aetherScanMode,
              items: _scanModes,
              enabled: !isRunning,
              onChanged: (v) {
                s.aetherScanMode = v;
                save();
              },
            ),
            const SizedBox(height: 16),
            AetherDropdownField(
              label: 'Obfuscation (--noize)',
              value: s.obfuscation,
              items: _obfuscations,
              enabled: !isRunning,
              onChanged: (v) {
                s.obfuscation = v;
                save();
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: s.aetherLocalPort.toString(),
              decoration: const InputDecoration(
                labelText: 'Local SOCKS port',
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: !isRunning,
              onChanged: (v) {
                final p = int.tryParse(v);
                if (p != null && p >= 1 && p <= 65535) {
                  s.aetherLocalPort = p;
                  save();
                }
              },
            ),
            const SizedBox(height: 16),
            AetherConnectionModeSection(isRunning: isRunning),
          ],
        ),
      ),
    );
  }
}
