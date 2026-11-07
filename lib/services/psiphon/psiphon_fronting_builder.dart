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
      "FRONTED-MEEK-CDN-QUIC-OSSH",
    ];

    // ═══════════════════════════════════════════════════════════
    //  🆕 Smart Fronting: اولویت‌بندی سرورهای موفق قبلی
    //  
    //  اگر settings.ip و settings.tlsSni ست شده باشند (یعنی
    //  از اتصال قبلی ذخیره شده‌اند)، آن‌ها را در ابتدای لیست
    //  قرار می‌دهیم تا Psiphon اول آن‌ها را امتحان کند.
    // ═══════════════════════════════════════════════════════════
    final dialAddresses = <String>[];
    
    // اول IP+SNI موفق قبلی (اگر موجود باشد)
    if (settings.ip.isNotEmpty && settings.tlsSni.isNotEmpty) {
      dialAddresses.add(settings.ip);
      processService.addLog(
        '→ Smart Fronting: prioritizing last successful IP ${settings.ip}',
        source: LogSource.psiphon,
      );
    }
    
    // بعد بقیه IPها از ipList
    for (final ip in ipList) {
      if (!dialAddresses.contains(ip)) {
        dialAddresses.add(ip);
      }
    }

    final addresses = dialAddresses.take(20).toList();

    config["FrontedMeekDialOverrides"] = [
      {
        "OverrideID": "user-fronting",
        "MatchDialAddressRegexes": [".*"],
        "DialAddresses": addresses,
        "SNIServerName": settings.tlsSni.isNotEmpty 
            ? settings.tlsSni 
            : (ipList.isNotEmpty ? settings.tlsSni : "a248.e.akamai.net"),
        "VerifyServerNames": [
          settings.tlsSni,
          settings.httpHost,
          if (settings.ip.isNotEmpty) settings.ip,
        ],
        "ALPNProtocols": ["h2", "http/1.1"],
        "TLSProfile": "Chrome-83",
      }
    ];

    config["FrontedMeekDialOverridesProbability"] = 1.0;
    config["FrontedMeekCDNScanUseBuiltInSpec"] = settings.autoFindIpAndSni;

    processService.addLog(
      '→ Fronting IP: ${settings.ip}',
      source: LogSource.psiphon,
    );
    processService.addLog(
      '→ TLS SNI: ${settings.tlsSni}',
      source: LogSource.psiphon,
    );
    processService.addLog(
      '→ HTTP Host: ${settings.httpHost}',
      source: LogSource.psiphon,
    );
    processService.addLog(
      '→ SunAndLion: ${settings.useSunAndLion}',
      source: LogSource.psiphon,
    );
  }
}
