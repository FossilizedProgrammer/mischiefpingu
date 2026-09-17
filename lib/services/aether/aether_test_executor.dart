library;

import 'dart:async';

import '../../models/settings_model.dart';
import '../aether_attempt_runner.dart';
import '../aether_attempts.dart';
import '../aether_cache_manager.dart';
import '../aether_endpoint_store.dart';
import '../process_service.dart';
import 'aether_failure_handler.dart';
import 'aether_test_helpers.dart';

class AetherTestExecutor {
  final ProcessService processService;
  final AppSettings settings;
  final AetherAttemptPlanner planner;
  final AetherEndpointStore store;
  final AetherAttemptRunner runner;
  final AetherCacheManager cacheManager;
  final AetherTestHelpers helpers;

  late final AetherFailureHandler _failureHandler = AetherFailureHandler(
    processService: processService,
    cacheManager: cacheManager,
    helpers: helpers,
  );

  bool _cancelRequested = false;
  bool _portSwapTried = false;

  AetherTestExecutor({
    required this.processService,
    required this.settings,
    required this.planner,
    required this.store,
    required this.runner,
    required this.cacheManager,
    required this.helpers,
  });

  bool get isCancelRequested => _cancelRequested;
  void requestCancel() => _cancelRequested = true;

  void reset() {
    _cancelRequested = false;
    _portSwapTried = false;
  }

  Future<bool> run({required bool isAuto}) async {
    var port = settings.aetherLocalPort;

    final wasRunningBefore = processService.isAetherRunning;

    MapEntry<String, String>? autoWinner;
    if (isAuto) {
      autoWinner = await helpers.safe<MapEntry<String, String>?>(
        store.loadAutoWinner,
      );
    }

    final candidates = planner.buildCandidates(autoWinner: autoWinner);

    for (final attempt in candidates) {
      if (_cancelRequested) break;

      processService.addLog(
        '↻ Trying ${attempt.label}',
        source: LogSource.aether,
      );

      final args = planner.argsFor(
        protocol: attempt.protocol,
        masqueOption: attempt.masque,
        port: port,
        endpointOverride: attempt.endpoint,
        forceFragmentH2: attempt.fragmentH2,
      );

      final result = await runner.run(
        attempt: attempt,
        args: args,
        port: port,
      );

      if (result.isSuccess) {
        await store.saveSuccessState(
          protocol: attempt.protocol,
          masque: attempt.masque,
          endpoint: attempt.endpoint,
        );
        processService.setAetherProtocolNotification(attempt.protocol);

        if (!wasRunningBefore) {
          processService.checkHappyTransition(
            tunnelName: 'Aether',
            wasConnected: false,
            isConnected: true,
          );
        } else {
          processService.addLog(
            '★ ${attempt.label} connected (already running — no happy notification)',
            source: LogSource.aether,
          );
        }

        processService.addLog(
          '★ ${attempt.label} connected successfully',
          source: LogSource.aether,
        );
        return true;
      }

      final shouldContinue = await _failureHandler.handle(
        result: result,
        attempt: attempt,
        port: port,
        portSwapTried: _portSwapTried,
        isCancelRequested: () => _cancelRequested,
        onPortSwapped: (newPort) {
          settings.aetherLocalPort = newPort;
          port = newPort;
        },
        onPortSwapTried: () => _portSwapTried = true,
      );
      if (!shouldContinue) break;
    }

    processService.addLog(
      '✗ All candidates failed',
      source: LogSource.aether,
    );
    return false;
  }
}
