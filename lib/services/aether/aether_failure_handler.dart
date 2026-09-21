library;

import '../aether_attempt_runner.dart';
import '../aether_attempts.dart';
import '../aether_cache_manager.dart';
import '../database/gateway_history_store.dart';
import '../process_service.dart';
import 'aether_test_helpers.dart';
import 'util/endpoint_parser.dart';

class AetherFailureHandler {
  final ProcessService processService;
  final AetherCacheManager cacheManager;
  final AetherTestHelpers helpers;

  /// اختیاری: برای ثبت شکست‌ها در دیتابیس (فاز ۳).
  GatewayHistoryStore? historyStore;

  AetherFailureHandler({
    required this.processService,
    required this.cacheManager,
    required this.helpers,
    this.historyStore,
  });

  Future<bool> handle({
    required AttemptResult result,
    required EndpointAttempt attempt,
    required int port,
    required bool portSwapTried,
    required void Function(int newPort) onPortSwapped,
    required void Function() onPortSwapTried,
    required bool Function() isCancelRequested,
  }) async {
    if (attempt.fromHistory && historyStore != null) {
      try {
        await historyStore!.recordFailure(
          ip: attempt.endpoint.isNotEmpty
              ? attempt.endpoint.split(':').first
              : 'unknown',
          port: port,
          protocol: attempt.protocol,
          masqueOption: attempt.masque,
        );
      } catch (_) {}
    }

    switch (result.outcome) {
      case AttemptOutcome.refused:
        processService.addLog(
          '→ ${attempt.label} refused, trying next candidate…',
          source: LogSource.aether,
        );
        await processService.stopAether();
        // ⚠️ کاهش از 400ms به 250ms
        await Future.delayed(const Duration(milliseconds: 250));
        return true;

      case AttemptOutcome.tunnelDead:
        processService.addLog(
          '→ ${attempt.label} tunnel dead, clearing cache and retrying…',
          source: LogSource.aether,
        );
        await processService.stopAether();
        // ⚠️ کاهش از 800ms به 400ms
        await Future.delayed(const Duration(milliseconds: 400));
        await helpers.safe<void>(
          () => cacheManager.clearCachedGateway(
            specificProtocol: attempt.protocol,
          ),
        );
        return true;

      case AttemptOutcome.allTargetsFailed:
        processService.addLog(
          '⚠ ${attempt.label} — SOCKS is up but HTTP probes all failed. '
          'Treating as "likely alive" and NOT clearing cache. '
          'Network may be blocking probe targets.',
          source: LogSource.aether,
        );
        return false;

      case AttemptOutcome.timeout:
      case AttemptOutcome.startFailed:
        final hasListener = await ProcessService.isPortInUse(port);
        if (!portSwapTried && !isCancelRequested() && !hasListener) {
          await processService.stopAether();
          // ⚠️ کاهش از 800ms به 400ms
          await Future.delayed(const Duration(milliseconds: 400));
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
        // ⚠️ کاهش از 600ms به 300ms
        await Future.delayed(const Duration(milliseconds: 300));
        return true;

      case AttemptOutcome.success:
        return false;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  پارس endpoint — delegate به EndpointParser مشترک.
  ///
  ///  ⚠️ این متد به عنوان wrapper باقی مونده تا کد قدیمی که
  ///  `AetherFailureHandler.parseEndpoint(...)` صدا می‌زنه،
  ///  بدون تغییر کار کنه.
  /// ═══════════════════════════════════════════════════════════════
  static (String, int)? parseEndpoint(String endpoint) {
    final parsed = EndpointParser.parse(endpoint);
    if (parsed == null) return null;
    return (parsed.$1, parsed.$2);
  }
}
