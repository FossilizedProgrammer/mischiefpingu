part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderLifecycle — startup + privilege.
///
///  ⚠️ منطق shutdown به
///  `app_provider_lifecycle_shutdown.dart` منتقل شد.
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
      processService.addLog(
        '⚠ Provider initialization failed: $e',
        source: LogSource.app,
      );
    }
  }

  Future<void> checkPrivilegeInternal() async {
    isElevated = await PrivilegeService.isElevated();
    touch();
  }
}
