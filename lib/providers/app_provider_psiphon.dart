// lib/providers/app_provider_psiphon.dart
part of 'app_provider.dart';

extension AppProviderPsiphon on AppProvider {
  Future<void> connectPsiphon({bool fromAutoReconnect = false}) async {
    const src = LogSource.psiphon;

    if (processService.isPsiphonRunning) {
      userStoppedPsiphon = true;
      _reconnectManager.cancelPsiphonTimer();
      await processService.stopPsiphon();
      await AppDataService.fixDataDirOwnership();
      touch();
      return;
    }

    if (isPsiphonBusy) {
      userStoppedPsiphon = true;
      _aetherTestService.requestCancel();
      _reconnectManager.cancelPsiphonTimer();
      await processService.stopPsiphon();
      isPsiphonBusy = false;
      isLoading = false;
      processService.addLog('Psiphon start cancelled by user', source: src);
      await AppDataService.fixDataDirOwnership();
      touch();
      return;
    }

    if (fromAutoReconnect && userStoppedPsiphon) {
      processService.addLog(
        '→ Psiphon auto-reconnect skipped (stopped by user)',
        source: src,
      );
      return;
    }

    // ═══════════════════════════════════════════
    //  بررسی وجود باینری Psiphon قبل از هر کاری
    // ═══════════════════════════════════════════
    try {
      final useSunAndLion = settings.effectiveUseSunAndLion;
      final binaryName = useSunAndLion
          ? 'psiphon-tunnel-core-sunandlion'
          : 'psiphon-tunnel-core';
      final binaryPath = await AppDataService.getBinaryPath(binaryName);

      if (!await File(binaryPath).exists()) {
        String msg;
        if (useSunAndLion) {
          msg =
              'SunAndLion Psiphon binary not found. Please place "psiphon-tunnel-core-sunandlion" in the app folder or data folder manually.';
        } else {
          msg =
              'Psiphon binary not found. Please click "Show more" and download it from "Core Updates".';
        }
        processService.setBinaryMissingMessage(msg);
        processService.addLog(
          '✗ Psiphon binary missing: $binaryPath',
          source: src,
        );
        touch();
        return;
      }
    } catch (e) {
      processService.addLog('✗ Error checking Psiphon binary: $e', source: src);
    }

    // ─── چک پورت‌ها قبل از هر کاری ───
    final socksPort = settings.socksPort;
    final httpPort = settings.httpPort;
    if (await ProcessService.isPortInUse(socksPort)) {
      final msg =
          'Psiphon: SOCKS port $socksPort is already in use by another application. Cannot start.';
      processService.setPortConflictMessage(msg);
      processService.addLog(
        '✗ SOCKS port $socksPort is in use — Psiphon not started',
        source: src,
      );
      touch();
      return;
    }
    if (await ProcessService.isPortInUse(httpPort)) {
      final msg =
          'Psiphon: HTTP port $httpPort is already in use by another application. Cannot start.';
      processService.setPortConflictMessage(msg);
      processService.addLog(
        '✗ HTTP port $httpPort is in use — Psiphon not started',
        source: src,
      );
      touch();
      return;
    }

    userStoppedPsiphon = false;
    isPsiphonBusy = true;
    isLoading = true;
    touch();

    try {
      if (settings.upstreamType == 2) {
        if (processService.isAetherRunning) {
          aetherStatus = 'Aether: Running (upstream)';
          touch();
        } else {
          if (fromAutoReconnect && userStoppedAether) {
            processService.addLog(
              '→ Psiphon auto-reconnect skipped (upstream Aether was stopped by user)',
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
            processService.addLog('Psiphon start cancelled by user',
                source: src);
            return;
          }

          if (!ok) {
            if (!processService.isAetherRunning) {
              aetherStatus = 'Aether: not available — Psiphon not started';
              processService.addLog(
                '✗ Aether unavailable → Psiphon not started',
                source: src,
              );
              return;
            }
            processService.addLog(
              '✗ Aether unverified but running → starting Psiphon anyway',
              source: src,
            );
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
    } catch (e) {
      processService.addLog('✗ connectPsiphon error: $e', source: src);
    } finally {
      isPsiphonBusy = false;
      isLoading = false;
      await AppDataService.fixDataDirOwnership();
      touch();
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
