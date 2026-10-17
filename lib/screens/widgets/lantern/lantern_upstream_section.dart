// lib/screens/widgets/lantern/lantern_upstream_section.dart

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/settings_model.dart';
import '../../../services/lantern/lantern_upstream_builder.dart';
import '../../../widgets/settings/port_text_field.dart';
import '../../../widgets/settings_tile_base.dart';

/// ═══════════════════════════════════════════════════════════════
///  LanternUpstreamSection — انتخاب آپ‌استریم برای لنترن
///  (فلگ سراسری `--upstream-proxy`):
///    • بدون آپ‌استریم / دستی / Psiphon / Tor / SSTP / WireGuard
///    • برای حالت دستی، فیلدهای آدرس پروکسی پر می‌شوند
/// ═══════════════════════════════════════════════════════════════
class LanternUpstreamSection extends StatelessWidget {
  final AppSettings s;
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback onSave;

  const LanternUpstreamSection({
    super.key,
    required this.s,
    required this.theme,
    required this.l10n,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final type = s.lanternUpstreamType;

    return SettingsSection(
      label: l10n.lanternUpstreamSection,
      children: [
        SettingsDropdown<int>(
          labelText: l10n.upstreamType,
          value: type,
          items: [
            DropdownMenuItem(
              value: LanternUpstreamBuilder.direct,
              child: Text(l10n.lanternUpstreamDirect),
            ),
            DropdownMenuItem(
              value: LanternUpstreamBuilder.manual,
              child: Text(l10n.lanternUpstreamManual),
            ),
            DropdownMenuItem(
              value: LanternUpstreamBuilder.psiphon,
              child: Text(l10n.lanternUpstreamPsiphon),
            ),
            DropdownMenuItem(
              value: LanternUpstreamBuilder.tor,
              child: Text(l10n.lanternUpstreamTor),
            ),
            DropdownMenuItem(
              value: LanternUpstreamBuilder.sstp,
              child: Text(l10n.lanternUpstreamSstp),
            ),
            DropdownMenuItem(
              value: LanternUpstreamBuilder.wireguard,
              child: Text(l10n.lanternUpstreamWireguard),
            ),
            DropdownMenuItem(
              value: LanternUpstreamBuilder.ffvpn,
              child: Text(l10n.lanternUpstreamFfvpn),
            ),
            DropdownMenuItem(
              value: LanternUpstreamBuilder.geph,
              child: Text(l10n.lanternUpstreamGeph),
            ),
          ],
          onChanged: (v) {
            s.lanternUpstreamType = v ?? LanternUpstreamBuilder.direct;
            onSave();
          },
        ),
        const SizedBox(height: 8),
        Text(
          l10n.lanternUpstreamDesc,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (type == LanternUpstreamBuilder.manual) ...[
          const SizedBox(height: 12),
          LanternManualProxyFields(s: s, l10n: l10n, onSave: onSave),
          const SizedBox(height: 8),
          Text(
            l10n.lanternUpstreamManualNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ] else if (type != LanternUpstreamBuilder.direct) ...[
          const SizedBox(height: 8),
          SettingsInfoCard(
            message: l10n.lanternUpstreamVia(
              _labelFor(type),
              '${_portFor(s, type)}',
            ),
          ),
        ],
      ],
    );
  }

  static String _labelFor(int type) {
    switch (type) {
      case LanternUpstreamBuilder.psiphon:
        return 'Psiphon';
      case LanternUpstreamBuilder.tor:
        return 'Tor';
      case LanternUpstreamBuilder.sstp:
        return 'SSTP';
      case LanternUpstreamBuilder.wireguard:
        return 'WireGuard';
      case LanternUpstreamBuilder.ffvpn:
        return 'Firefox VPN';
      case LanternUpstreamBuilder.geph:
        return 'Geph';
      default:
        return '';
    }
  }

  static int _portFor(AppSettings s, int type) {
    switch (type) {
      case LanternUpstreamBuilder.psiphon:
        return s.socksPort;
      case LanternUpstreamBuilder.tor:
        return s.torSocksPort;
      case LanternUpstreamBuilder.sstp:
        return s.sstpSocksPort;
      case LanternUpstreamBuilder.wireguard:
        return s.wireguardSocksPort;
      case LanternUpstreamBuilder.ffvpn:
        return s.ffvpnSocksPort;
      case LanternUpstreamBuilder.geph:
        return s.gephSocksPort;
      default:
        return 0;
    }
  }
}

/// فیلدهای آپ‌استریم دستی (socks5/socks5h/http/https).
class LanternManualProxyFields extends StatelessWidget {
  final AppSettings s;
  final AppLocalizations l10n;
  final VoidCallback onSave;

  const LanternManualProxyFields({
    super.key,
    required this.s,
    required this.l10n,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: s.lanternProxyType,
          decoration: InputDecoration(
            labelText: l10n.proxyType,
            isDense: true,
          ),
          items: const [
            DropdownMenuItem(value: 'socks5', child: Text('SOCKS5')),
            DropdownMenuItem(value: 'socks5h', child: Text('SOCKS5h')),
            DropdownMenuItem(value: 'http', child: Text('HTTP')),
            DropdownMenuItem(value: 'https', child: Text('HTTPS')),
          ],
          onChanged: (v) {
            s.lanternProxyType = v ?? 'socks5';
            onSave();
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                initialValue: s.lanternProxyIp,
                decoration: InputDecoration(
                  labelText: l10n.proxyIp,
                  hintText: '127.0.0.1',
                  isDense: true,
                ),
                onChanged: (v) {
                  s.lanternProxyIp = v.trim();
                  onSave();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: PortTextField(
                labelText: l10n.port,
                initialValue: s.lanternProxyPort.toString(),
                onChanged: (v) {
                  final p = int.tryParse(v.trim());
                  if (p != null && p > 0 && p < 65536) {
                    s.lanternProxyPort = p;
                    onSave();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: s.lanternProxyUser,
                decoration: InputDecoration(
                  labelText: l10n.userOptional,
                  isDense: true,
                ),
                onChanged: (v) {
                  s.lanternProxyUser = v.trim();
                  onSave();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: s.lanternProxyPass,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.passwordOptional,
                  isDense: true,
                ),
                onChanged: (v) {
                  s.lanternProxyPass = v;
                  onSave();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
