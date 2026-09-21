library;

import 'settings_serialization.dart';

part 'settings_presets.dart';
part 'settings_profiles.dart';

class AppSettings {
  String ip;
  String httpHost;
  String tlsSni;
  bool isFronted;
  bool useSunAndLion;
  bool onlyIpv4;
  bool autoFindIpAndSni;
  bool saveFoundIpsAndSni;
  bool watchdogEnabled;
  String watchdogNetworkProfile;  

  int upstreamType;

  int socksPort;
  int httpPort;
  String egressRegion;
  String proxyType;
  String proxyIp;
  int proxyPort;
  String proxyUser;
  String proxyPass;

  bool autoReconnectPsiphon;
  bool autoReconnectAether;
  bool autoReconnectTor;
  bool autoReconnectSstp;

  String aetherProfile;

  String aetherProtocol;

  String masqueOption;
  int aetherLocalPort;
  String aetherScanMode;
  String ipType;
  String obfuscation;
  bool aetherShareLan;
  bool aetherQuickReconnect;
  String aetherCustomEndpoint;
  bool aetherTryLastEndpointFirst;

  bool psiphonShareLan;
  String psiphonBuildRev;
  String psiphonBinarySha;

  String conduitMode;
  String conduitCompartmentId;
  bool conduitRejectCensoredCountries;
  String conduitBrokerSpecsJson;

  String torTransport;
  String torBridges;
  String torExitCountry;
  int torSocksPort;
  int torHttpPort;
  bool torShareLan;

  String torProxyType;
  String torProxyIp;
  int torProxyPort;
  String torProxyUser;
  String torProxyPass;

  String sstpServer;
  int sstpPort;
  String sstpUser;
  String sstpPass;
  int sstpSocksPort;
  int sstpHttpPort;
  int sstpUpstreamType;
  String sstpProxyType;
  String sstpProxyIp;
  int sstpProxyPort;
  String sstpProxyUser;
  String sstpProxyPass;
  String sstpSni;
  String sstpFingerprint;
  bool sstpShareLan;
  bool sstpVerbose;

  String themeId;
  bool muted;

  /// لیست منابع فعال لاگ.
  ///
  /// اگر خالی باشد، همه منابع لاگ می‌شوند.
  /// در غیر این صورت فقط منابع موجود در لیست لاگ می‌شوند.
  List<String> enabledLogSources;

  AppSettings({
    this.ip = '23.215.0.206',
    this.httpHost = 'aparat.com',
    this.tlsSni = 'a248.e.akamai.net',
    this.isFronted = true,
    this.useSunAndLion = true,
    this.onlyIpv4 = false,
    this.autoFindIpAndSni = true,
    this.saveFoundIpsAndSni = true,
    this.upstreamType = 0,
    this.socksPort = 1080,
    this.httpPort = 8080,
    this.egressRegion = '',
    this.proxyType = 'socks5',
    this.proxyIp = '',
    this.proxyPort = 1080,
    this.proxyUser = '',
    this.proxyPass = '',
    this.autoReconnectPsiphon = true,
    this.autoReconnectAether = true,
    this.autoReconnectTor = true,
    this.autoReconnectSstp = true,
    this.aetherProfile = 'adaptive',
    this.aetherProtocol = 'auto',
    this.masqueOption = 'HTTP-3',
    this.aetherLocalPort = 1819,
    this.aetherScanMode = 'balanced',
    this.ipType = 'ipv4',
    this.obfuscation = 'off',
    this.aetherShareLan = false,
    this.aetherQuickReconnect = true,
    this.aetherCustomEndpoint = '',
    this.aetherTryLastEndpointFirst = true,
    this.psiphonShareLan = false,
    this.conduitMode = 'auto',
    this.conduitCompartmentId = '',
    this.conduitRejectCensoredCountries = true,
    this.conduitBrokerSpecsJson = '',
    this.torTransport = 'direct',
    this.torBridges = '',
    this.torExitCountry = '',
    this.torSocksPort = 19050,
    this.torHttpPort = 18081,
    this.torShareLan = false,
    this.torProxyType = 'socks5',
    this.torProxyIp = '',
    this.torProxyPort = 1080,
    this.torProxyUser = '',
    this.torProxyPass = '',
    this.sstpServer = '',
    this.sstpPort = 443,
    this.sstpUser = '',
    this.sstpPass = '',
    this.sstpSocksPort = 1082,
    this.sstpHttpPort = 8082,
    this.sstpUpstreamType = 0,
    this.sstpProxyType = 'socks5',
    this.sstpProxyIp = '',
    this.sstpProxyPort = 0,
    this.sstpProxyUser = '',
    this.sstpProxyPass = '',
    this.sstpSni = '',
    this.sstpFingerprint = '',
    this.sstpShareLan = false,
    this.sstpVerbose = true,
    this.psiphonBuildRev = '',
    this.psiphonBinarySha = '',
    this.themeId = 'ocean',
    this.muted = false,
    this.watchdogEnabled = true,
    this.watchdogNetworkProfile = 'normal',
    List<String>? enabledLogSources,
  }) : enabledLogSources =
           enabledLogSources ??
           ['Psiphon', 'Aether', 'Tor', 'SSTP', 'App', 'System'];

  factory AppSettings.fromJson(Map<String, dynamic> m) =>
      AppSettingsSerialization.fromJson(m);

  Map<String, dynamic> toJson() => AppSettingsSerialization(this).toJsonMap();

  String toJsonString() => AppSettingsSerialization(this).toJsonString();

  bool get isConduit => upstreamType == 3;
  bool get effectiveUseSunAndLion => useSunAndLion && isFronted && !isConduit;
  bool get isDirectPsiphon =>
      (upstreamType == 0 || upstreamType == 4) && !isFronted;

  bool get isAetherProfileAutomatic => aetherProfile != 'manual';

  bool get isAetherProtocolLockedByProfile => isAetherProfileAutomatic;
}
