// lib/services/psiphon/psiphon_fronting_builder.dart
//
// ═══════════════════════════════════════════════════════════════
//  PsiphonFrontingBuilder — ساخت بخش fronting کانفیگ Psiphon
//  (تفکیک شده از psiphon_config_builder.dart)
// ═══════════════════════════════════════════════════════════════
library;

import '../../models/settings_model.dart';
import '../process_service.dart';

class PsiphonFrontingBuilder {
  final AppSettings settings;
  final List<String> ipList;
  final ProcessService processService;

  PsiphonFrontingBuilder({
    required this.settings,
    required this.ipList,
    required this.processService,
  });

  /// آیا fronting باید اعمال شود؟
  bool get shouldApply =>
      settings.useSunAndLion &&
      settings.isFronted &&
      settings.upstreamType != 3;

  /// بخش fronting را به config اضافه می‌کند.
  void apply(Map<String, dynamic> config) {
    if (!shouldApply) return;

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

    // لاگ
    processService.addLog('→ Fronting IP: ${settings.ip}',
        source: LogSource.psiphon);
    processService.addLog('→ TLS SNI: ${settings.tlsSni}',
        source: LogSource.psiphon);
    processService.addLog('→ HTTP Host: ${settings.httpHost}',
        source: LogSource.psiphon);
    processService.addLog('→ SunAndLion: ${settings.useSunAndLion}',
        source: LogSource.psiphon);
  }
}
