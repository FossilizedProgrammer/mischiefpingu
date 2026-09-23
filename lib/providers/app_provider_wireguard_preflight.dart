part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  WireGuard Preflight.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderWireGuardPreflight on AppProvider {
  Future<bool> _preflightWireGuardBinary(String src) async {
    try {
      final found = await WireGuardPaths.resolveBinary();
      if (found == null) {
        processService.addLog(
          '✗ wireproxy binary not found. Searched paths:',
          source: src,
        );
        await AppDataService.logBinaryCandidates(
          'wireproxy',
          log: (line) => processService.addLog(line, source: src),
        );

        final msg = 'wireproxy binary not found. Please place '
            '"wireproxy${AppDataService.exeExt}" in the data folder, '
            'or download it from "Core Updates".';
        processService.setBinaryMissingMessage(msg);
        wireGuardStatus = 'WireGuard: Binary missing';
        touch();
        return false;
      }
      processService.addLog('✓ wireproxy binary found: $found', source: src);
      return true;
    } catch (e) {
      processService.addLog(
        '✗ Error checking wireproxy binary: $e',
        source: src,
      );
      return false;
    }
  }

  Future<bool> _preflightWireGuardConfig(String src) async {
    final raw = settings.wireguardConfigRaw.trim();
    if (raw.isEmpty) {
      final msg = 'WireGuard config is empty. Please paste a WireGuard config '
          'or URI in the WireGuard settings.';
      processService.setPortConflictMessage(msg);
      processService.addLog('✗ WireGuard config is empty', source: src);
      wireGuardStatus = 'WireGuard: Config empty';
      touch();
      return false;
    }

    final parsed = WireGuardConfigParser.parse(raw);
    if (parsed == null || !parsed.isValid) {
      final msg = 'WireGuard config is invalid. Please check PrivateKey, '
          'PublicKey, and Endpoint.';
      processService.setPortConflictMessage(msg);
      processService.addLog(
        '✗ WireGuard config is invalid',
        source: src,
      );
      wireGuardStatus = 'WireGuard: Invalid config';
      touch();
      return false;
    }
    return true;
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
