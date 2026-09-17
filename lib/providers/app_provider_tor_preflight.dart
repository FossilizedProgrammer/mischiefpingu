part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Tor Preflight — بررسی‌های قبل از شروع
///  (وجود باینری + آزاد بودن پورت‌ها)
///  (تفکیک شده از app_provider_tor.dart)
/// ═══════════════════════════════════════════════════════════════
extension AppProviderTorPreflight on AppProvider {
  /// چک وجود باینری Tor.
  /// true = موجوده، false = نیست (پیام خطا ست شده).
  Future<bool> checkTorBinary() async {
    const src = LogSource.tor;
    try {
      final binaryPath = await AppDataService.findTorBinary() ??
          await AppDataService.getTorBinaryPath();
      if (await File(binaryPath).exists()) return true;

      final msg =
          'Tor binary not found. Please click "Show more" and download it from "Core Updates".';
      processService.setBinaryMissingMessage(msg);
      processService.addLog(
        '✗ Tor binary missing: $binaryPath — download it from Core Updates',
        source: src,
      );
      torStatus = 'Tor: Binary missing';
      touch();
      return false;
    } catch (e) {
      processService.addLog('✗ Error checking Tor binary: $e', source: src);
      return false;
    }
  }

  /// چک آزاد بودن پورت‌های SOCKS و HTTP.
  /// true = هر دو آزاد، false = یکی اشغال (پیام خطا ست شده).
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
