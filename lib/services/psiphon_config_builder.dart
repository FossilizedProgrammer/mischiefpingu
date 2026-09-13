import 'dart:convert';
import '../models/settings_model.dart';
import 'process_service.dart';

class PsiphonConfigBuilder {
  final AppSettings settings;
  final List<String> ipList;
  final ProcessService processService;
  PsiphonConfigBuilder({
    required this.settings,
    required this.ipList,
    required this.processService,
  });

  String build() {
    final bool isConduit = settings.upstreamType == 3;
    final Map<String, dynamic> config = {
      "PropagationChannelId": "92AACC5BABE0944C",
      "SponsorId": "1BC527D3D09985CF",
      "LocalSocksProxyPort": settings.socksPort,
      "LocalHttpProxyPort": settings.httpPort,
      "DisableTactics": !isConduit,
      "AggressiveEstablishment": !isConduit,
      "UseIndistinguishableTLS": true,
      "TunnelWholeDevice": false,
      "EgressRegion": settings.egressRegion,
      "EstablishTunnelTimeoutSeconds": 0,
      "EmitDiagnosticNotices": true,
      "EmitBytesTransferred": true,
      "ClientPlatform": "Linux",
      // ⚠️ توجه: دو کلید زیر عمداً از اینجا حذف شده‌اند تا Fronting خراب نشود.
    };

    // ─── این دو کلید فقط و فقط برای Conduit (upstreamType == 3) لازم هستند ───
    if (isConduit) {
      config["ServerEntrySignaturePublicKey"] =
          "sHuUVTWaRyh5pZwy4UguSgkwmBe0EHtJJkoF5WrxmvA=";
      config["DeviceRegion"] = "IR";
    }

    if (settings.onlyIpv4) config["NetworkStack"] = "IPv4Only";

    final bool hasUpstreamOverride =
        settings.upstreamType == 1 ||
        settings.upstreamType == 2 ||
        settings.upstreamType == 4 ||
        settings.upstreamType == 5;

    // ─── Upstream proxy configuration ───
    switch (settings.upstreamType) {
      case 1:
        String url = "${settings.proxyType}://";
        if (settings.proxyUser.isNotEmpty) {
          url += "${settings.proxyUser}:${settings.proxyPass}@";
        }
        url += "${settings.proxyIp}:${settings.proxyPort}";
        config["UpstreamProxyURL"] = url;
        processService.addLog(
          '→ Psiphon upstream: Manual proxy ($url)',
          source: LogSource.psiphon,
        );
        break;
      case 2:
        config["UpstreamProxyURL"] =
            "socks5://127.0.0.1:${settings.aetherLocalPort}";
        processService.addLog(
          '→ Psiphon upstream: Aether (127.0.0.1:${settings.aetherLocalPort})',
          source: LogSource.psiphon,
        );
        break;
      case 4:
        config["UpstreamProxyURL"] =
            "socks5://127.0.0.1:${settings.torSocksPort}";
        processService.addLog(
          '→ Psiphon upstream: Tor (127.0.0.1:${settings.torSocksPort})',
          source: LogSource.psiphon,
        );
        break;
      case 5:
        config["UpstreamProxyURL"] =
            "socks5://127.0.0.1:${settings.sstpSocksPort}";
        processService.addLog(
          '→ Psiphon upstream: SSTP (127.0.0.1:${settings.sstpSocksPort})',
          source: LogSource.psiphon,
        );
        break;
      default:
        break;
    }

    if (settings.upstreamType == 3 && !hasUpstreamOverride) {
      config["ClientVersion"] = "45";
      config["LimitTunnelProtocols"] = [
        "INPROXY-WEBRTC-SSH",
        "INPROXY-WEBRTC-OSSH",
        "INPROXY-WEBRTC-TLS-OSSH",
        "INPROXY-WEBRTC-UNFRONTED-MEEK-OSSH",
        "INPROXY-WEBRTC-UNFRONTED-MEEK-HTTPS-OSSH",
        "INPROXY-WEBRTC-UNFRONTED-MEEK-SESSION-TICKET-OSSH",
        "INPROXY-WEBRTC-FRONTED-MEEK-OSSH",
        "INPROXY-WEBRTC-FRONTED-MEEK-HTTP-OSSH",
        "INPROXY-WEBRTC-QUIC-OSSH",
        "INPROXY-WEBRTC-FRONTED-MEEK-QUIC-OSSH",
        "INPROXY-WEBRTC-SHADOWSOCKS-OSSH",
      ];
      config["InproxyEnabled"] = true;
      config["InproxyAllowClient"] = true;

      final compartment = settings.conduitCompartmentId.trim();
      if (compartment.isNotEmpty && settings.conduitMode != 'public') {
        config["InproxyClientPersonalCompartmentID"] = compartment;
      }

      if (settings.conduitRejectCensoredCountries) {
        config["InproxyRejectProxyCountryCodes"] = [
          "IR",
          "CN",
          "RU",
          "BY",
          "TM",
          "KP"
        ];
      }

      final brokerJson = settings.conduitBrokerSpecsJson.trim();
      if (brokerJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(brokerJson);
          if (decoded is List && decoded.isNotEmpty) {
            config["InproxyClientBrokerSpecs"] = decoded;
            processService.addLog(
              '→ Conduit: ${decoded.length} static broker spec(s) configured',
              source: LogSource.psiphon,
            );
          } else {
            processService.addLog(
              '⚠ Conduit broker specs ignored: expected a non-empty JSON array',
              source: LogSource.psiphon,
            );
          }
        } catch (e) {
          processService.addLog(
            '⚠ Conduit broker specs ignored: invalid JSON ($e)',
            source: LogSource.psiphon,
          );
        }
      }
    } else if (hasUpstreamOverride) {
      config["InproxyEnabled"] = false;
      config["InproxyAllowClient"] = false;
    }

    if (settings.useSunAndLion &&
        settings.isFronted &&
        settings.upstreamType != 3) {
      config["ClientVersion"] = "45";
      config["LimitTunnelProtocols"] = [
        "FRONTED-MEEK-CDN-OSSH",
        "FRONTED-MEEK-CDN-HTTP-OSSH",
        "FRONTED-MEEK-CDN-QUIC-OSSH"
      ];

      final dialAddresses = <String>{};
      if (settings.ip.isNotEmpty) dialAddresses.add(settings.ip);
      dialAddresses.addAll(ipList);
      final addresses = dialAddresses.take(20).toList();

      config["FrontedMeekDialOverrides"] = [
        {
          "OverrideID": "user-fronting",
          "MatchDialAddressRegexes": [".*"],
          "DialAddresses": addresses,
          "SNIServerName": settings.tlsSni,
          "VerifyServerNames": [
            settings.tlsSni,
            settings.httpHost,
            if (settings.ip.isNotEmpty) settings.ip
          ],
          "ALPNProtocols": ["h2", "http/1.1"],
          "TLSProfile": "Chrome-83",
        }
      ];
      config["FrontedMeekDialOverridesProbability"] = 1.0;
      config["FrontedMeekCDNScanUseBuiltInSpec"] = settings.autoFindIpAndSni;
    }

    final jsonStr = const JsonEncoder.withIndent('  ').convert(config);
    processService.addLog(
      '→ Psiphon config generated (${jsonStr.length} bytes)',
      source: LogSource.psiphon,
    );

    if (settings.isFronted) {
      processService.addLog('→ Fronting IP: ${settings.ip}',
          source: LogSource.psiphon);
      processService.addLog('→ TLS SNI: ${settings.tlsSni}',
          source: LogSource.psiphon);
      processService.addLog('→ HTTP Host: ${settings.httpHost}',
          source: LogSource.psiphon);
      processService.addLog('→ SunAndLion: ${settings.useSunAndLion}',
          source: LogSource.psiphon);
    }

    if (settings.upstreamType == 3) {
      processService.addLog(
        '→ Conduit mode: ${settings.conduitMode}'
        '${settings.conduitCompartmentId.trim().isNotEmpty ? ' (personal compartment set)' : ''}',
        source: LogSource.psiphon,
      );
      processService.addLog(
        '→ Conduit: tactics enabled (broker specs via tactics)',
        source: LogSource.psiphon,
      );
      if (settings.conduitRejectCensoredCountries) {
        processService.addLog('→ Conduit: rejecting censored relays',
            source: LogSource.psiphon);
      }
    }

    if (settings.psiphonShareLan) {
      processService.addLog(
        '→ Psiphon Share on LAN: enabled (via Dart native forwarders)',
        source: LogSource.psiphon,
      );
    }

    return jsonStr;
  }
}
