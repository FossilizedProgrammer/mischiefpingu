// lib/providers/sstp_fetcher/sstp_fetcher_proxy.dart
part of '../sstp_fetcher_provider.dart';

extension SstpFetcherProxy on SstpFetcherProvider {
  void bindPortGetters({
    required int Function() psiphon,
    required int Function() aether,
    required int Function() tor,
    int Function()? sstp,
  }) {
    psiphonPortGetter = psiphon;
    aetherPortGetter = aether;
    torPortGetter = tor;
    if (sstp != null) sstpPortGetter = sstp;
  }

  String? resolveProxy() {
    String? pick(String mode) {
      switch (mode) {
        case 'psiphon':
          return processService.isPsiphonConnected
              ? '127.0.0.1:${psiphonPortGetter()}'
              : null;
        case 'aether':
          return processService.isAetherRunning
              ? '127.0.0.1:${aetherPortGetter()}'
              : null;
        case 'tor':
          return processService.isTorConnected
              ? '127.0.0.1:${torPortGetter()}'
              : null;
        case 'sstp':
          return processService.isSstpConnected
              ? '127.0.0.1:${sstpPortGetter()}'
              : null;
        default:
          return null;
      }
    }

    if (proxyMode == 'direct') return null;
    if (proxyMode != 'auto') {
      final v = pick(proxyMode);
      if (v == null) {
        throw StateError(
          'Selected proxy ($proxyMode) is not running. '
          'Start it first or choose Auto/Direct.',
        );
      }
      return v;
    }
    for (final m in ['psiphon', 'aether', 'tor', 'sstp']) {
      final v = pick(m);
      if (v != null) return v;
    }
    return null;
  }

  void setProxyMode(String mode) {
    proxyMode = mode;
    touch(); // ✅ به‌جای notifyListeners
  }
}
