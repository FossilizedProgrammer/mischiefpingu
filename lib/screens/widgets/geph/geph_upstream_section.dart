// lib/screens/widgets/geph/geph_upstream_section.dart

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/settings_model.dart';
import '../../../services/geph/geph_upstream_builder.dart';
import '../../../widgets/settings/port_text_field.dart';
import '../../../widgets/settings_tile_base.dart';

/// ═══════════════════════════════════════════════════════════════
///  GephUpstreamSection — انتخاب آپ‌استریم برای گف
///  (فلگ سراسری `--upstream`):
///    • بدون آپ‌استریم / دستی / Psiphon / Tor / SSTP / WireGuard
///    • برای حالت دستی، فیلدهای آدرس پروکسی پر می‌شوند
/// ═══════════════════════════════════════════════════════════════
class GephUpstreamSection extends StatelessWidget {
  final AppSettings s;
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback onSave;

  const GephUpstreamSection({
    super.key,
    required this.s,
    required this.theme,
    required this.l10n,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final type = s.gephUpstreamType;

    return SettingsSection(
      label: l10n.gephUpstreamSection,
      children: [
        SettingsDropdown<int>(
          labelText: l10n.upstreamType,
          value: type,
          items: [
            DropdownMenuItem(
              value: GephUpstreamBuilder.direct,
              child: Text(l10n.gephUpstreamDirect),
            ),
            DropdownMenuItem(
              value: GephUpstreamBuilder.manual,
              child: Text(l10n.gephUpstreamManual),
            ),
            DropdownMenuItem(
              value: GephUpstreamBuilder.psiphon,
              child: Text(l10n.gephUpstreamPsiphon),
            ),
            DropdownMenuItem(
              value: GephUpstreamBuilder.tor,
              child: Text(l10n.gephUpstreamTor),
            ),
            DropdownMenuItem(
              value: GephUpstreamBuilder.sstp,
              child: Text(l10n.gephUpstreamSstp),
            ),
            DropdownMenuItem(
              value: GephUpstreamBuilder.wireguard,
              child: Text(l10n.gephUpstreamWireguard),
            ),
            DropdownMenuItem(
              value: GephUpstreamBuilder.ffvpn,
              child: Text(l10n.gephUpstreamFfvpn),
            ),
            DropdownMenuItem(
              value: GephUpstreamBuilder.lantern,
              child: Text(l10n.gephUpstreamLantern),
            ),
          ],
          onChanged: (v) {
            s.gephUpstreamType = v ?? GephUpstreamBuilder.direct;
            onSave();
          },
        ),
        const SizedBox(height: 8),
        Text(
          l10n.gephUpstreamDesc,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (type == GephUpstreamBuilder.manual) ...[
          const SizedBox(height: 12),
          GephManualProxyFields(s: s, l10n: l10n, onSave: onSave),
          const SizedBox(height: 8),
          Text(
            l10n.gephUpstreamManualNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ] else if (type != GephUpstreamBuilder.direct) ...[
          const SizedBox(height: 8),
          SettingsInfoCard(
            message: l10n.gephUpstreamVia(
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
      case GephUpstreamBuilder.psiphon:
        return 'Psiphon';
      case GephUpstreamBuilder.tor:
        return 'Tor';
      case GephUpstreamBuilder.sstp:
        return 'SSTP';
      case GephUpstreamBuilder.wireguard:
        return 'WireGuard';
      case GephUpstreamBuilder.ffvpn:
        return 'Firefox VPN';
      case GephUpstreamBuilder.lantern:
        return 'Lantern';
      default:
        return '';
    }
  }

  static int _portFor(AppSettings s, int type) {
    switch (type) {
      case GephUpstreamBuilder.psiphon:
        return s.socksPort;
      case GephUpstreamBuilder.tor:
        return s.torSocksPort;
      case GephUpstreamBuilder.sstp:
        return s.sstpSocksPort;
      case GephUpstreamBuilder.wireguard:
        return s.wireguardSocksPort;
      case GephUpstreamBuilder.ffvpn:
        return s.ffvpnSocksPort;
      case GephUpstreamBuilder.lantern:
        return s.lanternSocksPort;
      default:
        return 0;
    }
  }
}

/// فیلدهای آپ‌استریم دستی (socks5/socks5h/http/https).
class GephManualProxyFields extends StatelessWidget {
  final AppSettings s;
  final AppLocalizations l10n;
  final VoidCallback onSave;

  const GephManualProxyFields({
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
          initialValue: s.gephProxyType,
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
            s.gephProxyType = v ?? 'socks5';
            onSave();
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                initialValue: s.gephProxyIp,
                decoration: InputDecoration(
                  labelText: l10n.proxyIp,
                  hintText: '127.0.0.1',
                  isDense: true,
                ),
                onChanged: (v) {
                  s.gephProxyIp = v.trim();
                  onSave();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: PortTextField(
                labelText: l10n.port,
                initialValue: s.gephProxyPort.toString(),
                onChanged: (v) {
                  final p = int.tryParse(v.trim());
                  if (p != null && p > 0 && p < 65536) {
                    s.gephProxyPort = p;
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
                initialValue: s.gephProxyUser,
                decoration: InputDecoration(
                  labelText: l10n.userOptional,
                  isDense: true,
                ),
                onChanged: (v) {
                  s.gephProxyUser = v.trim();
                  onSave();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: s.gephProxyPass,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.passwordOptional,
                  isDense: true,
                ),
                onChanged: (v) {
                  s.gephProxyPass = v;
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
