// lib/services/aether_auto_test_service.dart
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
import 'aether/retry/retry_state.dart';

part 'aether/auto_test/store_attacher.dart';
part 'aether/auto_test/collaborators_builder.dart';
part 'aether/auto_test/endpoint_accessors.dart';

/// ═══════════════════════════════════════════════════════════════
///  AetherAutoTestService — مدیریت تست خودکار Aether.
///
///  ⚠️ بازآرایی: منطق به فایل‌های part منتقل شد:
///    • store_attacher.dart         → پیوستن storeها
///    • collaborators_builder.dart  → ساخت collaborators
///    • endpoint_accessors.dart     → دسترسی به endpoint
/// ═══════════════════════════════════════════════════════════════
class AetherAutoTestService {
  final ProcessService processService;
  AppSettings settings;

  RetryState? get retryState => _executor.retryState;

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

  /// ═══════════════════════════════════════════════════════════════
  ///  ✅ متد attachAllStores — delegate به extension در store_attacher.dart
  ///
  ///  این متد در کلاس اصلی تعریف شده تا از app_provider_constructor.dart
  ///  قابل فراخوانی باشد. پیاده‌سازی واقعی در store_attacher.dart است.
  /// ═══════════════════════════════════════════════════════════════
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

  /// اجرای auto-test.
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

  bool get isCancelRequested => _executor.isCancelRequested;

  void requestCancel() => _executor.requestCancel();

  AetherAttemptRunner get internalRunner => _runner;

  Future<bool> _runAutoTest() async {
    _executor.reset();
    return _executor.run(isAuto: settings.isAetherProfileAutomatic);
  }
}
