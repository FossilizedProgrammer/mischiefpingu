part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderFluxcore — start/stop هستهٔ Fluxcore.
///
///  Fluxcore خودش discovery و reconnect را انجام می‌دهد؛ این لایه فقط
///  تنظیمات را به پروسه می‌دهد و وضعیت connected/stopped را همگام نگه
///  می‌دارد.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderFluxcore on AppProvider {
  Future<void> connectFluxcore() async {
    final isCurrentlyActive = processService.isFluxcoreRunning || isFluxcoreBusy;

    if (isCurrentlyActive) {
      await stopFluxcoreByUser();
      return;
    }

    await _startFluxcoreInternal();
  }

  Future<void> stopFluxcoreByUser() async {
    const src = LogSource.fluxcore;

    userStoppedFluxcore = true;
    nextFluxcoreGeneration();

    try {
      await processService.stopFluxcore();
    } catch (e) {
      processService.addLog('⚠ Fluxcore stop error: $e', source: src);
    }

    isFluxcoreBusy = false;
    fluxcoreStatus = 'Fluxcore: Stopped';

    await AppDataService.fixDataDirOwnership();
    touch();
  }

  Future<void> _startFluxcoreInternal() async {
    const src = LogSource.fluxcore;

    if (isFluxcoreBusy) {
      processService.addLog(
        '→ Fluxcore start ignored — already starting',
        source: src,
      );
      return;
    }

    if (processService.isFluxcoreRunning) {
      processService.addLog(
        '→ Fluxcore is already running — ignoring redundant start',
        source: src,
      );
      return;
    }

    final binaryPath = await _preflightFluxcoreBinary(src);
    if (binaryPath == null) return;

    if (!await _preflightFluxcore(src)) return;

    final configHome = await FluxcorePaths.configHome();

    userStoppedFluxcore = false;
    isFluxcoreBusy = true;
    fluxcoreStatus = 'Fluxcore: Connecting…';
    touch();

    final myGeneration = nextFluxcoreGeneration();

    try {
      await saveSettings();

      if (userStoppedFluxcore) {
        processService.addLog(
          'Fluxcore start cancelled by user (after saveSettings)',
          source: src,
        );
        return;
      }

      final ok = await processService.startFluxcore(
        binaryPath: binaryPath,
        configHome: configHome,
        port: settings.fluxcorePort,
        httpPort: settings.fluxcoreHttpPort,
        country: settings.fluxcoreCountry,
        transport: settings.fluxcoreTransport,
        multihop: settings.fluxcoreMultihop,
        entry: settings.fluxcoreEntry,
        exit: settings.fluxcoreExit,
        killSwitch: settings.fluxcoreKillSwitch,
        autoReconnect: settings.fluxcoreAutoReconnect,
      );

      if (userStoppedFluxcore) {
        processService.addLog(
          'Fluxcore start cancelled by user (after process start)',
          source: src,
        );
        try {
          await processService.stopFluxcore();
        } catch (_) {}
        fluxcoreStatus = 'Fluxcore: Stopped';
        touch();
        return;
      }

      fluxcoreStatus = ok ? 'Fluxcore: Connecting…' : 'Fluxcore: Failed to start';

      if (myGeneration != _fluxcoreGeneration) {
        processService.addLog(
          '→ Fluxcore start completed but a newer start superseded it',
          source: src,
        );
      }
    } catch (e) {
      processService.addLog('✗ connectFluxcore error: $e', source: src);
      fluxcoreStatus = 'Fluxcore: Error';
    } finally {
      if (myGeneration == _fluxcoreGeneration) {
        isFluxcoreBusy = false;
      }
      await AppDataService.fixDataDirOwnership();
      touch();
    }
  }
}
