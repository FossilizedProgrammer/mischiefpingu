// lib/models/settings_validation.dart

library;

import 'settings_model.dart';

class SettingsValidation {
  SettingsValidation._();

  static const Set<String> _validLogSources = {
    'Psiphon',
    'Aether',
    'Tor',
    'SSTP',
    'WireGuard',
    'App',
    'System',
  };

  static const List<String> _defaultLogSources = [
    'Psiphon',
    'Aether',
    'Tor',
    'SSTP',
    'WireGuard',
    'App',
    'System',
  ];

  static const Set<String> _validEndpointPinningModes = {
    'automatic',
    'custom_first',
    'custom_only',
  };

  static void validateAndNormalize(AppSettings s) {
    _validateAetherProfile(s);
    _validateAether(s);
    _validateEndpointPinning(s);
    _validatePsiphon(s);
    _validateTor(s);
    _validateSstp(s);
    _validateConduit(s);
    _validateLogSources(s);
    _validateWatchdogProfile(s);
    _validateWireGuard(s);
  }

  static void _validateEndpointPinning(AppSettings s) {
    if (!_validEndpointPinningModes.contains(s.aetherEndpointPinning)) {
      s.aetherEndpointPinning = 'automatic';
    }
    if (s.aetherCustomEndpoint.trim().isEmpty &&
        s.aetherEndpointPinning != 'automatic') {
      s.aetherEndpointPinning = 'automatic';
    }
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

  static void _validateAetherProfile(AppSettings s) {
    const valid = {'adaptive', 'patchy', 'strict', 'manual'};
    if (!valid.contains(s.aetherProfile)) {
      s.aetherProfile = 'adaptive';
    }
  }

  static void _validateAether(AppSettings s) {
    if (s.aetherProfile != 'manual') {
      s.aetherProtocol = 'auto';
    } else if (!['masque', 'wireguard', 'gool', 'mim']
        .contains(s.aetherProtocol)) {
      s.aetherProtocol = 'masque';
    }
    if (s.masqueOption != 'HTTP-2') s.masqueOption = 'HTTP-3';

    if (!['turbo', 'balanced', 'thorough', 'stealth', 'ironclad']
        .contains(s.aetherScanMode)) {
      s.aetherScanMode = 'balanced';
    }
    if (s.aetherScanMode == 'turbo' && s.aetherProfile != 'manual') {
      s.aetherScanMode = 'balanced';
    }
    if (!['ipv4', 'ipv6', 'both'].contains(s.ipType)) s.ipType = 'ipv4';
    if (!['off', 'light', 'firewall', 'balanced', 'gfw', 'aggressive']
        .contains(s.obfuscation)) {
      s.obfuscation = 'off';
    }
    if (s.aetherLocalPort < 1 || s.aetherLocalPort > 65535) {
      s.aetherLocalPort = 1819;
    }
  }

  static void _validatePsiphon(AppSettings s) {
    if (!['socks5', 'http'].contains(s.proxyType)) s.proxyType = 'socks5';

    if (s.upstreamType < 0 || s.upstreamType > 6) {
      s.upstreamType = 0;
    }
  }

  static void _validateTor(AppSettings s) {
    if (![
      'direct',
      'bridge',
      'manual',
      'aether',
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
    if (s.sstpUpstreamType < 0 || s.sstpUpstreamType > 5) {
      s.sstpUpstreamType = 0;
    }
    if (!['socks5', 'http', 'socks5h'].contains(s.sstpProxyType)) {
      s.sstpProxyType = 'socks5';
    }
    if (s.sstpProxyPort < 0 || s.sstpProxyPort > 65535) {
      s.sstpProxyPort = 0;
    }
  }

  static void _validateConduit(AppSettings s) {
    if (!['auto', 'public', 'custom'].contains(s.conduitMode)) {
      s.conduitMode = 'auto';
    }
  }

  static void _validateWatchdogProfile(AppSettings s) {
    const valid = {'stable', 'normal', 'harsh'};
    if (!valid.contains(s.watchdogNetworkProfile)) {
      s.watchdogNetworkProfile = 'normal';
    }
  }
}
