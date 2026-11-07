part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderFfvpnPreflight — چک باینری و پورت قبل از استارت ffvpn.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderFfvpnPreflight on AppProvider {
  /// مسیر باینری ffvpn را پیدا می‌کند؛ اگر نبود پیام می‌دهد و null برمی‌گرداند.
  Future<String?> _preflightFfvpnBinary(String src) async {
    final path = await AppDataService.resolveBinaryPath('ffvpn');
    if (path != null) return path;

    processService.addLog(
      '✗ ffvpn binary not found. Place "ffvpn${AppDataService.exeExt}" '
      'in the data folder.',
      source: src,
    );
    await AppDataService.logBinaryCandidates(
      'ffvpn',
      log: (m) => processService.addLog(m, source: src),
    );
    processService.setBinaryMissingMessage(
      'ffvpn${AppDataService.exeExt} binary not found. '
      'Place it in the data folder next to the other tunnel binaries.',
    );
    touch();
    return null;
  }

  /// پورت‌های SOCKS/HTTP ffvpn را چک می‌کند (HTTP با 0 غیرفعال است).
  Future<bool> _preflightFfvpnPorts(String src) async {
    final ports = <String, int>{
      'SOCKS': settings.ffvpnSocksPort,
      'HTTP': settings.ffvpnHttpPort,
    };
    for (final entry in ports.entries) {
      if (entry.value <= 0) continue;
      if (await ProcessService.isPortInUse(entry.value)) {
        processService.addLog(
          '✗ Firefox VPN ${entry.key} port ${entry.value} is already in use',
          source: src,
        );
        processService.setPortConflictMessage(
          'Firefox VPN: ${entry.key} port ${entry.value} is already in use '
          'by another program. Pick a different port in the Firefox VPN '
          'settings.',
        );
        touch();
        return false;
      }
    }
    return true;
  }
}
