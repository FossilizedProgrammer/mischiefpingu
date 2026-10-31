// lib/screens/widgets/advanced_settings_column.dart
library;

import 'package:flutter/material.dart';
import 'advanced_settings/settings_group_general.dart';
import 'advanced_settings/settings_group_tunnels.dart';
import 'advanced_settings/settings_group_tools.dart';

/// ═══════════════════════════════════════════════════════════════
///  AdvancedSettingsColumn — orchestrator برای سه گروه تنظیمات.
///
///  ⚠️ بازآرایی: ویجت‌ها به سه فایل جدا منتقل شدند:
///    • SettingsGroupGeneral  → ظاهر، زبان، اعلان‌ها، کیفیت
///    • SettingsGroupTunnels  → Aether, Psiphon, Tor, SSTP, WG
///    • SettingsGroupTools    → اسکنرها، آپدیت، واچ‌داگ، لاگ
/// ═══════════════════════════════════════════════════════════════
class AdvancedSettingsColumn extends StatelessWidget {
  const AdvancedSettingsColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingsGroupGeneral(),
        SettingsGroupTunnels(),
        SettingsGroupTools(),
      ],
    );
  }
}
