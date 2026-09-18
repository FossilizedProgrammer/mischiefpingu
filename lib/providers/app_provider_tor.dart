part of 'app_provider.dart';

extension AppProviderTor on AppProvider {
  Future<int> _pickInternalPort(int publicPort) =>
      PortManager.internalFor(publicPort: publicPort);

  Future<void> connectTor({bool fromAutoReconnect = false}) async {
    const src = LogSource.tor;

    if (processService.isTorRunning || isTorBusy) {
      userStoppedTor = true;
      _reconnectManager.cancelTorTimer();
      _aetherTestService.requestCancel();
      await processService.stopTor();
      torStatus = 'Tor: Stopped';
      await AppDataService.fixDataDirOwnership();
      touch();
      return;
    }

    if (fromAutoReconnect && userStoppedTor) {
      processService.addLog(
        '→ Tor auto-reconnect skipped (stopped by user)',
        source: src,
      );
      return;
    }

    if (!await checkTorBinary()) return;
    if (!await checkTorPorts()) return;

    userStoppedTor = false;
    isTorBusy = true;
    torStatus = 'Tor: Starting…';
    touch();

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
        aetherSocks: settings.torTransport == 'aether'
            ? settings.aetherLocalPort
            : null,
        psiphonSocks: settings.torTransport == 'psiphon'
            ? settings.socksPort
            : null,
        sstpSocks: settings.torTransport == 'sstp'
            ? settings.sstpSocksPort
            : null,
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
          '✗ Tor failed to start — is `tor` installed? (Core Updates can fetch it)',
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
}
