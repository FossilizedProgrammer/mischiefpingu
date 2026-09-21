import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_provider.dart';
import 'aether_dropdown_field.dart';
import 'aether_masque_section.dart';
import 'aether_connection_mode_section.dart';
import 'aether_quick_profile_selector.dart';

class AetherProtocolCard extends StatelessWidget {
  const AetherProtocolCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final s = provider.settings;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isRunning =
        provider.processService.isAetherRunning || provider.isAutoTesting;

    final protocolLocked = s.isAetherProtocolLockedByProfile;

    final showMasqueSection = !protocolLocked &&
        (s.aetherProtocol == 'masque' || s.aetherProtocol == 'mim');

    void save() {
      provider.saveSettings();
      provider.touch();
    }

    final protocols = [
      MapEntry('masque', l10n.protoMasque),
      MapEntry('mim', l10n.protoMim),
      MapEntry('wireguard', l10n.protoWireguard),
      MapEntry('gool', l10n.protoGool),
    ];

    final scanModes = [
      MapEntry('turbo', l10n.scanTurbo),
      MapEntry('balanced', l10n.scanBalanced),
      MapEntry('thorough', l10n.scanThorough),
      MapEntry('stealth', l10n.scanStealth),
      MapEntry('ironclad', l10n.scanIronclad),
    ];

    final ipTypes = [
      MapEntry('ipv4', l10n.ipv4),
      MapEntry('ipv6', l10n.ipv6),
      MapEntry('both', l10n.both),
    ];

    final obfuscations = [
      MapEntry('off', l10n.obfOff),
      MapEntry('light', l10n.obfLight),
      MapEntry('firewall', l10n.obfFirewall),
      MapEntry('balanced', l10n.obfBalanced),
      MapEntry('gfw', l10n.obfGfw),
      MapEntry('aggressive', l10n.obfAggressive),
    ];

    final effectiveProtocol = protocolLocked
        ? 'masque'
        : (protocols.any((e) => e.key == s.aetherProtocol)
            ? s.aetherProtocol
            : protocols.first.key);

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
                  l10n.aetherSettings,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            AetherQuickProfileSelector(isRunning: isRunning),
            const Divider(height: 24),
            AetherDropdownField(
              label: l10n.protocol,
              value: effectiveProtocol,
              items: protocols,
              enabled: !isRunning && !protocolLocked,
              onChanged: (v) {
                s.aetherProtocol = v;
                save();
              },
            ),
            if (showMasqueSection) ...[
              const SizedBox(height: 12),
              AetherMasqueSection(isRunning: isRunning),
            ],
            const SizedBox(height: 16),
            AetherDropdownField(
              label: l10n.ipType,
              value: s.ipType,
              items: ipTypes,
              enabled: !isRunning,
              onChanged: (v) {
                s.ipType = v;
                save();
              },
            ),
            const SizedBox(height: 16),
            AetherDropdownField(
              label: l10n.scanMode,
              value: s.aetherScanMode,
              items: scanModes,
              enabled: !isRunning && !protocolLocked,
              onChanged: (v) {
                s.aetherScanMode = v;
                save();
              },
            ),
            const SizedBox(height: 16),
            AetherDropdownField(
              label: l10n.obfuscation,
              value: s.obfuscation,
              items: obfuscations,
              enabled: !isRunning && !protocolLocked,
              onChanged: (v) {
                s.obfuscation = v;
                save();
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: s.aetherLocalPort.toString(),
              decoration: InputDecoration(
                labelText: l10n.localSocksPort,
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
