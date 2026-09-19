part of 'app_provider.dart';

extension AppProviderSstp on AppProvider {
  /// ═══════════════════════════════════════════════════════════════
  ///  connectSstp — entry point عمومی
  /// ═══════════════════════════════════════════════════════════════
  Future<void> connectSstp({bool fromAutoReconnect = false}) async {
    if (fromAutoReconnect) {
      await _startSstpInternal(fromAutoReconnect: true);
      return;
    }

    final isCurrentlyActive = processService.isSstpRunning || isSstpBusy;

    if (isCurrentlyActive) {
      await _stopSstpByUser();
    } else {
      await _startSstpInternal(fromAutoReconnect: false);
    }
  }

  Future<void> _stopSstpByUser() async {
    const src = LogSource.sstp;

    userStoppedSstp = true;
    _reconnectManager.cancelSstpTimer();
    _reconnectManager.resetRetries('sstp');
    _aetherTestService.requestCancel();
    _recoveryCoordinator.releaseLeaseByTunnel('SSTP');

    nextSstpGeneration();

    try {
      await processService.stopSstp();
    } catch (e) {
      processService.addLog('⚠ SSTP stop error: $e', source: src);
    }

    isSstpBusy = false;
    sstpStatus = 'SSTP: Stopped';
    watchdogManager?.sstp.resetGracePeriod();
    watchdogManager?.sstp.resetCircuitBreaker();

    await AppDataService.fixDataDirOwnership();
    touch();
  }

  Future<void> _startSstpInternal({required bool fromAutoReconnect}) async {
    const src = LogSource.sstp;

    if (!fromAutoReconnect) {
      _reconnectManager.cancelSstpTimer();
    }

    if (fromAutoReconnect && userStoppedSstp) {
      processService.addLog(
        '→ SSTP auto-reconnect skipped (stopped by user)',
        source: src,
      );
      return;
    }

    if (fromAutoReconnect && isSstpBusy) {
      processService.addLog(
        '→ SSTP auto-reconnect skipped (already busy)',
        source: src,
      );
      return;
    }

    if (!fromAutoReconnect && isSstpBusy) {
      processService.addLog(
        '→ SSTP start ignored — already starting',
        source: src,
      );
      return;
    }

    if (processService.isSstpRunning && !fromAutoReconnect) {
      processService.addLog(
        '→ SSTP is already running — ignoring redundant start',
        source: src,
      );
      return;
    }

    try {
      final binaryPath = await AppDataService.getSstpBinaryPathForExecution();
      if (!await File(binaryPath).exists()) {
        processService.addLog(
          '✗ SSTP binary not found. Searched paths:',
          source: src,
        );
        await AppDataService.logBinaryCandidates(
          'sstp-proxy',
          log: (line) => processService.addLog(line, source: src),
        );

        final msg = 'SSTP binary not found. Place '
            '"sstp-proxy${AppDataService.exeExt}" '
            'in the data folder, next to the app binary, or inside the '
            '"${AppDataService.osFolder}" folder. You can also download it '
            'from "Core Updates".';
        processService.setBinaryMissingMessage(msg);
        sstpStatus = 'SSTP: Binary missing';
        touch();
        return;
      }

      processService.addLog('✓ SSTP binary found: $binaryPath', source: src);
    } catch (e) {
      processService.addLog('✗ Error checking SSTP binary: $e', source: src);
    }

    if (settings.sstpServer.trim().isEmpty) {
      final msg = 'SSTP: Server address is empty. Please configure it.';
      processService.setPortConflictMessage(msg);
      processService.addLog('✗ SSTP server not configured', source: src);
      sstpStatus = 'SSTP: Server not set';
      touch();
      return;
    }

    final socksPort = settings.sstpSocksPort;
    final httpPort = settings.sstpHttpPort;

    if (await ProcessService.isPortInUse(socksPort)) {
      final msg =
          'SSTP: SOCKS port $socksPort is already in use by another application. Cannot start.';
      processService.setPortConflictMessage(msg);
      processService.addLog(
        '✗ SOCKS port $socksPort is in use — SSTP not started',
        source: src,
      );
      sstpStatus = 'SSTP: Port $socksPort in use';
      touch();
      return;
    }
    if (await ProcessService.isPortInUse(httpPort)) {
      final msg =
          'SSTP: HTTP port $httpPort is already in use by another application. Cannot start.';
      processService.setPortConflictMessage(msg);
      processService.addLog(
        '✗ HTTP port $httpPort is in use — SSTP not started',
        source: src,
      );
      sstpStatus = 'SSTP: Port $httpPort in use';
      touch();
      return;
    }

    if (!fromAutoReconnect) {
      userStoppedSstp = false;
    }

    isSstpBusy = true;
    sstpStatus = 'SSTP: Starting…';
    touch();

    final myGeneration = nextSstpGeneration();

    try {
      final upstreamOk = await resolveSstpUpstream(
        fromAutoReconnect: fromAutoReconnect,
      );
      if (!upstreamOk) return;

      if (userStoppedSstp) {
        processService.addLog('SSTP start cancelled by user', source: src);
        return;
      }

      await saveSettings();

      final builder = SstpConfigBuilder(
        settings: settings,
        processService: processService,
      );
      final args = builder.buildArgs();

      if (userStoppedSstp) {
        processService.addLog('SSTP start cancelled by user', source: src);
        return;
      }

      final serverInfo = '${settings.sstpServer}:${settings.sstpPort}';
      processService.prepareSstpNotification(
        serverInfo,
        'Server: $serverInfo',
      );

      final ok = await processService.startSstp(
        args: args,
        shareLan: settings.sstpShareLan,
        socksPort: settings.sstpSocksPort,
        httpPort: settings.sstpHttpPort,
      );

      sstpStatus = ok ? 'SSTP: Connected' : 'SSTP: Failed to start';

      if (myGeneration != _sstpGeneration) {
        processService.addLog(
          '→ SSTP start completed but a newer start superseded it',
          source: src,
        );
      }
    } catch (e) {
      processService.addLog('✗ connectSstp error: $e', source: src);
      sstpStatus = 'SSTP: Error';
    } finally {
      isSstpBusy = false;
      await AppDataService.fixDataDirOwnership();
      touch();
    }
  }

  Future<void> restartSstpInternal({required String reason}) async {
    const src = LogSource.sstp;

    if (userStoppedSstp || isShuttingDown) {
      processService.addLog(
        '→ restartSstpInternal skipped '
        '(userStopped=$userStoppedSstp, shutdown=$isShuttingDown)',
        source: src,
      );
      return;
    }

    if (restartingSstp) {
      processService.addLog(
        '→ restartSstpInternal skipped (already restarting)',
        source: src,
      );
      return;
    }

    restartingSstp = true;
    try {
      processService.addLog(
        '↻ Restarting SSTP — reason: $reason',
        source: src,
      );
      processService.setSadNotification('SSTP');

      _reconnectManager.cancelSstpTimer();

      nextSstpGeneration();

      await processService.stopSstp();
      await Future.delayed(const Duration(seconds: 3));

      if (!userStoppedSstp && !isShuttingDown) {
        await _startSstpInternal(fromAutoReconnect: true);
      }
    } finally {
      restartingSstp = false;
    }
  }
}
