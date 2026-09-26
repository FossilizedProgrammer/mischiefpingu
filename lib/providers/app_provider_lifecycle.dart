part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderLifecycle — startup + DB init + privilege.
///
///  ⚠️ منطق shutdown به
///  `app_provider_lifecycle_shutdown.dart` منتقل شد.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderLifecycle on AppProvider {
  Future<void> initializeProvider() async {
    try {
      await loadSettingsInternal();
      await checkPrivilegeInternal();
      // ─── مقداردهی اولیه دیتابیس ───
      await _initializeGatewayDatabase();
      final coreUpdateService = CoreUpdateService(log: processService.addLog);
      await coreUpdateService.applyPendingUpdates();
      touch();
    } catch (e) {
      processService.addLog(
        '⚠ Provider initialization failed: $e',
        source: LogSource.app,
      );
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  _initializeGatewayDatabase — راه‌اندازی دیتابیس، لاگ آمار، prune.
  /// ═══════════════════════════════════════════════════════════════
  Future<void> _initializeGatewayDatabase() async {
    try {
      DatabaseInitializer.ensureInitialized();
      // ─── Gateway history (فاز ۱) ───
      final count = await _gatewayHistoryStore.count();
      processService.addLog(
        '→ Gateway history DB ready ($count record(s))',
        source: LogSource.app,
      );
      // ─── Structured Logging (فاز v2) ───
      final eventCount = await _aetherEventStore.count();
      processService.addLog(
        '→ Aether event log: $eventCount event(s)',
        source: LogSource.app,
      );
      // ─── Smart Cache (فاز v3) ───
      final profileCount = await _profilePerformanceStore.count();
      processService.addLog(
        '→ Profile performance cache: $profileCount entry(ies)',
        source: LogSource.app,
      );
      // ─── پاک‌سازی خودکار در startup ───
      await _runStartupPrune();
    } catch (e) {
      processService.addLog(
        '⚠ Gateway DB initialization failed: $e',
        source: LogSource.app,
      );
    }
  }

  /// پاک‌سازی رکوردهای ضعیف در startup.
  Future<void> _runStartupPrune() async {
    // Gateway history
    try {
      final pruned = await _gatewayHistoryStore.pruneWeakGateways(
        minScore: 10.0,
        minFailures: 3,
        maxAgeDays: 30,
      );
      if (pruned > 0) {
        processService.addLog(
          '→ Startup prune: removed $pruned weak gateway record(s)',
          source: LogSource.app,
        );
      }
    } catch (e) {
      processService.addLog(
        '⚠ Gateway prune failed: $e',
        source: LogSource.app,
      );
    }
    // Profile performance
    try {
      final pruned = await _profilePerformanceStore.pruneWeakEntries(
        minSuccessRate: 0.2,
        minSamples: 3,
        maxAgeDays: 30,
      );
      if (pruned > 0) {
        processService.addLog(
          '→ Startup prune: removed $pruned weak profile perf entry(ies)',
          source: LogSource.app,
        );
      }
    } catch (e) {
      processService.addLog(
        '⚠ Profile perf prune failed: $e',
        source: LogSource.app,
      );
    }
  }

  Future<void> checkPrivilegeInternal() async {
    isElevated = await PrivilegeService.isElevated();
    touch();
  }
}
