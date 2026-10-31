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
    final now = _healthTrackedStates(current);
    final before = previous == null
        ? const <TunnelKind, bool>{}
        : _healthTrackedStates(previous);

    for (final entry in now.entries) {
      final kind = entry.key;
      final wasUp = before[kind] ?? false;
      if (entry.value == wasUp) continue;

      if (entry.value) {
        _healthRegistry.startMonitor(kind, DateTime.now());
        processService.addLog(
          '→ ${kind.displayName} health monitor started',
          source: LogSource.app,
        );
      } else {
        _healthRegistry.stopMonitor(kind);
        processService.addLog(
          '→ ${kind.displayName} health monitor stopped',
          source: LogSource.app,
        );
      }
    }
  }
}

/// حالتی که برای هر تونل سلامت را بالا نگه می‌دارد. WireGuard با
/// `tunnelReady` سنجیده می‌شود (Connected فقط بالا آمدن پروسه است).
Map<TunnelKind, bool> _healthTrackedStates(_TunnelStateSnapshot s) => {
      TunnelKind.psiphon: s.psiphonConnected,
      TunnelKind.tor: s.torConnected,
      TunnelKind.sstp: s.sstpConnected,
      TunnelKind.wireguard: s.wireGuardTunnelReady,
      TunnelKind.ffvpn: s.ffvpnConnected,
      TunnelKind.lantern: s.lanternConnected,
      TunnelKind.geph: s.gephConnected,
      TunnelKind.npv: s.npvConnected,
    };
