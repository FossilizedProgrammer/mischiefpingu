part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  منطق start Psiphon (internal).
/// ═══════════════════════════════════════════════════════════════
extension AppProviderPsiphonLaunch on AppProvider {
  Future<void> startPsiphonInternal({required bool fromAutoReconnect}) async {
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
}
