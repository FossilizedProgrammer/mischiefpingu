// lib/screens/widgets/advanced_settings_column.dart
library;

import 'package:flutter/material.dart';
import '../../l10n/language_selector_tile.dart';
import 'theme_selector_tile.dart';
import '../../widgets/notifications_settings_tile.dart';
import 'aether_settings_tile.dart';
import 'psiphon_settings_tile.dart';
import 'tor_settings_tile.dart';
import 'sstp_settings_tile.dart';
import 'sstp_fetcher_section.dart';
import 'core_update_tile.dart';
import 'log_tile.dart';
import '../../widgets/cdn_scanner_section.dart';

class AdvancedSettingsColumn extends StatelessWidget {
  const AdvancedSettingsColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ThemeSelectorTile(),
        LanguageSelectorTile(),
        NotificationsSettingsTile(),
        AetherSettingsTile(),
        PsiphonSettingsTile(),
        TorSettingsTile(),
        SstpSettingsTile(),
        CdnScannerSection(),
        SstpFetcherSection(),
        CoreUpdateTile(),
        LogTile(),
      ],
    );
  }
}
