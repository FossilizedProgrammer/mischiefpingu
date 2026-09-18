part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Tor Preflight — بررسی‌های قبل از شروع
/// ═══════════════════════════════════════════════════════════════
extension AppProviderTorPreflight on AppProvider {
  /// چک وجود باینری Tor.
  Future<bool> checkTorBinary() async {
    const src = LogSource.tor;
    try {
      final binaryPath = await AppDataService.findTorBinary();

      if (binaryPath != null && await File(binaryPath).exists()) {
        processService.addLog(
          '✓ Tor binary found: $binaryPath',
          source: src,
        );
        return true;
      }

      processService.addLog(
        '✗ Tor binary not found. Searched paths:',
        source: src,
      );
      await AppDataService.logTorBinaryCandidates(
        log: (line) => processService.addLog(line, source: src),
      );

      final msg =
          'Tor binary not found. Please click "Show more" and download it from '
          '"Core Updates", or place "tor${AppDataService.exeExt}" in one of the '
          'searched paths (see Log).';
      processService.setBinaryMissingMessage(msg);

      try {
        final fallback = await AppDataService.getTorBinaryPath();
        processService.addLog(
          '→ Expected default location: $fallback',
          source: src,
        );
      } catch (_) {}

      torStatus = 'Tor: Binary missing';
      touch();
      return false;
    } catch (e) {
      processService.addLog('✗ Error checking Tor binary: $e', source: src);
      return false;
    }
  }

  /// چک آزاد بودن پورت‌های SOCKS و HTTP.
  Future<bool> checkTorPorts() async {
    const src = LogSource.tor;
    final socksPort = settings.torSocksPort;
    final httpPort = settings.torHttpPort;

    if (await ProcessService.isPortInUse(socksPort)) {
      final msg =
          'Tor: SOCKS port $socksPort is already in use by another application. Cannot start.';
      processService.setPortConflictMessage(msg);
      processService.addLog(
        '✗ SOCKS port $socksPort is in use — Tor not started',
        source: src,
      );
      torStatus = 'Tor: Port $socksPort in use';
      touch();
      return false;
    }

    if (await ProcessService.isPortInUse(httpPort)) {
      final msg =
          'Tor: HTTP port $httpPort is already in use by another application. Cannot start.';
      processService.setPortConflictMessage(msg);
      processService.addLog(
        '✗ HTTP port $httpPort is in use — Tor not started',
        source: src,
      );
      torStatus = 'Tor: Port $httpPort in use';
      touch();
      return false;
    }

    return true;
  }
}
