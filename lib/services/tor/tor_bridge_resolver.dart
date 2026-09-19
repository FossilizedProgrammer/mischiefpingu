library;

import '../../models/settings_model.dart';
import '../tor_bridges.dart';

/// نتیجهٔ تصمیم‌گیری درباره bridges و upstream.
class TorBridgeDecision {
  /// bridges نهایی (خالی = direct).
  final List<String> bridges;

  /// پورت SOCKS آپ‌استریم (null = بدون upstream).
  final int? upstreamSocks;

  /// آیا از TOR_PT_PROXY استفاده می‌شود؟
  final bool usePtProxy;

  const TorBridgeDecision({
    required this.bridges,
    required this.upstreamSocks,
    required this.usePtProxy,
  });
}

class TorBridgeResolver {
  TorBridgeResolver._();

  /// تصمیم‌گیری درباره اینکه کدام bridges فعال باشند
  /// و آیا SOCKS5Proxy / TOR_PT_PROXY لازم است.
  static TorBridgeDecision resolve({
    required AppSettings settings,
    int? aetherSocks,
    int? psiphonSocks,
    int? sstpSocks,
  }) {
    final transport = settings.torTransport;

    final rawBridges = (transport == 'direct' || transport == 'manual')
        ? <String>[]
        : TorBridges.parseBridges(settings.torBridges);

    int? upstreamSocks;
    if (transport == 'aether' && aetherSocks != null) {
      upstreamSocks = aetherSocks;
    } else if (transport == 'psiphon' && psiphonSocks != null) {
      upstreamSocks = psiphonSocks;
    } else if (transport == 'sstp' && sstpSocks != null) {
      upstreamSocks = sstpSocks;
    } else if (transport == 'manual' && settings.torProxyPort > 0) {
      upstreamSocks = settings.torProxyPort;
    }

    final usePtProxy = upstreamSocks != null && rawBridges.isNotEmpty;

    return TorBridgeDecision(
      bridges: rawBridges,
      upstreamSocks: upstreamSocks,
      usePtProxy: usePtProxy,
    );
  }
}
