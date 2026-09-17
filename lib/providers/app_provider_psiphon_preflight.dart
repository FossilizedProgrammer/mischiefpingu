part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Psiphon Preflight — بررسی‌های قبل از شروع
///  (وجود باینری + آزاد بودن پورت‌ها)
///  (تفکیک شده از app_provider_psiphon.dart)
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
      final binaryPath = await AppDataService.getBinaryPath(binaryName);

      if (await File(binaryPath).exists()) return true;

      final msg = useSunAndLion
          ? 'SunAndLion Psiphon binary not found. Please place '
              '"psiphon-tunnel-core-sunandlion" in the app folder or data '
              'folder manually.'
          : 'Psiphon binary not found. Please click "Show more" and '
              'download it from "Core Updates".';
      processService.setBinaryMissingMessage(msg);
      processService.addLog(
        '✗ Psiphon binary missing: $binaryPath',
        source: src,
      );
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
  /// true = هر دو آزاد هستن، false = یکی اشغاله (پیام خطا ست شده).
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
