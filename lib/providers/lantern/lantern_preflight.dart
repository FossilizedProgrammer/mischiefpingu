part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderLanternPreflight — چک باینری و پورت قبل از استارت لنترن.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderLanternPreflight on AppProvider {
  /// مسیر باینری لنترن را پیدا می‌کند؛ اگر نبود پیام می‌دهد و null برمی‌گرداند.
  Future<String?> _preflightLanternBinary(String src) async {
    final path = await AppDataService.resolveBinaryPath('lantern');
    if (path != null) return path;

    processService.addLog(
      '✗ lantern binary not found. Place "lantern${AppDataService.exeExt}" '
      'in the data folder.',
      source: src,
    );
    await AppDataService.logBinaryCandidates(
      'lantern',
      log: (m) => processService.addLog(m, source: src),
    );
    processService.setBinaryMissingMessage(
      'lantern${AppDataService.exeExt} binary not found. '
      'Place it in the data folder next to the other tunnel binaries.',
    );
    touch();
    return null;
  }

  /// پورت‌های SOCKS/HTTP لنترن را چک می‌کند (HTTP با 0 غیرفعال است).
  Future<bool> _preflightLanternPorts(String src) async {
    final ports = <String, int>{
      'SOCKS': settings.lanternSocksPort,
      'HTTP': settings.lanternHttpPort,
    };
    for (final entry in ports.entries) {
      if (entry.value <= 0) continue;
      if (await ProcessService.isPortInUse(entry.value)) {
        processService.addLog(
          '✗ Lantern ${entry.key} port ${entry.value} is already in use',
          source: src,
        );
        processService.setPortConflictMessage(
          'Lantern: ${entry.key} port ${entry.value} is already in use '
          'by another program. Pick a different port in the Lantern '
          'settings.',
        );
        touch();
        return false;
      }
    }
    return true;
  }
}
