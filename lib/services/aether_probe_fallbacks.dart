library;

import 'process_service.dart';
import 'aether_probe_fallbacks/curl_probe.dart';
import 'aether_probe_fallbacks/log_ready_probe.dart';

/// ═══════════════════════════════════════════════════════════════
///  Facade — API عمومی AetherProbeFallbacks حفظ می‌شود.
/// ═══════════════════════════════════════════════════════════════
class AetherProbeFallbacks {
  final ProcessService processService;

  late final CurlProbe _curl = CurlProbe();
  late final LogReadyProbe _logReady = LogReadyProbe(
    processService: processService,
  );

  AetherProbeFallbacks({required this.processService});

  Future<bool> curlProbe(int port) => _curl.run(port);

  bool coreSaysReady(int port) => _logReady.run(port);
}
