library;

import '../../../providers/app_provider.dart';
import '../../../services/health/tunnel_health_models.dart';

/// ═══════════════════════════════════════════════════════════════
///  TunnelStateResolver — resolve وضعیت running و SOCKS port
///  برای هر TunnelKind.
///
///  ⚠️ برای Aether از isAetherTunnelReady استفاده می‌کنیم نه
///  isAetherRunning. دلیل: SOCKS Aether فقط وقتی قابل استفاده
///  است که tunnel validate شده باشد.
/// ═══════════════════════════════════════════════════════════════
class TunnelStateResolver {
  final AppProvider provider;

  const TunnelStateResolver(this.provider);

  Map<TunnelKind, bool> resolveRunningStates() {
    final ps = provider.processService;
    return {
      TunnelKind.psiphon: ps.isPsiphonConnected,
      TunnelKind.aether: ps.isAetherTunnelReady,
      TunnelKind.tor: ps.isTorConnected,
      TunnelKind.sstp: ps.isSstpConnected,
      TunnelKind.wireguard: ps.isWireGuardConnected,
      TunnelKind.ffvpn: ps.isFfvpnConnected,
      TunnelKind.lantern: ps.isLanternConnected,
      TunnelKind.geph: ps.isGephConnected,
      TunnelKind.npv: ps.isNpvConnected,
    };
  }

  bool isTunnelRunning(TunnelKind kind) =>
      resolveRunningStates()[kind] ?? false;

  int socksPortFor(TunnelKind kind) {
    final s = provider.settings;
    switch (kind) {
      case TunnelKind.psiphon:
        return s.socksPort;
      case TunnelKind.aether:
        return s.aetherLocalPort;
      case TunnelKind.tor:
        return s.torSocksPort;
      case TunnelKind.sstp:
        return s.sstpSocksPort;
      case TunnelKind.wireguard:
        return s.wireguardSocksPort;
      case TunnelKind.ffvpn:
        return s.ffvpnSocksPort;
      case TunnelKind.lantern:
        return s.lanternSocksPort;
      case TunnelKind.geph:
        return s.gephSocksPort;
      case TunnelKind.npv:
        return s.npvSocksPort;
    }
  }
}
