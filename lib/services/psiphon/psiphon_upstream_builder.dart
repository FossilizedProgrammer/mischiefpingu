library;

import '../../models/settings_model.dart';
import '../process_service.dart';

class PsiphonUpstreamBuilder {
  /// بدون آپ‌استریم — اتصال مستقیم.
  static const int direct = 0;

  /// پروکسی دستی که خود کاربر آدرس/پورت‌اش را می‌دهد.
  static const int manual = 1;

  /// Conduit (WebRTC Inproxy) — در کانفیگ جداگانه اعمال می‌شود.
  static const int conduit = 3;

  /// SOCKS محلی Tor.
  static const int tor = 4;

  /// SOCKS محلی SSTP.
  static const int sstp = 5;

  /// SOCKS محلی WireGuard.
  static const int wireguard = 6;

  /// SOCKS محلی Firefox VPN.
  static const int ffvpn = 7;

  /// SOCKS محلی Lantern.
  static const int lantern = 8;

  /// SOCKS محلی Geph.
  static const int geph = 9;

  final AppSettings settings;
  final ProcessService processService;

  PsiphonUpstreamBuilder({
    required this.settings,
    required this.processService,
  });

  /// آیا upstream override فعال است؟
  bool get hasOverride => const {
        manual,
        tor,
        sstp,
        wireguard,
        ffvpn,
        lantern,
        geph,
      }.contains(settings.upstreamType);

  /// بخش upstream را به config اضافه می‌کند.
  void apply(Map<String, dynamic> config) {
    switch (settings.upstreamType) {
      case manual:
        _applyManual(config);
        break;
      case tor:
        _applySocks(config, settings.torSocksPort, 'Tor');
        break;
      case sstp:
        _applySocks(config, settings.sstpSocksPort, 'SSTP');
        break;
      case wireguard:
        _applySocks(config, settings.wireguardSocksPort, 'WireGuard');
        break;
      case ffvpn:
        _applySocks(config, settings.ffvpnSocksPort, 'Firefox VPN');
        break;
      case lantern:
        _applySocks(config, settings.lanternSocksPort, 'Lantern');
        break;
      case geph:
        _applySocks(config, settings.gephSocksPort, 'Geph');
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
