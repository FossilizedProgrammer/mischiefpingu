part of 'app_provider.dart';

extension AppProviderAether on AppProvider {
  Future<void> connectAether({bool fromAutoReconnect = false}) async {
    const src = LogSource.aether;

    if (processService.isAetherRunning || isAutoTesting) {
      userStoppedAether = true;
      _aetherTestService.requestCancel();
      _reconnectManager.cancelAetherTimer();
      await processService.stopAether();
      aetherStatus = 'Aether: Stopped';
      await AppDataService.fixDataDirOwnership();
      touch();
      return;
    }

    if (fromAutoReconnect && userStoppedAether) {
      processService.addLog('→ Aether auto-reconnect skipped (stopped by user)',
          source: src);
      return;
    }

    try {
      final binaryPath = await AppDataService.getBinaryPath('aether');
      if (!await File(binaryPath).exists()) {
        final msg =
            'Aether binary not found. Please click "Show more" and download it from "Core Updates".';
        processService.setBinaryMissingMessage(msg);
        processService.addLog(
          '✗ Aether binary missing: $binaryPath — download it from Core Updates',
          source: src,
        );
        aetherStatus = 'Aether: Binary missing';
        touch();
        return;
      }

      final dataDir = await AppDataService.getDataDir();
      final ptDir = Directory('$dataDir/pt');
      if (!await ptDir.exists()) {
        final msg =
            'Aether `pt` directory not found in data folder. Please click "Show more" and download Aether again from "Core Updates".';
        processService.setBinaryMissingMessage(msg);
        processService.addLog(
          '✗ Aether `pt` directory missing: ${ptDir.path} — download Aether from Core Updates',
          source: src,
        );
        aetherStatus = 'Aether: `pt` directory missing';
        touch();
        return;
      }
    } catch (e) {
      processService.addLog('✗ Error checking Aether binary: $e', source: src);
    }

    final aetherPort = settings.aetherLocalPort;
    if (await ProcessService.isPortInUse(aetherPort)) {
      final msg =
          'Aether: Port $aetherPort is already in use by another application. Cannot start.';
      processService.setPortConflictMessage(msg);
      processService.addLog('✗ Port $aetherPort is in use — Aether not started',
          source: src);
      aetherStatus = 'Aether: Port $aetherPort in use';
      touch();
      return;
    }

    userStoppedAether = false;
    touch();

    try {
      aetherStatus = settings.aetherProtocol == 'auto'
          ? 'Aether: Auto-testing protocols…'
          : 'Aether: Starting…';
      touch();

      isAutoTesting = true;
      final ok = await _aetherTestService.ensureHealthy(showUi: true);
      isAutoTesting = false;

      if (ok) {
        aetherStatus = 'Aether: Healthy';
      } else if (processService.isAetherRunning) {
        aetherStatus = 'Aether: Running (unverified)';
      } else {
        aetherStatus = 'Aether: Auto-test failed';
      }
    } catch (e) {
      processService.addLog('✗ connectAether error: $e', source: src);
      aetherStatus = 'Aether: Error';
    }

    await AppDataService.fixDataDirOwnership();
    touch();
  }
}
