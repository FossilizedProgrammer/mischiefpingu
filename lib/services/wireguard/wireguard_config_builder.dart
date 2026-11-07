library;

import 'dart:io';

import '../../models/wireguard_core_type.dart';
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
///    BindAddress = 127.0.0.1:1085
///
///  اگر shareOnLan فعال باشه، BindAddress به 0.0.0.0 تغییر می‌کنه.
/// ═══════════════════════════════════════════════════════════════
class WireGuardConfigBuilder {
  final ProcessService processService;

  WireGuardConfigBuilder({required this.processService});

  /// ساخت فایل‌های کانفیگ و برگرداندن مسیر wrapper.
  Future<String> build({
    required WireGuardConfig config,
    required int socksPort,
    required bool shareOnLan,
    required WireGuardCoreType coreType,
  }) async {
    final wgPath = await WireGuardPaths.wgConfigPath();
    final includeAmnezia = coreType == WireGuardCoreType.amnezia;
    final confContent = WireGuardConfigParser.serialize(
      config,
      includeAmnezia: includeAmnezia,
    );
    await File(wgPath).writeAsString(confContent);

    processService.addLog(
      '→ WireGuard config written: $wgPath '
      '(core=${coreType.name}, amneziaParams=$includeAmnezia)',
      source: LogSource.wireguard,
    );

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
