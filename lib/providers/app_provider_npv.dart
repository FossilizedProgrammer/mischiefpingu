part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderNpv — entry point + start/stop تونل NPV Tunnel (npv).
///
///  npv پرچمی برای عبور از یک پروکسی بالادستی ندارد، برخلاف ffvpn/Lantern
///  پس زنجیرهٔ آپ‌استریمِ خودش را ندارد؛ ولی SOCKS محلی‌اش را می‌توان به‌عنوان
///  هاپ آپ‌استریم برای بقیهٔ تونل‌ها انتخاب کرد.
///
///  ⚠️ preflightها در `npv/npv_preflight.dart` جدا شده‌اند.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderNpv on AppProvider {
  /// connectNpv — entry point عمومی (toggle connect/stop).
  Future<void> connectNpv() async {
    final isCurrentlyActive = processService.isNpvRunning || isNpvBusy;

    if (isCurrentlyActive) {
      await stopNpvByUser();
      return;
    }

    await _startNpvInternal();
  }

  Future<void> stopNpvByUser() async {
    const src = LogSource.npv;

    userStoppedNpv = true;
    nextNpvGeneration();

    try {
      await processService.stopNpv();
    } catch (e) {
      processService.addLog('⚠ NPV stop error: $e', source: src);
    }

    isNpvBusy = false;
    npvStatus = 'NPV: Stopped';

    await AppDataService.fixDataDirOwnership();
    touch();
  }

  Future<void> _startNpvInternal() async {
    const src = LogSource.npv;

    if (isNpvBusy) {
      processService.addLog(
        '→ NPV start ignored — already starting',
        source: src,
      );
      return;
    }

    if (processService.isNpvRunning) {
      processService.addLog(
        '→ NPV is already running — ignoring redundant start',
        source: src,
      );
      return;
    }

    final binaryPath = await _preflightNpvBinary(src);
    if (binaryPath == null) return;

    final configPath = await _preflightNpvConfig(src);
    if (configPath == null) return;

    if (!await _preflightNpvPorts(src)) return;

    userStoppedNpv = false;
    isNpvBusy = true;
    npvStatus = 'NPV: Connecting…';
    touch();

    final myGeneration = nextNpvGeneration();

    try {
      await saveSettings();

      if (userStoppedNpv) {
        processService.addLog(
          'NPV start cancelled by user (after saveSettings)',
          source: src,
        );
        return;
      }

      final ok = await processService.startNpv(
        binaryPath: binaryPath,
        configPath: configPath,
        socksPort: settings.npvSocksPort,
        httpPort: settings.npvHttpPort,
        probeTimeoutSeconds: settings.npvProbeTimeout,
        probeJobs: settings.npvProbeJobs,
        probeUrl: settings.npvProbeUrl.isEmpty ? null : settings.npvProbeUrl,
        pinnedIndex:
            settings.npvPinnedIndex.isEmpty ? null : settings.npvPinnedIndex,
        shareOnLan: settings.npvShareLan,
      );

      if (userStoppedNpv) {
        processService.addLog(
          'NPV start cancelled by user (after process start)',
          source: src,
        );
        try {
          await processService.stopNpv();
        } catch (_) {}
        npvStatus = 'NPV: Stopped';
        touch();
        return;
      }

      npvStatus = ok ? 'NPV: Connecting…' : 'NPV: Failed to start';

      if (myGeneration != _npvGeneration) {
        processService.addLog(
          '→ NPV start completed but a newer start superseded it',
          source: src,
        );
      }
    } catch (e) {
      processService.addLog('✗ connectNpv error: $e', source: src);
      npvStatus = 'NPV: Error';
    } finally {
      if (myGeneration == _npvGeneration) {
        isNpvBusy = false;
      }
      await AppDataService.fixDataDirOwnership();
      touch();
    }
  }
}
