// lib/services/aether/auto_test/collaborators_builder.dart
part of '../../aether_auto_test_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  CollaboratorsBuilder — ساخت و مدیریت collaborators.
///
///  این extension مسئول:
///    • ساخت prober, planner, store, runner, etc.
///    • بازسازی collaborators وقتی settings تغییر می‌کند
/// ═══════════════════════════════════════════════════════════════
extension AetherAutoTestCollaboratorsBuilder on AetherAutoTestService {
  /// بازسازی تمام collaborators.
  void rebuildCollaborators() {
    _prober = SocksProber(
      processService,
      isCancelled: () => _executor.isCancelRequested,
    );
    _planner = AetherAttemptPlanner(
      settings,
      historyStore: gatewayHistoryStore,
      profileStore: profilePerformanceStore,
      decisionEngine: decisionEngine,
    );
    _store = AetherEndpointStore(
      settings: settings,
      log: processService.addLog,
    );
    _runner = AetherAttemptRunner(
      processService: processService,
      prober: _prober,
    );
    _cacheManager = AetherCacheManager(processService: processService);
    _helpers = AetherTestHelpers(processService: processService);

    final store = gatewayHistoryStore;
    _performanceTracker = store == null
        ? null
        : GatewayPerformanceTracker(store: store, log: processService.addLog);

    _executor = AetherTestExecutor(
      processService: processService,
      settings: settings,
      planner: _planner,
      store: _store,
      runner: _runner,
      cacheManager: _cacheManager,
      helpers: _helpers,
      historyStore: gatewayHistoryStore,
      performanceTracker: _performanceTracker,
      profilePerformanceStore: profilePerformanceStore,
      logger: aetherLogger,
      decisionEngine: decisionEngine,
    );
  }

  /// به‌روزرسانی settings و بازسازی collaborators.
  void updateSettings(AppSettings newSettings) {
    settings = newSettings;
    rebuildCollaborators();
  }
}
