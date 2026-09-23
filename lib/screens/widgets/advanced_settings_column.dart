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
import 'app_update_tile.dart';
import 'log_tile.dart';
import 'diagnostics_report_tile.dart';
import '../../widgets/cdn_scanner_section.dart';
import '../../widgets/internet_quality_tile.dart';
import '../../widgets/diagnostics/connection_health_section.dart';
import '../../widgets/watchdog_settings_tile.dart';
import 'wireguard_settings_tile.dart';

class AdvancedSettingsColumn extends StatelessWidget {
  const AdvancedSettingsColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        InternetQualityTile(),
        ConnectionHealthSection(),
        ThemeSelectorTile(),
        LanguageSelectorTile(),
        NotificationsSettingsTile(),
        AetherSettingsTile(),
        PsiphonSettingsTile(),
        TorSettingsTile(),
        SstpSettingsTile(),
        WireGuardSettingsTile(),
        CdnScannerSection(),
        SstpFetcherSection(),
        CoreUpdateTile(),
        AppUpdateTile(),
        WatchdogSettingsTile(),
        DiagnosticsReportTile(),
        LogTile(),
      ],
    );
  }
}
