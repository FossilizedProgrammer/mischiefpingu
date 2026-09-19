part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Process listener — واکنش به تغییرات ProcessService
///
///  ⚠️ نکته مهم:
///  این listener روی *هر* notifyListeners از ProcessService صدا زده
///  میشود — و ProcessService روی هر خط لاگ notify میکند!
///
///  برای جلوگیری از:
///    • حلقهٔ restart بین watchdog و auto-reconnect
///    • sync مداوم watchdog (start/stop پشت سر هم)
///    • بار زیاد روی checkAutoReconnects
///
///  فقط وقتی state *واقعی* تونلها تغییر کرد، منطق سنگین اجرا میشود.
///
///  ⚠️ کلاس `_TunnelStateSnapshot` در `app_provider.dart` تعریف
///  شده — اینجا فقط استفاده میشود. آن را دوباره تعریف نکنید!
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

    final currentState = _TunnelStateSnapshot(
      psiphonRunning: processService.isPsiphonRunning,
      psiphonConnected: processService.isPsiphonConnected,
      aetherRunning: processService.isAetherRunning,
      torRunning: processService.isTorRunning,
      torConnected: processService.isTorConnected,
      torBootstrapProgress: processService.torBootstrapProgress,
      sstpRunning: processService.isSstpRunning,
      sstpConnected: processService.isSstpConnected,
    );

    final stateChanged = _lastTunnelState != currentState;
    _lastTunnelState = currentState;

    if (stateChanged) {
      checkAutoReconnects();
      updateTunnelStatuses();
      syncWatchdogs();
    }

    touch();
  }
}
