part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  منطق start Tor (internal).
///
///  ⚠️ FIX:
///   • isTorBusy با generation check در finally
///   • چک userStoppedTor بعد از هر await طولانی
/// ═══════════════════════════════════════════════════════════════
extension AppProviderTorLaunch on AppProvider {
  Future<void> startTorInternal({required bool fromAutoReconnect}) async {
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

      // ⚠️ FIX: چک cancel بعد از upstream
      if (userStoppedTor) {
        processService.addLog(
          'Tor start cancelled by user (after upstream resolve)',
          source: src,
        );
        return;
      }

      if (!upstream.ok) return;

      final transportType = upstream.type;
      final transportDetail = upstream.detail;

      await saveSettings();

      // ⚠️ FIX: چک cancel بعد از saveSettings
      if (userStoppedTor) {
        processService.addLog(
          'Tor start cancelled by user (after saveSettings)',
          source: src,
        );
        return;
      }

      final dataDir = await AppDataService.getDataDir();
      final torDir = await AppDataService.ensureTorDir();
      final torDataDir = '$torDir/tordata';
      await Directory(torDataDir).create(recursive: true);

      // ⚠️ FIX: چک cancel
      if (userStoppedTor) {
        processService.addLog(
          'Tor start cancelled by user (after ensureTorDir)',
          source: src,
        );
        return;
      }

      var internalSocks = settings.torSocksPort;
      var internalHttp = settings.torHttpPort;
      if (settings.torShareLan) {
        internalSocks = await pickInternalPort(settings.torSocksPort);
        internalHttp = await pickInternalPort(settings.torHttpPort);
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

      // ⚠️ FIX: چک cancel قبل از start نهایی
      if (userStoppedTor) {
        processService.addLog(
          'Tor start cancelled by user (before process start)',
          source: src,
        );
        torStatus = 'Tor: Stopped';
        touch();
        return;
      }

      torStatus = 'Tor: Bootstrapping…';
      touch();

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

      // ⚠️ FIX: چک cancel بعد از start
      if (userStoppedTor) {
        processService.addLog(
          'Tor start cancelled by user (after process start) — stopping',
          source: src,
        );
        try {
          await processService.stopTor();
        } catch (_) {}
        torStatus = 'Tor: Stopped';
        touch();
        return;
      }

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
      // ⚠️ FIX: generation check — فقط اگر start فعلی معتبره
      if (myGeneration == _torGeneration) {
        isTorBusy = false;
      }
      await AppDataService.fixDataDirOwnership();
      touch();
    }
  }
}
