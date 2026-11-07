part of 'diagnostics_report_builder.dart';

/// ═══════════════════════════════════════════════════════════════
///  helper برای encode کردن settings به JSON.
///
///  ⚠️ این تابع در حال حاضر استفاده نمی‌شه ولی برای usage
///  خارجی (مثلاً clipboard export در آینده) نگه داشته شده.
///
///  اگه می‌خوای این تابع حذف بشه، از `diagnostics_report_builder.dart`
///  اسمش رو پاک کن.
/// ═══════════════════════════════════════════════════════════════
String settingsToPrettyJson(AppSettings s) {
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(s.toJson());
}
