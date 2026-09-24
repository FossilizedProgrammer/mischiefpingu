// lib/screens/widgets/psiphon/psiphon_manual_proxy_section.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/app_provider.dart';

class PsiphonManualProxySection extends StatelessWidget {
  const PsiphonManualProxySection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final s = provider.settings;
    final l10n = AppLocalizations.of(context);

    void save() {
      provider.saveSettings();
      provider.touch();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: s.proxyType,
                decoration: InputDecoration(
                  labelText: l10n.proxyType,
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'socks5', child: Text('SOCKS5')),
                  DropdownMenuItem(value: 'http', child: Text('HTTP')),
                ],
                onChanged: (v) {
                  s.proxyType = v ?? 'socks5';
                  save();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: s.proxyIp,
                decoration: InputDecoration(
                  labelText: l10n.proxyIp,
                  isDense: true,
                ),
                onChanged: (v) {
                  s.proxyIp = v.trim();
                  save();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: s.proxyPort.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.port,
                  isDense: true,
                ),
                onChanged: (v) {
                  final p = int.tryParse(v.trim());
                  if (p != null && p > 0 && p < 65536) {
                    s.proxyPort = p;
                    save();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: s.proxyUser,
                decoration: InputDecoration(
                  labelText: l10n.userOptional,
                  isDense: true,
                ),
                onChanged: (v) {
                  s.proxyUser = v.trim();
                  save();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: s.proxyPass,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.passwordOptional,
                  isDense: true,
                ),
                onChanged: (v) {
                  s.proxyPass = v;
                  save();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
