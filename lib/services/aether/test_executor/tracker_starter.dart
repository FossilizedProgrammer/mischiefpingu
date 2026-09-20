part of '../aether_test_executor.dart';

/// ═══════════════════════════════════════════════════════════════
///  شروع performance tracker بعد از اتصال موفق.
/// ═══════════════════════════════════════════════════════════════
extension AetherTestExecutorTrackerStarter on AetherTestExecutor {
  void startPerformanceTracker({
    required EndpointAttempt attempt,
    required int port,
  }) {
    final tracker = performanceTracker;
    if (tracker == null) return;

    // ignore: discarded_futures
    tracker.startFor(
      socksPort: port,
      ip: settings.ip.isNotEmpty ? settings.ip : 'local',
      port: port,
      protocol: attempt.protocol,
      masqueOption: attempt.masque,
      sni: settings.tlsSni,
      endpoint: attempt.endpoint,
    );
  }
}
