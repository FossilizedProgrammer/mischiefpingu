part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  منطق start SSTP.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderSstpLaunch on AppProvider {
  Future<void> startSstpInternal({required bool fromAutoReconnect}) async {
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

    if (!await checkSstpBinaryAndServer()) return;
    if (!await checkSstpPorts()) return;

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
      processService.prepareSstpNotification(serverInfo, 'Server: $serverInfo');

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
}
