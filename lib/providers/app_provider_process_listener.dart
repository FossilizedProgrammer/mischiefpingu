part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Process listener — واکنش به تغییرات ProcessService
///  (تفکیک شده از app_provider.dart)
///
///  ⚠️ نکته: چون این یک extension است، به `notifyListeners`
///  (که protected است) دسترسی نداریم. به‌جایش از `touch()`
///  استفاده می‌کنیم که در AppProvider تعریف شده و همان کار را می‌کند.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderProcessListener on AppProvider {
  void handleProcessServiceChange() {
    if (isShuttingDown) return;

    final logs = processService.fullLog;
    if (logs.isNotEmpty) {
      final last = logs.last;
      tryParseFoundFronting(last);
      tryParseBuildRev(last);
    }

    checkAutoReconnects();

    updateTunnelStatuses();

    syncWatchdogs();

    touch();
  }
}
