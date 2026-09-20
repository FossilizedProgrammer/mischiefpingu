library;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../models/gateway_record.dart';
import '../process/log_source.dart';
import 'database_schema.dart';
import 'gateway_database.dart';
import 'gateway_score_calculator.dart';

part 'gateway_history_store/gateway_history_store_internal.dart';
part 'gateway_history_store/gateway_history_store_record.dart';
part 'gateway_history_store/gateway_history_store_query.dart';
part 'gateway_history_store/gateway_history_store_maintenance.dart';
part 'gateway_history_store/record/success_failure.dart';
part 'gateway_history_store/record/performance_session.dart';

/// ═══════════════════════════════════════════════════════════════
///  GatewayHistoryStore — ذخیره، بازیابی و رتبه‌بندی Gatewayها.
///
///  فاز v4: پشتیبانی از uptime و reconnect.
///
///  این فایل فقط shell است. منطق در بخش‌های جدا شده:
///    • internal       → helpers خصوصی مشترک
///    • record         → ثبت موفقیت/شکست/عملکرد/session
///    • query          → خواندن
///    • maintenance    → prune / clear / count
///    • success_failure → recordSuccess + recordFailure
///    • performance_session → recordPerformance + recordSessionEnd
///                              + recordReconnectEvent
/// ═══════════════════════════════════════════════════════════════
class GatewayHistoryStore {
  final void Function(String message, {String source}) log;

  GatewayHistoryStore({required this.log});

  void _log(String msg) => log(msg, source: LogSource.aether);
}
