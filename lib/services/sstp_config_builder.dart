// lib/services/sstp_config_builder.dart

library;

import '../models/settings_model.dart';
import 'process_service.dart';
import 'sstp/sstp_upstream_builder.dart';

/// ═══════════════════════════════════════════════════════════════
///  SstpConfigBuilder — ساخت args نهایی برای باینری sstp-proxy.
///
///  ⚠️ تغییرات کلیدی این نسخه:
///    • -retry همیشه فعاله — جلوگیری از exit کامل پروسه
///    • -dns 1.1.1.1,8.8.8.8 — جلوگیری از DNS poisoning ISP
///    • -fingerprint (اگه تنظیم شده) برای DPI evasion
///    • -sni (اگه تنظیم شده) برای SNI-based DPI
///    • -mtu (اگه تنظیم شده) برای fragmentation
///    • -verbose حالا در آخر میاد (بعد از -retry)
/// ═══════════════════════════════════════════════════════════════
class SstpConfigBuilder {
  final AppSettings settings;
  final ProcessService processService;

  late final SstpUpstreamBuilder _upstream;

  SstpConfigBuilder({required this.settings, required this.processService}) {
    _upstream = SstpUpstreamBuilder(
      settings: settings,
      processService: processService,
    );
  }

  /// ساخت لیست آرگومان‌های خط فرمان برای باینری sstp-proxy.
  List<String> buildArgs() {
    final args = <String>[];

    // ═══════════════════════════════════════════════════════════
    //  سرور و پورت
    // ═══════════════════════════════════════════════════════════
    final server = settings.sstpServer.trim();
    if (server.isEmpty) {
      throw StateError('SSTP server address is empty');
    }
    args.addAll(['-server', server]);
    args.addAll(['-port', settings.sstpPort.toString()]);

    // ═══════════════════════════════════════════════════════════
    //  پورت‌های محلی SOCKS و HTTP
    // ═══════════════════════════════════════════════════════════
    final socksBind = settings.sstpShareLan ? '0.0.0.0' : '127.0.0.1';
    args.addAll(['-socks', '$socksBind:${settings.sstpSocksPort}']);

    final httpBind = settings.sstpShareLan ? '0.0.0.0' : '127.0.0.1';
    args.addAll(['-http', '$httpBind:${settings.sstpHttpPort}']);

    // ═══════════════════════════════════════════════════════════
    //  احراز هویت (PPP)
    // ═══════════════════════════════════════════════════════════
    if (settings.sstpUser.trim().isNotEmpty) {
      args.addAll(['-user', settings.sstpUser.trim()]);
    }
    if (settings.sstpPass.isNotEmpty) {
      args.addAll(['-pass', settings.sstpPass]);
    }

    // ═══════════════════════════════════════════════════════════
    //  upstream proxy (اختیاری)
    // ═══════════════════════════════════════════════════════════
    _upstream.apply(args);

    // ═══════════════════════════════════════════════════════════
    //  🆕 DNS through tunnel — جلوگیری از DNS poisoning
    //
    //  ISP ممکنه DNS رو poison کنه تا SOCKS CONNECT با hostname
    //  به IP اشتباه بره. با -dns، sstp-proxy DNS رو از داخل
    //  تونل resolve می‌کنه.
    //
    //  از 1.1.1.1 و 8.8.8.8 استفاده می‌کنیم چون:
    //    • هر دو DoH/DoT دارن، کاربر می‌تونه Trust کنه
    //    • در ایران معمولاً از داخل تونل قابل دسترسن
    // ═══════════════════════════════════════════════════════════
    args.addAll(['-dns', '1.1.1.1,8.8.8.8']);

    // ═══════════════════════════════════════════════════════════
    //  SNI (اختیاری)
    // ═══════════════════════════════════════════════════════════
    final sni = settings.sstpSni.trim();
    if (sni.isNotEmpty) {
      args.addAll(['-sni', sni]);
    }

    // ═══════════════════════════════════════════════════════════
    //  fingerprint (DPI evasion)
    // ═══════════════════════════════════════════════════════════
    final fingerprint = settings.sstpFingerprint.trim();
    if (fingerprint.isNotEmpty) {
      args.addAll(['-fingerprint', fingerprint]);
    }

    // ═══════════════════════════════════════════════════════════
    //  ★ -retry : جلوگیری از exit کامل پروسه هنگام قطع تونل
    // ═══════════════════════════════════════════════════════════
    args.add('-retry');

    // ═══════════════════════════════════════════════════════════
    //  MTU (اختیاری)
    // ═══════════════════════════════════════════════════════════
    final mtu = settings.sstpMtu;
    if (mtu > 0 && mtu != 1400) {
      args.addAll(['-mtu', mtu.toString()]);
    }

    // ═══════════════════════════════════════════════════════════
    //  verbose (اختیاری، برای دیباگ)
    // ═══════════════════════════════════════════════════════════
    if (settings.sstpVerbose) {
      args.add('-verbose');
    }

    // ═══════════════════════════════════════════════════════════
    //  لاگ نهایی
    // ═══════════════════════════════════════════════════════════
    processService.addLog(
      '→ SSTP args: ${args.join(' ')}',
      source: LogSource.sstp,
    );

    return args;
  }
}
