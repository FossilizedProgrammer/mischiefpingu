import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class TorManualProxySection extends StatelessWidget {
  final String proxyType;
  final ValueChanged<String> onProxyTypeChanged;
  final String proxyIp;
  final ValueChanged<String> onProxyIpChanged;
  final int proxyPort;
  final ValueChanged<String> onProxyPortChanged;
  final String proxyUser;
  final ValueChanged<String> onProxyUserChanged;
  final String proxyPass;
  final ValueChanged<String> onProxyPassChanged;

  const TorManualProxySection({
    super.key,
    required this.proxyType,
    required this.onProxyTypeChanged,
    required this.proxyIp,
    required this.onProxyIpChanged,
    required this.proxyPort,
    required this.onProxyPortChanged,
    required this.proxyUser,
    required this.onProxyUserChanged,
    required this.proxyPass,
    required this.onProxyPassChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          l10n.manualProxyOption,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: proxyType,
          decoration: InputDecoration(labelText: l10n.proxyType, isDense: true),
          items: const [
            DropdownMenuItem(value: 'socks5', child: Text('SOCKS5')),
            DropdownMenuItem(value: 'socks5h', child: Text('SOCKS5h')),
            DropdownMenuItem(value: 'http', child: Text('HTTP')),
          ],
          onChanged: (v) => onProxyTypeChanged(v ?? 'socks5'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                initialValue: proxyIp,
                decoration: InputDecoration(
                  labelText: l10n.proxyIp,
                  hintText: '127.0.0.1',
                  isDense: true,
                ),
                onChanged: onProxyIpChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: TextFormField(
                initialValue: proxyPort.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.port,
                  isDense: true,
                ),
                onChanged: onProxyPortChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: proxyUser,
                decoration: InputDecoration(
                  labelText: l10n.userOptional,
                  isDense: true,
                ),
                onChanged: onProxyUserChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: proxyPass,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.passwordOptional,
                  isDense: true,
                ),
                onChanged: onProxyPassChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
