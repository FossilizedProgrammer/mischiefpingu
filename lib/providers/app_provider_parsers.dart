part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Parsers: استخراج اطلاعات از لاگ‌های پروسه (build rev، fronting،
///  Aether real endpoint)
///
///  ⚠️ اضافه‌شده: parse خط `using cloudflare edge X.X.X.X:PORT`
///  از لاگ Aether و ذخیرهٔ آن به عنوان endpoint واقعی.
///  این خط در logs وقتی Aether موفق به اتصال می‌شود چاپ می‌شود.
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

  /// ═══════════════════════════════════════════════════════════════
  ///  استخراج endpoint واقعی Aether از لاگ.
  ///
  ///  Aether این خط را وقتی موفق به اتصال می‌شود چاپ می‌کند:
  ///    [+] using cloudflare edge 188.114.98.62:987
  ///    [+] using edge 1.2.3.4:2408
  ///
  ///  این endpoint واقعی WARP است (public IP). ذخیرهٔ آن باعث
  ///  می‌شود fast-path بار بعد درست کار کند.
  /// ═══════════════════════════════════════════════════════════════
  void tryParseAetherRealEndpoint(String line) {
    if (!line.contains('using') || !line.contains('edge')) return;

    final endpoint = _aetherTestService.extractRealEndpointFromLog(line);
    if (endpoint == null || endpoint.isEmpty) return;

    // فقط اگر endpoint فعلی ذخیره‌شده با این فرق دارد ذخیره کن
    final winner = settings.aetherProtocol == 'auto'
        ? 'auto'
        : settings.aetherProtocol;

    // fire-and-forget
    // ignore: discarded_futures
    _aetherTestService.saveRealEndpointFromLog(
      endpoint,
      protocol: winner == 'auto' ? 'masque' : winner,
      masque: settings.masqueOption,
    );
  }
}
