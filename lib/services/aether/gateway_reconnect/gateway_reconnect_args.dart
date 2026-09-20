part of '../gateway_reconnect_orchestrator.dart';

/// ═══════════════════════════════════════════════════════════════
///  ساخت args برای Aether + شروع tracker.
/// ═══════════════════════════════════════════════════════════════
extension GatewayReconnectArgs on GatewayReconnectOrchestrator {
  List<String> buildReconnectArgs({
    required String protocol,
    required String masque,
    required String endpoint,
    required int port,
  }) {
    final args = <String>['--bind', '127.0.0.1:$port'];

    switch (protocol) {
      case 'masque':
        args.add('--masque');
        if (masque == 'HTTP-2') args.add('--h2');
        break;
      case 'wireguard':
        args.add('--wg');
        break;
      case 'gool':
        args.add('--gool');
        if (endpoint.isNotEmpty) args.addAll(['--wiw-outer', endpoint]);
        return args;
      case 'mim':
        args.add('--mim');
        if (masque == 'HTTP-2') args.add('--h2');
        if (endpoint.isNotEmpty) args.addAll(['--mim-outer', endpoint]);
        return args;
    }

    if (endpoint.isNotEmpty) {
      args.addAll(['--peer', endpoint]);
    } else {
      args.addAll(['--scan', 'balanced']);
    }
    return args;
  }

  /// شروع tracker برای یک gateway.
  ///
  /// ⚠️ در fast-path از sampleCount کمتر و interval کوتاه‌تر
  /// استفاده می‌کنیم تا UI سریع‌تر آماده شود.
  void startTrackerForGateway({
    required GatewayRecord record,
    required int port,
    required String endpoint,
    bool quick = false,
  }) {
    final tracker = performanceTracker;
    if (tracker == null) return;

    // ignore: discarded_futures
    tracker.startFor(
      socksPort: port,
      ip: record.ip,
      port: record.port,
      protocol: record.protocol,
      masqueOption: record.masqueOption,
      sni: record.sni,
      endpoint: endpoint,
      // ⚠️ در حالت quick، فقط ۳ نمونه با interval ۱.۵s
      sampleCount: quick ? 3 : 6,
      interval: quick
          ? const Duration(milliseconds: 1500)
          : const Duration(milliseconds: 2500),
    );
  }
}
