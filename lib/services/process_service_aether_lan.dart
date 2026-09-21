part of 'process_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  منطق LAN / bind parsing مخصوص Aether
///  (تفکیک شده تا process_service_aether.dart کوتاه‌تر بشه)
///
///  وابستگی‌ها:
///    • AetherBindInfo         → نتیجهٔ تحلیل آرگومان --bind
///    • PortManager            → پیدا کردن پورت داخلی آزاد
///    • createForwarder        → در process_service.dart تعریف شده
/// ═══════════════════════════════════════════════════════════════

/// نتیجهٔ تحلیل آرگومان `--bind`
class AetherBindInfo {
  final bool shareLan;
  final int requestedPort;
  final int bindIdx;

  const AetherBindInfo({
    required this.shareLan,
    required this.requestedPort,
    required this.bindIdx,
  });
}

extension ProcessServiceAetherLan on ProcessService {
  /// پارس `--bind <host:port>` از آرگومان‌ها.
  /// اگر معتبر نبود، null برمی‌گردونه و لاگ می‌کنه.
  AetherBindInfo? parseAetherBindArgs(
    List<String> args,
    void Function(String) log,
  ) {
    final bindIdx = args.indexOf('--bind');
    if (bindIdx < 0 || bindIdx + 1 >= args.length) {
      log('ERROR: Aether start arguments do not contain --bind <host:port>');
      return null;
    }

    final requestedBind = args[bindIdx + 1];
    final colon = requestedBind.lastIndexOf(':');
    if (colon <= 0 || colon == requestedBind.length - 1) {
      log('ERROR: invalid Aether bind address: $requestedBind');
      return null;
    }

    final requestedPort = int.tryParse(requestedBind.substring(colon + 1));
    if (requestedPort == null || requestedPort < 1 || requestedPort > 65535) {
      log('ERROR: invalid Aether bind port: $requestedBind');
      return null;
    }

    return AetherBindInfo(
      shareLan: requestedBind.startsWith('0.0.0.0:'),
      requestedPort: requestedPort,
      bindIdx: bindIdx,
    );
  }

  /// آرگومان‌های نهایی رو آماده می‌کنه:
  ///   - LAN mode: Aether روی loopback می‌شینه، forwarder عمومی می‌شه
  ///   - local mode: Aether مستقیم روی loopback
  ///
  /// خروجی: (args نهایی, publicPort, internalPort)
  Future<({List<String> args, int? publicPort, int? internalPort})>
  prepareAetherArgs({
    required List<String> effectiveArgs,
    required AetherBindInfo info,
  }) async {
    const src = LogSource.aether;

    if (info.shareLan) {
      final publicPort = info.requestedPort;

      final internalPort = await PortManager.internalFor(
        publicPort: publicPort,
      );

      effectiveArgs[info.bindIdx + 1] = '127.0.0.1:$internalPort';

      addLog(
        '→ Aether LAN mode: private SOCKS 127.0.0.1:$internalPort '
        '→ public SOCKS 0.0.0.0:$publicPort',
        source: src,
      );

      return (
        args: effectiveArgs,
        publicPort: publicPort,
        internalPort: internalPort,
      );
    }

    effectiveArgs[info.bindIdx + 1] = '127.0.0.1:${info.requestedPort}';
    addLog(
      '→ Aether local mode: SOCKS on 127.0.0.1:${info.requestedPort}',
      source: src,
    );
    return (
      args: effectiveArgs,
      publicPort: null,
      internalPort: info.requestedPort,
    );
  }

  /// forwarder عمومی رو برای Aether بالا میاره.
  /// اگر شکست بخوره، null برمی‌گردونه.
  Future<ServerSocket?> setupAetherLanForwarder({
    required int publicPort,
    required int internalPort,
  }) async {
    const src = LogSource.aether;
    final server = await createForwarder(
      publicPort: publicPort,
      internalPort: internalPort,
      label: 'Aether-SOCKS',
      source: src,
    );
    if (server != null) {
      addLog(
        '★ Aether Share on LAN READY: 0.0.0.0:$publicPort '
        '→ 127.0.0.1:$internalPort',
        source: src,
      );
    }
    return server;
  }
}
