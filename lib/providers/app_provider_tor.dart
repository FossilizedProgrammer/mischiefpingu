// lib/providers/app_provider_tor.dart
part of 'app_provider.dart';

extension AppProviderTor on AppProvider {
  Future<int> _pickInternalPort(int publicPort) =>
      PortManager.internalFor(publicPort: publicPort);

  Future<void> connectTor({bool fromAutoReconnect = false}) async {
    const src = LogSource.tor;

    // ─── اگر در حال اجراست، متوقف کن ───
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
      processService.addLog('→ Tor auto-reconnect skipped (stopped by user)',
          source: src);
      return;
    }

    // ─── بررسی باینری ───
    try {
      final binaryPath = await AppDataService.findTorBinary() ??
          await AppDataService.getTorBinaryPath();
      if (!await File(binaryPath).exists()) {
        final msg =
            'Tor binary not found. Please click "Show more" and download it from "Core Updates".';
        processService.setBinaryMissingMessage(msg);
        processService.addLog(
          '✗ Tor binary missing: $binaryPath — download it from Core Updates',
          source: src,
        );
        torStatus = 'Tor: Binary missing';
        touch();
        return;
      }
    } catch (e) {
      processService.addLog('✗ Error checking Tor binary: $e', source: src);
    }

    // ─── چک پورت‌ها ───
    final socksPort = settings.torSocksPort;
    final httpPort = settings.torHttpPort;
    if (await ProcessService.isPortInUse(socksPort)) {
      final msg =
          'Tor: SOCKS port $socksPort is already in use by another application. Cannot start.';
      processService.setPortConflictMessage(msg);
      processService.addLog(
        '✗ SOCKS port $socksPort is in use — Tor not started',
        source: src,
      );
      torStatus = 'Tor: Port $socksPort in use';
      touch();
      return;
    }
    if (await ProcessService.isPortInUse(httpPort)) {
      final msg =
          'Tor: HTTP port $httpPort is already in use by another application. Cannot start.';
      processService.setPortConflictMessage(msg);
      processService.addLog('✗ HTTP port $httpPort is in use — Tor not started',
          source: src);
      torStatus = 'Tor: Port $httpPort in use';
      touch();
      return;
    }

    userStoppedTor = false;
    isTorBusy = true;
    torStatus = 'Tor: Starting…';
    touch();

    try {
      // ─── upstream ───
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

      // ─── آماده‌سازی مسیرها ───
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

      // ─── پیدا کردن مسیرهای pluggable transports ───
      String? lyrebirdPath;
      String? conjurePath;
      String? geoipPath;
      String? geoip6Path;

      for (final cand in [
        '$dataDir/lyrebird',
        '$torDir/pluggable_transports/lyrebird',
        '$torDir/lyrebird',
      ]) {
        if (await File(cand).exists()) {
          lyrebirdPath = cand;
          break;
        }
      }
      for (final cand in [
        '$dataDir/conjure-client',
        '$torDir/pluggable_transports/conjure-client',
        '$torDir/conjure-client',
      ]) {
        if (await File(cand).exists()) {
          conjurePath = cand;
          break;
        }
      }
      for (final cand in ['$torDir/geoip', '$dataDir/geoip']) {
        if (await File(cand).exists()) {
          geoipPath = cand;
          break;
        }
      }
      for (final cand in ['$torDir/geoip6', '$dataDir/geoip6']) {
        if (await File(cand).exists()) {
          geoip6Path = cand;
          break;
        }
      }

      // ─── ساخت torrc ───
      final builder = TorConfigBuilder(
        settings: settings,
        processService: processService,
      );
      final res = builder.build(
        socksPort: internalSocks,
        httpPort: internalHttp,
        torDataDir: torDataDir,
        geoipPath: geoipPath,
        geoip6Path: geoip6Path,
        lyrebirdPath: lyrebirdPath,
        conjurePath: conjurePath,
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
