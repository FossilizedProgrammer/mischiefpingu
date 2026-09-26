part of 'app_provider.dart';

extension AppProviderPublicActions on AppProvider {
  Future<void> applyScannerResults({
    required List<String> ips,
    String? tlsSni,
  }) async {
    if (ips.isEmpty) return;
    final merged = <String>{...ipList, ...ips}.toList();
    await saveIpList(merged);
    settings.ip = ips.first;
    if (tlsSni != null && tlsSni.isNotEmpty) {
      settings.tlsSni = tlsSni;
      if (!tlsSniList.contains(tlsSni)) {
        await saveTlsSniList([...tlsSniList, tlsSni]);
      }
    }
    settings.isFronted = true;
    settings.useSunAndLion = true;
    settings.upstreamType = 0;
    await saveSettings();
    touch(); // ✅ استفاده از touch() به جای notifyListeners()
  }

  void applySetting(int number) {
    settings.applyPreset(number);
    saveSettings();
    touch(); // ✅ استفاده از touch() به جای notifyListeners()
  }

  Future<void> copyLogToClipboard() async {
    final text = processService.fullLog.join('\n');
    await Clipboard.setData(ClipboardData(text: text));
  }

  void cancelAllAutoReconnect() {
    _reconnectManager.cancelAll();
    _watchdogManager?.stopAll();
    _recoveryCoordinator.releaseAll();
    try {
      _aetherTestService.requestCancel();
    } catch (_) {}
  }

  Future<void> shutdownAll() => shutdownAllInternal();
}
