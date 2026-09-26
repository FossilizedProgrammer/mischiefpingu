// lib/services/diagnostics/diagnostics_report_builder.dart

library;

import 'dart:convert';

import '../../models/settings_model.dart';
import '../database/gateway_history_store.dart';
import '../process_service.dart';
import 'diagnostics_report_redactor.dart';

part 'diagnostics_report_sections.dart';
part 'diagnostics_report_json.dart';

/// ═══════════════════════════════════════════════════════════════
///  DiagnosticsReportBuilder — تولید گزارش تشخیصی از وضعیت برنامه.
///
///  گزارش شامل:
///    • اطلاعات نسخه و پلتفرم
///    • تنظیمات فعلی (با redaction)
///    • آخرین لاگ‌ها (با redaction)
///    • آخرین gatewayهای موفق
///    • وضعیت فعلی تونل‌ها
///
///  ⚠️ همه اطلاعات حساس قبل از نوشتن redact میشن.
///
///  ⚠️ بازآرایی: این فایل حالا فقط orchestrator هست.
///  بخش‌های گزارش در `diagnostics_report_sections.dart`
///  و helper JSON در `diagnostics_report_json.dart` قرار دارن.
/// ═══════════════════════════════════════════════════════════════
class DiagnosticsReportBuilder {
  final ProcessService processService;
  final GatewayHistoryStore? gatewayHistoryStore;
  final AppSettings settings;

  DiagnosticsReportBuilder({
    required this.processService,
    required this.settings,
    this.gatewayHistoryStore,
  });

  /// ساخت گزارش کامل به صورت یک رشته.
  ///
  /// ترتیب بخش‌ها:
  ///   1. Header (نام برنامه)
  ///   2. Timestamp
  ///   3. Tunnel states (وضعیت تونل‌ها)
  ///   4. Settings (تنظیمات)
  ///   5. Recent gateways (تاریخچه)
  ///   6. Recent logs (لاگ‌ها)
  ///   7. Footer
  ///
  /// در نهایت همه‌ی اطلاعات حساس redact میشن.
  Future<String> build() async {
    final sb = StringBuffer();

    writeReportHeader(sb);
    writeReportTimestamp(sb);
    writeTunnelStates(sb, processService);
    writeSettingsSection(sb, settings);
    await writeRecentGateways(sb, gatewayHistoryStore);
    writeRecentLogs(sb, processService);
    writeReportFooter(sb);

    final raw = sb.toString();
    return DiagnosticsReportRedactor.redact(raw);
  }
}
