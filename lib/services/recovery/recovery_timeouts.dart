library;

/// timeoutهای lease برای هر tunnel.
class RecoveryTimeouts {
  RecoveryTimeouts._();

  static const Duration _default = Duration(seconds: 120);

  static const Map<String, Duration> _byTunnel = {
    'Psiphon': Duration(seconds: 150),
    'Aether': Duration(seconds: 180),
    'Tor': Duration(seconds: 240),
    'SSTP': Duration(seconds: 120),
  };

  static Duration forTunnel(String tunnel) => _byTunnel[tunnel] ?? _default;
}
