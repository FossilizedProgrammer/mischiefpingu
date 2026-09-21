part of '../profile_performance_store.dart';

/// ═══════════════════════════════════════════════════════════════
///  نگهداری: prune و clear.
/// ═══════════════════════════════════════════════════════════════
extension ProfilePerformanceStoreMaintenance on ProfilePerformanceStore {
  /// حذف رکوردهای ضعیف و قدیمی.
  ///
  /// معیار ضعیف بودن:
  ///   • successRate < [minSuccessRate]  AND
  ///   • (success + failure) >= [minSamples]  AND
  ///   • آخرین بروزرسانی بیشتر از [maxAgeDays] روز پیش
  ///
  /// خروجی: تعداد حذف‌شده‌ها.
  Future<int> pruneWeakEntries({
    double minSuccessRate = 0.2,
    int minSamples = 3,
    int maxAgeDays = 30,
  }) async {
    try {
      final db = await GatewayDatabase.instance();
      final cutoff = DateTime.now()
          .subtract(Duration(days: maxAgeDays))
          .millisecondsSinceEpoch;

      final deleted = await db.delete(
        DatabaseSchema.tableProfilePerformance,
        where:
            '(${DatabaseSchema.colSuccessCount} * 1.0 / '
            '(${DatabaseSchema.colSuccessCount} + ${DatabaseSchema.colFailureCount})) < ? '
            'AND (${DatabaseSchema.colSuccessCount} + ${DatabaseSchema.colFailureCount}) >= ? '
            'AND ${DatabaseSchema.colUpdatedAt} < ?',
        whereArgs: [minSuccessRate, minSamples, cutoff],
      );

      if (deleted > 0) {
        logInternal('→ Pruned $deleted weak profile performance entry(ies)');
      }
      return deleted;
    } catch (e) {
      logInternal('⚠ pruneWeakEntries failed: $e');
      return 0;
    }
  }

  /// حذف کل رکوردها (برای تست/ریست).
  Future<void> clearAll() async {
    try {
      final db = await GatewayDatabase.instance();
      await db.delete(DatabaseSchema.tableProfilePerformance);
      logInternal('→ Profile performance cleared');
    } catch (e) {
      logInternal('⚠ clearAll failed: $e');
    }
  }
}
