library;

import '../../models/aether_event.dart';
import '../process/log_source.dart';
import 'database_schema.dart';
import 'gateway_database.dart';

/// ═══════════════════════════════════════════════════════════════
///  AetherEventStore — ثبت و بازیابی رویدادهای ساختاریافته.
///
///  برخلاف GatewayHistoryStore که aggregate نگه می‌دارد، این
///  store تاریخچهٔ خام رویدادها را نگه می‌دارد. برای تحلیل
///  و دیباگ استفاده می‌شود.
///
///  نگهداری: حداکثر N رویداد (پاک‌سازی خودکار قدیمی‌ها).
/// ═══════════════════════════════════════════════════════════════
class AetherEventStore {
  final void Function(String message, {String source}) log;

  /// حداکثر تعداد رویداد که نگه داشته می‌شود.
  static const int maxEvents = 5000;

  AetherEventStore({required this.log});

  void _log(String msg) => log(msg, source: LogSource.aether);

  /// ثبت یک رویداد.
  Future<void> record(AetherEvent event) async {
    try {
      final db = await GatewayDatabase.instance();
      await db.insert(DatabaseSchema.tableAetherEvents, event.toMap());

      // پاک‌سازی خودکار (fire-and-forget، هر ۲۰ رویداد یک بار)
      if (DateTime.now().millisecond % 20 == 0) {
        // ignore: discarded_futures
        _pruneOldEvents(db);
      }
    } catch (e) {
      _log('⚠ record event failed: $e');
    }
  }

  /// آخرین رویدادها به ترتیب نزولی.
  Future<List<AetherEvent>> recent({int limit = 100}) async {
    try {
      final db = await GatewayDatabase.instance();
      final rows = await db.query(
        DatabaseSchema.tableAetherEvents,
        orderBy: '${DatabaseSchema.colTimestamp} DESC',
        limit: limit,
      );
      return rows.map(AetherEvent.fromMap).toList();
    } catch (e) {
      _log('⚠ recent events failed: $e');
      return [];
    }
  }

  /// شمارش کل رویدادها.
  Future<int> count() async {
    try {
      final db = await GatewayDatabase.instance();
      final r = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM ${DatabaseSchema.tableAetherEvents}',
      );
      return (r.first['c'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// حذف کل رویدادها.
  Future<void> clear() async {
    try {
      final db = await GatewayDatabase.instance();
      await db.delete(DatabaseSchema.tableAetherEvents);
    } catch (e) {
      _log('⚠ clear events failed: $e');
    }
  }

  Future<void> _pruneOldEvents(dynamic db) async {
    try {
      final total = await count();
      if (total <= maxEvents) return;
      final toDelete = total - maxEvents;
      await db.rawDelete(
        'DELETE FROM ${DatabaseSchema.tableAetherEvents} '
        'WHERE ${DatabaseSchema.colId} IN '
        '(SELECT ${DatabaseSchema.colId} FROM ${DatabaseSchema.tableAetherEvents} '
        'ORDER BY ${DatabaseSchema.colTimestamp} ASC LIMIT ?)',
        [toDelete],
      );
    } catch (_) {}
  }
}
