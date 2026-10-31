library;

/// ═══════════════════════════════════════════════════════════════
///  TunnelKind — نوع تونل.
/// ═══════════════════════════════════════════════════════════════
enum TunnelKind {
  psiphon,
  aether,
  tor,
  sstp,
  wireguard,
  ffvpn,
  lantern,
  geph,
  npv;

  String get displayName {
    switch (this) {
      case TunnelKind.psiphon:
        return 'Psiphon';
      case TunnelKind.aether:
        return 'Aether';
      case TunnelKind.tor:
        return 'Tor';
      case TunnelKind.sstp:
        return 'SSTP';
      case TunnelKind.wireguard:
        return 'WireGuard';
      case TunnelKind.ffvpn:
        return 'Firefox VPN';
      case TunnelKind.lantern:
        return 'Lantern';
      case TunnelKind.geph:
        return 'Geph';
      case TunnelKind.npv:
        return 'NPV';
    }
  }

  String get id => name;
}
