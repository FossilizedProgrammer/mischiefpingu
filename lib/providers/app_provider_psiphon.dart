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

    if (!await checkPsiphonBinary()) return;
    if (!await checkPsiphonPorts()) return;

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
