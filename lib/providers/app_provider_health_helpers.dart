part of 'app_provider.dart';

extension AppProviderHealthHelpers on AppProvider {
  void _onNetworkChanged() {
    if (isShuttingDown) return;
    processService.addLog(
      '→ Network changed — invalidating connectivity/quality caches',
      source: LogSource.app,
    );
    try {
      _connectivityProbe.invalidateCache();
    } catch (e) {
      processService.addLog(
          '⚠ Failed to invalidate ConnectivityProbe cache: $e',
          source: LogSource.app);
    }
    try {
      _qualityProvider?.invalidateCache();
    } catch (e) {
      processService.addLog('⚠ Failed to invalidate InternetQuality cache: $e',
          source: LogSource.app);
    }
  }
}
