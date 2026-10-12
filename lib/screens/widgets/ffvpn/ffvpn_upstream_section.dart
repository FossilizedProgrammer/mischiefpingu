// lib/screens/widgets/ffvpn/ffvpn_upstream_section.dart

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/settings_model.dart';
import '../../../services/ffvpn/ffvpn_upstream_builder.dart';
import '../../../widgets/settings_tile_base.dart';

/// ═══════════════════════════════════════════════════════════════
///  FfvpnUpstreamSection — انتخاب آپ‌استریم SOCKS برای Firefox VPN:
///    • بدون آپ‌استریم / دستی / Psiphon / Tor / SSTP / WireGuard
///    • برای حالت دستی، فیلدهای آدرس SOCKS5 پر می‌شوند
/// ═══════════════════════════════════════════════════════════════
class FfvpnUpstreamSection extends StatelessWidget {
  final AppSettings s;
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback onSave;

  const FfvpnUpstreamSection({
    super.key,
    required this.s,
    required this.theme,
    required this.l10n,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final type = s.ffvpnUpstreamType;

    return SettingsSection(
      label: l10n.ffvpnUpstreamSection,
      children: [
        SettingsDropdown<int>(
          labelText: l10n.upstreamType,
          value: type,
          items: [
            DropdownMenuItem(
              value: FfvpnUpstreamBuilder.direct,
              child: Text(l10n.ffvpnUpstreamDirect),
            ),
            DropdownMenuItem(
              value: FfvpnUpstreamBuilder.manual,
              child: Text(l10n.ffvpnUpstreamManual),
            ),
            DropdownMenuItem(
              value: FfvpnUpstreamBuilder.psiphon,
              child: Text(l10n.ffvpnUpstreamPsiphon),
            ),
            DropdownMenuItem(
              value: FfvpnUpstreamBuilder.tor,
              child: Text(l10n.ffvpnUpstreamTor),
            ),
            DropdownMenuItem(
              value: FfvpnUpstreamBuilder.sstp,
              child: Text(l10n.ffvpnUpstreamSstp),
            ),
            DropdownMenuItem(
              value: FfvpnUpstreamBuilder.wireguard,
              child: Text(l10n.ffvpnUpstreamWireguard),
            ),
          ],
          onChanged: (v) {
            s.ffvpnUpstreamType = v ?? FfvpnUpstreamBuilder.direct;
            onSave();
          },
        ),
        const SizedBox(height: 8),
        Text(
          l10n.ffvpnUpstreamDesc,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (type == FfvpnUpstreamBuilder.manual) ...[
          const SizedBox(height: 12),
          FfvpnManualProxyFields(s: s, l10n: l10n, onSave: onSave),
          const SizedBox(height: 8),
          Text(
            l10n.ffvpnUpstreamManualNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ] else if (type != FfvpnUpstreamBuilder.direct) ...[
          const SizedBox(height: 8),
          SettingsInfoCard(
            message: l10n.ffvpnUpstreamVia(
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
      case FfvpnUpstreamBuilder.psiphon:
        return 'Psiphon';
      case FfvpnUpstreamBuilder.tor:
        return 'Tor';
      case FfvpnUpstreamBuilder.sstp:
        return 'SSTP';
      case FfvpnUpstreamBuilder.wireguard:
        return 'WireGuard';
      default:
        return '';
    }
  }

  static int _portFor(AppSettings s, int type) {
    switch (type) {
      case FfvpnUpstreamBuilder.psiphon:
        return s.socksPort;
      case FfvpnUpstreamBuilder.tor:
        return s.torSocksPort;
      case FfvpnUpstreamBuilder.sstp:
        return s.sstpSocksPort;
      case FfvpnUpstreamBuilder.wireguard:
        return s.wireguardSocksPort;
      default:
        return 0;
    }
  }
}

/// فیلدهای آپ‌استریم دستی (فقط SOCKS5 — باینری Go فقط socks5 را می‌پذیرد).
class FfvpnManualProxyFields extends StatelessWidget {
  final AppSettings s;
  final AppLocalizations l10n;
  final VoidCallback onSave;

  const FfvpnManualProxyFields({
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
          initialValue: s.ffvpnProxyType,
          decoration: InputDecoration(
            labelText: l10n.proxyType,
            isDense: true,
          ),
          items: const [
            DropdownMenuItem(value: 'socks5', child: Text('SOCKS5')),
            DropdownMenuItem(value: 'socks5h', child: Text('SOCKS5h')),
          ],
          onChanged: (v) {
            s.ffvpnProxyType = v ?? 'socks5';
            onSave();
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                initialValue: s.ffvpnProxyIp,
                decoration: InputDecoration(
                  labelText: l10n.proxyIp,
                  hintText: '127.0.0.1',
                  isDense: true,
                ),
                onChanged: (v) {
                  s.ffvpnProxyIp = v.trim();
                  onSave();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: TextFormField(
                initialValue: s.ffvpnProxyPort.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.port,
                  isDense: true,
                ),
                onChanged: (v) {
                  final p = int.tryParse(v.trim());
                  if (p != null && p > 0 && p < 65536) {
                    s.ffvpnProxyPort = p;
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
                initialValue: s.ffvpnProxyUser,
                decoration: InputDecoration(
                  labelText: l10n.userOptional,
                  isDense: true,
                ),
                onChanged: (v) {
                  s.ffvpnProxyUser = v.trim();
                  onSave();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: s.ffvpnProxyPass,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.passwordOptional,
                  isDense: true,
                ),
                onChanged: (v) {
                  s.ffvpnProxyPass = v;
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
