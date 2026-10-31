part of 'app_provider.dart';

extension AppProviderLifecyclePersistence on AppProvider {
  Future<void> loadSettingsInternal() async {
    loggingEnabled = await persistence.loadLoggingEnabled();
    processService.loggingEnabled = loggingEnabled;
    settings = await persistence.loadSettings();
    aetherTestService.updateSettings(settings);

    // ─── انتقال منابع فعال لاگ به ProcessService ───
    processService.setEnabledLogSources(settings.enabledLogSources.toSet());

    final hasExisting = (await persistence.loadIpList(const [])).isNotEmpty;
    if (!hasExisting) {
      applySetting(1);
    }

    ipList = cleanIpList(await persistence.loadIpList(ipList));
    httpHostList = await persistence.loadHttpHostList(httpHostList);
    tlsSniList = await persistence.loadTlsSniList(tlsSniList);

    settings.ip = cleanIp(settings.ip);
    if (settings.ip.isEmpty || !ipList.contains(settings.ip)) {
      if (ipList.isNotEmpty) settings.ip = ipList.first;
    }
    if (settings.httpHost.isEmpty ||
        !httpHostList.contains(settings.httpHost)) {
      if (httpHostList.isNotEmpty) settings.httpHost = httpHostList.first;
    }
    if (settings.tlsSni.isEmpty || !tlsSniList.contains(settings.tlsSni)) {
      if (tlsSniList.isNotEmpty) settings.tlsSni = tlsSniList.first;
    }

    if (settings.aetherLocalPort > 40000) {
      processService.addLog(
        '⚠ Saved Aether port ${settings.aetherLocalPort} is in the ephemeral range → resetting to 1819',
        source: LogSource.aether,
      );
      settings.aetherLocalPort = 1819;
    }
  }

  Future<void> setLoggingEnabledInternal(bool value) async {
    loggingEnabled = value;
    processService.loggingEnabled = value;
    await persistence.saveLoggingEnabled(value);
    touch();
  }

  Future<void> setLogSourcesInternal(Set<String> sources) async {
    settings.enabledLogSources = sources.toList();
    processService.setEnabledLogSources(sources);
    await saveSettings();
    touch();
  }

  Future<void> saveSettingsInternal() async {
    await persistence.saveSettings(settings);
  }

  Future<void> saveIpListInternal(List<String> list) async {
    ipList = cleanIpList(list);
    await persistence.saveIpList(ipList);
    touch();
  }

  Future<void> saveHttpHostListInternal(List<String> list) async {
    httpHostList = list;
    await persistence.saveHttpHostList(list);
    touch();
  }

  Future<void> saveTlsSniListInternal(List<String> list) async {
    tlsSniList = list;
    await persistence.saveTlsSniList(list);
    touch();
  }
}
