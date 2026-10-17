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
    'Geph',
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
    'Geph',
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
    _validateGeph(s);
  }

  /// مقدار آپ‌استریم را در مجموعهٔ مجاز نگه می‌دارد؛ وگرنه «مستقیم» (0).
  static int _normalizeUpstream(int value, Set<int> allowed) =>
      allowed.contains(value) ? value : 0;

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

    // 0 direct، 1 manual، 3 Conduit، 4 Tor، 5 SSTP، 6 WireGuard،
    // 7 Firefox VPN، 8 Lantern، 9 Geph. (۲ = Aether حذف شد.)
    s.upstreamType = _normalizeUpstream(
      s.upstreamType,
      const {0, 1, 3, 4, 5, 6, 7, 8, 9},
    );
  }

  static void _validateTor(AppSettings s) {
    if (![
      'direct',
      'bridge',
      'manual',
      'psiphon',
      'sstp',
      'wireguard',
      'ffvpn',
      'lantern',
      'geph',
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
    // 0 direct، 1 manual، 3 Psiphon، 4 Tor، 5 WireGuard، 6 Firefox VPN،
    // 7 Lantern، 8 Geph. (۲ = Aether حذف شد.)
    s.sstpUpstreamType = _normalizeUpstream(
      s.sstpUpstreamType,
      const {0, 1, 3, 4, 5, 6, 7, 8},
    );
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
    if (!['all', 'free', 'plus'].contains(s.ffvpnCountryFilter)) {
      s.ffvpnCountryFilter = 'free';
    }
    if (s.ffvpnSocksPort < 1 || s.ffvpnSocksPort > 65535) {
      s.ffvpnSocksPort = 1083;
    }
    // 0 disables the HTTP listener entirely.
    if (s.ffvpnHttpPort < 0 || s.ffvpnHttpPort > 65535) {
      s.ffvpnHttpPort = 8083;
    }
    s.ffvpnSni = normalizeFfvpnSni(s.ffvpnSni);
    // 0 direct، 1 manual، 3 Psiphon، 4 Tor، 5 SSTP، 6 WireGuard،
    // 8 Lantern، 9 Geph. (۷ = خودِ Firefox VPN؛ ۲ = Aether حذف‌شده.)
    s.ffvpnUpstreamType = _normalizeUpstream(
      s.ffvpnUpstreamType,
      const {0, 1, 3, 4, 5, 6, 8, 9},
    );
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
    // 0 direct، 1 manual، 3 Psiphon، 4 Tor، 5 SSTP، 6 WireGuard،
    // 7 Firefox VPN، 9 Geph. (۸ = خودِ Lantern؛ ۲ = Aether حذف‌شده.)
    s.lanternUpstreamType = _normalizeUpstream(
      s.lanternUpstreamType,
      const {0, 1, 3, 4, 5, 6, 7, 9},
    );
    if (!['socks5', 'socks5h', 'http', 'https'].contains(s.lanternProxyType)) {
      s.lanternProxyType = 'socks5';
    }
    s.lanternProxyIp = s.lanternProxyIp.trim();
    s.lanternProxyUser = s.lanternProxyUser.trim();
    if (s.lanternProxyPort < 0 || s.lanternProxyPort > 65535) {
      s.lanternProxyPort = 1080;
    }
  }

  static void _validateGeph(AppSettings s) {
    // پورت SOCKS باید معتبر باشد؛ پورت HTTP با 0 غیرفعال می‌شود.
    if (s.gephSocksPort < 1 || s.gephSocksPort > 65535) {
      s.gephSocksPort = 9909;
    }
    if (s.gephHttpPort < 0 || s.gephHttpPort > 65535) {
      s.gephHttpPort = 9910;
    }
    s.gephCountry = s.gephCountry.trim();
    if (s.gephCountry.isEmpty) s.gephCountry = 'auto';
    if (s.gephCountry != 'auto') {
      s.gephCountry = s.gephCountry.toUpperCase();
      if (s.gephCountry.length != 2) s.gephCountry = 'auto';
    }
    // 0 direct، 1 manual، 3 Psiphon، 4 Tor، 5 SSTP، 6 WireGuard،
    // 7 Firefox VPN، 8 Lantern. (۹ = خودِ Geph؛ ۲ = Aether حذف‌شده.)
    s.gephUpstreamType = _normalizeUpstream(
      s.gephUpstreamType,
      const {0, 1, 3, 4, 5, 6, 7, 8},
    );
    if (!['socks5', 'socks5h', 'http', 'https'].contains(s.gephProxyType)) {
      s.gephProxyType = 'socks5';
    }
    s.gephProxyIp = s.gephProxyIp.trim();
    s.gephProxyUser = s.gephProxyUser.trim();
    if (s.gephProxyPort < 0 || s.gephProxyPort > 65535) {
      s.gephProxyPort = 1080;
    }
    if (!['all', 'free', 'plus'].contains(s.gephCountryFilter)) {
      s.gephCountryFilter = 'all';
    }
    if (![
      AppSettings.gephAccountSourceFile,
      AppSettings.gephAccountSourceCode,
    ].contains(s.gephAccountSource)) {
      s.gephAccountSource = AppSettings.gephAccountSourceFile;
    }
    s.gephAccountFile = s.gephAccountFile.trim();
    s.gephAccountCode = s.gephAccountCode.trim();
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
