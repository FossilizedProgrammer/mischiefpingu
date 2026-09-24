// lib/screens/widgets/wireguard_settings_tile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/wireguard_core_type.dart';
import '../../providers/app_provider.dart';
import '../../services/wireguard/wireguard_config_parser.dart';
import '../../widgets/settings_tile_base.dart';
import 'wireguard/wireguard_config_section.dart';
import 'wireguard/wireguard_ports_section.dart';
import 'wireguard/wireguard_switches_section.dart';

class WireGuardSettingsTile extends StatelessWidget {
  const WireGuardSettingsTile({super.key});

  static String? _shortEndpoint(String rawConfig) {
    if (rawConfig.trim().isEmpty) return null;
    final parsed = WireGuardConfigParser.parse(rawConfig);
    if (parsed == null || !parsed.isValid) return null;

    final endpoint = parsed.endpoint;
    final colon = endpoint.lastIndexOf(':');
    if (colon <= 0) {
      return endpoint.length > 18 ? '${endpoint.substring(0, 15)}…' : endpoint;
    }

    final host = endpoint.substring(0, colon);
    final port = endpoint.substring(colon);
    if (host.length <= 15) return endpoint;
    return '${host.substring(0, 12)}…$port';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final s = provider.settings;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final ps = provider.processService;

    final isConnected = ps.isWireGuardConnected;

    final endpoint = _shortEndpoint(s.wireguardConfigRaw);
    final trailing = isConnected && endpoint != null
        ? '${l10n.connected} · $endpoint'
        : (isConnected ? l10n.connected : null);

    void save() {
      provider.saveSettings();
      provider.touch();
    }

    return SettingsTile(
      title: l10n.wireguardSettings,
      icon: Icons.vpn_key_outlined,
      iconBackgroundColor: theme.colorScheme.primary,
      initiallyExpanded: false,
      trailingText: trailing,
      children: [
        // ═══════════════════════════════════════════════════════
        //  انتخاب هسته (Standard / Amnezia)
        // ═══════════════════════════════════════════════════════
        Text(
          l10n.wireguardCoreTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.wireguardCoreDescription,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        SegmentedButton<WireGuardCoreType>(
          segments: [
            ButtonSegment(
              value: WireGuardCoreType.standard,
              label: Text(l10n.wireguardCoreStandard),
              icon: const Icon(Icons.shield_outlined, size: 16),
            ),
            ButtonSegment(
              value: WireGuardCoreType.amnezia,
              label: Text(l10n.wireguardCoreAmnezia),
              icon: const Icon(Icons.enhanced_encryption, size: 16),
            ),
          ],
          selected: {s.wireGuardCoreType},
          onSelectionChanged: (set) {
            if (set.isEmpty) return;
            s.wireguardCore =
                set.first == WireGuardCoreType.amnezia ? 'amnezia' : 'standard';
            save();
          },
          showSelectedIcon: false,
        ),
        const Divider(height: 28),

        // ═══════════════════════════════════════════════════════
        //  کانفیگ
        // ═══════════════════════════════════════════════════════
        WireGuardConfigSection(
          theme: theme,
          l10n: l10n,
          initialConfig: s.wireguardConfigRaw,
          onConfigChanged: (v) {
            s.wireguardConfigRaw = v;
            save();
          },
        ),
        const SizedBox(height: 16),
        WireGuardPortsSection(
          theme: theme,
          l10n: l10n,
          socksPort: s.wireguardSocksPort,
          onSocksPortChanged: (p) {
            s.wireguardSocksPort = p;
            save();
          },
        ),
        const Divider(height: 28),
        WireGuardSwitchesSection(
          shareLan: s.wireguardShareLan,
          onShareLanChanged: (v) {
            s.wireguardShareLan = v;
            save();
          },
          autoReconnect: s.wireguardAutoReconnect,
          onAutoReconnectChanged: (v) {
            s.wireguardAutoReconnect = v;
            save();
          },
          l10n: l10n,
        ),
      ],
    );
  }
}
