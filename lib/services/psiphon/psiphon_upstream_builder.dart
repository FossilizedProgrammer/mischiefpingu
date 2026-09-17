library;

import '../../models/settings_model.dart';
import '../process_service.dart';

class PsiphonUpstreamBuilder {
  final AppSettings settings;
  final ProcessService processService;

  PsiphonUpstreamBuilder({
    required this.settings,
    required this.processService,
  });

  /// آیا upstream override فعال است؟
  bool get hasOverride =>
      settings.upstreamType == 1 ||
      settings.upstreamType == 2 ||
      settings.upstreamType == 4 ||
      settings.upstreamType == 5;

  /// بخش upstream را به config اضافه می‌کند.
  void apply(Map<String, dynamic> config) {
    switch (settings.upstreamType) {
      case 1:
        _applyManual(config);
        break;
      case 2:
        _applySocks(config, settings.aetherLocalPort, 'Aether');
        break;
      case 4:
        _applySocks(config, settings.torSocksPort, 'Tor');
        break;
      case 5:
        _applySocks(config, settings.sstpSocksPort, 'SSTP');
        break;
      default:
        break;
    }
  }

  void _applyManual(Map<String, dynamic> config) {
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
  }

  void _applySocks(Map<String, dynamic> config, int port, String label) {
    config["UpstreamProxyURL"] = "socks5://127.0.0.1:$port";
    processService.addLog(
      '→ Psiphon upstream: $label (127.0.0.1:$port)',
      source: LogSource.psiphon,
    );
  }
}
