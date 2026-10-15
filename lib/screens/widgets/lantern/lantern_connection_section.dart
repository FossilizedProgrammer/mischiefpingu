// lib/screens/widgets/lantern/lantern_connection_section.dart

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/settings_model.dart';
import '../../../widgets/settings/port_text_field.dart';
import '../../../widgets/settings_tile_base.dart';

/// ═══════════════════════════════════════════════════════════════
///  LanternConnectionSection — پورت‌های SOCKS/HTTP لنترن.
/// ═══════════════════════════════════════════════════════════════
class LanternConnectionSection extends StatelessWidget {
  final AppSettings s;
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback onSave;

  const LanternConnectionSection({
    super.key,
    required this.s,
    required this.theme,
    required this.l10n,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      label: l10n.lanternConnectionSection,
      children: [
        Row(
          children: [
            Expanded(
              child: PortTextField(
                labelText: l10n.lanternPortSocks,
                initialValue: s.lanternSocksPort.toString(),
                onChanged: (v) {
                  final p = int.tryParse(v.trim());
                  if (p != null && p > 0 && p < 65536) {
                    s.lanternSocksPort = p;
                    onSave();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PortTextField(
                labelText: l10n.lanternPortHttp,
                initialValue: s.lanternHttpPort.toString(),
                min: 0,
                onChanged: (v) {
                  final p = int.tryParse(v.trim());
                  if (p != null && p >= 0 && p < 65536) {
                    s.lanternHttpPort = p;
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
