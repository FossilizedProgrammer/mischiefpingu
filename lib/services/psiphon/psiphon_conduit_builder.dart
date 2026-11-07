library;

import 'dart:convert';

import '../../models/settings_model.dart';
import '../process_service.dart';

class PsiphonConduitBuilder {
  final AppSettings settings;
  final ProcessService processService;

  PsiphonConduitBuilder({required this.settings, required this.processService});

  /// اعمال تنظیمات Conduit روی config.
  void apply(Map<String, dynamic> config) {
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
        "KP",
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

  /// لاگ وضعیت نهایی Conduit.
  void logFinalState() {
    if (settings.upstreamType != 3) return;

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
      processService.addLog(
        '→ Conduit: rejecting censored relays',
        source: LogSource.psiphon,
      );
    }
  }
}
