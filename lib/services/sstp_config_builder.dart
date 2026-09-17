// lib/services/sstp_config_builder.dart
library;

import '../models/settings_model.dart';
import 'process_service.dart';
import 'sstp/sstp_upstream_builder.dart';

class SstpConfigBuilder {
  final AppSettings settings;
  final ProcessService processService;

  late final SstpUpstreamBuilder _upstream;

  SstpConfigBuilder({
    required this.settings,
    required this.processService,
  }) {
    _upstream = SstpUpstreamBuilder(
      settings: settings,
      processService: processService,
    );
  }

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

    // ─── Upstream proxy (delegated) ───
    _upstream.apply(args);

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
}
