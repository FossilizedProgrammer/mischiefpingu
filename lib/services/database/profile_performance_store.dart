library;

import '../process/log_source.dart';
import 'database_schema.dart';
import 'gateway_database.dart';

part 'profile_performance/record.dart';
part 'profile_performance/query.dart';
part 'profile_performance/maintenance.dart';

/// ═══════════════════════════════════════════════════════════════
///  ProfilePerformanceStore — آمار عملکرد به تفکیک
///  (profile, protocol, network_type).
///
///  هدف: برنامه بداند در شرایط شبکهٔ فعلی کدام پروتکل بهتر کار
///  می‌کند — و ترتیب تست candidateها را بر این اساس بچیند.
///
///  بخش‌های داخلی در `profile_performance/` جدا شده‌اند:
///    • record      → ثبت نتیجه
///    • query       → خواندن
///    • maintenance → prune / clear
/// ═══════════════════════════════════════════════════════════════
class ProfilePerformanceStore {
  final void Function(String message, {String source}) log;

  ProfilePerformanceStore({required this.log});

  void logInternal(String msg) => log(msg, source: LogSource.aether);

  static String buildKey(
    String profile,
    String protocol,
    String masque,
    String network,
  ) => '$profile|$protocol|$masque|$network';
}
