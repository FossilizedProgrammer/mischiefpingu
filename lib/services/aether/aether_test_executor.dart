// lib/services/aether/aether_test_executor.dart
//
// ═══════════════════════════════════════════════════════════════
//  AetherTestExecutor — اجرای حلقه اصلی auto-test Aether.
//  (تفکیک شده از aether_auto_test_service.dart)
// ═══════════════════════════════════════════════════════════════
library;

import 'dart:async';

import '../../models/settings_model.dart';
import '../aether_attempt_runner.dart';
import '../aether_attempts.dart';
import '../aether_cache_manager.dart';
import '../aether_endpoint_store.dart';
import '../process_service.dart';
import 'aether_test_helpers.dart';

class AetherTestExecutor {
  final ProcessService processService;
  final AppSettings settings;
  final AetherAttemptPlanner planner;
  final AetherEndpointStore store;
  final AetherAttemptRunner runner;
  final AetherCacheManager cacheManager;
  final AetherTestHelpers helpers;

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

  /// اجرای تست خودکار. true اگر یک attempt موفق شد.
  Future<bool> run({required bool isAuto}) async {
    var port = settings.aetherLocalPort;

    // بارگذاری برندهٔ قبلی (فقط برای حالت auto)
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
      );

      final result = await runner.run(
        attempt: attempt,
        args: args,
        port: port,
      );

      // ─── موفقیت ───
      if (result.isSuccess) {
        await store.saveSuccessState(
          protocol: attempt.protocol,
          masque: attempt.masque,
          endpoint: attempt.endpoint,
        );
        processService.setAetherProtocolNotification(attempt.protocol);
        processService.addLog(
          '★ ${attempt.label} connected successfully',
          source: LogSource.aether,
        );
        return true;
      }

      // ─── شکست — تصمیم‌گیری ───
      final shouldContinue = await _handleFailure(
        result: result,
        attempt: attempt,
        port: port,
        onPortSwapped: (newPort) => port = newPort,
      );
      if (!shouldContinue) continue;
    }

    processService.addLog(
      '✗ All candidates failed',
      source: LogSource.aether,
    );
    return false;
  }

  Future<bool> _handleFailure({
    required AttemptResult result,
    required EndpointAttempt attempt,
    required int port,
    required void Function(int) onPortSwapped,
  }) async {
    switch (result.outcome) {
      case AttemptOutcome.refused:
        processService.addLog(
          '→ ${attempt.label} refused, trying next candidate…',
          source: LogSource.aether,
        );
        await processService.stopAether();
        await Future.delayed(const Duration(milliseconds: 400));
        return true;

      case AttemptOutcome.tunnelDead:
        processService.addLog(
          '→ ${attempt.label} tunnel dead, clearing cache and retrying…',
          source: LogSource.aether,
        );
        await processService.stopAether();
        await Future.delayed(const Duration(milliseconds: 800));
        await helpers.safe<void>(
          () => cacheManager.clearCachedGateway(
            specificProtocol: attempt.protocol,
          ),
        );
        return true;

      case AttemptOutcome.timeout:
      case AttemptOutcome.startFailed:
        final hasListener = await ProcessService.isPortInUse(port);
        if (!_portSwapTried && !_cancelRequested && !hasListener) {
          await processService.stopAether();
          await Future.delayed(const Duration(milliseconds: 800));
          final np = await helpers.swapPort(
            currentPort: port,
            onPortChanged: (newPort) {
              settings.aetherLocalPort = newPort;
              _portSwapTried = true;
            },
          );
          if (np != null) {
            onPortSwapped(np);
            processService.addLog(
              '→ Switched to port $np, retrying…',
              source: LogSource.aether,
            );
            return true;
          }
        }
        await processService.stopAether();
        await Future.delayed(const Duration(milliseconds: 600));
        return true;

      case AttemptOutcome.success:
        return false;
    }
  }
}
