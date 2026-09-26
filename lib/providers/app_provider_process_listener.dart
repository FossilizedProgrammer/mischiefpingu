part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderProcessListener — handle کردن تغییرات ProcessService.
///
///  ⚠️ منطق _syncHealthMonitors به
///  `app_provider_process_listener_sync.dart` منتقل شد.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderProcessListener on AppProvider {
  void handleProcessServiceChange() {
    if (isShuttingDown) return;
    final logs = processService.fullLog;
    if (logs.isNotEmpty) {
      final last = logs.last;
      tryParseFoundFronting(last);
      tryParseBuildRev(last);
      tryParseAetherRealEndpoint(last);
    }
    // ═══════════════════════════════════════════════════════════
    //  🆕 wireGuardTunnelReady هم به snapshot اضافه شد
    // ═══════════════════════════════════════════════════════════
    final currentState = _TunnelStateSnapshot(
      psiphonRunning: processService.isPsiphonRunning,
      psiphonConnected: processService.isPsiphonConnected,
      aetherRunning: processService.isAetherRunning,
      torRunning: processService.isTorRunning,
      torConnected: processService.isTorConnected,
      torBootstrapProgress: processService.torBootstrapProgress,
      sstpRunning: processService.isSstpRunning,
      sstpConnected: processService.isSstpConnected,
      wireGuardRunning: processService.isWireGuardRunning,
      wireGuardConnected: processService.isWireGuardConnected,
      wireGuardTunnelReady: processService.isWireGuardTunnelReady,
    );
    final previousState = _lastTunnelState;
    final stateChanged = previousState != currentState;
    _lastTunnelState = currentState;
    if (stateChanged) {
      checkAutoReconnects();
      updateTunnelStatuses();
      syncWatchdogs();
      _syncHealthMonitors(currentState, previousState);
    }
    touch();
  }
}
