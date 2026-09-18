part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Psiphon Preflight — بررسی‌های قبل از شروع
///  (وجود باینری + آزاد بودن پورت‌ها)
/// ═══════════════════════════════════════════════════════════════
extension AppProviderPsiphonPreflight on AppProvider {
  /// چک وجود باینری Psiphon بر اساس useSunAndLion.
  /// true = باینری موجوده، false = نیست (پیام خطا ست شده).
  Future<bool> checkPsiphonBinary() async {
    const src = LogSource.psiphon;
    try {
      final useSunAndLion = settings.effectiveUseSunAndLion;
      final binaryName = useSunAndLion
          ? 'psiphon-tunnel-core-sunandlion'
          : 'psiphon-tunnel-core';

      final found = await AppDataService.resolveBinaryPath(binaryName);
      if (found != null) {
        processService.addLog(
          '✓ Psiphon binary found: $found',
          source: src,
        );
        return true;
      }

      processService.addLog(
        '✗ Psiphon binary "$binaryName" not found. Searched paths:',
        source: src,
      );
      await AppDataService.logBinaryCandidates(
        binaryName,
        log: (line) => processService.addLog(line, source: src),
      );

      final msg = useSunAndLion
          ? 'SunAndLion Psiphon binary not found. Please place '
              '"psiphon-tunnel-core-sunandlion${AppDataService.exeExt}" '
              'in the data folder or in the app folder, or download it from '
              '"Core Updates".'
          : 'Psiphon binary not found. Please click "Show more" and '
              'download it from "Core Updates", or place '
              '"psiphon-tunnel-core${AppDataService.exeExt}" '
              'in the data folder.';
      processService.setBinaryMissingMessage(msg);
      touch();
      return false;
    } catch (e) {
      processService.addLog(
        '✗ Error checking Psiphon binary: $e',
        source: src,
      );
      return false;
    }
  }

  /// چک آزاد بودن پورت‌های SOCKS و HTTP.
  Future<bool> checkPsiphonPorts() async {
    const src = LogSource.psiphon;
    final socksPort = settings.socksPort;
    final httpPort = settings.httpPort;

    if (await ProcessService.isPortInUse(socksPort)) {
      final msg = 'Psiphon: SOCKS port $socksPort is already in use by '
          'another application. Cannot start.';
      processService.setPortConflictMessage(msg);
      processService.addLog(
        '✗ SOCKS port $socksPort is in use — Psiphon not started',
        source: src,
      );
      touch();
      return false;
    }

    if (await ProcessService.isPortInUse(httpPort)) {
      final msg = 'Psiphon: HTTP port $httpPort is already in use by '
          'another application. Cannot start.';
      processService.setPortConflictMessage(msg);
      processService.addLog(
        '✗ HTTP port $httpPort is in use — Psiphon not started',
        source: src,
      );
      touch();
      return false;
    }

    return true;
  }
}
