library;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../models/gateway_record.dart';
import '../process/log_source.dart';
import 'database_schema.dart';
import 'gateway_database.dart';
import 'gateway_score_calculator.dart';

part 'gateway_history_store/gateway_history_store_internal.dart';
part 'gateway_history_store/gateway_history_store_query.dart';
part 'gateway_history_store/gateway_history_store_maintenance.dart';
part 'gateway_history_store/record/success_failure.dart';
part 'gateway_history_store/record/performance_session.dart';
// ❌ حذف شد: part 'gateway_history_store/gateway_history_store_record.dart';

class GatewayHistoryStore {
  final void Function(String message, {String source}) log;

  GatewayHistoryStore({required this.log});

  void _log(String msg) => log(msg, source: LogSource.aether);
}
