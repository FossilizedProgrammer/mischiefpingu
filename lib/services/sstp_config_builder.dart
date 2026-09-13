// lib/services/sstp_config_builder.dart
library;

import '../models/settings_model.dart';
import 'process_service.dart';

class SstpConfigBuilder {
  final AppSettings settings;
  final ProcessService processService;

  SstpConfigBuilder({
    required this.settings,
    required this.processService,
  });

  /// ساخت لیست آرگومان‌های خط فرمان برای باینری sstp-proxy
  List<String> buildArgs() {
    final args = <String>[];

    // ─── سرور (اجباری) ───
    final server = settings.sstpServer.trim();
    if (server.isEmpty) {
      throw StateError('SSTP server address is empty');
    }
    args.addAll(['-server', server]);

    // ─── پورت (اجباری) — پیش‌فرض 443 ───
    args.addAll(['-port', settings.sstpPort.toString()]);

    // ─── SOCKS proxy ───
    final socksBind = settings.sstpShareLan ? '0.0.0.0' : '127.0.0.1';
    args.addAll(['-socks', '$socksBind:${settings.sstpSocksPort}']);

    // ─── HTTP proxy ───
    final httpBind = settings.sstpShareLan ? '0.0.0.0' : '127.0.0.1';
    args.addAll(['-http', '$httpBind:${settings.sstpHttpPort}']);

    // ─── احراز هویت (اختیاری) ───
    if (settings.sstpUser.trim().isNotEmpty) {
      args.addAll(['-user', settings.sstpUser.trim()]);
    }
    if (settings.sstpPass.isNotEmpty) {
      args.addAll(['-pass', settings.sstpPass]);
    }

    // ─── Upstream proxy ───
    switch (settings.sstpUpstreamType) {
      case 1:
        // آپ‌استریم دستی — فقط اگر IP و پورت پر باشند
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
        break;
      case 2:
        // آپ‌استریم از طریق Aether
        args.addAll([
          '-proxy',
          'socks5://127.0.0.1:${settings.aetherLocalPort}',
        ]);
        processService.addLog(
          '→ SSTP upstream: Aether (127.0.0.1:${settings.aetherLocalPort})',
          source: LogSource.sstp,
        );
        break;
      case 3:
        // آپ‌استریم از طریق Psiphon
        args.addAll([
          '-proxy',
          'socks5://127.0.0.1:${settings.socksPort}',
        ]);
        processService.addLog(
          '→ SSTP upstream: Psiphon (127.0.0.1:${settings.socksPort})',
          source: LogSource.sstp,
        );
        break;
      case 4:
        // آپ‌استریم از طریق Tor
        args.addAll([
          '-proxy',
          'socks5://127.0.0.1:${settings.torSocksPort}',
        ]);
        processService.addLog(
          '→ SSTP upstream: Tor (127.0.0.1:${settings.torSocksPort})',
          source: LogSource.sstp,
        );
        break;
      default:
        // 0 = بدون آپ‌استریم
        break;
    }

    // ─── SNI / Fronting (اختیاری) ───
    final sni = settings.sstpSni.trim();
    if (sni.isNotEmpty) {
      args.addAll(['-sni', sni]);
    }

    // ─── Fingerprint (اختیاری) ───
    final fp = settings.sstpFingerprint.trim();
    if (fp.isNotEmpty) {
      args.addAll(['-fingerprint', fp]);
    }

    // ─── Verbose ───
    if (settings.sstpVerbose) {
      args.add('-verbose');
    }

    processService.addLog(
      '→ SSTP args: ${args.join(' ')}',
      source: LogSource.sstp,
    );

    return args;
  }

  String _buildManualUpstreamUrl() {
    final type = settings.sstpProxyType; // 'socks5' | 'http' | 'socks5h'
    final ip = settings.sstpProxyIp.trim();
    final port = settings.sstpProxyPort;

    // هم IP و هم پورت باید معتبر باشند
    if (ip.isEmpty || port <= 0) return '';

    var url = '$type://';

    if (settings.sstpProxyUser.trim().isNotEmpty) {
      url += '${settings.sstpProxyUser.trim()}:${settings.sstpProxyPass}@';
    }

    url += '$ip:$port';
    return url;
  }
}
