// lib/providers/app_provider_lifecycle.dart
part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Lifecycle: initialization, shutdown, save, list management
///  حالا به صورت extension پیاده‌سازی شده تا حلقهٔ ارث‌بری
///  (recursive interface inheritance) رفع شود.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderLifecycle on AppProvider {
  Future<void> initializeProvider() async {
    try {
      await loadSettingsInternal();
      await checkPrivilegeInternal();
      final coreUpdateService = CoreUpdateService(log: processService.addLog);
      await coreUpdateService.applyPendingUpdates();
      touch();
    } catch (e) {
      processService.addLog('⚠ Provider initialization failed: $e',
          source: LogSource.app);
    }
  }

  Future<void> checkPrivilegeInternal() async {
    isElevated = await PrivilegeService.isElevated();
    touch();
  }

  Future<void> loadSettingsInternal() async {
    loggingEnabled = await persistence.loadLoggingEnabled();
    processService.loggingEnabled = loggingEnabled;
    settings = await persistence.loadSettings();
    aetherTestService.updateSettings(settings);

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

  Future<void> shutdownAllInternal() async {
    if (isShuttingDown) return;
    isShuttingDown = true;

    // ═══════════════════════════════════════════
    //  اول watchdogها را متوقف کن تا وسط shutdown
    //  دوباره restart نزنند و با پروسه‌های در حال
    //  مرگ تداخل نکنند.
    // ═══════════════════════════════════════════
    try {
      watchdogManager?.disposeAll();
    } catch (_) {}

    processService.addLog(
      '→ App is closing — disconnecting all active tunnels…',
      source: LogSource.app,
    );

    reconnectManager.cancelAll();

    try {
      aetherTestService.requestCancel();
    } catch (_) {}

    // Psiphon
    try {
      if (processService.isPsiphonRunning || isPsiphonBusy) {
        processService.addLog('→ Stopping Psiphon…', source: LogSource.app);
        await processService.stopPsiphon();
      }
    } catch (e) {
      processService.addLog('⚠ Psiphon shutdown error: $e',
          source: LogSource.app);
    }

    // Tor
    try {
      if (processService.isTorRunning || isTorBusy) {
        processService.addLog('→ Stopping Tor…', source: LogSource.app);
        await processService.stopTor();
      }
    } catch (e) {
      processService.addLog('⚠ Tor shutdown error: $e', source: LogSource.app);
    }

    // SSTP
    try {
      if (processService.isSstpRunning || isSstpBusy) {
        processService.addLog('→ Stopping SSTP…', source: LogSource.app);
        await processService.stopSstp();
      }
    } catch (e) {
      processService.addLog('⚠ SSTP shutdown error: $e', source: LogSource.app);
    }

    // Aether (آخر)
    try {
      if (processService.isAetherRunning || isAutoTesting) {
        processService.addLog('→ Stopping Aether…', source: LogSource.app);
        await processService.stopAether();
      }
    } catch (e) {
      processService.addLog('⚠ Aether shutdown error: $e',
          source: LogSource.app);
    }

    try {
      await processService.closeAllForwardSockets();
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 300));

    processService.addLog('★ All tunnels disconnected. Safe to exit.',
        source: LogSource.app);
  }
}
