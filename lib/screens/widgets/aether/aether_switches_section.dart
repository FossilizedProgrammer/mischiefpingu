import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  سوییچ‌های Aether (Share LAN + Auto-reconnect).
///
///  این widget از `AetherSettingsTile` جدا شده تا فایل اصلی
///  کوتاه‌تر بشه و logic سوییچ‌ها متمرکز بمونه.
/// ═══════════════════════════════════════════════════════════════
class AetherSwitchesSection extends StatelessWidget {
  const AetherSwitchesSection({super.key});

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
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.shareOnLan),
          value: s.aetherShareLan,
          onChanged: (v) {
            s.aetherShareLan = v;
            save();
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.autoReconnectAether),
          value: s.autoReconnectAether,
          onChanged: (v) {
            s.autoReconnectAether = v;
            save();
          },
        ),
      ],
    );
  }
}
