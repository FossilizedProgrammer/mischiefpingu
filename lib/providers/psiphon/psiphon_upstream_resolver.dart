part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  آپ‌استریم Psiphon
///
///  Psiphon فقط `UpstreamProxyURL` را در config می‌گذارد؛ اگر آن
///  پورت SOCKS کسی باز نکند، هسته تا سقف EstablishTunnelTimeoutSeconds
///  (۱۲۰ ثانیه) به یک پروکسی مرده رجوع می‌کند و UI روی «connecting»
///  می‌ماند. پس اول هستهٔ آپ‌استریم بالا می‌آید و منتظر listener آن
///  می‌مانیم.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderPsiphonUpstream on AppProvider {
  /// false یعنی Psiphon نباید شروع شود.
  Future<bool> resolvePsiphonUpstream({
    required bool fromAutoReconnect,
  }) async {
    switch (settings.upstreamType) {
      case PsiphonUpstreamBuilder.tor:
        return _ensurePsiphonUpstreamTunnel(
          name: 'Tor',
          socksPort: settings.torSocksPort,
          isRunning: () => processService.isTorRunning,
          stoppedByUser: () => userStoppedTor,
          start: () => connectTor(fromAutoReconnect: fromAutoReconnect),
          fromAutoReconnect: fromAutoReconnect,
        );
      case PsiphonUpstreamBuilder.sstp:
        return _ensurePsiphonUpstreamTunnel(
          name: 'SSTP',
          socksPort: settings.sstpSocksPort,
          isRunning: () => processService.isSstpRunning,
          stoppedByUser: () => userStoppedSstp,
          start: () => connectSstp(fromAutoReconnect: fromAutoReconnect),
          fromAutoReconnect: fromAutoReconnect,
        );
      case PsiphonUpstreamBuilder.wireguard:
        return _ensurePsiphonUpstreamTunnel(
          name: 'WireGuard',
          socksPort: settings.wireguardSocksPort,
          isRunning: () => processService.isWireGuardRunning,
          stoppedByUser: () => userStoppedWireGuard,
          start: () => connectWireGuard(fromAutoReconnect: fromAutoReconnect),
          fromAutoReconnect: fromAutoReconnect,
        );
      case PsiphonUpstreamBuilder.ffvpn:
        return _ensurePsiphonUpstreamTunnel(
          name: 'Firefox VPN',
          socksPort: settings.ffvpnSocksPort,
          isRunning: () => processService.isFfvpnRunning,
          stoppedByUser: () => userStoppedFfvpn,
          start: () => connectFfvpn(),
          fromAutoReconnect: fromAutoReconnect,
        );
      case PsiphonUpstreamBuilder.lantern:
        return _ensurePsiphonUpstreamTunnel(
          name: 'Lantern',
          socksPort: settings.lanternSocksPort,
          isRunning: () => processService.isLanternRunning,
          stoppedByUser: () => userStoppedLantern,
          start: () => connectLantern(),
          fromAutoReconnect: fromAutoReconnect,
        );
      case PsiphonUpstreamBuilder.geph:
        return _ensurePsiphonUpstreamTunnel(
          name: 'Geph',
          socksPort: settings.gephSocksPort,
          isRunning: () => processService.isGephRunning,
          stoppedByUser: () => userStoppedGeph,
          start: () => connectGeph(),
          fromAutoReconnect: fromAutoReconnect,
        );
      case PsiphonUpstreamBuilder.npv:
        return _ensurePsiphonUpstreamTunnel(
          name: 'NPV',
          socksPort: settings.npvSocksPort,
          isRunning: () => processService.isNpvRunning,
          stoppedByUser: () => userStoppedNpv,
          start: () => connectNpv(),
          fromAutoReconnect: fromAutoReconnect,
        );
      default:
        return true;
    }
  }

  Future<bool> _ensurePsiphonUpstreamTunnel({
    required String name,
    required int socksPort,
    required bool Function() isRunning,
    required bool Function() stoppedByUser,
    required Future<void> Function() start,
    required bool fromAutoReconnect,
  }) async {
    const src = LogSource.psiphon;

    if (_psiphonUpstreamResolving) {
      processService.addLog(
        '✗ Psiphon upstream $name loops back to Psiphon — Psiphon not started',
        source: src,
      );
      return false;
    }

    if (fromAutoReconnect && stoppedByUser()) {
      processService.addLog(
        '→ Psiphon auto-reconnect skipped (upstream $name was stopped by user)',
        source: src,
      );
      return false;
    }

    if (!isRunning()) {
      _psiphonUpstreamResolving = true;
      processService.addLog(
        '→ Psiphon upstream: starting $name…',
        source: src,
      );
      touch();
      try {
        await start();
      } finally {
        _psiphonUpstreamResolving = false;
      }
    }

    if (userStoppedPsiphon) {
      processService.addLog(
        'Psiphon start cancelled by user (during $name upstream)',
        source: src,
      );
      return false;
    }

    if (!isRunning()) {
      processService.addLog(
        '✗ $name unavailable → Psiphon not started',
        source: src,
      );
      return false;
    }

    // هستهٔ بالاآمده هنوز لزوماً listener SOCKS را باز نکرده است.
    if (!await _waitForUpstreamListener(socksPort)) {
      processService.addLog(
        '✗ $name has no SOCKS listener on 127.0.0.1:$socksPort '
        'after ${_upstreamListenerTimeout.inSeconds}s — Psiphon not started',
        source: src,
      );
      return false;
    }

    processService.addLog(
      '→ Psiphon will use $name as upstream proxy (127.0.0.1:$socksPort)',
      source: src,
    );
    return true;
  }

  static const Duration _upstreamListenerTimeout = Duration(seconds: 120);

  Future<bool> _waitForUpstreamListener(int port) async {
    final deadline = DateTime.now().add(_upstreamListenerTimeout);
    while (DateTime.now().isBefore(deadline)) {
      if (userStoppedPsiphon) return false;
      if (await ProcessService.isPortInUse(port)) return true;
      await Future.delayed(const Duration(seconds: 1));
    }
    return false;
  }
}
