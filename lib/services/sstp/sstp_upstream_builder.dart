library;

import '../../models/settings_model.dart';
import '../process_service.dart';

class SstpUpstreamBuilder {
  /// بدون آپ‌استریم — اتصال مستقیم.
  static const int direct = 0;

  /// پروکسی دستی که خود کاربر آدرس/پورت‌اش را می‌دهد.
  static const int manual = 1;

  /// SOCKS محلی Psiphon.
  static const int psiphon = 3;

  /// SOCKS محلی Tor.
  static const int tor = 4;

  /// SOCKS محلی WireGuard.
  static const int wireguard = 5;

  /// SOCKS محلی Firefox VPN.
  static const int ffvpn = 6;

  /// SOCKS محلی Lantern.
  static const int lantern = 7;

  /// SOCKS محلی Geph.
  static const int geph = 8;

  final AppSettings settings;
  final ProcessService processService;

  SstpUpstreamBuilder({required this.settings, required this.processService});

  int get type => settings.sstpUpstreamType;

  /// args مربوط به upstream را به لیست اضافه می‌کند.
  void apply(List<String> args) {
    switch (settings.sstpUpstreamType) {
      case manual:
        _applyManual(args);
        break;
      case psiphon:
        _applySocks(args, settings.socksPort, 'Psiphon');
        break;
      case tor:
        _applySocks(args, settings.torSocksPort, 'Tor');
        break;
      case wireguard:
        _applySocks(args, settings.wireguardSocksPort, 'WireGuard');
        break;
      case ffvpn:
        _applySocks(args, settings.ffvpnSocksPort, 'Firefox VPN');
        break;
      case lantern:
        _applySocks(args, settings.lanternSocksPort, 'Lantern');
        break;
      case geph:
        _applySocks(args, settings.gephSocksPort, 'Geph');
        break;
      default:
        break;
    }
  }

  void _applyManual(List<String> args) {
    final upstream = _buildManualUpstreamUrl();
    if (upstream.isNotEmpty) {
      args.addAll(['-proxy', upstream]);
      processService.addLog(
        '→ SSTP upstream: Manual proxy ($upstream)',
        source: LogSource.sstp,
      );
    } else {
      processService.addLog(
        '⚠ SSTP upstream is set to Manual but IP/port is empty — skipping -proxy',
        source: LogSource.sstp,
      );
    }
  }

  /// یک آپ‌استریم SOCKS محلی را به argv اضافه می‌کند.
  void _applySocks(List<String> args, int port, String label) {
    args.addAll(['-proxy', 'socks5://127.0.0.1:$port']);
    processService.addLog(
      '→ SSTP upstream: $label (127.0.0.1:$port)',
      source: LogSource.sstp,
    );
  }

  String _buildManualUpstreamUrl() {
    final type = settings.sstpProxyType;
    final ip = settings.sstpProxyIp.trim();
    final port = settings.sstpProxyPort;

    if (ip.isEmpty || port <= 0) return '';

    var url = '$type://';

    if (settings.sstpProxyUser.trim().isNotEmpty) {
      url += '${settings.sstpProxyUser.trim()}:${settings.sstpProxyPass}@';
    }

    url += '$ip:$port';
    return url;
  }
}
