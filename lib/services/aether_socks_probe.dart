library;

import 'dart:async';

import 'aether_probe_fallbacks.dart';
import 'aether_probe/socks_diagnose.dart';
import 'aether_probe/socks_diag.dart';
import 'aether_probe/socks_wait_loop.dart';
import 'process_service.dart';

export 'aether_probe/socks_diag.dart' show SocksDiag;

/// ═══════════════════════════════════════════════════════════════
///  SocksProber — probe سلامت Aether SOCKS.
///
///  منطق در `aether_probe/` جدا شده:
///    • SocksDiagnoser        → یک diagnose کامل
///    • SocksWaitLoop         → loop تا healthy شدن
///    • AetherProbeFallbacks  → curl/coreSaysReady
/// ═══════════════════════════════════════════════════════════════
class SocksProber {
  final ProcessService processService;
  final bool Function() isCancelled;

  late final AetherProbeFallbacks _fallbacks = AetherProbeFallbacks(
    processService: processService,
  );

  late final SocksDiagnoser _diagnoser = SocksDiagnoser(
    processService: processService,
    fallbacks: _fallbacks,
  );

  late final SocksWaitLoop _waitLoop = SocksWaitLoop(
    processService: processService,
    diagnoser: _diagnoser,
    fallbacks: _fallbacks,
    isCancelled: isCancelled,
  );

  SocksProber(this.processService, {required this.isCancelled});

  Future<SocksDiag> diagnoseSocks(int port) => _diagnoser.diagnose(port);

  String diagText(SocksDiag d, int port) => SocksDiagText.forDiag(d, port);

  Future<SocksDiag> waitForHealthy(int port, {required Duration timeout}) =>
      _waitLoop.run(port, timeout: timeout);
}
