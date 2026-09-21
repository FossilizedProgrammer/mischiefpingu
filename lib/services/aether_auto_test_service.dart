library;

import 'dart:async';

import '../models/settings_model.dart';
import 'aether/aether_test_executor.dart';
import 'aether/aether_test_helpers.dart';
import 'aether/decision/aether_decision_engine.dart';
import 'aether/performance_sample.dart';
import 'aether/gateway_performance_tracker.dart';
import 'aether_attempt_runner.dart';
import 'aether_attempts.dart';
import 'aether_cache_manager.dart';
import 'aether_endpoint_store.dart';
import 'aether_logger.dart';
import 'aether_socks_probe.dart';
import 'database/gateway_history_store.dart';
import 'database/profile_performance_store.dart';
import 'process_service.dart';

part 'aether/auto_test/store_attacher.dart';

class AetherAutoTestService {
  final ProcessService processService;
  AppSettings settings;

  GatewayHistoryStore? gatewayHistoryStore;
  ProfilePerformanceStore? profilePerformanceStore;
  AetherLogger? aetherLogger;
  AetherDecisionEngine? decisionEngine;

  Future<bool>? _testFuture;

  late SocksProber _prober;
  late AetherAttemptPlanner _planner;
  late AetherEndpointStore _store;
  late AetherAttemptRunner _runner;
  late AetherCacheManager _cacheManager;
  late AetherTestHelpers _helpers;
  late GatewayPerformanceTracker? _performanceTracker;
  late AetherTestExecutor _executor;

  AetherAutoTestService({
    required this.processService,
    required this.settings,
    this.gatewayHistoryStore,
    this.profilePerformanceStore,
    this.aetherLogger,
    this.decisionEngine,
  }) {
    rebuildCollaborators();
  }

  /// بازسازی collaboratorها.
  ///
  /// ⚠️ public شده تا `store_attacher.dart` (که `part of` هست)
  /// بتونه صدا بزنه — و از خارج از کلاس هم قابل استفاده باشه.
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
        : GatewayPerformanceTracker(
            store: store,
            log: processService.addLog,
          );

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

  void updateSettings(AppSettings newSettings) {
    settings = newSettings;
    rebuildCollaborators();
  }

  /// attach کردن همه storeها با یک rebuild واحد.
  ///
  /// ⚠️ پیاده‌سازی در `store_attacher.dart` هست.
  void attachAllStores({
    GatewayHistoryStore? historyStore,
    ProfilePerformanceStore? profileStore,
    AetherLogger? logger,
    AetherDecisionEngine? decisionEngine,
  }) =>
      attachAllStoresInternal(
        historyStore: historyStore,
        profileStore: profileStore,
        logger: logger,
        decisionEngine: decisionEngine,
      );

  void attachDecisionEngine(AetherDecisionEngine engine) {
    decisionEngine = engine;
    rebuildCollaborators();
  }

  void attachGatewayHistoryStore(GatewayHistoryStore store) {
    gatewayHistoryStore = store;
    rebuildCollaborators();
  }

  void attachProfilePerformanceStore(ProfilePerformanceStore store) {
    profilePerformanceStore = store;
    rebuildCollaborators();
  }

  void attachAetherLogger(AetherLogger logger) {
    aetherLogger = logger;
    rebuildCollaborators();
  }

  bool get isCancelRequested => _executor.isCancelRequested;
  void requestCancel() => _executor.requestCancel();

  Future<bool> ensureHealthy({bool showUi = true}) {
    final existing = _testFuture;
    if (existing != null) return existing;

    final future = _runAutoTest();
    _testFuture = future;
    future.whenComplete(() {
      if (identical(_testFuture, future)) _testFuture = null;
    });
    return future;
  }

  /// آخرین endpoint موفق — برای fast-path.
  Future<String?> getLastSuccessfulEndpoint() =>
      _store.getLastSuccessfulEndpoint();

  /// آخرین transport موفق — برای fast-path.
  Future<MapEntry<String, String>?> loadAutoWinner() =>
      _store.loadAutoWinner();

  /// پاک کردن endpoint ذخیره‌شده (وقتی fail شد).
  Future<void> clearLastEndpoint() => _store.clearLastEndpoint();

  /// ذخیرهٔ endpoint واقعی از لاگ Aether.
  Future<void> saveRealEndpointFromLog(
    String endpoint, {
    required String protocol,
    required String masque,
  }) =>
      _store.saveRealEndpointFromLog(
        endpoint,
        protocol: protocol,
        masque: masque,
      );

  /// استخراج endpoint واقعی از خط لاگ.
  String? extractRealEndpointFromLog(String line) =>
      _store.extractRealEndpointFromLog(line);

  PerformanceReport? get lastPerformanceReport =>
      _performanceTracker?.lastReport;

  GatewayPerformanceTracker? get performanceTracker => _performanceTracker;

  AetherAttemptRunner get internalRunner => _runner;

  Future<bool> _runAutoTest() async {
    _executor.reset();
    return _executor.run(isAuto: settings.isAetherProfileAutomatic);
  }
}
