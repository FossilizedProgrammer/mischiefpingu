// lib/services/aether/test_executor/tracker_starter.dart

part of '../aether_test_executor.dart';

/// ═══════════════════════════════════════════════════════════════
///  شروع performance tracker بعد از اتصال موفق.
///
///  ⚠️ تغییر: effectiveMasque حالا به tracker پاس داده میشه
///  (به جای attempt.masque که ممکنه با effective فرق داشته باشه).
/// ═══════════════════════════════════════════════════════════════
extension AetherTestExecutorTrackerStarter on AetherTestExecutor {
  void startPerformanceTracker({
    required EndpointAttempt attempt,
    required int port,
    String? effectiveMasque,
  }) {
    final tracker = performanceTracker;
    if (tracker == null) return;

    // ignore: discarded_futures
    tracker.startFor(
      socksPort: port,
      ip: settings.ip.isNotEmpty ? settings.ip : 'local',
      port: port,
      protocol: attempt.protocol,
      masqueOption: effectiveMasque ?? attempt.masque,
      sni: settings.tlsSni,
      endpoint: attempt.endpoint,
    );
  }
}
