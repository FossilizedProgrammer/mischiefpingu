library;

import 'watchdog_network_profile.dart';

/// ═══════════════════════════════════════════════════════════════
///  WatchdogProfileParams — پارامترهای watchdog برای هر پروفایل.
/// ═══════════════════════════════════════════════════════════════
class WatchdogProfileParams {
  final Duration psiphonInterval;
  final Duration aetherInterval;
  final Duration torInterval;
  final Duration sstpInterval;
  final Duration wireguardInterval;
  final int maxFailures;
  final Duration connectTimeout;
  final Duration socksTimeout;
  final Duration httpProbeTimeout;
  final Duration restartGracePeriod;
  final int circuitBreakerMaxRestarts;
  final Duration circuitBreakerWindow;
  final Duration circuitBreakerCooldown;
  final bool requireHttpSuccess;
  final bool tolerateHttpFailureAfterConnect;
  final bool requireAllTargetsFailToMarkDead;
  final bool includeCloudflareTarget;
  final bool enableQualityBasedRestart;
  final int highLatencyMs;
  final int degradedConsecutiveLimit;

  const WatchdogProfileParams({
    required this.psiphonInterval,
    required this.aetherInterval,
    required this.torInterval,
    required this.sstpInterval,
    required this.wireguardInterval,
    required this.maxFailures,
    required this.connectTimeout,
    required this.socksTimeout,
    required this.httpProbeTimeout,
    required this.restartGracePeriod,
    required this.circuitBreakerMaxRestarts,
    required this.circuitBreakerWindow,
    required this.circuitBreakerCooldown,
    required this.requireHttpSuccess,
    required this.tolerateHttpFailureAfterConnect,
    required this.requireAllTargetsFailToMarkDead,
    required this.includeCloudflareTarget,
    required this.enableQualityBasedRestart,
    required this.highLatencyMs,
    required this.degradedConsecutiveLimit,
  });

  /// انتخاب interval مناسب برای هر تونل.
  Duration intervalFor(String tunnelName) {
    switch (tunnelName.toLowerCase()) {
      case 'psiphon':
        return psiphonInterval;
      case 'aether':
        return aetherInterval;
      case 'tor':
        return torInterval;
      case 'sstp':
        return sstpInterval;
      case 'wireguard':
        return wireguardInterval;
      default:
        return psiphonInterval; // fallback
    }
  }

  static WatchdogProfileParams forProfile(WatchdogNetworkProfile profile) {
    switch (profile) {
      case WatchdogNetworkProfile.stable:
        return const WatchdogProfileParams(
          psiphonInterval: Duration(seconds: 50),
          aetherInterval: Duration(seconds: 50),
          torInterval: Duration(seconds: 75),
          sstpInterval: Duration(seconds: 50),
          wireguardInterval: Duration(seconds: 50),
          maxFailures: 3,
          connectTimeout: Duration(seconds: 7),
          socksTimeout: Duration(seconds: 9),
          httpProbeTimeout: Duration(seconds: 11),
          restartGracePeriod: Duration(minutes: 2),
          circuitBreakerMaxRestarts: 2,
          circuitBreakerWindow: Duration(minutes: 10),
          circuitBreakerCooldown: Duration(minutes: 15),
          requireHttpSuccess: true,
          tolerateHttpFailureAfterConnect: false,
          requireAllTargetsFailToMarkDead: false,
          includeCloudflareTarget: true,
          enableQualityBasedRestart: false,
          highLatencyMs: 5000,
          degradedConsecutiveLimit: 4,
        );

      case WatchdogNetworkProfile.normal:
        return const WatchdogProfileParams(
          psiphonInterval: Duration(seconds: 75),
          aetherInterval: Duration(seconds: 75),
          torInterval: Duration(seconds: 100),
          sstpInterval: Duration(seconds: 75),
          wireguardInterval: Duration(seconds: 75),
          maxFailures: 5,
          connectTimeout: Duration(seconds: 11),
          socksTimeout: Duration(seconds: 13),
          httpProbeTimeout: Duration(seconds: 16),
          restartGracePeriod: Duration(minutes: 2, seconds: 30),
          circuitBreakerMaxRestarts: 3,
          circuitBreakerWindow: Duration(minutes: 10),
          circuitBreakerCooldown: Duration(minutes: 12),
          requireHttpSuccess: false,
          tolerateHttpFailureAfterConnect: true,
          requireAllTargetsFailToMarkDead: false,
          includeCloudflareTarget: true,
          enableQualityBasedRestart: false,
          highLatencyMs: 8000,
          degradedConsecutiveLimit: 5,
        );

      case WatchdogNetworkProfile.harsh:
        return const WatchdogProfileParams(
          psiphonInterval: Duration(seconds: 105),
          aetherInterval: Duration(seconds: 105),
          torInterval: Duration(seconds: 120),
          sstpInterval: Duration(seconds: 105),
          wireguardInterval: Duration(seconds: 105),
          maxFailures: 9,
          connectTimeout: Duration(seconds: 13),
          socksTimeout: Duration(seconds: 17),
          httpProbeTimeout: Duration(seconds: 22),
          restartGracePeriod: Duration(minutes: 4),
          circuitBreakerMaxRestarts: 5,
          circuitBreakerWindow: Duration(minutes: 15),
          circuitBreakerCooldown: Duration(minutes: 20),
          requireHttpSuccess: false,
          tolerateHttpFailureAfterConnect: true,
          requireAllTargetsFailToMarkDead: true,
          includeCloudflareTarget: false,
          enableQualityBasedRestart: false,
          highLatencyMs: 12000,
          degradedConsecutiveLimit: 8,
        );
    }
  }
}
