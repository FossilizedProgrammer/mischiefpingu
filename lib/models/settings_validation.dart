library;

import 'settings_model.dart';

/// ═══════════════════════════════════════════════════════════════
///  SettingsValidation — اعتبارسنجی و نرمال‌سازی AppSettings.
///
///  این کلاس مقادیر نامعتبر را به مقادیر امن برمی‌گرداند:
///    • پروفایل Aether
///    • پروتکل/اسکن/مبهم‌سازی Aether
///    • نوع upstream Psiphon
///    • transport/ports/proxy Tor
///    • server/ports/proxy SSTP
///    • حالت Conduit
///    • منابع لاگ
///    • پروفایل شبکه واچ‌داگ (جدید)
/// ═══════════════════════════════════════════════════════════════
class SettingsValidation {
  SettingsValidation._();

  // ═══════════════════════════════════════════════════════════════
  //  ثابت‌های منابع لاگ
  // ═══════════════════════════════════════════════════════════════
  static const Set<String> _validLogSources = {
    'Psiphon',
    'Aether',
    'Tor',
    'SSTP',
    'App',
    'System',
  };

  static const List<String> _defaultLogSources = [
    'Psiphon',
    'Aether',
    'Tor',
    'SSTP',
    'App',
    'System',
  ];

  // ═══════════════════════════════════════════════════════════════
  //  نقطه ورود
  // ═══════════════════════════════════════════════════════════════
  static void validateAndNormalize(AppSettings s) {
    _validateAetherProfile(s);
    _validateAether(s);
    _validatePsiphon(s);
    _validateTor(s);
    _validateSstp(s);
    _validateConduit(s);
    _validateLogSources(s);
    _validateWatchdogProfile(s);
  }

  // ═══════════════════════════════════════════════════════════════
  //  اعتبارسنجی‌ها
  // ═══════════════════════════════════════════════════════════════

  /// منابع لاگ: اگر لیست خالی یا نامعتبر بود، به پیش‌فرض برمی‌گردد.
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

  /// پروفایل Aether: فقط {adaptive, patchy, strict, manual}.
  static void _validateAetherProfile(AppSettings s) {
    const valid = {'adaptive', 'patchy', 'strict', 'manual'};
    if (!valid.contains(s.aetherProfile)) {
      s.aetherProfile = 'adaptive';
    }
  }

  /// پارامترهای Aether.
  static void _validateAether(AppSettings s) {
    // ─── پروتکل: در حالت خودکار قفل است ───
    if (s.aetherProfile != 'manual') {
      s.aetherProtocol = 'auto';
    } else if (![
      'masque',
      'wireguard',
      'gool',
      'mim',
    ].contains(s.aetherProtocol)) {
      s.aetherProtocol = 'masque';
    }

    // ─── MASQUE option ───
    if (s.masqueOption != 'HTTP-2') s.masqueOption = 'HTTP-3';

    // ─── حالت اسکن ───
    if (![
      'turbo',
      'balanced',
      'thorough',
      'stealth',
      'ironclad',
    ].contains(s.aetherScanMode)) {
      s.aetherScanMode = 'balanced';
    }

    // ⚠️ turbo فقط در manual مجاز است
    if (s.aetherScanMode == 'turbo' && s.aetherProfile != 'manual') {
      s.aetherScanMode = 'balanced';
    }

    // ─── نوع IP ───
    if (!['ipv4', 'ipv6', 'both'].contains(s.ipType)) s.ipType = 'ipv4';

    // ─── مبهم‌سازی ───
    if (![
      'off',
      'light',
      'firewall',
      'balanced',
      'gfw',
      'aggressive',
    ].contains(s.obfuscation)) {
      s.obfuscation = 'off';
    }

    // ─── پورت محلی ───
    if (s.aetherLocalPort < 1 || s.aetherLocalPort > 65535) {
      s.aetherLocalPort = 1819;
    }
  }

  /// پارامترهای Psiphon.
  static void _validatePsiphon(AppSettings s) {
    if (!['socks5', 'http'].contains(s.proxyType)) s.proxyType = 'socks5';

    // ⬅ upstreamType های معتبر: 0..5
    //   0 = direct
    //   1 = manual
    //   2 = Aether upstream (Preset 2)
    //   3 = Conduit
    //   4 = Tor upstream
    //   5 = SSTP upstream
    if (s.upstreamType < 0 || s.upstreamType > 5) {
      s.upstreamType = 0;
    }
  }

  /// پارامترهای Tor.
  static void _validateTor(AppSettings s) {
    if (![
      'direct',
      'bridge',
      'manual',
      'aether',
      'psiphon',
      'sstp',
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

  /// پارامترهای SSTP.
  static void _validateSstp(AppSettings s) {
    if (s.sstpPort < 1 || s.sstpPort > 65535) s.sstpPort = 443;
    if (s.sstpSocksPort < 1 || s.sstpSocksPort > 65535) {
      s.sstpSocksPort = 1082;
    }
    if (s.sstpHttpPort < 1 || s.sstpHttpPort > 65535) {
      s.sstpHttpPort = 8082;
    }
    if (s.sstpUpstreamType < 0 || s.sstpUpstreamType > 4) {
      s.sstpUpstreamType = 0;
    }
    if (!['socks5', 'http', 'socks5h'].contains(s.sstpProxyType)) {
      s.sstpProxyType = 'socks5';
    }
    if (s.sstpProxyPort < 0 || s.sstpProxyPort > 65535) {
      s.sstpProxyPort = 0;
    }
  }

  /// پارامترهای Conduit.
  static void _validateConduit(AppSettings s) {
    if (!['auto', 'public', 'custom'].contains(s.conduitMode)) {
      s.conduitMode = 'auto';
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  پروفایل شبکه واچ‌داگ.
  ///
  ///  فقط سه مقدار مجاز: 'stable' | 'normal' | 'harsh'
  ///  پیش‌فرض در صورت مقدار نامعتبر: 'normal'
  ///
  ///  ⚠️ Manual وجود ندارد — تصمیم عمدی برای سادگی.
  /// ═══════════════════════════════════════════════════════════════
  static void _validateWatchdogProfile(AppSettings s) {
    const valid = {'stable', 'normal', 'harsh'};
    if (!valid.contains(s.watchdogNetworkProfile)) {
      s.watchdogNetworkProfile = 'normal';
    }
  }
}
