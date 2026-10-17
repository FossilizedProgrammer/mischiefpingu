part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  هندل upstream برای SSTP
///  (Psiphon / Tor / WireGuard / Firefox VPN / Lantern / Geph)
///
///  ⚠️ نکات:
///   • isAutoTesting در try/finally
///   • چک userStoppedSstp بعد از هر await
/// ═══════════════════════════════════════════════════════════════
extension AppProviderSstpUpstream on AppProvider {
  Future<bool> resolveSstpUpstream({required bool fromAutoReconnect}) async {
    final builder = SstpUpstreamBuilder(
      settings: settings,
      processService: processService,
    );

    switch (builder.type) {
      case SstpUpstreamBuilder.psiphon:
        return _ensureSstpUpstreamTunnel(
          name: 'Psiphon',
          isRunning: () => processService.isPsiphonRunning,
          isStoppedByUser: () => userStoppedPsiphon,
          start: () => connectPsiphon(fromAutoReconnect: fromAutoReconnect),
          fromAutoReconnect: fromAutoReconnect,
        );
      case SstpUpstreamBuilder.tor:
        return _ensureSstpUpstreamTunnel(
          name: 'Tor',
          isRunning: () => processService.isTorRunning,
          isStoppedByUser: () => userStoppedTor,
          start: () => connectTor(fromAutoReconnect: fromAutoReconnect),
          fromAutoReconnect: fromAutoReconnect,
        );
      case SstpUpstreamBuilder.wireguard:
        return _ensureSstpUpstreamTunnel(
          name: 'WireGuard',
          isRunning: () => processService.isWireGuardRunning,
          isStoppedByUser: () => userStoppedWireGuard,
          start: () => connectWireGuard(fromAutoReconnect: fromAutoReconnect),
          fromAutoReconnect: fromAutoReconnect,
        );
      case SstpUpstreamBuilder.ffvpn:
        return _ensureSstpUpstreamTunnel(
          name: 'Firefox VPN',
          isRunning: () => processService.isFfvpnRunning,
          isStoppedByUser: () => userStoppedFfvpn,
          start: () => connectFfvpn(),
          fromAutoReconnect: fromAutoReconnect,
        );
      case SstpUpstreamBuilder.lantern:
        return _ensureSstpUpstreamTunnel(
          name: 'Lantern',
          isRunning: () => processService.isLanternRunning,
          isStoppedByUser: () => userStoppedLantern,
          start: () => connectLantern(),
          fromAutoReconnect: fromAutoReconnect,
        );
      case SstpUpstreamBuilder.geph:
        return _ensureSstpUpstreamTunnel(
          name: 'Geph',
          isRunning: () => processService.isGephRunning,
          isStoppedByUser: () => userStoppedGeph,
          start: () => connectGeph(),
          fromAutoReconnect: fromAutoReconnect,
        );
      default:
        return true;
    }
  }

  /// بالا آوردن تونل آپ‌استریم اگر لازم باشد؛ false یعنی SSTP شروع نشود.
  Future<bool> _ensureSstpUpstreamTunnel({
    required String name,
    required bool Function() isRunning,
    required bool Function() isStoppedByUser,
    required Future<void> Function() start,
    required bool fromAutoReconnect,
  }) async {
    const src = LogSource.sstp;

    if (isRunning()) {
      processService.addLog(
        '→ SSTP upstream: $name already running',
        source: src,
      );
      return true;
    }

    if (fromAutoReconnect && isStoppedByUser()) {
      sstpStatus = 'SSTP: upstream $name stopped by user — skipped';
      processService.addLog(
        '→ SSTP auto-reconnect skipped (upstream $name was stopped by user)',
        source: src,
      );
      touch();
      return false;
    }

    sstpStatus = 'SSTP: starting $name upstream…';
    touch();

    await start();

    // ⚠️ FIX: چک cancel
    if (userStoppedSstp) {
      processService.addLog(
        'SSTP start cancelled by user (after $name upstream)',
        source: src,
      );
      return false;
    }

    if (!isRunning()) {
      sstpStatus = 'SSTP: $name unavailable — SSTP not started';
      processService.addLog(
        '✗ $name unavailable → SSTP not started',
        source: src,
      );
      return false;
    }

    processService.addLog(
      '→ SSTP will use $name as upstream proxy',
      source: src,
    );
    return true;
  }
}
