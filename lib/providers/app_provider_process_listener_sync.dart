part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderProcessListenerSync — sync کردن health monitorها
///  با تغییر state تونل‌ها.
///
///  این extension از `app_provider_process_listener.dart` جدا شده
///  تا فایل اصلی فقط handleProcessServiceChange رو نگه داره.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderProcessListenerSync on AppProvider {
  void _syncHealthMonitors(
    _TunnelStateSnapshot current,
    _TunnelStateSnapshot? previous,
  ) {
    // ─── Psiphon ───
    final psiphonWasConnected = previous?.psiphonConnected ?? false;
    final psiphonIsConnected = current.psiphonConnected;
    if (psiphonIsConnected && !psiphonWasConnected) {
      _healthRegistry.startMonitor(TunnelKind.psiphon, DateTime.now());
      processService.addLog(
        '→ Psiphon health monitor started',
        source: LogSource.app,
      );
    } else if (!psiphonIsConnected && psiphonWasConnected) {
      _healthRegistry.stopMonitor(TunnelKind.psiphon);
      processService.addLog(
        '→ Psiphon health monitor stopped',
        source: LogSource.app,
      );
    }
    // ─── Tor ───
    final torWasConnected = previous?.torConnected ?? false;
    final torIsConnected = current.torConnected;
    if (torIsConnected && !torWasConnected) {
      _healthRegistry.startMonitor(TunnelKind.tor, DateTime.now());
      processService.addLog(
        '→ Tor health monitor started',
        source: LogSource.app,
      );
    } else if (!torIsConnected && torWasConnected) {
      _healthRegistry.stopMonitor(TunnelKind.tor);
      processService.addLog(
        '→ Tor health monitor stopped',
        source: LogSource.app,
      );
    }
    // ─── SSTP ───
    final sstpWasConnected = previous?.sstpConnected ?? false;
    final sstpIsConnected = current.sstpConnected;
    if (sstpIsConnected && !sstpWasConnected) {
      _healthRegistry.startMonitor(TunnelKind.sstp, DateTime.now());
      processService.addLog(
        '→ SSTP health monitor started',
        source: LogSource.app,
      );
    } else if (!sstpIsConnected && sstpWasConnected) {
      _healthRegistry.stopMonitor(TunnelKind.sstp);
      processService.addLog(
        '→ SSTP health monitor stopped',
        source: LogSource.app,
      );
    }
    // ═══════════════════════════════════════════════════════════
    //  WireGuard — بر اساس TunnelReady، نه Connected
    // ═══════════════════════════════════════════════════════════
    final wgWasReady = previous?.wireGuardTunnelReady ?? false;
    final wgIsReady = current.wireGuardTunnelReady;
    if (wgIsReady && !wgWasReady) {
      _healthRegistry.startMonitor(TunnelKind.wireguard, DateTime.now());
      processService.addLog(
        '→ WireGuard health monitor started (tunnel ready)',
        source: LogSource.app,
      );
    } else if (!wgIsReady && wgWasReady) {
      _healthRegistry.stopMonitor(TunnelKind.wireguard);
      processService.addLog(
        '→ WireGuard health monitor stopped',
        source: LogSource.app,
      );
    }
  }
}
