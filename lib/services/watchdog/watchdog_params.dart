library;

import 'watchdog_network_profile.dart';
import 'watchdog_profile_params.dart';

class WatchdogParams {
  final String name;
  final int socksPort;
  final Duration interval;
  final int maxFailures;
  final Duration connectTimeout;
  final Duration socksTimeout;
  final Duration httpProbeTimeout;

  /// پروفایل شبکه‌ای که این watchdog بر اساس آن ساخته شده.
  final WatchdogNetworkProfile networkProfile;

  const WatchdogParams({
    required this.name,
    required this.socksPort,
    required this.interval,
    required this.maxFailures,
    required this.connectTimeout,
    required this.socksTimeout,
    required this.httpProbeTimeout,
    required this.networkProfile,
  });

  /// سازنده از پروفایل.
  factory WatchdogParams.fromProfile({
    required String name,
    required int socksPort,
    required WatchdogNetworkProfile profile,
  }) {
    final p = WatchdogProfileParams.forProfile(profile);
    return WatchdogParams(
      name: name,
      socksPort: socksPort,
      interval: p.intervalFor(name),
      maxFailures: p.maxFailures,
      connectTimeout: p.connectTimeout,
      socksTimeout: p.socksTimeout,
      httpProbeTimeout: p.httpProbeTimeout,
      networkProfile: profile,
    );
  }
}
