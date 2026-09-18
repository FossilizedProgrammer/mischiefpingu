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
      final found = await AppDataService.resolveBinaryPath('aether');
      if (found == null) {
        processService.addLog(
          '✗ Aether binary not found. Searched paths:',
          source: src,
        );
        await AppDataService.logBinaryCandidates(
          'aether',
          log: (line) => processService.addLog(line, source: src),
        );

        final msg =
            'Aether binary not found. Please click "Show more" and download '
            'it from "Core Updates", or place "aether${AppDataService.exeExt}" '
            'in the data folder.';
        processService.setBinaryMissingMessage(msg);
        aetherStatus = 'Aether: Binary missing';
        touch();
        return;
      }

      processService.addLog(
        '✓ Aether binary found: $found',
        source: src,
      );
    } catch (e) {
      processService.addLog('✗ Error checking Aether binary: $e', source: src);
    }

    try {
      final ptDir = await AppDataService.findAetherPtDir();
      if (ptDir == null) {
        processService.addLog(
          '✗ Aether `pt` directory not found. Searched paths:',
          source: src,
        );
        for (final c in await AppDataService.aetherPtCandidates()) {
          final exists = await Directory(c).exists();
          processService.addLog(
            '   ${exists ? "✓" : "✗"} $c',
            source: src,
          );
        }

        final msg =
            'Aether `pt` directory not found. Please click "Show more" and '
            'download Aether again from "Core Updates".';
        processService.setBinaryMissingMessage(msg);
        aetherStatus = 'Aether: `pt` directory missing';
        touch();
        return;
      }

      processService.addLog(
        '✓ Aether `pt` directory found: $ptDir',
        source: src,
      );
    } catch (e) {
      processService.addLog(
        '✗ Error checking Aether `pt` directory: $e',
        source: src,
      );
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
