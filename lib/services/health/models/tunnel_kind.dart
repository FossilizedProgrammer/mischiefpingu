library;

/// ═══════════════════════════════════════════════════════════════
///  TunnelKind — نوع تونل.
/// ═══════════════════════════════════════════════════════════════
enum TunnelKind {
  psiphon,
  aether,
  tor,
  sstp,
  wireguard;

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
    }
  }

  String get id => name;
}
