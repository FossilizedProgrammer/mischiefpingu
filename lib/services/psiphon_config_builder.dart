// lib/services/psiphon_config_builder.dart
library;

import 'dart:convert';
import '../models/settings_model.dart';
import 'process_service.dart';
import 'psiphon/psiphon_fronting_builder.dart';
import 'psiphon/psiphon_upstream_builder.dart';

class PsiphonConfigBuilder {
  final AppSettings settings;
  final List<String> ipList;
  final ProcessService processService;

  late final PsiphonFrontingBuilder _fronting;
  late final PsiphonUpstreamBuilder _upstream;

  PsiphonConfigBuilder({
    required this.settings,
    required this.ipList,
    required this.processService,
  }) {
    _fronting = PsiphonFrontingBuilder(
      settings: settings,
      ipList: ipList,
      processService: processService,
    );
    _upstream = PsiphonUpstreamBuilder(
      settings: settings,
      processService: processService,
    );
  }

  String build() {
    final isConduit = settings.upstreamType == 3;
    final config = _baseConfig(isConduit: isConduit);

    if (settings.onlyIpv4) config["NetworkStack"] = "IPv4Only";

    _upstream.apply(config);

    if (isConduit && !_upstream.hasOverride) {
      _applyConduit(config);
    } else if (_upstream.hasOverride) {
      config["InproxyEnabled"] = false;
      config["InproxyAllowClient"] = false;
    }

    _fronting.apply(config);

    final jsonStr = const JsonEncoder.withIndent('  ').convert(config);
    processService.addLog(
      '→ Psiphon config generated (${jsonStr.length} bytes)',
      source: LogSource.psiphon,
    );

    _logFinalState();

    return jsonStr;
  }

  Map<String, dynamic> _baseConfig({required bool isConduit}) {
    final config = <String, dynamic>{
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
    };

    if (isConduit) {
      config["ServerEntrySignaturePublicKey"] =
          "sHuUVTWaRyh5pZwy4UguSgkwmBe0EHtJJkoF5WrxmvA=";
      config["DeviceRegion"] = "IR";
    }

    return config;
  }

  void _applyConduit(Map<String, dynamic> config) {
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
        "IR", "CN", "RU", "BY", "TM", "KP"
      ];
    }

    _applyBrokerSpecs(config);
  }

  void _applyBrokerSpecs(Map<String, dynamic> config) {
    final brokerJson = settings.conduitBrokerSpecsJson.trim();
    if (brokerJson.isEmpty) return;

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

  void _logFinalState() {
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
  }
}
