// lib/screens/widgets/advanced_settings/settings_group_general.dart
library;

import 'package:flutter/material.dart';
import '../../../l10n/language_selector_tile.dart';
import '../theme_selector_tile.dart';
import '../../../widgets/notifications_settings_tile.dart';
import '../../../widgets/internet_quality_tile.dart';
import '../../../widgets/diagnostics/connection_health_section.dart';

/// ═══════════════════════════════════════════════════════════════
///  گروه تنظیمات عمومی: ظاهر، زبان، اعلان‌ها، کیفیت اینترنت
/// ═══════════════════════════════════════════════════════════════
class SettingsGroupGeneral extends StatelessWidget {
  const SettingsGroupGeneral({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        InternetQualityTile(),
        ConnectionHealthSection(),
        ThemeSelectorTile(),
        LanguageSelectorTile(),
        NotificationsSettingsTile(),
      ],
    );
  }
}
