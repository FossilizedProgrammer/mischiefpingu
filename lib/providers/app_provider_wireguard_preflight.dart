part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  WireGuard Preflight — بررسی‌های قبل از start.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderWireGuardPreflight on AppProvider {
  Future<bool> _preflightWireGuardBinary(String src) async {
    try {
      final coreType = settings.wireGuardCoreType;
      final found = await WireGuardPaths.resolveBinary(coreType);
      if (found == null) {
        processService.addLog(
          '✗ ${WireGuardPaths.binaryName(coreType)} binary not found. Searched paths:',
          source: src,
        );
        await AppDataService.logBinaryCandidates(
          WireGuardPaths.binaryName(coreType),
          log: (line) => processService.addLog(line, source: src),
        );

        final msg =
            '${WireGuardPaths.binaryName(coreType)} binary not found. Please place '
            '"${WireGuardPaths.binaryName(coreType)}${AppDataService.exeExt}" in the data folder, '
            'or download it from "Core Updates".';
        processService.setBinaryMissingMessage(msg);
        wireGuardStatus = 'WireGuard: Binary missing';
        touch();
        return false;
      }
      processService.addLog(
        '✓ ${WireGuardPaths.binaryName(coreType)} binary found: $found',
        source: src,
      );
      return true;
    } catch (e) {
      processService.addLog(
        '✗ Error checking wireproxy binary: $e',
        source: src,
      );
      return false;
    }
  }

  Future<bool> _preflightWireGuardPort(String src) async {
    final port = settings.wireguardSocksPort;
    if (await ProcessService.isPortInUse(port)) {
      final msg = 'WireGuard: SOCKS port $port is already in use by another '
          'application. Cannot start.';
      processService.setPortConflictMessage(msg);
      processService.addLog(
        '✗ Port $port is in use — WireGuard not started',
        source: src,
      );
      wireGuardStatus = 'WireGuard: Port $port in use';
      touch();
      return false;
    }
    return true;
  }
}
