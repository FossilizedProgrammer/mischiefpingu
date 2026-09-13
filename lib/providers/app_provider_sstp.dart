// lib/providers/app_provider_sstp.dart
part of 'app_provider.dart';

extension AppProviderSstp on AppProvider {
  Future<void> connectSstp({bool fromAutoReconnect = false}) async {
    const src = LogSource.sstp;

    // ─── اگر در حال اجراست، متوقف کن ───
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

    // ─── بررسی باینری (اجرا از dataDir یا platformDir) ───
    try {
      final binaryPath = await AppDataService.getSstpBinaryPathForExecution();
      if (!await File(binaryPath).exists()) {
        final msg =
            'SSTP binary not found. Please place "sstp-proxy" (Linux) or "sstp-proxy.exe" (Windows) next to the app binary or in Core Updates.';
        processService.setBinaryMissingMessage(msg);
        processService.addLog(
          '✗ SSTP binary missing: $binaryPath',
          source: src,
        );
        sstpStatus = 'SSTP: Binary missing';
        touch();
        return;
      }
    } catch (e) {
      processService.addLog('✗ Error checking SSTP binary: $e', source: src);
    }

    // ─── بررسی سرور ───
    if (settings.sstpServer.trim().isEmpty) {
      final msg = 'SSTP: Server address is empty. Please configure it.';
      processService.setPortConflictMessage(msg);
      processService.addLog('✗ SSTP server not configured', source: src);
      sstpStatus = 'SSTP: Server not set';
      touch();
      return;
    }

    // ─── چک پورت‌ها ───
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
      // ─── upstream ───
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
