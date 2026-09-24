// lib/services/aether/test_executor/executor_runner.dart

part of '../aether_test_executor.dart';

/// ═══════════════════════════════════════════════════════════════
///  منطق اصلی run() — با پشتیبانی از retry هوشمند.
///
///  ⚠️ تغییرات این نسخه:
///    • استفاده از AetherRetryStrategy برای تاخیر و H2/H3
///    • شمارش تلاش‌ها و نمایش در RetryState
///    • custom-only mode: اگه endpoint سفارشی fail شد،
///      بلافاصله برگردون (بدون تلاش مجدد)
///    • custom-first mode: اگه همه customها fail شدن،
///      به automatic fallback کن
///    • ⚠️ FIX: H2/H3 swap در auto-reconnect حتی در manual profile
///    • ⚠️ FIX: زمان‌بندی بهتر retry در custom-only
///    • ⚠️ FIX: effectiveMasque به notification پاس می‌شه
///    • ⚠️ FIX: استفاده از local variable برای retryState
///      (جلوگیری از خطای nullable در analyzer)
/// ═══════════════════════════════════════════════════════════════
extension AetherTestExecutorRunner on AetherTestExecutor {
  Future<bool> run({required bool isAuto}) async {
    // ⚠️ reset state برای start جدید
    cancelRequested = false;
    portSwapTried = false;

    // ═══════════════════════════════════════════════════════════
    //  ساخت RetryState
    // ═══════════════════════════════════════════════════════════
    retryState = RetryState(
      maxAttempts: AetherRetryStrategy.maxAttempts,
      currentProtocol: settings.aetherProtocol,
      currentMasque: settings.masqueOption,
    );

    // ═══════════════════════════════════════════════════════════
    //  ⚠️ FIX: local variable غیر-nullable برای جلوگیری از
    //  خطای analyzer (unchecked_use_of_nullable_value)
    // ═══════════════════════════════════════════════════════════
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

    processService.addLog(
      '→ Aether candidates (${candidates.length}):',
      source: LogSource.aether,
    );
    for (final c in candidates) {
      final tag = c.fromProfileCache || c.fromHistory ? ' [${c.cacheTag}]' : '';
      final pinTag = c.isCustomEndpoint ? ' [PINNED]' : '';
      processService.addLog('   • ${c.label}$tag$pinTag',
          source: LogSource.aether);
    }

    // ═══════════════════════════════════════════════════════════
    //  حلقه اصلی تلاش‌ها
    // ═══════════════════════════════════════════════════════════
    try {
      for (var i = 0; i < candidates.length; i++) {
        if (cancelRequested) break;

        final attempt = candidates[i];
        final isLastAttempt = (i == candidates.length - 1);

        // ═══════════════════════════════════════════════════════
        //  ⚠️ custom-only: اگه این attempt سفارشی بود و fail شد،
        //  دیگه ادامه نده (چون بقیه candidates نباید امتحان بشن)
        // ═══════════════════════════════════════════════════════
        final isCustomOnlyMode = settings.isEndpointPinningCustomOnly;
        if (isCustomOnlyMode && !attempt.isCustomEndpoint) {
          processService.addLog(
            '→ Skipping non-custom candidate (custom-only mode): ${attempt.label}',
            source: LogSource.aether,
          );
          continue;
        }

        // ═══════════════════════════════════════════════════════
        //  🆕 MASQUE option برای این تلاش (alternating H2/H3)
        // ═══════════════════════════════════════════════════════
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
              error: result.outcome.name,
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

        if (treatAsSuccess) {
          await store.saveSuccessState(
            protocol: attempt.protocol,
            masque: effectiveMasque,
            endpoint: attempt.endpoint,
          );

          // ═══════════════════════════════════════════════════════
          //  ⚠️ FIX: notification با effectiveMasque (نه masque اصلی)
          //  تا UI اطلاعات درست نشون بده
          // ═══════════════════════════════════════════════════════
          processService.setAetherProtocolNotification(
            _protocolLabelWithMasque(attempt.protocol, effectiveMasque),
          );

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
              '★ ${attempt.label} connected successfully '
              '(attempt ${state.currentAttempt}/${state.maxAttempts})',
              source: LogSource.aether,
            );
          }

          startPerformanceTracker(
            attempt: attempt,
            port: port,
            effectiveMasque: effectiveMasque,
          );

          return true;
        }

        // ═══════════════════════════════════════════════════════
        //  ثبت خطا در retryState
        // ═══════════════════════════════════════════════════════
        state.recordError(result.outcome.name);

        // ═══════════════════════════════════════════════════════
        //  ⚠️ FIX: محاسبه تاخیر قبل از تلاش بعدی
        //  در custom-only mode، تاخیر طولانی‌تر (چون endpoint
        //  خاص ممکنه زمان بیشتری برای recover نیاز داشته باشه)
        // ═══════════════════════════════════════════════════════
        if (!isLastAttempt &&
            !cancelRequested &&
            AetherRetryStrategy.shouldContinue(
              attemptIndex: state.currentAttempt,
              success: false,
            )) {
          final delay = _computeRetryDelay(
            state.currentAttempt,
            isCustomOnlyMode,
          );

          if (delay > Duration.zero) {
            processService.addLog(
              '→ Waiting ${delay.inSeconds}s before next attempt '
              '(${state.currentAttempt + 1}/${state.maxAttempts})…',
              source: LogSource.aether,
            );

            // ⚠️ این delay قابل cancel است
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

        // ═══════════════════════════════════════════════════════
        //  مدیریت failure (port swap و ...)
        // ═══════════════════════════════════════════════════════
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

  /// برچسب protocol با masque برای notification.
  String _protocolLabelWithMasque(String protocol, String masque) {
    if (masque.isEmpty) return protocol;
    return '$protocol/$masque';
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  محاسبه تاخیر retry.
  ///
  ///  ⚠️ تغییر: در custom-only mode، تاخیر طولانی‌تر از ۵ ثانیه
  ///  شروع می‌شه و افزایشی است.
  /// ═══════════════════════════════════════════════════════════════
  Duration _computeRetryDelay(int attemptIndex, bool isCustomOnly) {
    if (isCustomOnly) {
      // custom-only: 5s, 8s, 11s, 14s, ...
      final seconds = 5 + (attemptIndex - 1) * 3;
      return Duration(seconds: seconds.clamp(5, 30));
    }
    return AetherRetryStrategy.delayAfterAttempt(attemptIndex + 1);
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  محاسبه MASQUE option مؤثر برای یک attempt.
  ///
  ///  ⚠️ تغییرات این نسخه:
  ///    • در auto-reconnect، H2/H3 swap حتی در manual profile فعاله
  ///    • در custom-first، masque از خود attempt گرفته میشه
  /// ═══════════════════════════════════════════════════════════════
  String _effectiveMasqueForAttempt(EndpointAttempt attempt, int index) {
    // custom endpoint: masque رو از خود attempt بگیر
    // (چون custom-first خودش دو نسخه H2/H3 ساخته)
    if (attempt.isCustomEndpoint && attempt.masque.isNotEmpty) {
      return attempt.masque;
    }

    // فقط masque و mim از جابه‌جایی H2/H3 پشتیبانی می‌کنن
    if (attempt.protocol != 'masque' && attempt.protocol != 'mim') {
      return attempt.masque;
    }

    // اگه masque نداره، چیزی برای تغییر نیست
    if (attempt.masque.isEmpty) {
      return attempt.masque;
    }

    // ═══════════════════════════════════════════════════════════
    //  ⚠️ FIX: در automatic profile یا auto-reconnect،
    //  H2/H3 جابه‌جا میشه — حتی در manual profile.
    //
    //  دلیل: در auto-reconnect، کاربر نیاز داره که اگه یک نسخه
    //  fail شد، نسخهٔ دیگه امتحان بشه. manual بودن profile
    //  نباید این رو مسدود کنه.
    // ═══════════════════════════════════════════════════════════
    final shouldSwap = settings.isAetherProfileAutomatic ||
        settings.aetherProfile == 'manual' ||
        settings.isEndpointPinningCustomFirst;

    if (shouldSwap) {
      return AetherRetryStrategy.masqueForAttempt(
        preferredMasque: attempt.masque,
        attemptIndex: index + 1, // 1-based
      );
    }

    return attempt.masque;
  }

  /// انتظار با قابلیت cancel.
  Future<void> _waitWithCancel(Duration delay) async {
    final endTime = DateTime.now().add(delay);
    const checkInterval = Duration(milliseconds: 250);

    while (DateTime.now().isBefore(endTime)) {
      if (cancelRequested) return;

      final remaining = endTime.difference(DateTime.now());
      if (remaining <= Duration.zero) return;

      final sleepTime = remaining < checkInterval ? remaining : checkInterval;
      await Future.delayed(sleepTime);
    }
  }
}
