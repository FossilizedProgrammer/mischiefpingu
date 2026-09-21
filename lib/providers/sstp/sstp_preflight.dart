part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  SSTP preflight checks — باینری + پورت + server.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderSstpPreflight on AppProvider {
  Future<bool> checkSstpBinaryAndServer() async {
    const src = LogSource.sstp;

    try {
      final binaryPath = await AppDataService.getSstpBinaryPathForExecution();
      if (!await File(binaryPath).exists()) {
        processService.addLog(
          '✗ SSTP binary not found. Searched paths:',
          source: src,
        );
        await AppDataService.logBinaryCandidates(
          'sstp-proxy',
          log: (line) => processService.addLog(line, source: src),
        );

        final msg =
            'SSTP binary not found. Place '
            '"sstp-proxy${AppDataService.exeExt}" '
            'in the data folder, next to the app binary, or inside the '
            '"${AppDataService.osFolder}" folder. You can also download it '
            'from "Core Updates".';
        processService.setBinaryMissingMessage(msg);
        sstpStatus = 'SSTP: Binary missing';
        touch();
        return false;
      }

      processService.addLog('✓ SSTP binary found: $binaryPath', source: src);
    } catch (e) {
      processService.addLog('✗ Error checking SSTP binary: $e', source: src);
    }

    if (settings.sstpServer.trim().isEmpty) {
      final msg = 'SSTP: Server address is empty. Please configure it.';
      processService.setPortConflictMessage(msg);
      processService.addLog('✗ SSTP server not configured', source: src);
      sstpStatus = 'SSTP: Server not set';
      touch();
      return false;
    }

    return true;
  }

  Future<bool> checkSstpPorts() async {
    const src = LogSource.sstp;
    final socksPort = settings.sstpSocksPort;
    final httpPort = settings.sstpHttpPort;

    if (await ProcessService.isPortInUse(socksPort)) {
      final msg =
          'SSTP: SOCKS port $socksPort is already in use by another application. Cannot start.';
      processService.setPortConflictMessage(msg);
      processService.addLog(
        '✗ SOCKS port $socksPort is in use — SSTP not started',
        source: src,
      );
      sstpStatus = 'SSTP: Port $socksPort in use';
      touch();
      return false;
    }
    if (await ProcessService.isPortInUse(httpPort)) {
      final msg =
          'SSTP: HTTP port $httpPort is already in use by another application. Cannot start.';
      processService.setPortConflictMessage(msg);
      processService.addLog(
        '✗ HTTP port $httpPort is in use — SSTP not started',
        source: src,
      );
      sstpStatus = 'SSTP: Port $httpPort in use';
      touch();
      return false;
    }
    return true;
  }
}
