// lib/services/aether/test_executor/executor_success_handler.dart

part of '../aether_test_executor.dart';

/// ═══════════════════════════════════════════════════════════════
///  منطق اتصال موفق و ثبت شکست.
///
///  این extension مسئول:
///    • تفسیر AttemptResult
///    • ثبت در DecisionEngine یا logger + profileStore
///    • ذخیره endpoint برای بار بعد
///    • notification و happy transition
///    • شروع performance tracker
///
///  خروجی: `true` اگه اتصال موفق بود.
/// ═══════════════════════════════════════════════════════════════
extension AetherTestExecutorSuccessHandler on AetherTestExecutor {
  Future<bool> _handleAttemptResult({
    required EndpointAttempt attempt,
    required AttemptResult result,
    required String effectiveMasque,
    required int latencyMs,
    required bool wasRunningBefore,
    required int port,
    required int attemptIndex,
    required int maxAttempts,
  }) async {
    final treatAsSuccess =
        result.isSuccess || result.outcome == AttemptOutcome.allTargetsFailed;

    final engine = decisionEngine;
    if (engine != null && attempt.rankedSource != null) {
      // ignore: discarded_futures
      engine.recordOutcome(
        candidate: attempt.rankedSource!,
        success: treatAsSuccess,
        latencyMs: latencyMs,
        errorMessage: treatAsSuccess ? '' : result.outcome.name,
      );
    } else {
      _recordOutcomeFallback(
        attempt: attempt,
        effectiveMasque: effectiveMasque,
        latencyMs: latencyMs,
        success: treatAsSuccess,
        outcomeName: result.outcome.name,
      );
    }

    if (!treatAsSuccess) return false;

    await store.saveSuccessState(
      protocol: attempt.protocol,
      masque: effectiveMasque,
      endpoint: attempt.endpoint,
    );

    processService.setAetherProtocolNotification(
      _protocolLabelWithMasque(attempt.protocol, effectiveMasque),
    );

    _fireHappyTransitionIfNeeded(
      attempt: attempt,
      wasRunningBefore: wasRunningBefore,
    );

    _logSuccess(
      attempt: attempt,
      attemptIndex: attemptIndex,
      maxAttempts: maxAttempts,
      outcome: result.outcome,
    );

    startPerformanceTracker(
      attempt: attempt,
      port: port,
      effectiveMasque: effectiveMasque,
    );

    return true;
  }

  void _recordOutcomeFallback({
    required EndpointAttempt attempt,
    required String effectiveMasque,
    required int latencyMs,
    required bool success,
    required String outcomeName,
  }) {
    if (success) {
      logger?.connectionSuccess(
        settings: settings,
        protocol: attempt.protocol,
        masque: effectiveMasque,
        endpoint: attempt.endpoint,
        durationMs: latencyMs,
        latencyMs: latencyMs,
      );
      // ignore: discarded_futures
      profilePerformanceStore?.record(
        profile: settings.aetherProfile,
        protocol: attempt.protocol,
        masqueOption: effectiveMasque,
        networkType: settings.ipType,
        success: true,
      );
    } else {
      logger?.connectionFailed(
        settings: settings,
        protocol: attempt.protocol,
        masque: effectiveMasque,
        endpoint: attempt.endpoint,
        error: outcomeName,
        durationMs: latencyMs,
      );
      // ignore: discarded_futures
      profilePerformanceStore?.record(
        profile: settings.aetherProfile,
        protocol: attempt.protocol,
        masqueOption: effectiveMasque,
        networkType: settings.ipType,
        success: false,
      );
    }
  }

  void _fireHappyTransitionIfNeeded({
    required EndpointAttempt attempt,
    required bool wasRunningBefore,
  }) {
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
  }

  void _logSuccess({
    required EndpointAttempt attempt,
    required int attemptIndex,
    required int maxAttempts,
    required AttemptOutcome outcome,
  }) {
    if (outcome == AttemptOutcome.allTargetsFailed) {
      processService.addLog(
        '★ ${attempt.label} accepted (SOCKS up, HTTP probes blocked '
        'by network — likely working)',
        source: LogSource.aether,
      );
    } else {
      processService.addLog(
        '★ ${attempt.label} connected successfully '
        '(attempt $attemptIndex/$maxAttempts)',
        source: LogSource.aether,
      );
    }
  }
}
