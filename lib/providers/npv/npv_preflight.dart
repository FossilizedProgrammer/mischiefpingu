part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderNpvPreflight — باینری، فایل کانفیگ و پورت‌ها قبل از استارت npv.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderNpvPreflight on AppProvider {
  Future<String?> _preflightNpvBinary(String src) async {
    final path = await NpvPaths.resolveBinary();
    if (path != null) return path;

    processService.addLog(
      '✗ npv binary not found. Place "npv${AppDataService.exeExt}" '
      'in the data folder.',
      source: src,
    );
    await AppDataService.logBinaryCandidates(
      NpvPaths.binaryName,
      log: (m) => processService.addLog(m, source: src),
    );
    processService.setBinaryMissingMessage(
      'npv${AppDataService.exeExt} binary not found. Place it in the data '
      'folder next to the other tunnel binaries.',
    );
    touch();
    return null;
  }

  /// مسیر فایل کانفیگ را قطعی می‌کند. فایلی نیست؟ اتصال شروع نمی‌شود:
  /// نمونهٔ پیش‌فرضی داخل برنامه نیست که بی‌سروصدا جای کاربر باز شود.
  Future<String?> _preflightNpvConfig(String src) async {
    try {
      final path = await NpvPaths.resolveConfigPath(settings.npvConfigName);
      if (path == null || await File(path).length() == 0) {
        processService.addLog(
          '✗ NPV has no config file — pick an .npvs file in the NPV settings',
          source: src,
        );
        processService.setPortConflictMessage(
          'NPV needs a config file (.npvs). Open the NPV settings and choose '
          'one first.',
        );
        touch();
        return null;
      }
      processService.addLog('→ NPV config file: $path', source: src);
      return path;
    } catch (e) {
      processService.addLog('✗ NPV config lookup failed: $e', source: src);
      touch();
      return null;
    }
  }

  /// پورت‌های SOCKS/HTTP npv را چک می‌کند (HTTP با 0 غیرفعال است).
  Future<bool> _preflightNpvPorts(String src) async {
    final ports = <String, int>{
      'SOCKS': settings.npvSocksPort,
      'HTTP': settings.npvHttpPort,
    };
    for (final entry in ports.entries) {
      if (entry.value <= 0) continue;
      if (await ProcessService.isPortInUse(entry.value)) {
        processService.addLog(
          '✗ NPV ${entry.key} port ${entry.value} is already in use',
          source: src,
        );
        processService.setPortConflictMessage(
          'NPV: ${entry.key} port ${entry.value} is already in use by '
          'another program. Pick a different port in the NPV settings.',
        );
        touch();
        return false;
      }
    }
    return true;
  }
}
