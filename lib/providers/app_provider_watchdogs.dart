part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderWatchdogs — ساخت و sync کردن watchdogها.
///
///  ⚠️ بازآرایی: منطق پیچیده به فایل‌های جداگانه منتقل شده:
///    • app_provider_watchdogs_leases.dart
///        → همهٔ acquireXLease callbackها
///    • app_provider_watchdogs_factory.dart
///        → ساخت TunnelWatchdogManager با پارامترها
///
///  این فایل حالا فقط orchestrator + sync logic است.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderWatchdogs on AppProvider {
  /// ساخت watchdog manager (idempotent).
  ///
  /// اگه قبلاً ساخته شده باشه، کاری نمی‌کنه.
  void ensureWatchdogs() {
    if (_watchdogManager != null) return;

    // ─── internet check ───
    final internetAliveCheck = _buildInternetAliveCheck(this);

    // ─── lease acquirerها ───
    final acquirePsiphonLease =
        _makePsiphonLeaseAcquirer(this, _recoveryCoordinator);
    final acquireAetherLease =
        _makeAetherLeaseAcquirer(this, _recoveryCoordinator);
    final acquireTorLease = _makeTorLeaseAcquirer(this, _recoveryCoordinator);
    final acquireSstpLease = _makeSstpLeaseAcquirer(this, _recoveryCoordinator);
    final acquireWireGuardLease =
        _makeWireGuardLeaseAcquirer(this, _recoveryCoordinator);

    // ─── build ───
    _watchdogManager = _buildWatchdogManager(
      provider: this,
      processService: processService,
      isInternetAlive: internetAliveCheck,
      acquirePsiphonLease: acquirePsiphonLease,
      acquireAetherLease: acquireAetherLease,
      acquireTorLease: acquireTorLease,
      acquireSstpLease: acquireSstpLease,
      acquireWireGuardLease: acquireWireGuardLease,
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  syncWatchdogs — حالا به settings.watchdogEnabled و تغییر
  ///  پروفایل احترام می‌گذارد.
  ///
  ///  وقتی user واچ‌داگ را غیرفعال می‌کند:
  ///    • همهٔ watchdogها stop() می‌شوند
  ///    • هیچ probe جدیدی زده نمی‌شود
  ///    • هیچ restart خودکاری رخ نمی‌دهد
  ///
  ///  وقتی دوباره فعال می‌کند:
  ///    • ensureWatchdogs دوباره صدا زده می‌شود
  ///    • syncWithConnectionState وضعیت را reset می‌کند
  /// ═══════════════════════════════════════════════════════════════
  void syncWatchdogs() {
    // ─── واچ‌داگ غیرفعال است → همه را متوقف کن ───
    if (!settings.watchdogEnabled) {
      _watchdogManager?.stopAll();
      return;
    }

    // ═══════════════════════════════════════════════════════════
    //  بررسی تغییر پروفایل: اگر پروفایل عوض شده باشد،
    //  watchdog manager را دوباره می‌سازیم.
    // ═══════════════════════════════════════════════════════════
    final currentProfile = settings.watchdogNetworkProfile;
    if (_lastBuiltProfile != null && _lastBuiltProfile != currentProfile) {
      processService.addLog(
        '→ Watchdog profile changed: '
        '$_lastBuiltProfile → $currentProfile — rebuilding',
        source: LogSource.app,
      );
      _watchdogManager?.disposeAll();
      _watchdogManager = null;
      _lastBuiltProfile = null;
    }

    ensureWatchdogs();

    _lastBuiltProfile ??= currentProfile;

    _watchdogManager!.syncWithConnectionState(
      psiphonConnected: processService.isPsiphonConnected,
      aetherConnected: processService.isAetherRunning && !isAutoTesting,
      torConnected: processService.isTorConnected,
      sstpConnected: processService.isSstpConnected,
      wireGuardConnected: processService.isWireGuardConnected,
    );
  }
}

/// wrapper ساده برای lease.
class _LeaseHandleWrapper implements RecoveryLeaseHandle {
  final RecoveryLease _lease;
  final RecoveryCoordinator _coordinator;

  _LeaseHandleWrapper(this._lease, this._coordinator);

  @override
  void release() {
    _coordinator.release(_lease);
  }
}
