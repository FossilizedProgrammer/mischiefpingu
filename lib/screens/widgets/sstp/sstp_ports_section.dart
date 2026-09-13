// lib/screens/widgets/sstp/sstp_ports_section.dart
//
// ═══════════════════════════════════════════════════════════════
//  بخش Local proxy ports برای SSTP
//  (تفکیک شده از sstp_settings_tile.dart)
// ═══════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../../../models/settings_model.dart';

class SstpPortsSection extends StatelessWidget {
  final AppSettings settings;
  final ThemeData theme;
  final VoidCallback onSave;

  const SstpPortsSection({
    super.key,
    required this.settings,
    required this.theme,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Local proxy ports',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: settings.sstpSocksPort.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'SOCKS port',
                  isDense: true,
                ),
                onChanged: (v) {
                  final p = int.tryParse(v.trim());
                  if (p != null && p > 0 && p < 65536) {
                    settings.sstpSocksPort = p;
                    onSave();
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: settings.sstpHttpPort.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'HTTP port',
                  isDense: true,
                ),
                onChanged: (v) {
                  final p = int.tryParse(v.trim());
                  if (p != null && p > 0 && p < 65536) {
                    settings.sstpHttpPort = p;
                    onSave();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
