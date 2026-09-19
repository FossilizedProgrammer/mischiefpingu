part of 'app_provider.dart';

extension AppProviderTor on AppProvider {
  Future<int> _pickInternalPort(int publicPort) =>
      PortManager.internalFor(publicPort: publicPort);

  /// ═══════════════════════════════════════════════════════════════
  ///  connectTor — entry point عمومی
  /// ═══════════════════════════════════════════════════════════════
  Future<void> connectTor({bool fromAutoReconnect = false}) async {
    if (fromAutoReconnect) {
      await _startTorInternal(fromAutoReconnect: true);
      return;
    }

    final isCurrentlyActive = processService.isTorRunning || isTorBusy;

    if (isCurrentlyActive) {
      await _stopTorByUser();
    } else {
      await _startTorInternal(fromAutoReconnect: false);
    }
  }

  Future<void> _stopTorByUser() async {
    const src = LogSource.tor;

    userStoppedTor = true;
    _reconnectManager.cancelTorTimer();
    _reconnectManager.resetRetries('tor');
    _aetherTestService.requestCancel();
    _recoveryCoordinator.releaseLeaseByTunnel('Tor');

    nextTorGeneration();

    try {
      await processService.stopTor();
    } catch (e) {
      processService.addLog('⚠ Tor stop error: $e', source: src);
    }

    isTorBusy = false;
    torStatus = 'Tor: Stopped';
    watchdogManager?.tor.resetGracePeriod();
    watchdogManager?.tor.resetCircuitBreaker();

    await AppDataService.fixDataDirOwnership();
    touch();
  }

  Future<void> _startTorInternal({required bool fromAutoReconnect}) async {
    const src = LogSource.tor;

    if (!fromAutoReconnect) {
      _reconnectManager.cancelTorTimer();
    }

    if (fromAutoReconnect && userStoppedTor) {
      processService.addLog(
        '→ Tor auto-reconnect skipped (stopped by user)',
        source: src,
      );
      return;
    }

    if (fromAutoReconnect && isTorBusy) {
      processService.addLog(
        '→ Tor auto-reconnect skipped (already busy)',
        source: src,
      );
      return;
    }

    if (!fromAutoReconnect && isTorBusy) {
      processService.addLog(
        '→ Tor start ignored — already starting',
        source: src,
      );
      return;
    }

    if (processService.isTorRunning && !fromAutoReconnect) {
      processService.addLog(
        '→ Tor is already running — ignoring redundant start',
        source: src,
      );
      return;
    }

    if (!await checkTorBinary()) return;
    if (!await checkTorPorts()) return;

    if (!fromAutoReconnect) {
      userStoppedTor = false;
    }

    isTorBusy = true;
    torStatus = 'Tor: Starting…';
    touch();

    final myGeneration = nextTorGeneration();

    try {
      final upstream = await resolveTorUpstream(
        fromAutoReconnect: fromAutoReconnect,
      );
      if (!upstream.ok) return;

      final transportType = upstream.type;
      final transportDetail = upstream.detail;

      if (userStoppedTor) {
        processService.addLog('Tor start cancelled by user', source: src);
        return;
      }

      await saveSettings();
      final dataDir = await AppDataService.getDataDir();
      final torDir = await AppDataService.ensureTorDir();
      final torDataDir = '$torDir/tordata';
      await Directory(torDataDir).create(recursive: true);

      var internalSocks = settings.torSocksPort;
      var internalHttp = settings.torHttpPort;
      if (settings.torShareLan) {
        internalSocks = await _pickInternalPort(settings.torSocksPort);
        internalHttp = await _pickInternalPort(settings.torHttpPort);
      }

      final assets = await resolveTorAssets(dataDir: dataDir, torDir: torDir);

      final builder = TorConfigBuilder(
        settings: settings,
        processService: processService,
      );
      final res = builder.build(
        socksPort: internalSocks,
        httpPort: internalHttp,
        torDataDir: torDataDir,
        geoipPath: assets.geoipPath,
        geoip6Path: assets.geoip6Path,
        lyrebirdPath: assets.lyrebirdPath,
        conjurePath: assets.conjurePath,
        aetherSocks:
            settings.torTransport == 'aether' ? settings.aetherLocalPort : null,
        psiphonSocks:
            settings.torTransport == 'psiphon' ? settings.socksPort : null,
        sstpSocks:
            settings.torTransport == 'sstp' ? settings.sstpSocksPort : null,
      );

      final torrcPath = '$torDir/torrc';
      await File(torrcPath).writeAsString(res.torrc);

      torStatus = 'Tor: Bootstrapping…';
      touch();

      if (userStoppedTor) {
        processService.addLog('Tor start cancelled by user', source: src);
        torStatus = 'Tor: Stopped';
        touch();
        return;
      }

      processService.prepareTorNotification(transportType, transportDetail);

      final ok = await processService.startTor(
        torrcPath: torrcPath,
        workDir: torDir,
        env: res.env,
        shareLan: settings.torShareLan,
        socksPort: settings.torSocksPort,
        httpPort: settings.torHttpPort,
        internalSocksPort: internalSocks,
        internalHttpPort: internalHttp,
      );

      torStatus = ok ? 'Tor: Bootstrapping…' : 'Tor: Failed to start';
      if (!ok) {
        processService.addLog(
          '✗ Tor failed to start — is `tor` installed? '
          '(Core Updates can fetch it)',
          source: src,
        );
      }

      if (myGeneration != _torGeneration) {
        processService.addLog(
          '→ Tor start completed but a newer start superseded it',
          source: src,
        );
      }
    } catch (e) {
      processService.addLog('✗ connectTor error: $e', source: src);
      torStatus = 'Tor: Error';
    } finally {
      isTorBusy = false;
      await AppDataService.fixDataDirOwnership();
      touch();
    }
  }

  Future<void> restartTorInternal({required String reason}) async {
    const src = LogSource.tor;

    if (userStoppedTor || isShuttingDown) {
      processService.addLog(
        '→ restartTorInternal skipped '
        '(userStopped=$userStoppedTor, shutdown=$isShuttingDown)',
        source: src,
      );
      return;
    }

    if (restartingTor) {
      processService.addLog(
        '→ restartTorInternal skipped (already restarting)',
        source: src,
      );
      return;
    }

    restartingTor = true;
    try {
      processService.addLog(
        '↻ Restarting Tor — reason: $reason',
        source: src,
      );
      processService.setSadNotification('Tor');

      _reconnectManager.cancelTorTimer();

      nextTorGeneration();

      await processService.stopTor();
      await Future.delayed(const Duration(seconds: 3));

      if (!userStoppedTor && !isShuttingDown) {
        await _startTorInternal(fromAutoReconnect: true);
      }
    } finally {
      restartingTor = false;
    }
  }
}
