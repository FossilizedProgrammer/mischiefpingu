// lib/services/aether/test_executor/executor_runner.dart

part of '../aether_test_executor.dart';

/// ═══════════════════════════════════════════════════════════════
///  منطق اصلی run() — با پشتیبانی از retry هوشمند.
///
///  ⚠️ بازآرایی: این فایل حالا فقط orchestrator هست.
///  منطق موفقیت، شکست، و MASQUE در فایل‌های part جداگانه:
///    • executor_success_handler.dart  → _handleAttemptResult
///    • executor_failure_handler.dart  → _computeRetryDelay + _waitWithCancel
///    • executor_masque_helper.dart    → _effectiveMasqueForAttempt + _protocolLabelWithMasque
/// ═══════════════════════════════════════════════════════════════
extension AetherTestExecutorRunner on AetherTestExecutor {
  Future<bool> run({required bool isAuto}) async {
    cancelRequested = false;
    portSwapTried = false;

    retryState = RetryState(
      maxAttempts: AetherRetryStrategy.maxAttempts,
      currentProtocol: settings.aetherProtocol,
      currentMasque: settings.masqueOption,
    );

    final state = retryState!;
    var port = settings.aetherLocalPort;
    final wasRunningBefore = processService.isAetherRunning;

    MapEntry<String, String>? autoWinner;
    if (isAuto) {
      autoWinner = await helpers.safe<MapEntry<String, String>?>(
        store.loadAutoWinner,
      );
    }

    if (cancelRequested) {
      processService.addLog(
        '→ Aether test cancelled before candidates build',
        source: LogSource.aether,
      );
      return false;
    }

    final candidates = await planner.buildCandidates(autoWinner: autoWinner);

    if (cancelRequested) {
      processService.addLog(
        '→ Aether test cancelled after candidates build',
        source: LogSource.aether,
      );
      return false;
    }

    if (candidates.isEmpty) {
      processService.addLog('✗ No candidates to try', source: LogSource.aether);
      return false;
    }

    _logCandidates(candidates);

    try {
      for (var i = 0; i < candidates.length; i++) {
        if (cancelRequested) break;

        final attempt = candidates[i];
        final isLastAttempt = (i == candidates.length - 1);

        if (settings.isEndpointPinningCustomOnly && !attempt.isCustomEndpoint) {
          processService.addLog(
            '→ Skipping non-custom candidate (custom-only mode): '
            '${attempt.label}',
            source: LogSource.aether,
          );
          continue;
        }

        final effectiveMasque = _effectiveMasqueForAttempt(attempt, i);

        state.beginAttempt(
          protocol: attempt.protocol,
          masque: effectiveMasque,
        );

        final attemptLabel = AetherRetryStrategy.describeAttempt(
          attemptIndex: state.currentAttempt,
          masque: effectiveMasque,
          protocol: attempt.protocol,
        );

        processService.addLog(
          '↻ $attemptLabel → ${attempt.label}',
          source: LogSource.aether,
        );

        logger?.connectionStarted(
          settings: settings,
          protocol: attempt.protocol,
          masque: effectiveMasque,
          endpoint: attempt.endpoint,
        );

        final attemptStart = DateTime.now();

        final args = planner.argsFor(
          protocol: attempt.protocol,
          masqueOption: effectiveMasque,
          port: port,
          endpointOverride: attempt.endpoint,
          forceFragmentH2: attempt.fragmentH2,
        );

        final result = await runner.run(
          attempt: attempt,
          args: args,
          port: port,
        );

        if (cancelRequested) {
          processService.addLog(
            '→ Aether test cancelled after attempt ${attempt.label}',
            source: LogSource.aether,
          );
          break;
        }

        final attemptDuration = DateTime.now().difference(attemptStart);
        final latencyMs = attemptDuration.inMilliseconds;

        final success = await _handleAttemptResult(
          attempt: attempt,
          result: result,
          effectiveMasque: effectiveMasque,
          latencyMs: latencyMs,
          wasRunningBefore: wasRunningBefore,
          port: port,
          attemptIndex: state.currentAttempt,
          maxAttempts: state.maxAttempts,
        );

        if (success) return true;

        state.recordError(result.outcome.name);

        if (!isLastAttempt &&
            !cancelRequested &&
            AetherRetryStrategy.shouldContinue(
              attemptIndex: state.currentAttempt,
              success: false,
            )) {
          final delay = _computeRetryDelay(
            state.currentAttempt,
            settings.isEndpointPinningCustomOnly,
          );

          if (delay > Duration.zero) {
            processService.addLog(
              '→ Waiting ${delay.inSeconds}s before next attempt '
              '(${state.currentAttempt + 1}/${state.maxAttempts})…',
              source: LogSource.aether,
            );

            await _waitWithCancel(delay);

            if (cancelRequested) {
              processService.addLog(
                '→ Retry delay cancelled by user',
                source: LogSource.aether,
              );
              break;
            }
          }
        }

        final shouldContinue = await failureHandler.handle(
          result: result,
          attempt: attempt,
          port: port,
          portSwapTried: portSwapTried,
          isCancelRequested: () => cancelRequested,
          onPortSwapped: (newPort) {
            settings.aetherLocalPort = newPort;
            port = newPort;
          },
          onPortSwapTried: () => portSwapTried = true,
        );
        if (!shouldContinue) break;
      }
    } finally {
      cancelRequested = false;
      portSwapTried = false;
    }

    processService.addLog(
      '✗ All candidates failed after ${state.currentAttempt} attempt(s)',
      source: LogSource.aether,
    );
    return false;
  }

  /// لاگ لیست candidates.
  void _logCandidates(List<EndpointAttempt> candidates) {
    processService.addLog(
      '→ Aether candidates (${candidates.length}):',
      source: LogSource.aether,
    );
    for (final c in candidates) {
      final tag = c.fromProfileCache || c.fromHistory ? ' [${c.cacheTag}]' : '';
      final pinTag = c.isCustomEndpoint ? ' [PINNED]' : '';
      processService.addLog(
        '   • ${c.label}$tag$pinTag',
        source: LogSource.aether,
      );
    }
  }
}
