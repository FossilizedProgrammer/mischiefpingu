part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  منطق start SSTP.
///
///  ⚠️ FIX:
///   • isSstpBusy با generation check در finally
///   • چک userStoppedSstp بعد از هر await طولانی
///   • چک cancel بعد از resolveSstpUpstream
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

      // ⚠️ FIX: چک cancel بعد از resolveSstpUpstream
      if (userStoppedSstp) {
        processService.addLog(
          'SSTP start cancelled by user (after upstream resolve)',
          source: src,
        );
        sstpStatus = 'SSTP: Stopped';
        touch();
        return;
      }

      if (!upstreamOk) return;

      await saveSettings();

      // ⚠️ FIX: چک cancel
      if (userStoppedSstp) {
        processService.addLog(
          'SSTP start cancelled by user (after saveSettings)',
          source: src,
        );
        return;
      }

      final builder = SstpConfigBuilder(
        settings: settings,
        processService: processService,
      );
      final args = builder.buildArgs();

      // ⚠️ FIX: چک cancel قبل از start نهایی
      if (userStoppedSstp) {
        processService.addLog(
          'SSTP start cancelled by user (before process start)',
          source: src,
        );
        sstpStatus = 'SSTP: Stopped';
        touch();
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

      // ⚠️ FIX: چک cancel بعد از start
      if (userStoppedSstp) {
        processService.addLog(
          'SSTP start cancelled by user (after process start) — stopping',
          source: src,
        );
        try {
          await processService.stopSstp();
        } catch (_) {}
        sstpStatus = 'SSTP: Stopped';
        touch();
        return;
      }

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
      // ⚠️ FIX: generation check
      if (myGeneration == _sstpGeneration) {
        isSstpBusy = false;
      }
      await AppDataService.fixDataDirOwnership();
      touch();
    }
  }
}
