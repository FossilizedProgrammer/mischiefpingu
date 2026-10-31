// lib/screens/widgets/npv/npv_connection_section.dart
//
// پورت‌های local listener و پارامترهای سنجش کانفیگ‌ها.
//
// npv قبل از باز کردن listener، تک‌تک کانفیگ‌های فایل را با یک درخواست
// واقعی می‌سنجد؛ `-timeout` مهلت هر درخواست و `-jobs` تعداد سنجش‌های
// همزمان است. `-url` هدف تست را عوض می‌کند (خالی = خود npv چند آدرس
// generate_204 را امتحان می‌کند).

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/settings_model.dart';
import '../../../widgets/settings/port_text_field.dart';
import '../../../widgets/settings_tile_base.dart';

class NpvConnectionSection extends StatelessWidget {
  final AppSettings s;
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback onSave;

  const NpvConnectionSection({
    super.key,
    required this.s,
    required this.theme,
    required this.l10n,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      label: l10n.npvConnectionSection,
      children: [
        Row(
          children: [
            Expanded(
              child: PortTextField(
                labelText: l10n.npvPortSocks,
                initialValue: s.npvSocksPort.toString(),
                onChanged: (v) {
                  final p = int.tryParse(v.trim());
                  if (p != null && p > 0 && p < 65536) {
                    s.npvSocksPort = p;
                    onSave();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PortTextField(
                labelText: l10n.npvPortHttp,
                initialValue: s.npvHttpPort.toString(),
                min: 0,
                onChanged: (v) {
                  final p = int.tryParse(v.trim());
                  if (p != null && p >= 0 && p < 65536) {
                    s.npvHttpPort = p;
                    onSave();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SettingsSubSection(
          label: l10n.npvProbeSection,
          hint: l10n.npvProbeDesc,
          children: [
            Row(
              children: [
                Expanded(
                  child: PortTextField(
                    labelText: l10n.npvProbeTimeout,
                    initialValue: s.npvProbeTimeout.toString(),
                    min: 1,
                    max: 60,
                    onChanged: (v) {
                      final n = int.tryParse(v.trim());
                      if (n != null && n >= 1 && n <= 60) {
                        s.npvProbeTimeout = n;
                        onSave();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PortTextField(
                    labelText: l10n.npvProbeJobs,
                    initialValue: s.npvProbeJobs.toString(),
                    min: 1,
                    max: 16,
                    onChanged: (v) {
                      final n = int.tryParse(v.trim());
                      if (n != null && n >= 1 && n <= 16) {
                        s.npvProbeJobs = n;
                        onSave();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SettingsTextField(
              labelText: l10n.npvProbeUrl,
              hintText: 'http://clients3.google.com/generate_204',
              initialValue: s.npvProbeUrl,
              onChanged: (v) {
                s.npvProbeUrl = v.trim();
                onSave();
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        SettingsSwitch(
          title: l10n.shareOnLan,
          value: s.npvShareLan,
          onChanged: (v) {
            s.npvShareLan = v;
            onSave();
          },
        ),
        SettingsSwitch(
          title: l10n.autoReconnectNpv,
          value: s.npvAutoReconnect,
          onChanged: (v) {
            s.npvAutoReconnect = v;
            onSave();
          },
        ),
      ],
    );
  }
}
