// lib/models/settings_validation.dart

library;

import 'settings_model.dart';

class SettingsValidation {
  SettingsValidation._();

  static const Set<String> _validLogSources = {
    'Psiphon',
    'Tor',
    'SSTP',
    'WireGuard',
    'Firefox VPN',
    'Lantern',
    'App',
    'System',
  };

  static const List<String> _defaultLogSources = [
    'Psiphon',
    'Tor',
    'SSTP',
    'WireGuard',
    'Firefox VPN',
    'Lantern',
    'App',
    'System',
  ];

  static void validateAndNormalize(AppSettings s) {
    _validatePsiphon(s);
    _validateTor(s);
    _validateSstp(s);
    _validateConduit(s);
    _validateLogSources(s);
    _validateWatchdogProfile(s);
    _validateWireGuard(s);
    _validateFfvpn(s);
    _validateLantern(s);
  }

  static void _validateLogSources(AppSettings s) {
    if (s.enabledLogSources.isEmpty) {
      s.enabledLogSources = List.from(_defaultLogSources);
      return;
    }
    final filtered = s.enabledLogSources
        .where((source) => _validLogSources.contains(source))
        .toList();
    if (filtered.isEmpty) {
      s.enabledLogSources = List.from(_defaultLogSources);
    } else {
      s.enabledLogSources = filtered;
    }
  }

  static void _validateWireGuard(AppSettings s) {
    if (s.wireguardSocksPort < 1 || s.wireguardSocksPort > 65535) {
      s.wireguardSocksPort = 1085;
    }

    if (s.wireguardCore != 'standard' && s.wireguardCore != 'amnezia') {
      s.wireguardCore = 'standard';
    }
  }

  static void _validatePsiphon(AppSettings s) {
    if (!['socks5', 'http'].contains(s.proxyType)) s.proxyType = 'socks5';

    // 2 (Aether upstream) removed → fall back to direct.
    if (s.upstreamType == 2) s.upstreamType = 0;
    if (s.upstreamType < 0 || s.upstreamType > 6) {
      s.upstreamType = 0;
    }
  }

  static void _validateTor(AppSettings s) {
    if (![
      'direct',
      'bridge',
      'manual',
      'psiphon',
      'sstp',
      'wireguard',
    ].contains(s.torTransport)) {
      s.torTransport = 'direct';
    }
    if (s.torSocksPort < 1 || s.torSocksPort > 65535) s.torSocksPort = 19050;
    if (s.torHttpPort < 1 || s.torHttpPort > 65535) s.torHttpPort = 18081;
    if (!['socks5', 'socks5h', 'http'].contains(s.torProxyType)) {
      s.torProxyType = 'socks5';
    }
    if (s.torProxyPort < 0 || s.torProxyPort > 65535) {
      s.torProxyPort = 0;
    }
  }

  static void _validateSstp(AppSettings s) {
    if (s.sstpPort < 1 || s.sstpPort > 65535) s.sstpPort = 443;
    if (s.sstpSocksPort < 1 || s.sstpSocksPort > 65535) {
      s.sstpSocksPort = 1082;
    }
    if (s.sstpHttpPort < 1 || s.sstpHttpPort > 65535) {
      s.sstpHttpPort = 8082;
    }
    // 2 (Aether upstream) removed → fall back to direct.
    if (s.sstpUpstreamType == 2) s.sstpUpstreamType = 0;
    if (s.sstpUpstreamType < 0 || s.sstpUpstreamType > 5) {
      s.sstpUpstreamType = 0;
    }
    if (!['socks5', 'http', 'socks5h'].contains(s.sstpProxyType)) {
      s.sstpProxyType = 'socks5';
    }
    if (s.sstpProxyPort < 0 || s.sstpProxyPort > 65535) {
      s.sstpProxyPort = 0;
    }

    if (s.sstpMtu < 576 || s.sstpMtu > 1500) {
      s.sstpMtu = 1400;
    }
  }

  static void _validateConduit(AppSettings s) {
    if (!['auto', 'public', 'custom'].contains(s.conduitMode)) {
      s.conduitMode = 'auto';
    }
  }

  static void _validateFfvpn(AppSettings s) {
    s.ffvpnSessionToken = s.ffvpnSessionToken.trim();
    s.ffvpnCountry = s.ffvpnCountry.trim().toUpperCase();
    if (s.ffvpnSocksPort < 1 || s.ffvpnSocksPort > 65535) {
      s.ffvpnSocksPort = 1083;
    }
    // 0 disables the HTTP listener entirely.
    if (s.ffvpnHttpPort < 0 || s.ffvpnHttpPort > 65535) {
      s.ffvpnHttpPort = 8083;
    }
    s.ffvpnSni = normalizeFfvpnSni(s.ffvpnSni);
    // 2 (Aether upstream) removed → fall back to direct.
    if (s.ffvpnUpstreamType == 2) s.ffvpnUpstreamType = 0;
    if (s.ffvpnUpstreamType < 0 || s.ffvpnUpstreamType > 6) {
      s.ffvpnUpstreamType = 0;
    }
    if (!['socks5', 'socks5h'].contains(s.ffvpnProxyType)) {
      s.ffvpnProxyType = 'socks5';
    }
    s.ffvpnProxyIp = s.ffvpnProxyIp.trim();
    s.ffvpnProxyUser = s.ffvpnProxyUser.trim();
    if (s.ffvpnProxyPort < 0 || s.ffvpnProxyPort > 65535) {
      s.ffvpnProxyPort = 1080;
    }
  }

  static void _validateLantern(AppSettings s) {
    // پورت SOCKS باید معتبر باشد؛ چون فعال‌سازی HTTP با 0 ممکن است
    // (مثل ffvpn) پورت HTTP می‌تواند 0 (= غیرفعال) باشد.
    if (s.lanternSocksPort < 1 || s.lanternSocksPort > 65535) {
      s.lanternSocksPort = 18071;
    }
    if (s.lanternHttpPort < 0 || s.lanternHttpPort > 65535) {
      s.lanternHttpPort = 18070;
    }
    if (s.lanternUpstreamType < 0 || s.lanternUpstreamType > 6 ||
        s.lanternUpstreamType == 2) {
      s.lanternUpstreamType = 0;
    }
    if (!['socks5', 'socks5h', 'http', 'https'].contains(s.lanternProxyType)) {
      s.lanternProxyType = 'socks5';
    }
    s.lanternProxyIp = s.lanternProxyIp.trim();
    s.lanternProxyUser = s.lanternProxyUser.trim();
    if (s.lanternProxyPort < 0 || s.lanternProxyPort > 65535) {
      s.lanternProxyPort = 1080;
    }
  }

  /// SNI must be a bare hostname: strip a pasted scheme/path/port.
  static String normalizeFfvpnSni(String raw) {
    var sni = raw.trim();
    final schemeAt = sni.indexOf('://');
    if (schemeAt >= 0) sni = sni.substring(schemeAt + 3);
    final slashAt = sni.indexOf('/');
    if (slashAt >= 0) sni = sni.substring(0, slashAt);
    final colonAt = sni.indexOf(':');
    if (colonAt >= 0) sni = sni.substring(0, colonAt);
    return sni.trim();
  }

  static void _validateWatchdogProfile(AppSettings s) {
    const valid = {'stable', 'normal', 'harsh'};
    if (!valid.contains(s.watchdogNetworkProfile)) {
      // ═══════════════════════════════════════════════════════════
      //  🆕 fallback از 'normal' به 'harsh' تغییر کرد
      // ═══════════════════════════════════════════════════════════
      s.watchdogNetworkProfile = 'harsh';
    }
  }
}
