library;

import 'dart:convert';

import 'settings_model.dart';
import 'settings_validation.dart';

extension AppSettingsSerialization on AppSettings {
  static String _s(Map m, String k, String d) {
    final v = m[k];
    return v is String ? v : (v == null ? d : v.toString());
  }

  static int _i(Map m, String k, int d) {
    final v = m[k];
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? d;
    return d;
  }

  static bool _b(Map m, String k, bool d) {
    final v = m[k];
    if (v is bool) return v;
    if (v is String) return v == 'true';
    if (v is num) return v != 0;
    return d;
  }

  static List<String> _list(Map m, String k, List<String> d) {
    final v = m[k];
    if (v is List) {
      return v.map((e) => e.toString()).toList();
    }
    return d;
  }

  static AppSettings fromJson(Map<String, dynamic> m) {
    final s = AppSettings(
      ip: _s(m, 'ip', ''),
      httpHost: _s(m, 'httpHost', 'aparat.com'),
      tlsSni: _s(m, 'tlsSni', 'a248.e.akamai.net'),
      isFronted: _b(m, 'isFronted', false),
      useSunAndLion: _b(m, 'useSunAndLion', false),
      onlyIpv4: _b(m, 'onlyIpv4', false),
      autoFindIpAndSni: _b(m, 'autoFindIpAndSni', false),
      saveFoundIpsAndSni: _b(m, 'saveFoundIpsAndSni', false),
      upstreamType: _i(m, 'upstreamType', 0),
      socksPort: _i(m, 'socksPort', 1080),
      httpPort: _i(m, 'httpPort', 8080),
      egressRegion: _s(m, 'egressRegion', ''),
      proxyType: _s(m, 'proxyType', 'socks5'),
      proxyIp: _s(m, 'proxyIp', ''),
      proxyPort: _i(m, 'proxyPort', 1080),
      proxyUser: _s(m, 'proxyUser', ''),
      proxyPass: _s(m, 'proxyPass', ''),
      autoReconnectPsiphon: _b(m, 'autoReconnectPsiphon', true),
      autoReconnectAether: _b(m, 'autoReconnectAether', true),
      autoReconnectTor: _b(m, 'autoReconnectTor', true),
      autoReconnectSstp: _b(m, 'autoReconnectSstp', true),
      aetherProfile: _s(m, 'aetherProfile', 'adaptive'),
      aetherProtocol: _s(m, 'aetherProtocol', 'auto'),
      masqueOption: _s(m, 'masqueOption', 'HTTP-3'),
      aetherLocalPort: _i(m, 'aetherLocalPort', 1819),
      aetherScanMode: _s(m, 'aetherScanMode', 'balanced'),
      ipType: _s(m, 'ipType', 'ipv4'),
      obfuscation: _s(m, 'obfuscation', 'off'),
      aetherShareLan: _b(m, 'aetherShareLan', false),
      aetherQuickReconnect: _b(m, 'aetherQuickReconnect', true),
      psiphonShareLan: _b(m, 'psiphonShareLan', false),
      conduitMode: _s(m, 'conduitMode', 'auto'),
      conduitCompartmentId: _s(m, 'conduitCompartmentId', ''),
      conduitRejectCensoredCountries: _b(
        m,
        'conduitRejectCensoredCountries',
        true,
      ),
      conduitBrokerSpecsJson: _s(m, 'conduitBrokerSpecsJson', ''),
      torTransport: _s(m, 'torTransport', 'direct'),
      torBridges: _s(m, 'torBridges', ''),
      torExitCountry: _s(m, 'torExitCountry', ''),
      torSocksPort: _i(m, 'torSocksPort', 19050),
      torHttpPort: _i(m, 'torHttpPort', 18081),
      torShareLan: _b(m, 'torShareLan', false),
      torProxyType: _s(m, 'torProxyType', 'socks5'),
      torProxyIp: _s(m, 'torProxyIp', ''),
      torProxyPort: _i(m, 'torProxyPort', 1080),
      torProxyUser: _s(m, 'torProxyUser', ''),
      torProxyPass: _s(m, 'torProxyPass', ''),
      sstpServer: _s(m, 'sstpServer', ''),
      sstpPort: _i(m, 'sstpPort', 443),
      sstpUser: _s(m, 'sstpUser', ''),
      sstpPass: _s(m, 'sstpPass', ''),
      sstpSocksPort: _i(m, 'sstpSocksPort', 1082),
      sstpHttpPort: _i(m, 'sstpHttpPort', 8082),
      sstpUpstreamType: _i(m, 'sstpUpstreamType', 0),
      sstpProxyType: _s(m, 'sstpProxyType', 'socks5'),
      sstpProxyIp: _s(m, 'sstpProxyIp', ''),
      sstpProxyPort: _i(m, 'sstpProxyPort', 0),
      sstpProxyUser: _s(m, 'sstpProxyUser', ''),
      sstpProxyPass: _s(m, 'sstpProxyPass', ''),
      sstpSni: _s(m, 'sstpSni', ''),
      sstpFingerprint: _s(m, 'sstpFingerprint', ''),
      sstpShareLan: _b(m, 'sstpShareLan', false),
      sstpVerbose: _b(m, 'sstpVerbose', true),
      psiphonBuildRev: _s(m, 'psiphonBuildRev', ''),
      psiphonBinarySha: _s(m, 'psiphonBinarySha', ''),
      aetherCustomEndpoint: _s(m, 'aetherCustomEndpoint', ''),
      aetherTryLastEndpointFirst: _b(m, 'aetherTryLastEndpointFirst', true),
      themeId: _s(m, 'themeId', 'ocean'),
      muted: _b(m, 'muted', false),
      wireguardConfigRaw: _s(m, 'wireguardConfigRaw', ''),
      wireguardSocksPort: _i(m, 'wireguardSocksPort', 25344),
      wireguardShareLan: _b(m, 'wireguardShareLan', false),
      wireguardAutoReconnect: _b(m, 'wireguardAutoReconnect', true),
      watchdogEnabled: _b(m, 'watchdogEnabled', true),
      watchdogNetworkProfile: _s(m, 'watchdogNetworkProfile', 'normal'),
      enabledLogSources: _list(m, 'enabledLogSources', [
        'Psiphon',
        'Aether',
        'Tor',
        'SSTP',
        'App',
        'System',
      ]),
    );
    SettingsValidation.validateAndNormalize(s);
    return s;
  }

  Map<String, dynamic> toJsonMap() => {
        'ip': ip,
        'httpHost': httpHost,
        'tlsSni': tlsSni,
        'isFronted': isFronted,
        'useSunAndLion': useSunAndLion,
        'onlyIpv4': onlyIpv4,
        'autoFindIpAndSni': autoFindIpAndSni,
        'saveFoundIpsAndSni': saveFoundIpsAndSni,
        'upstreamType': upstreamType,
        'socksPort': socksPort,
        'httpPort': httpPort,
        'egressRegion': egressRegion,
        'proxyType': proxyType,
        'proxyIp': proxyIp,
        'proxyPort': proxyPort,
        'proxyUser': proxyUser,
        'proxyPass': proxyPass,
        'autoReconnectPsiphon': autoReconnectPsiphon,
        'autoReconnectAether': autoReconnectAether,
        'autoReconnectTor': autoReconnectTor,
        'autoReconnectSstp': autoReconnectSstp,
        'aetherProfile': aetherProfile,
        'aetherProtocol': aetherProtocol,
        'masqueOption': masqueOption,
        'aetherLocalPort': aetherLocalPort,
        'aetherScanMode': aetherScanMode,
        'ipType': ipType,
        'obfuscation': obfuscation,
        'aetherShareLan': aetherShareLan,
        'aetherQuickReconnect': aetherQuickReconnect,
        'psiphonShareLan': psiphonShareLan,
        'conduitMode': conduitMode,
        'conduitCompartmentId': conduitCompartmentId,
        'conduitRejectCensoredCountries': conduitRejectCensoredCountries,
        'conduitBrokerSpecsJson': conduitBrokerSpecsJson,
        'torTransport': torTransport,
        'torBridges': torBridges,
        'torExitCountry': torExitCountry,
        'torSocksPort': torSocksPort,
        'torHttpPort': torHttpPort,
        'torShareLan': torShareLan,
        'torProxyType': torProxyType,
        'torProxyIp': torProxyIp,
        'torProxyPort': torProxyPort,
        'torProxyUser': torProxyUser,
        'torProxyPass': torProxyPass,
        'sstpServer': sstpServer,
        'sstpPort': sstpPort,
        'sstpUser': sstpUser,
        'sstpPass': sstpPass,
        'sstpSocksPort': sstpSocksPort,
        'sstpHttpPort': sstpHttpPort,
        'sstpUpstreamType': sstpUpstreamType,
        'sstpProxyType': sstpProxyType,
        'sstpProxyIp': sstpProxyIp,
        'sstpProxyPort': sstpProxyPort,
        'sstpProxyUser': sstpProxyUser,
        'sstpProxyPass': sstpProxyPass,
        'sstpSni': sstpSni,
        'sstpFingerprint': sstpFingerprint,
        'sstpShareLan': sstpShareLan,
        'sstpVerbose': sstpVerbose,
        'psiphonBuildRev': psiphonBuildRev,
        'psiphonBinarySha': psiphonBinarySha,
        'aetherCustomEndpoint': aetherCustomEndpoint,
        'aetherTryLastEndpointFirst': aetherTryLastEndpointFirst,
        'themeId': themeId,
        'muted': muted,
        'watchdogEnabled': watchdogEnabled,
        'watchdogNetworkProfile': watchdogNetworkProfile,
        'enabledLogSources': enabledLogSources,
        'wireguardConfigRaw': wireguardConfigRaw,
        'wireguardSocksPort': wireguardSocksPort,
        'wireguardShareLan': wireguardShareLan,
        'wireguardAutoReconnect': wireguardAutoReconnect,
      };

  String toJsonString() => jsonEncode(toJsonMap());
}
