library;

import 'dart:async';

import '../../models/settings_model.dart';
import '../aether_attempt_runner.dart';
import '../aether_attempts.dart';
import '../aether_cache_manager.dart';
import '../aether_endpoint_store.dart';
import '../aether_logger.dart';
import '../database/gateway_history_store.dart';
import '../database/profile_performance_store.dart';
import '../process_service.dart';
import 'aether_failure_handler.dart';
import 'aether_test_helpers.dart';
import 'decision/aether_decision_engine.dart';
import 'gateway_performance_tracker.dart';

part 'test_executor/executor_runner.dart';
part 'test_executor/tracker_starter.dart';

/// ═══════════════════════════════════════════════════════════════
///  AetherTestExecutor — اجرای چرخهٔ تست candidateها.
///
///  بخش‌های داخلی در `test_executor/` جدا شده‌اند:
///    • ExecutorRunner   → منطق اصلی run()
///    • TrackerStarter   → شروع performance tracker
///
///  ⚠️ FIX: run() در runner خودش cancelRequested رو ریست می‌کنه.
/// ═══════════════════════════════════════════════════════════════
class AetherTestExecutor {
  final ProcessService processService;
  final AppSettings settings;
  final AetherAttemptPlanner planner;
  final AetherEndpointStore store;
  final AetherAttemptRunner runner;
  final AetherCacheManager cacheManager;
  final AetherTestHelpers helpers;

  final GatewayHistoryStore? historyStore;
  GatewayPerformanceTracker? performanceTracker;
  ProfilePerformanceStore? profilePerformanceStore;
  AetherLogger? logger;

  final AetherDecisionEngine? decisionEngine;

  late final AetherFailureHandler _failureHandler;

  bool cancelRequested = false;
  bool portSwapTried = false;

  AetherTestExecutor({
    required this.processService,
    required this.settings,
    required this.planner,
    required this.store,
    required this.runner,
    required this.cacheManager,
    required this.helpers,
    this.historyStore,
    this.performanceTracker,
    this.profilePerformanceStore,
    this.logger,
    this.decisionEngine,
  }) {
    _failureHandler = AetherFailureHandler(
      processService: processService,
      cacheManager: cacheManager,
      helpers: helpers,
      historyStore: historyStore,
    );
  }

  bool get isCancelRequested => cancelRequested;
  void requestCancel() => cancelRequested = true;

  void reset() {
    cancelRequested = false;
    portSwapTried = false;
  }

  AetherFailureHandler get failureHandler => _failureHandler;
}
