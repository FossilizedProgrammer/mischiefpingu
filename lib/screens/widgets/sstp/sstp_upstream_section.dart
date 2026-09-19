import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'sstp_upstream_info_box.dart';
import 'sstp_manual_proxy_fields.dart';

class SstpUpstreamSection extends StatelessWidget {
  final ThemeData theme;
  final int sstpUpstreamType;
  final ValueChanged<int> onUpstreamTypeChanged;
  final String sstpProxyType;
  final ValueChanged<String> onProxyTypeChanged;
  final String sstpProxyIp;
  final ValueChanged<String> onProxyIpChanged;
  final int sstpProxyPort;
  final ValueChanged<String> onProxyPortChanged;
  final String sstpProxyUser;
  final ValueChanged<String> onProxyUserChanged;
  final String sstpProxyPass;
  final ValueChanged<String> onProxyPassChanged;
  final int aetherLocalPort;

  const SstpUpstreamSection({
    super.key,
    required this.theme,
    required this.sstpUpstreamType,
    required this.onUpstreamTypeChanged,
    required this.sstpProxyType,
    required this.onProxyTypeChanged,
    required this.sstpProxyIp,
    required this.onProxyIpChanged,
    required this.sstpProxyPort,
    required this.onProxyPortChanged,
    required this.sstpProxyUser,
    required this.onProxyUserChanged,
    required this.sstpProxyPass,
    required this.onProxyPassChanged,
    required this.aetherLocalPort,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.upstream,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: sstpUpstreamType,
          decoration: InputDecoration(
            labelText: l10n.upstreamType,
            isDense: true,
          ),
          items: [
            DropdownMenuItem(value: 0, child: Text(l10n.noUpstreamDirect)),
            DropdownMenuItem(value: 1, child: Text(l10n.manualProxyOption)),
            DropdownMenuItem(value: 2, child: Text(l10n.aetherUpstream)),
            DropdownMenuItem(value: 3, child: Text(l10n.psiphonUpstream)),
            DropdownMenuItem(value: 4, child: Text(l10n.torUpstream)),
          ],
          onChanged: (v) => onUpstreamTypeChanged(v ?? 0),
        ),
        if (sstpUpstreamType == 1) ...[
          const SizedBox(height: 12),
          SstpManualProxyFields(
            proxyType: sstpProxyType,
            onProxyTypeChanged: onProxyTypeChanged,
            proxyIp: sstpProxyIp,
            onProxyIpChanged: onProxyIpChanged,
            proxyPort: sstpProxyPort,
            onProxyPortChanged: onProxyPortChanged,
            proxyUser: sstpProxyUser,
            onProxyUserChanged: onProxyUserChanged,
            proxyPass: sstpProxyPass,
            onProxyPassChanged: onProxyPassChanged,
          ),
        ],
        if (sstpUpstreamType == 2)
          _InfoBox(
            theme: theme,
            icon: Icons.info_outline,
            message:
                'SSTP will route through Aether on 127.0.0.1:$aetherLocalPort. '
                'Make sure Aether is running.',
          ),
        if (sstpUpstreamType == 3)
          _InfoBox(
            theme: theme,
            icon: Icons.info_outline,
            message: 'SSTP will route through Psiphon. '
                'Make sure Psiphon is running.',
          ),
        if (sstpUpstreamType == 4)
          _InfoBox(
            theme: theme,
            icon: Icons.info_outline,
            message: 'SSTP will route through Tor. '
                'Make sure Tor is running.',
          ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String message;

  const _InfoBox({
    required this.theme,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        SstpUpstreamInfoBox(theme: theme, icon: icon, message: message),
      ],
    );
  }
}
