// lib/services/aether_auto_test_service.dart
//
// ═══════════════════════════════════════════════════════════════
//  AetherAutoTestService — orchestrator اصلی auto-test Aether.
//
//  مسئولیت‌ها پس از تفکیک:
//    • AetherAttemptPlanner       → ساخت لیست کاندیداها + args
//    • AetherEndpointStore        → ذخیره/خواندن endpoint موفق
//    • SocksProber                → probe سلامت SOCKS
//    • AetherAttemptRunner        → اجرای یک attempt
//    • PortManager                → مدیریت پورت
//    • AetherCacheManager         → پاک‌سازی کش
//    • AetherTestHelpers          → helperهای عمومی (safe, swapPort)
//
//  این کلاس فقط حلقهٔ اصلی + تصمیم‌گیری را دارد.
// ═══════════════════════════════════════════════════════════════
library;

import 'dart:async';

import '../models/settings_model.dart';
import 'aether/aether_test_helpers.dart';
import 'aether_attempt_runner.dart';
import 'aether_attempts.dart';
import 'aether_cache_manager.dart';
import 'aether_endpoint_store.dart';
import 'aether_socks_probe.dart';
import 'process_service.dart';

class AetherAutoTestService {
  final ProcessService processService;
  AppSettings settings;

  bool _cancelRequested = false;
  bool _portSwapTried = false;
  Future<bool>? _testFuture;

  // ─── collaborators ───
  late SocksProber _prober;
  late AetherAttemptPlanner _planner;
  late AetherEndpointStore _store;
  late AetherAttemptRunner _runner;
  late AetherCacheManager _cacheManager;
  late AetherTestHelpers _helpers;

  AetherAutoTestService({
    required this.processService,
    required this.settings,
  }) {
    _rebuildCollaborators();
  }

  /// (Re)build همهٔ collaboratorها بر اساس `settings` فعلی.
  void _rebuildCollaborators() {
    _prober = SocksProber(
      processService,
      isCancelled: () => _cancelRequested,
    );

    _planner = AetherAttemptPlanner(settings);

    _store = AetherEndpointStore(
      settings: settings,
      log: processService.addLog,
    );

    _runner = AetherAttemptRunner(
      processService: processService,
      prober: _prober,
    );

    _cacheManager = AetherCacheManager(processService: processService);

    _helpers = AetherTestHelpers(processService: processService);
  }

  void updateSettings(AppSettings newSettings) {
    settings = newSettings;
    _rebuildCollaborators();
  }

  bool get isCancelRequested => _cancelRequested;

  void requestCancel() {
    _cancelRequested = true;
  }

  /// نقطهٔ ورود عمومی — idempotent اگر تست در حال اجرا باشد.
  Future<bool> ensureHealthy({bool showUi = true}) {
    final existing = _testFuture;
    if (existing != null) return existing;

    final future = _runAutoTest(showUi: showUi);
    _testFuture = future;
    future.whenComplete(() {
      if (identical(_testFuture, future)) _testFuture = null;
    });
    return future;
  }

  /// خواندن آخرین endpoint موفق (از UI فراخوانی می‌شود).
  Future<String?> getLastSuccessfulEndpoint() =>
      _store.getLastSuccessfulEndpoint();

  // ═══════════════════════════════════════════
  //  اجرای تست خودکار
  //
  //  اولویت‌ها:
  //    1) Custom Endpoint (اگر کاربر تعیین کرده)
  //    2) Last Successful Endpoint (اگر quickReconnect فعال است)
  //    3) Auto Winner (از SharedPreferences)
  //    4) اسکن عادی بر اساس پروتکل انتخاب‌شده
  // ═══════════════════════════════════════════
  Future<bool> _runAutoTest({bool showUi = true}) async {
    _cancelRequested = false;
    _portSwapTried = false;
    var port = settings.aetherLocalPort;
    final isAuto = settings.aetherProtocol == 'auto';

    // بارگذاری برندهٔ قبلی (فقط برای حالت auto)
    // ✅ type parameter صریح داده شده تا nullable درست resolve شود
    MapEntry<String, String>? autoWinner;
    if (isAuto) {
      autoWinner = await _helpers.safe<MapEntry<String, String>?>(
        _store.loadAutoWinner,
      );
    }

    final candidates = _planner.buildCandidates(autoWinner: autoWinner);

    for (final attempt in candidates) {
      if (_cancelRequested) break;

      processService.addLog(
        '↻ Trying ${attempt.label}',
        source: LogSource.aether,
      );

      final args = _planner.argsFor(
        protocol: attempt.protocol,
        masqueOption: attempt.masque,
        port: port,
        endpointOverride: attempt.endpoint,
      );

      final result = await _runner.run(
        attempt: attempt,
        args: args,
        port: port,
      );

      // ─── موفقیت ───
      if (result.isSuccess) {
        await _store.saveSuccessState(
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

      // ─── شکست — تصمیم‌گیری بر اساس نوع ───
      switch (result.outcome) {
        case AttemptOutcome.refused:
          processService.addLog(
            '→ ${attempt.label} refused, trying next candidate…',
            source: LogSource.aether,
          );
          await processService.stopAether();
          await Future.delayed(const Duration(milliseconds: 400));
          continue;

        case AttemptOutcome.tunnelDead:
          processService.addLog(
            '→ ${attempt.label} tunnel dead, clearing cache and retrying…',
            source: LogSource.aether,
          );
          await processService.stopAether();
          await Future.delayed(const Duration(milliseconds: 800));
          await _helpers.safe<void>(
            () => _cacheManager.clearCachedGateway(
              specificProtocol: attempt.protocol,
            ),
          );
          continue;

        case AttemptOutcome.timeout:
        case AttemptOutcome.startFailed:
          // یک بار swap پورت امتحان کن
          final hasListener = await ProcessService.isPortInUse(port);
          if (!_portSwapTried && !_cancelRequested && !hasListener) {
            await processService.stopAether();
            await Future.delayed(const Duration(milliseconds: 800));
            final np = await _helpers.swapPort(
              currentPort: port,
              onPortChanged: (newPort) {
                settings.aetherLocalPort = newPort;
                _portSwapTried = true;
              },
            );
            if (np != null) {
              port = np;
              processService.addLog(
                '→ Switched to port $port, retrying…',
                source: LogSource.aether,
              );
              continue;
            }
          }
          await processService.stopAether();
          await Future.delayed(const Duration(milliseconds: 600));
          continue;

        case AttemptOutcome.success:
          // قبلاً handle شده — برای exhaustive switch
          return true;
      }
    }

    processService.addLog(
      '✗ All candidates failed',
      source: LogSource.aether,
    );
    return false;
  }
}
