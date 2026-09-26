part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Reconnect Scheduler Helper — منطق مشترک scheduling.
///
///  این extension نقطهٔ ورودی مشترک برای همهٔ تونل‌هاست تا کد
///  تکرارشونده حذف بشه.
///
///  الگوی کار:
///    • اگر شرایط reconnect برقرار بود → schedule کن
///    • اگر نه (running/busy/stopped) → timer رو cancel کن
///
///  ⚠️ تمام پارامترها به صورت جدی چک می‌شن تا از race condition
///  جلوگیری بشه.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderReconnectScheduler on AppProvider {
  /// schedule یا cancel کردن reconnect برای یک تونل.
  ///
  /// پارامترها:
  ///   • [tunnel] — شناسه تونل ('psiphon', 'aether', ...)
  ///   • [isRunning] — آیا تونل الان در حال اجراست
  ///   • [isBusy] — آیا تونل مشغول start/stop است
  ///   • [isLoading] — آیا در حال load تنظیمات است
  ///   • [hasPid] — آیا پروسه زنده است
  ///   • [userStopped] — آیا user دستی stop کرده
  ///   • [autoReconnectEnabled] — آیا auto-reconnect در settings فعاله
  ///   • [isAutoTesting] — آیا auto-test در حال اجراست
  ///   • [isRestarting] — آیا restart در حال اجراست
  ///   • [shouldReconnect] — predicate نهایی برای تصمیم
  ///   • [onReconnect] — callback اجرا در زمان reconnect
  void _scheduleReconnectFor({
    required String tunnel,
    required bool isRunning,
    required bool isBusy,
    required bool isLoading,
    required bool hasPid,
    required bool userStopped,
    required bool autoReconnectEnabled,
    required bool isAutoTesting,
    required bool isRestarting,
    required bool Function() shouldReconnect,
    required void Function() onReconnect,
  }) {
    final needsSchedule = !isRunning &&
        !isBusy &&
        !isLoading &&
        !hasPid &&
        !userStopped &&
        autoReconnectEnabled &&
        !isAutoTesting &&
        !isRestarting;

    if (needsSchedule) {
      _dispatchSchedule(
        tunnel: tunnel,
        shouldReconnect: shouldReconnect,
        onReconnect: onReconnect,
      );
    } else {
      _dispatchCancel(tunnel);
    }
  }

  /// dispatch به متد مناسب scheduler بر اساس tunnel.
  void _dispatchSchedule({
    required String tunnel,
    required bool Function() shouldReconnect,
    required void Function() onReconnect,
  }) {
    final log = processService.addLog;

    switch (tunnel) {
      case 'psiphon':
        _reconnectManager.schedulePsiphonReconnect(
          shouldReconnect: shouldReconnect,
          onReconnect: onReconnect,
          log: log,
        );
        break;
      case 'aether':
        _reconnectManager.scheduleAetherReconnect(
          shouldReconnect: shouldReconnect,
          onReconnect: onReconnect,
          log: log,
        );
        break;
      case 'tor':
        _reconnectManager.scheduleTorReconnect(
          shouldReconnect: shouldReconnect,
          onReconnect: onReconnect,
          log: log,
        );
        break;
      case 'sstp':
        _reconnectManager.scheduleSstpReconnect(
          shouldReconnect: shouldReconnect,
          onReconnect: onReconnect,
          log: log,
        );
        break;
      case 'wireguard':
        _reconnectManager.scheduleWireGuardReconnect(
          shouldReconnect: shouldReconnect,
          onReconnect: onReconnect,
          log: log,
        );
        break;
    }
  }

  /// cancel کردن timer بر اساس tunnel.
  void _dispatchCancel(String tunnel) {
    switch (tunnel) {
      case 'psiphon':
        _reconnectManager.cancelPsiphonTimer();
        break;
      case 'aether':
        _reconnectManager.cancelAetherTimer();
        break;
      case 'tor':
        _reconnectManager.cancelTorTimer();
        break;
      case 'sstp':
        _reconnectManager.cancelSstpTimer();
        break;
      case 'wireguard':
        _reconnectManager.cancelWireGuardTimer();
        break;
    }
  }
}
