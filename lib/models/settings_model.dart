// lib/models/settings_model.dart
library;

import 'settings_serialization.dart';

class AppSettings {
  // ─── Fronting / Psiphon core ───
  String ip;
  String httpHost;
  String tlsSni;
  bool isFronted;
  bool useSunAndLion;
  bool onlyIpv4;
  bool autoFindIpAndSni;
  bool saveFoundIpsAndSni;

  /// upstreamType:
  ///   0 = Direct (no upstream)
  ///   1 = Manual proxy
  ///   2 = Aether (SOCKS upstream)
  ///   3 = Conduit (WebRTC Inproxy)
  ///   4 = Tor (SOCKS upstream)
  ///   5 = SSTP (SOCKS upstream)
  int upstreamType;

  int socksPort;
  int httpPort;
  String egressRegion;
  String proxyType;
  String proxyIp;
  int proxyPort;
  String proxyUser;
  String proxyPass;

  // ─── Auto reconnect ───
  bool autoReconnectPsiphon;
  bool autoReconnectAether;
  bool autoReconnectTor;
  bool autoReconnectSstp;

  // ─── Aether ───
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

  // ─── Psiphon ───
  bool psiphonShareLan;
  String psiphonBuildRev;
  String psiphonBinarySha;

  // ─── Conduit ───
  String conduitMode;
  String conduitCompartmentId;
  bool conduitRejectCensoredCountries;
  String conduitBrokerSpecsJson;

  // ─── Tor ───
  String torTransport;
  String torBridges;
  String torExitCountry;
  int torSocksPort;
  int torHttpPort;
  bool torShareLan;

  // ─── SSTP ───
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

  // ─── Theme ───
  String themeId;

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
    this.aetherProtocol = 'auto',
    this.masqueOption = 'HTTP-3',
    this.aetherLocalPort = 1819,
    this.aetherScanMode = 'turbo',
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
  });

  // ─── Delegating serialization (سازگاری با کد قبلی) ───
  factory AppSettings.fromJson(Map<String, dynamic> m) =>
      AppSettingsSerialization.fromJson(m);

  Map<String, dynamic> toJson() => AppSettingsSerialization(this).toJsonMap();

  String toJsonString() => AppSettingsSerialization(this).toJsonString();

  // ─── Computed getters ───
  bool get isConduit => upstreamType == 3;

  bool get effectiveUseSunAndLion => useSunAndLion && isFronted && !isConduit;

  bool get isDirectPsiphon =>
      (upstreamType == 0 || upstreamType == 4) && !isFronted;

  void applyPreset(int number) {
    switch (number) {
      case 1:
        isFronted = true;
        useSunAndLion = true;
        upstreamType = 0;
        autoFindIpAndSni = true;
        saveFoundIpsAndSni = true;
        break;
      case 2:
        isFronted = false;
        useSunAndLion = false;
        upstreamType = 2;
        break;
      case 3:
        isFronted = false;
        useSunAndLion = false;
        upstreamType = 3;
        break;
      case 4:
        isFronted = false;
        useSunAndLion = false;
        upstreamType = 4;
        break;
    }
  }
}
