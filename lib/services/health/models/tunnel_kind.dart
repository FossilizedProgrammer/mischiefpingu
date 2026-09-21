library;

/// ═══════════════════════════════════════════════════════════════
///  TunnelKind — نوع تونل.
/// ═══════════════════════════════════════════════════════════════
enum TunnelKind {
  psiphon,
  aether,
  tor,
  sstp;

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
    }
  }

  String get id => name;
}
