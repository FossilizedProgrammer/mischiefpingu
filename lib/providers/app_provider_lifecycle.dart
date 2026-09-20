part of 'app_provider.dart';

extension AppProviderLifecycle on AppProvider {
  Future<void> initializeProvider() async {
    try {
      await loadSettingsInternal();
      await checkPrivilegeInternal();

      // ─── مقداردهی اولیه دیتابیس ───
      await _initializeGatewayDatabase();

      final coreUpdateService = CoreUpdateService(log: processService.addLog);
      await coreUpdateService.applyPendingUpdates();
      touch();
    } catch (e) {
      processService.addLog(
        '⚠ Provider initialization failed: $e',
        source: LogSource.app,
      );
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  _initializeGatewayDatabase — راه‌اندازی دیتابیس، لاگ آمار، prune.
  /// ═══════════════════════════════════════════════════════════════
  Future<void> _initializeGatewayDatabase() async {
    try {
      DatabaseInitializer.ensureInitialized();

      // ─── Gateway history (فاز ۱) ───
      final count = await _gatewayHistoryStore.count();
      processService.addLog(
        '→ Gateway history DB ready ($count record(s))',
        source: LogSource.app,
      );

      // ─── Structured Logging (فاز v2) ───
      final eventCount = await _aetherEventStore.count();
      processService.addLog(
        '→ Aether event log: $eventCount event(s)',
        source: LogSource.app,
      );

      // ─── Smart Cache (فاز v3) ───
      final profileCount = await _profilePerformanceStore.count();
      processService.addLog(
        '→ Profile performance cache: $profileCount entry(ies)',
        source: LogSource.app,
      );

      // ─── پاک‌سازی خودکار در startup ───
      await _runStartupPrune();
    } catch (e) {
      processService.addLog(
        '⚠ Gateway DB initialization failed: $e',
        source: LogSource.app,
      );
    }
  }

  /// پاک‌سازی رکوردهای ضعیف در startup.
  Future<void> _runStartupPrune() async {
    // Gateway history
    try {
      final pruned = await _gatewayHistoryStore.pruneWeakGateways(
        minScore: 10.0,
        minFailures: 3,
        maxAgeDays: 30,
      );
      if (pruned > 0) {
        processService.addLog(
          '→ Startup prune: removed $pruned weak gateway record(s)',
          source: LogSource.app,
        );
      }
    } catch (e) {
      processService.addLog(
        '⚠ Gateway prune failed: $e',
        source: LogSource.app,
      );
    }

    // Profile performance
    try {
      final pruned = await _profilePerformanceStore.pruneWeakEntries(
        minSuccessRate: 0.2,
        minSamples: 3,
        maxAgeDays: 30,
      );
      if (pruned > 0) {
        processService.addLog(
          '→ Startup prune: removed $pruned weak profile perf entry(ies)',
          source: LogSource.app,
        );
      }
    } catch (e) {
      processService.addLog(
        '⚠ Profile perf prune failed: $e',
        source: LogSource.app,
      );
    }
  }

  Future<void> checkPrivilegeInternal() async {
    isElevated = await PrivilegeService.isElevated();
    touch();
  }

  Future<void> shutdownAllInternal() async {
    if (isShuttingDown) return;
    isShuttingDown = true;

    try {
      watchdogManager?.disposeAll();
    } catch (_) {}

    processService.addLog(
      '→ App is closing — disconnecting all active tunnels…',
      source: LogSource.app,
    );

    reconnectManager.cancelAll();

    try {
      aetherTestService.requestCancel();
    } catch (_) {}

    try {
      if (processService.isPsiphonRunning || isPsiphonBusy) {
        processService.addLog('→ Stopping Psiphon…', source: LogSource.app);
        await processService.stopPsiphon();
      }
    } catch (e) {
      processService.addLog(
        '⚠ Psiphon shutdown error: $e',
        source: LogSource.app,
      );
    }

    try {
      if (processService.isTorRunning || isTorBusy) {
        processService.addLog('→ Stopping Tor…', source: LogSource.app);
        await processService.stopTor();
      }
    } catch (e) {
      processService.addLog('⚠ Tor shutdown error: $e', source: LogSource.app);
    }

    try {
      if (processService.isSstpRunning || isSstpBusy) {
        processService.addLog('→ Stopping SSTP…', source: LogSource.app);
        await processService.stopSstp();
      }
    } catch (e) {
      processService.addLog('⚠ SSTP shutdown error: $e', source: LogSource.app);
    }

    try {
      if (processService.isAetherRunning || isAutoTesting) {
        processService.addLog('→ Stopping Aether…', source: LogSource.app);
        await processService.stopAether();
      }
    } catch (e) {
      processService.addLog(
        '⚠ Aether shutdown error: $e',
        source: LogSource.app,
      );
    }

    try {
      await processService.closeAllForwardSockets();
    } catch (_) {}

    // ─── بستن دیتابیس ───
    try {
      await GatewayDatabase.close();
      processService.addLog(
        '→ Gateway history database closed',
        source: LogSource.app,
      );
    } catch (e) {
      processService.addLog(
        '⚠ Failed to close gateway DB: $e',
        source: LogSource.app,
      );
    }

    await Future.delayed(const Duration(milliseconds: 300));

    processService.addLog(
      '★ All tunnels disconnected. Safe to exit.',
      source: LogSource.app,
    );
  }
}
