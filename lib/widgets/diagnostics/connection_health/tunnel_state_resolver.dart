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
    }
  }
}
