library;

import '../aether_attempt_runner.dart';
import '../aether_attempts.dart';
import '../aether_cache_manager.dart';
import '../process_service.dart';
import 'aether_test_helpers.dart';

class AetherFailureHandler {
  final ProcessService processService;
  final AetherCacheManager cacheManager;
  final AetherTestHelpers helpers;

  const AetherFailureHandler({
    required this.processService,
    required this.cacheManager,
    required this.helpers,
  });

  /// پردازش شکست یک attempt.
  ///
  /// خروجی:
  ///   - true  → candidate بعدی را امتحان کن
  ///   - false → حلقه را متوقف کن
  ///
  /// ⚠️ نکته: در نسخهٔ قبلی منطق continue معکوس بود؛ این نسخه
  /// قرارداد را صریح می‌کند.
  Future<bool> handle({
    required AttemptResult result,
    required EndpointAttempt attempt,
    required int port,
    required bool portSwapTried,
    required void Function(int newPort) onPortSwapped,
    required void Function() onPortSwapTried,
    required bool Function() isCancelRequested,
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
        if (!portSwapTried && !isCancelRequested() && !hasListener) {
          await processService.stopAether();
          await Future.delayed(const Duration(milliseconds: 800));
          final np = await helpers.swapPort(
            currentPort: port,
            onPortChanged: (newPort) {
              onPortSwapped(newPort);
              onPortSwapTried();
            },
          );
          if (np != null) {
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
