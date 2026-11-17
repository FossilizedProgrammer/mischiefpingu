part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderFluxcorePreflight — باینری و پورت قبل از استارت Fluxcore.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderFluxcorePreflight on AppProvider {
  Future<String?> _preflightFluxcoreBinary(String src) async {
    final path = await FluxcorePaths.resolveBinary();
    if (path != null) return path;

    processService.addLog(
      '✗ fluxcore binary not found. Place '
      '"fluxcore${AppDataService.exeExt}" in the data folder.',
      source: src,
    );
    await AppDataService.logBinaryCandidates(
      FluxcorePaths.binaryName,
      log: (m) => processService.addLog(m, source: src),
    );
    processService.setBinaryMissingMessage(
      'fluxcore${AppDataService.exeExt} binary not found. Place it in the '
      'data folder next to the other tunnel binaries.',
    );
    touch();
    return null;
  }

  Future<bool> _preflightFluxcore(String src) async {
    if (settings.fluxcorePort == settings.fluxcoreHttpPort) {
      processService.addLog(
        '✗ Fluxcore SOCKS5 and HTTP ports are both '
        '${settings.fluxcorePort}',
        source: src,
      );
      processService.setPortConflictMessage(
        'Fluxcore: the SOCKS5 and HTTP ports must be different. Change one of '
        'them in the Fluxcore settings.',
      );
      touch();
      return false;
    }

    if (await ProcessService.isPortInUse(settings.fluxcorePort)) {
      processService.addLog(
        '✗ Fluxcore SOCKS5 port ${settings.fluxcorePort} is already in use',
        source: src,
      );
      processService.setPortConflictMessage(
        'Fluxcore: SOCKS5 port ${settings.fluxcorePort} is already in use by '
        'another program. Pick a different port in the Fluxcore settings.',
      );
      touch();
      return false;
    }

    if (await ProcessService.isPortInUse(settings.fluxcoreHttpPort)) {
      processService.addLog(
        '✗ Fluxcore HTTP port ${settings.fluxcoreHttpPort} is already in use',
        source: src,
      );
      processService.setPortConflictMessage(
        'Fluxcore: HTTP port ${settings.fluxcoreHttpPort} is already in use by '
        'another program. Pick a different port in the Fluxcore settings.',
      );
      touch();
      return false;
    }

    if (settings.fluxcoreMultihop &&
        (settings.fluxcoreEntry.trim().isEmpty ||
            settings.fluxcoreExit.trim().isEmpty)) {
      processService.addLog(
        '✗ Fluxcore multi-hop needs both an entry and an exit location',
        source: src,
      );
      processService.setPortConflictMessage(
        'Fluxcore: fill in both the entry and exit locations for a multi-hop '
        'route, or turn multi-hop off.',
      );
      touch();
      return false;
    }

    return true;
  }
}
