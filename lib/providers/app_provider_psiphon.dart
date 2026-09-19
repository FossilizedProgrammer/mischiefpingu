part of 'app_provider.dart';

extension AppProviderPsiphon on AppProvider {
  /// ═══════════════════════════════════════════════════════════════
  ///  connectPsiphon — entry point عمومی
  /// ═══════════════════════════════════════════════════════════════
  Future<void> connectPsiphon({bool fromAutoReconnect = false}) async {
    if (fromAutoReconnect) {
      await _startPsiphonInternal(fromAutoReconnect: true);
      return;
    }

    final isCurrentlyActive = processService.isPsiphonRunning || isPsiphonBusy;

    if (isCurrentlyActive) {
      await _stopPsiphonByUser();
    } else {
      await _startPsiphonInternal(fromAutoReconnect: false);
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  _stopPsiphonByUser — تنها جایی که userStoppedPsiphon=true می‌شود.
  /// ═══════════════════════════════════════════════════════════════
  Future<void> _stopPsiphonByUser() async {
    const src = LogSource.psiphon;

    userStoppedPsiphon = true;
    _reconnectManager.cancelPsiphonTimer();
    _reconnectManager.resetRetries('psiphon');
    _aetherTestService.requestCancel();
    _recoveryCoordinator.releaseLeaseByTunnel('Psiphon');

    nextPsiphonGeneration();

    try {
      await processService.stopPsiphon();
    } catch (e) {
      processService.addLog('⚠ Psiphon stop error: $e', source: src);
    }

    isPsiphonBusy = false;
    isLoading = false;
    watchdogManager?.psiphon.resetGracePeriod();
    watchdogManager?.psiphon.resetCircuitBreaker();

    await AppDataService.fixDataDirOwnership();
    touch();
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  _startPsiphonInternal — start/reconnect داخلی.
  /// ═══════════════════════════════════════════════════════════════
  Future<void> _startPsiphonInternal({
    required bool fromAutoReconnect,
  }) async {
    const src = LogSource.psiphon;

    if (!fromAutoReconnect) {
      _reconnectManager.cancelPsiphonTimer();
    }

    if (fromAutoReconnect && userStoppedPsiphon) {
      processService.addLog(
        '→ Psiphon auto-reconnect skipped (stopped by user)',
        source: src,
      );
      return;
    }

    if (fromAutoReconnect && isPsiphonBusy) {
      processService.addLog(
        '→ Psiphon auto-reconnect skipped (already busy)',
        source: src,
      );
      return;
    }

    if (!fromAutoReconnect && isPsiphonBusy) {
      processService.addLog(
        '→ Psiphon start ignored — already starting',
        source: src,
      );
      return;
    }

    if (processService.isPsiphonRunning && !fromAutoReconnect) {
      processService.addLog(
        '→ Psiphon is already running — ignoring redundant start',
        source: src,
      );
      return;
    }

    if (!await checkPsiphonBinary()) return;
    if (!await checkPsiphonPorts()) return;

    if (!fromAutoReconnect) {
      userStoppedPsiphon = false;
    }

    isPsiphonBusy = true;
    isLoading = true;
    touch();

    final myGeneration = nextPsiphonGeneration();

    try {
      if (settings.upstreamType == 2) {
        if (processService.isAetherRunning) {
          aetherStatus = 'Aether: Running (upstream)';
          touch();
        } else {
          if (fromAutoReconnect && userStoppedAether) {
            processService.addLog(
              '→ Psiphon auto-reconnect skipped '
              '(upstream Aether was stopped by user)',
              source: src,
            );
            return;
          }

          aetherStatus = settings.aetherProtocol == 'auto'
              ? 'Aether: Auto-testing protocols…'
              : 'Aether: Testing ${settings.aetherProtocol.toUpperCase()}…';
          touch();

          isAutoTesting = true;
          final ok = await _aetherTestService.ensureHealthy(showUi: false);
          isAutoTesting = false;

          if (userStoppedPsiphon || _aetherTestService.isCancelRequested) {
            processService.addLog(
              'Psiphon start cancelled by user',
              source: src,
            );
            return;
          }

          if (!ok && !processService.isAetherRunning) {
            aetherStatus = 'Aether: not available — Psiphon not started';
            processService.addLog(
              '✗ Aether unavailable → Psiphon not started',
              source: src,
            );
            return;
          }

          aetherStatus = 'Aether: Running (upstream)';
          touch();
        }
      }

      if (userStoppedPsiphon) {
        processService.addLog('Psiphon start cancelled by user', source: src);
        return;
      }

      await saveSettings();
      final config = buildPsiphonConfig();
      final useSunAndLion = settings.effectiveUseSunAndLion;
      processService.addLog(
        '→ Tunnel core: ${useSunAndLion ? 'SunAndLion (fronting)' : 'official'}',
        source: src,
      );

      if (userStoppedPsiphon) {
        processService.addLog('Psiphon start cancelled by user', source: src);
        return;
      }

      await processService.startPsiphon(
        configJson: config,
        useSunAndLion: useSunAndLion,
        shareLan: settings.psiphonShareLan,
        socksPort: settings.socksPort,
        httpPort: settings.httpPort,
      );

      if (myGeneration != _psiphonGeneration) {
        processService.addLog(
          '→ Psiphon start completed but a newer start superseded it',
          source: src,
        );
      }
    } catch (e) {
      processService.addLog('✗ connectPsiphon error: $e', source: src);
    } finally {
      isPsiphonBusy = false;
      isLoading = false;
      await AppDataService.fixDataDirOwnership();
      touch();
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  restartPsiphonInternal — برای watchdog.
  /// ═══════════════════════════════════════════════════════════════
  Future<void> restartPsiphonInternal({required String reason}) async {
    const src = LogSource.psiphon;

    if (userStoppedPsiphon || isShuttingDown) {
      processService.addLog(
        '→ restartPsiphonInternal skipped '
        '(userStopped=$userStoppedPsiphon, shutdown=$isShuttingDown)',
        source: src,
      );
      return;
    }

    if (restartingPsiphon) {
      processService.addLog(
        '→ restartPsiphonInternal skipped (already restarting)',
        source: src,
      );
      return;
    }

    restartingPsiphon = true;
    try {
      processService.addLog(
        '↻ Restarting Psiphon — reason: $reason',
        source: src,
      );
      processService.setSadNotification('Psiphon');

      _reconnectManager.cancelPsiphonTimer();

      nextPsiphonGeneration();

      await processService.stopPsiphon();
      await Future.delayed(const Duration(seconds: 3));

      if (!userStoppedPsiphon && !isShuttingDown) {
        await _startPsiphonInternal(fromAutoReconnect: true);
      }
    } finally {
      restartingPsiphon = false;
    }
  }

  String buildPsiphonConfig() {
    final builder = PsiphonConfigBuilder(
      settings: settings,
      ipList: ipList,
      processService: processService,
    );
    return builder.build();
  }
}
