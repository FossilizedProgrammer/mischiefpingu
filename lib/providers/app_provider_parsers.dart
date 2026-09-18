part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Parsers: استخراج اطلاعات از لاگ‌های پروسه (build rev، fronting)
///  به صورت extension پیاده‌سازی شده تا از حلقهٔ ارث‌بری جلوگیری شود.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderParsers on AppProvider {
  void tryParseBuildRev(String line) {
    final rev = LogLineParsers.parseBuildRev(line);
    if (rev == null) return;
    if (rev == settings.psiphonBuildRev) return;
    settings.psiphonBuildRev = rev;
    saveSettings();
    processService.addLog(
      '→ Psiphon core build rev: $rev',
      source: LogSource.psiphon,
    );
  }

  void tryParseFoundFronting(String line) {
    if (!settings.saveFoundIpsAndSni || !settings.isFronted) return;
    final found = LogLineParsers.parseFoundFronting(line);
    if (found == null) return;
    final foundIp = found.ip;
    final foundTlsSni = found.sni;
    var changed = false;

    if (!ipList.contains(foundIp)) {
      ipList = [...ipList, foundIp];
      saveIpList(ipList);
      changed = true;
    }
    if (!tlsSniList.contains(foundTlsSni)) {
      tlsSniList = [...tlsSniList, foundTlsSni];
      saveTlsSniList(tlsSniList);
      changed = true;
    }
    if (settings.ip != foundIp || settings.tlsSni != foundTlsSni) {
      settings.ip = foundIp;
      settings.tlsSni = foundTlsSni;
      saveSettings();
      changed = true;
    }
    if (changed) {
      processService.addLog(
        '★ Auto-saved found fronting → $foundIp / $foundTlsSni',
        source: LogSource.psiphon,
      );
    }
  }
}
