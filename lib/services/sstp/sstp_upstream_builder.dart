library;

import '../../models/settings_model.dart';
import '../process_service.dart';

class SstpUpstreamBuilder {
  final AppSettings settings;
  final ProcessService processService;

  SstpUpstreamBuilder({required this.settings, required this.processService});

  /// args مربوط به upstream را به لیست اضافه می‌کند.
  void apply(List<String> args) {
    switch (settings.sstpUpstreamType) {
      case 1:
        _applyManual(args);
        break;
      case 2:
        _applyAether(args);
        break;
      case 3:
        _applyPsiphon(args);
        break;
      case 4:
        _applyTor(args);
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

  void _applyAether(List<String> args) {
    args.addAll(['-proxy', 'socks5://127.0.0.1:${settings.aetherLocalPort}']);
    processService.addLog(
      '→ SSTP upstream: Aether (127.0.0.1:${settings.aetherLocalPort})',
      source: LogSource.sstp,
    );
  }

  void _applyPsiphon(List<String> args) {
    args.addAll(['-proxy', 'socks5://127.0.0.1:${settings.socksPort}']);
    processService.addLog(
      '→ SSTP upstream: Psiphon (127.0.0.1:${settings.socksPort})',
      source: LogSource.sstp,
    );
  }

  void _applyTor(List<String> args) {
    args.addAll(['-proxy', 'socks5://127.0.0.1:${settings.torSocksPort}']);
    processService.addLog(
      '→ SSTP upstream: Tor (127.0.0.1:${settings.torSocksPort})',
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
