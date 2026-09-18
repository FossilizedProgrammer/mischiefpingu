import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class PsiphonManualProxySection extends StatelessWidget {
  const PsiphonManualProxySection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: 'socks5',
                decoration: InputDecoration(
                  labelText: l10n.proxyType,
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'socks5', child: Text('SOCKS5')),
                  DropdownMenuItem(value: 'http', child: Text('HTTP')),
                ],
                onChanged: (v) {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: '',
                decoration: InputDecoration(
                  labelText: l10n.proxyIp,
                  isDense: true,
                ),
                onChanged: (v) {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: '1080',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.port,
                  isDense: true,
                ),
                onChanged: (v) {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: '',
                decoration: InputDecoration(
                  labelText: l10n.userOptional,
                  isDense: true,
                ),
                onChanged: (v) {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: '',
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.passwordOptional,
                  isDense: true,
                ),
                onChanged: (v) {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}
