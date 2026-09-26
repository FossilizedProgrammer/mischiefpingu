// lib/screens/widgets/advanced_settings/settings_group_tools.dart
library;

import 'package:flutter/material.dart';
import '../../../widgets/cdn_scanner_section.dart';
import '../../../widgets/bridge_scanner_section.dart';
import '../sstp_fetcher_section.dart';
import '../core_update_tile.dart';
import '../app_update_tile.dart';
import '../../../widgets/watchdog_settings_tile.dart';
import '../diagnostics_report_tile.dart';
import '../log_tile.dart';

/// ═══════════════════════════════════════════════════════════════
///  گروه ابزارها: اسکنرها، آپدیت‌ها، واچ‌داگ، لاگ
/// ═══════════════════════════════════════════════════════════════
class SettingsGroupTools extends StatelessWidget {
  const SettingsGroupTools({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CdnScannerSection(),
        BridgeScannerSection(),
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
