part of 'app_provider.dart';

extension AppProviderWrappers on AppProvider {
  Future<void> setLoggingEnabled(bool value) =>
      setLoggingEnabledInternal(value);
  Future<void> saveSettings() => saveSettingsInternal();
  Future<void> saveIpList(List<String> list) => saveIpListInternal(list);
  Future<void> saveHttpHostList(List<String> list) =>
      saveHttpHostListInternal(list);
  Future<void> saveTlsSniList(List<String> list) =>
      saveTlsSniListInternal(list);
}
