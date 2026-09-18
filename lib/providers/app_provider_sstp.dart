part of 'app_provider.dart';

extension AppProviderSstp on AppProvider {
  Future<void> connectSstp({bool fromAutoReconnect = false}) async {
    const src = LogSource.sstp;

    if (processService.isSstpRunning || isSstpBusy) {
      userStoppedSstp = true;
      _reconnectManager.cancelSstpTimer();
      _aetherTestService.requestCancel();
      await processService.stopSstp();
      sstpStatus = 'SSTP: Stopped';
      await AppDataService.fixDataDirOwnership();
      touch();
      return;
    }

    if (fromAutoReconnect && userStoppedSstp) {
      processService.addLog(
        '→ SSTP auto-reconnect skipped (stopped by user)',
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

        final msg =
            'SSTP binary not found. Place "sstp-proxy${AppDataService.exeExt}" '
            'in the data folder, next to the app binary, or inside the '
            '"${AppDataService.osFolder}" folder. You can also download it '
            'from "Core Updates".';
        processService.setBinaryMissingMessage(msg);
        sstpStatus = 'SSTP: Binary missing';
        touch();
        return;
      }

      processService.addLog(
        '✓ SSTP binary found: $binaryPath',
        source: src,
      );
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

    userStoppedSstp = false;
    isSstpBusy = true;
    sstpStatus = 'SSTP: Starting…';
    touch();

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
    } catch (e) {
      processService.addLog('✗ connectSstp error: $e', source: src);
      sstpStatus = 'SSTP: Error';
    } finally {
      isSstpBusy = false;
      await AppDataService.fixDataDirOwnership();
      touch();
    }
  }
}
