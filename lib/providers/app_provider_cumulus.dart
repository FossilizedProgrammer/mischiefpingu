part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderCumulus — start/stop هستهٔ CumulusVPN.
///
///  Cumulus خودش discovery و reconnect را انجام می‌دهد؛ این لایه فقط
///  تنظیمات را به پروسه می‌دهد و وضعیت connected/stopped را همگام نگه
///  می‌دارد.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderCumulus on AppProvider {
  Future<void> connectCumulus() async {
    final isCurrentlyActive = processService.isCumulusRunning || isCumulusBusy;

    if (isCurrentlyActive) {
      await stopCumulusByUser();
      return;
    }

    await _startCumulusInternal();
  }

  Future<void> stopCumulusByUser() async {
    const src = LogSource.cumulus;

    userStoppedCumulus = true;
    nextCumulusGeneration();

    try {
      await processService.stopCumulus();
    } catch (e) {
      processService.addLog('⚠ Cumulus stop error: $e', source: src);
    }

    isCumulusBusy = false;
    cumulusStatus = 'Cumulus: Stopped';

    await AppDataService.fixDataDirOwnership();
    touch();
  }

  Future<void> _startCumulusInternal() async {
    const src = LogSource.cumulus;

    if (isCumulusBusy) {
      processService.addLog(
        '→ Cumulus start ignored — already starting',
        source: src,
      );
      return;
    }

    if (processService.isCumulusRunning) {
      processService.addLog(
        '→ Cumulus is already running — ignoring redundant start',
        source: src,
      );
      return;
    }

    final binaryPath = await _preflightCumulusBinary(src);
    if (binaryPath == null) return;

    if (!await _preflightCumulus(src)) return;

    final configHome = await CumulusPaths.configHome();

    userStoppedCumulus = false;
    isCumulusBusy = true;
    cumulusStatus = 'Cumulus: Connecting…';
    touch();

    final myGeneration = nextCumulusGeneration();

    try {
      await saveSettings();

      if (userStoppedCumulus) {
        processService.addLog(
          'Cumulus start cancelled by user (after saveSettings)',
          source: src,
        );
        return;
      }

      final ok = await processService.startCumulus(
        binaryPath: binaryPath,
        configHome: configHome,
        port: settings.cumulusPort,
        httpPort: settings.cumulusHttpPort,
        country: settings.cumulusCountry,
        transport: settings.cumulusTransport,
        multihop: settings.cumulusMultihop,
        entry: settings.cumulusEntry,
        exit: settings.cumulusExit,
        killSwitch: settings.cumulusKillSwitch,
        autoReconnect: settings.cumulusAutoReconnect,
      );

      if (userStoppedCumulus) {
        processService.addLog(
          'Cumulus start cancelled by user (after process start)',
          source: src,
        );
        try {
          await processService.stopCumulus();
        } catch (_) {}
        cumulusStatus = 'Cumulus: Stopped';
        touch();
        return;
      }

      cumulusStatus = ok ? 'Cumulus: Connecting…' : 'Cumulus: Failed to start';

      if (myGeneration != _cumulusGeneration) {
        processService.addLog(
          '→ Cumulus start completed but a newer start superseded it',
          source: src,
        );
      }
    } catch (e) {
      processService.addLog('✗ connectCumulus error: $e', source: src);
      cumulusStatus = 'Cumulus: Error';
    } finally {
      if (myGeneration == _cumulusGeneration) {
        isCumulusBusy = false;
      }
      await AppDataService.fixDataDirOwnership();
      touch();
    }
  }
}
