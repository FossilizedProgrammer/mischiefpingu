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
    int? psiphonSocks,
    int? sstpSocks,
    int? wireguardSocks,
    int? ffvpnSocks,
    int? lanternSocks,
    int? gephSocks,
  }) {
    final transport = settings.torTransport;

    final rawBridges = (transport == 'direct' || transport == 'manual')
        ? <String>[]
        : TorBridges.parseBridges(settings.torBridges);

    int? upstreamSocks;
    switch (transport) {
      case 'psiphon':
        upstreamSocks = psiphonSocks;
        break;
      case 'sstp':
        upstreamSocks = sstpSocks;
        break;
      case 'wireguard':
        upstreamSocks = wireguardSocks;
        break;
      case 'ffvpn':
        upstreamSocks = ffvpnSocks;
        break;
      case 'lantern':
        upstreamSocks = lanternSocks;
        break;
      case 'geph':
        upstreamSocks = gephSocks;
        break;
      case 'manual':
        upstreamSocks =
            settings.torProxyPort > 0 ? settings.torProxyPort : null;
        break;
    }

    final usePtProxy = upstreamSocks != null && rawBridges.isNotEmpty;

    return TorBridgeDecision(
      bridges: rawBridges,
      upstreamSocks: upstreamSocks,
      usePtProxy: usePtProxy,
    );
  }
}
