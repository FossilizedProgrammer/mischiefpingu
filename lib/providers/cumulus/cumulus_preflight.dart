part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderCumulusPreflight — باینری و پورت قبل از استارت Cumulus.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderCumulusPreflight on AppProvider {
  Future<String?> _preflightCumulusBinary(String src) async {
    final path = await CumulusPaths.resolveBinary();
    if (path != null) return path;

    processService.addLog(
      '✗ cumulusvpn binary not found. Place '
      '"cumulusvpn${AppDataService.exeExt}" in the data folder.',
      source: src,
    );
    await AppDataService.logBinaryCandidates(
      CumulusPaths.binaryName,
      log: (m) => processService.addLog(m, source: src),
    );
    processService.setBinaryMissingMessage(
      'cumulusvpn${AppDataService.exeExt} binary not found. Place it in the '
      'data folder next to the other tunnel binaries.',
    );
    touch();
    return null;
  }

  Future<bool> _preflightCumulus(String src) async {
    if (settings.cumulusPort == settings.cumulusHttpPort) {
      processService.addLog(
        '✗ Cumulus SOCKS5 and HTTP ports are both '
        '${settings.cumulusPort}',
        source: src,
      );
      processService.setPortConflictMessage(
        'Cumulus: the SOCKS5 and HTTP ports must be different. Change one of '
        'them in the Cumulus settings.',
      );
      touch();
      return false;
    }

    if (await ProcessService.isPortInUse(settings.cumulusPort)) {
      processService.addLog(
        '✗ Cumulus SOCKS5 port ${settings.cumulusPort} is already in use',
        source: src,
      );
      processService.setPortConflictMessage(
        'Cumulus: SOCKS5 port ${settings.cumulusPort} is already in use by '
        'another program. Pick a different port in the Cumulus settings.',
      );
      touch();
      return false;
    }

    if (await ProcessService.isPortInUse(settings.cumulusHttpPort)) {
      processService.addLog(
        '✗ Cumulus HTTP port ${settings.cumulusHttpPort} is already in use',
        source: src,
      );
      processService.setPortConflictMessage(
        'Cumulus: HTTP port ${settings.cumulusHttpPort} is already in use by '
        'another program. Pick a different port in the Cumulus settings.',
      );
      touch();
      return false;
    }

    if (settings.cumulusMultihop &&
        (settings.cumulusEntry.trim().isEmpty ||
            settings.cumulusExit.trim().isEmpty)) {
      processService.addLog(
        '✗ Cumulus multi-hop needs both an entry and an exit location',
        source: src,
      );
      processService.setPortConflictMessage(
        'Cumulus: fill in both the entry and exit locations for a multi-hop '
        'route, or turn multi-hop off.',
      );
      touch();
      return false;
    }

    return true;
  }
}
