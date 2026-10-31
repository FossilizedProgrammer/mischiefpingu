part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Aether Preflight — بررسی‌های قبل از start.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderAetherPreflight on AppProvider {
  Future<bool> _preflightAetherBinary(String src) async {
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
            'it from "Core Updates", or place '
            '"aether${AppDataService.exeExt}" in the data folder.';
        processService.setBinaryMissingMessage(msg);
        aetherStatus = 'Aether: Binary missing';
        touch();
        return false;
      }
      processService.addLog('✓ Aether binary found: $found', source: src);
      return true;
    } catch (e) {
      processService.addLog('✗ Error checking Aether binary: $e', source: src);
      return false;
    }
  }

  Future<bool> _preflightAetherPtDir(String src) async {
    try {
      final ptDir = await AppDataService.findAetherPtDir();
      if (ptDir == null) {
        processService.addLog(
          '✗ Aether `pt` directory not found. Searched paths:',
          source: src,
        );
        for (final c in await AppDataService.aetherPtCandidates()) {
          final exists = await Directory(c).exists();
          processService.addLog('   ${exists ? "✓" : "✗"} $c', source: src);
        }

        final msg =
            'Aether `pt` directory not found. Please click "Show more" and '
            'download Aether again from "Core Updates".';
        processService.setBinaryMissingMessage(msg);
        aetherStatus = 'Aether: `pt` directory missing';
        touch();
        return false;
      }
      processService.addLog(
        '✓ Aether `pt` directory found: $ptDir',
        source: src,
      );
      return true;
    } catch (e) {
      processService.addLog(
        '✗ Error checking Aether `pt` directory: $e',
        source: src,
      );
      return false;
    }
  }

  Future<bool> _preflightAetherPort(String src) async {
    final aetherPort = settings.aetherLocalPort;
    if (await ProcessService.isPortInUse(aetherPort)) {
      final msg =
          'Aether: Port $aetherPort is already in use by another application. Cannot start.';
      processService.setPortConflictMessage(msg);
      processService.addLog(
        '✗ Port $aetherPort is in use — Aether not started',
        source: src,
      );
      aetherStatus = 'Aether: Port $aetherPort in use';
      touch();
      return false;
    }
    return true;
  }
}
