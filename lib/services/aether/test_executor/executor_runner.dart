part of '../aether_test_executor.dart';

/// ═══════════════════════════════════════════════════════════════
///  منطق اصلی run().
///
///  ⚠️ FIX:
///   • در ابتدای run، cancelRequested = false (start جدید)
///   • در finally، دوباره cancelRequested = false (بار بعد)
///   • portSwapTried هم reset می‌شه
/// ═══════════════════════════════════════════════════════════════
extension AetherTestExecutorRunner on AetherTestExecutor {
  Future<bool> run({required bool isAuto}) async {
    // ⚠️ FIX: reset state برای start جدید
    cancelRequested = false;
    portSwapTried = false;

    var port = settings.aetherLocalPort;

    final wasRunningBefore = processService.isAetherRunning;

    MapEntry<String, String>? autoWinner;
    if (isAuto) {
      autoWinner = await helpers.safe<MapEntry<String, String>?>(
        store.loadAutoWinner,
      );
    }

    // ⚠️ FIX: چک cancel بعد از loadAutoWinner
    if (cancelRequested) {
      processService.addLog(
        '→ Aether test cancelled before candidates build',
        source: LogSource.aether,
      );
      return false;
    }

    final candidates = await planner.buildCandidates(autoWinner: autoWinner);

    // ⚠️ FIX: چک cancel بعد از buildCandidates
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

    processService.addLog(
      '→ Aether candidates (${candidates.length}):',
      source: LogSource.aether,
    );
    for (final c in candidates) {
      final tag = c.fromProfileCache || c.fromHistory ? ' [${c.cacheTag}]' : '';
      processService.addLog('   • ${c.label}$tag', source: LogSource.aether);
    }

    try {
      for (final attempt in candidates) {
        if (cancelRequested) break;

        processService.addLog(
          '↻ Trying ${attempt.label}',
          source: LogSource.aether,
        );

        logger?.connectionStarted(
          settings: settings,
          protocol: attempt.protocol,
          masque: attempt.masque,
          endpoint: attempt.endpoint,
        );

        final attemptStart = DateTime.now();

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

        // ⚠️ FIX: چک cancel بعد از runner.run
        if (cancelRequested) {
          processService.addLog(
            '→ Aether test cancelled after attempt ${attempt.label}',
            source: LogSource.aether,
          );
          break;
        }

        final attemptDuration = DateTime.now().difference(attemptStart);
        final latencyMs = attemptDuration.inMilliseconds;

        final treatAsSuccess = result.isSuccess ||
            result.outcome == AttemptOutcome.allTargetsFailed;

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
          if (treatAsSuccess) {
            logger?.connectionSuccess(
              settings: settings,
              protocol: attempt.protocol,
              masque: attempt.masque,
              endpoint: attempt.endpoint,
              durationMs: latencyMs,
              latencyMs: latencyMs,
            );
            // ignore: discarded_futures
            profilePerformanceStore?.record(
              profile: settings.aetherProfile,
              protocol: attempt.protocol,
              masqueOption: attempt.masque,
              networkType: settings.ipType,
              success: true,
            );
          } else {
            logger?.connectionFailed(
              settings: settings,
              protocol: attempt.protocol,
              masque: attempt.masque,
              endpoint: attempt.endpoint,
              error: result.outcome.name,
              durationMs: latencyMs,
            );
            // ignore: discarded_futures
            profilePerformanceStore?.record(
              profile: settings.aetherProfile,
              protocol: attempt.protocol,
              masqueOption: attempt.masque,
              networkType: settings.ipType,
              success: false,
            );
          }
        }

        if (treatAsSuccess) {
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

          if (result.outcome == AttemptOutcome.allTargetsFailed) {
            processService.addLog(
              '★ ${attempt.label} accepted (SOCKS up, HTTP probes blocked '
              'by network — likely working)',
              source: LogSource.aether,
            );
          } else {
            processService.addLog(
              '★ ${attempt.label} connected successfully',
              source: LogSource.aether,
            );
          }

          startPerformanceTracker(attempt: attempt, port: port);

          return true;
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
      // ⚠️ FIX: در پایان، state رو ریست کن برای بار بعد
      cancelRequested = false;
      portSwapTried = false;
    }

    processService.addLog('✗ All candidates failed', source: LogSource.aether);
    return false;
  }
}
