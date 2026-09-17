import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.localProxyPorts,
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
                decoration: InputDecoration(
                  labelText: l10n.socksPort,
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
                decoration: InputDecoration(
                  labelText: l10n.httpPort,
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
