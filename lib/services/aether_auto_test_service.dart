// lib/services/aether_auto_test_service.dart
//
// ═══════════════════════════════════════════════════════════════
//  AetherAutoTestService — orchestrator اصلی auto-test Aether.
//
//  مسئولیت‌ها:
//    • ساخت collaboratorها (planner/store/runner/cache/helpers)
//    • مدیریت _testFuture و _cancelRequested
//    • delegate کردن اجرا به AetherTestExecutor
// ═══════════════════════════════════════════════════════════════
library;

import 'dart:async';

import '../models/settings_model.dart';
import 'aether/aether_test_executor.dart';
import 'aether/aether_test_helpers.dart';
import 'aether_attempt_runner.dart';
import 'aether_attempts.dart';
import 'aether_cache_manager.dart';
import 'aether_endpoint_store.dart';
import 'aether_socks_probe.dart';
import 'process_service.dart';

class AetherAutoTestService {
  final ProcessService processService;
  AppSettings settings;

  Future<bool>? _testFuture;

  // ─── collaborators ───
  late SocksProber _prober;
  late AetherAttemptPlanner _planner;
  late AetherEndpointStore _store;
  late AetherAttemptRunner _runner;
  late AetherCacheManager _cacheManager;
  late AetherTestHelpers _helpers;
  late AetherTestExecutor _executor;

  AetherAutoTestService({
    required this.processService,
    required this.settings,
  }) {
    _rebuildCollaborators();
  }

  void _rebuildCollaborators() {
    _prober = SocksProber(
      processService,
      isCancelled: () => _executor.isCancelRequested,
    );

    _planner = AetherAttemptPlanner(settings);

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

    _executor = AetherTestExecutor(
      processService: processService,
      settings: settings,
      planner: _planner,
      store: _store,
      runner: _runner,
      cacheManager: _cacheManager,
      helpers: _helpers,
    );
  }

  void updateSettings(AppSettings newSettings) {
    settings = newSettings;
    _rebuildCollaborators();
  }

  bool get isCancelRequested => _executor.isCancelRequested;

  void requestCancel() => _executor.requestCancel();

  /// نقطهٔ ورود عمومی — idempotent.
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

  Future<String?> getLastSuccessfulEndpoint() =>
      _store.getLastSuccessfulEndpoint();

  Future<bool> _runAutoTest() async {
    _executor.reset();
    return _executor.run(isAuto: settings.aetherProtocol == 'auto');
  }
}
