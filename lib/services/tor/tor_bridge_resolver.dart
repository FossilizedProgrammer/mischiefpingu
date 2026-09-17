// lib/services/tor/tor_bridge_resolver.dart
//
// ═══════════════════════════════════════════════════════════════
//  TorBridgeResolver — تصمیم‌گیری درباره bridges و upstream
//  (تفکیک شده از tor_config_builder.dart)
// ═══════════════════════════════════════════════════════════════
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

    // در حالت direct هیچ bridge‌ای استفاده نمی‌شه.
    final rawBridges = (transport == 'direct')
        ? <String>[]
        : TorBridges.parseBridges(settings.torBridges);

    // تعیین upstream
    int? upstreamSocks;
    if (transport == 'aether' && aetherSocks != null) {
      upstreamSocks = aetherSocks;
    } else if (transport == 'psiphon' && psiphonSocks != null) {
      upstreamSocks = psiphonSocks;
    } else if (transport == 'sstp' && sstpSocks != null) {
      upstreamSocks = sstpSocks;
    }

    // منطق: اگر bridge داریم، از TOR_PT_PROXY استفاده کن.
    // اگر bridge نداریم ولی upstream داریم، از Socks5Proxy.
    final usePtProxy = upstreamSocks != null && rawBridges.isNotEmpty;

    return TorBridgeDecision(
      bridges: rawBridges,
      upstreamSocks: upstreamSocks,
      usePtProxy: usePtProxy,
    );
  }
}
