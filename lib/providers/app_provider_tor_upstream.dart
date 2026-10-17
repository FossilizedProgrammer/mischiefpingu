part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  هندل کردن upstream برای Tor
///  (Psiphon / SSTP / WireGuard / Firefox VPN / Lantern / Geph)
///
///  ⚠️ نکات:
///   • isAutoTesting در try/finally
///   • چک userStoppedTor بعد از هر await
/// ═══════════════════════════════════════════════════════════════
extension AppProviderTorUpstream on AppProvider {
  Future<({bool ok, String type, String detail})> resolveTorUpstream({
    required bool fromAutoReconnect,
  }) async {
    switch (settings.torTransport) {
      case 'psiphon':
        return _resolveTorChainedTunnel(
          type: 'psiphon',
          label: 'Psiphon',
          isRunning: () => processService.isPsiphonRunning,
          stoppedByUser: () => userStoppedPsiphon,
          start: () => connectPsiphon(fromAutoReconnect: fromAutoReconnect),
          fromAutoReconnect: fromAutoReconnect,
        );
      case 'sstp':
        return _resolveTorChainedTunnel(
          type: 'sstp',
          label: 'SSTP',
          isRunning: () => processService.isSstpRunning,
          stoppedByUser: () => userStoppedSstp,
          start: () => connectSstp(fromAutoReconnect: fromAutoReconnect),
          fromAutoReconnect: fromAutoReconnect,
        );
      case 'wireguard':
        return _resolveTorChainedTunnel(
          type: 'wireguard',
          label: 'WireGuard',
          isRunning: () => processService.isWireGuardRunning,
          stoppedByUser: () => userStoppedWireGuard,
          start: () => connectWireGuard(fromAutoReconnect: fromAutoReconnect),
          fromAutoReconnect: fromAutoReconnect,
        );
      case 'ffvpn':
        return _resolveTorChainedTunnel(
          type: 'ffvpn',
          label: 'Firefox VPN',
          isRunning: () => processService.isFfvpnRunning,
          stoppedByUser: () => userStoppedFfvpn,
          start: () => connectFfvpn(),
          fromAutoReconnect: fromAutoReconnect,
        );
      case 'lantern':
        return _resolveTorChainedTunnel(
          type: 'lantern',
          label: 'Lantern',
          isRunning: () => processService.isLanternRunning,
          stoppedByUser: () => userStoppedLantern,
          start: () => connectLantern(),
          fromAutoReconnect: fromAutoReconnect,
        );
      case 'geph':
        return _resolveTorChainedTunnel(
          type: 'geph',
          label: 'Geph',
          isRunning: () => processService.isGephRunning,
          stoppedByUser: () => userStoppedGeph,
          start: () => connectGeph(),
          fromAutoReconnect: fromAutoReconnect,
        );
    }

    if (settings.torTransport == 'bridge') {
      final bridges = settings.torBridges.trim();
      String detail = 'direct connection';
      if (bridges.isNotEmpty) {
        if (bridges.contains('obfs4')) {
          detail = 'using obfs4 bridge';
        } else if (bridges.contains('snowflake')) {
          detail = 'using Snowflake bridge';
        } else if (bridges.contains('meek')) {
          detail = 'using Meek bridge';
        } else if (bridges.contains('webtunnel')) {
          detail = 'using WebTunnel bridge';
        } else {
          detail = 'using custom bridge';
        }
      }
      return (ok: true, type: 'bridge', detail: detail);
    }

    return (ok: true, type: 'direct', detail: 'direct connection');
  }

  /// بالا آوردن تونل آپ‌استریم برای Tor (اگر لازم باشد).
  ///
  /// `ok = false` یعنی Tor نباید شروع شود.
  Future<({bool ok, String type, String detail})> _resolveTorChainedTunnel({
    required String type,
    required String label,
    required bool Function() isRunning,
    required bool Function() stoppedByUser,
    required Future<void> Function() start,
    required bool fromAutoReconnect,
  }) async {
    const src = LogSource.tor;

    if (isRunning()) {
      processService.addLog(
        '→ Tor upstream: $label already running',
        source: src,
      );
      return (ok: true, type: type, detail: 'via $label');
    }

    if (fromAutoReconnect && stoppedByUser()) {
      torStatus = 'Tor: upstream $label stopped by user — skipped';
      processService.addLog(
        '→ Tor auto-reconnect skipped (upstream $label was stopped by user)',
        source: src,
      );
      touch();
      return (ok: false, type: type, detail: '');
    }

    torStatus = 'Tor: starting $label upstream…';
    touch();

    await start();

    // ⚠️ FIX: چک cancel
    if (userStoppedTor) {
      processService.addLog(
        'Tor start cancelled by user (after $label upstream)',
        source: src,
      );
      return (ok: false, type: type, detail: '');
    }

    if (!isRunning()) {
      torStatus = 'Tor: $label unavailable — Tor not started';
      processService.addLog(
        '✗ $label unavailable → Tor not started',
        source: src,
      );
      return (ok: false, type: type, detail: '');
    }

    processService.addLog('→ Tor will chain through $label', source: src);
    return (ok: true, type: type, detail: 'via $label');
  }
}
