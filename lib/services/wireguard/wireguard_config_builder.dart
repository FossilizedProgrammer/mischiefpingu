library;

import 'dart:io';

import '../process_service.dart';
import 'wireguard_config_parser.dart';
import 'wireguard_paths.dart';

/// ═══════════════════════════════════════════════════════════════
///  WireGuardConfigBuilder — ساخت فایل wireproxy.conf.
///
///  wireproxy یک فایل wrapper می‌خواد که به کانفیگ واقعی
///  WireGuard اشاره کنه و پورت SOCKS5 رو تعیین کنه:
///
///    WGConfig = /path/to/wg.conf
///
///    [Socks5]
///    BindAddress = 127.0.0.1:25344
///
///  اگر shareOnLan فعال باشه، BindAddress به 0.0.0.0 تغییر می‌کنه.
/// ═══════════════════════════════════════════════════════════════
class WireGuardConfigBuilder {
  final ProcessService processService;

  WireGuardConfigBuilder({required this.processService});

  /// ساخت فایل‌های کانفیگ و برگرداندن مسیر wrapper.
  ///
  /// خروجی: مسیر `wireproxy.conf` که باید به wireproxy -c داده بشه.
  Future<String> build({
    required WireGuardConfig config,
    required int socksPort,
    required bool shareOnLan,
  }) async {
    // ۱. نوشتن کانفیگ استاندارد WireGuard
    final wgPath = await WireGuardPaths.wgConfigPath();
    final standardConf = WireGuardConfigParser.serialize(config);
    await File(wgPath).writeAsString(standardConf);

    processService.addLog(
      '→ WireGuard standard config written: $wgPath',
      source: LogSource.wireguard,
    );

    // ۲. نوشتن فایل wrapper برای wireproxy
    final bindHost = shareOnLan ? '0.0.0.0' : '127.0.0.1';
    final wrapperPath = await WireGuardPaths.wireproxyConfigPath();

    final wrapper = StringBuffer()
      ..writeln('WGConfig = $wgPath')
      ..writeln()
      ..writeln('[Socks5]')
      ..writeln('BindAddress = $bindHost:$socksPort');

    await File(wrapperPath).writeAsString(wrapper.toString());

    processService.addLog(
      '→ WireGuard wrapper config written: $wrapperPath '
      '(bind=$bindHost:$socksPort)',
      source: LogSource.wireguard,
    );

    return wrapperPath;
  }
}
