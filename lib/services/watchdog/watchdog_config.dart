library;

class WatchdogConfig {
  WatchdogConfig._();

  static const Duration psiphonInterval = Duration(seconds: 120);
  static const Duration aetherInterval = Duration(seconds: 120);
  static const Duration torInterval = Duration(seconds: 180);
  static const Duration sstpInterval = Duration(seconds: 120);

  static const int maxFailures = 10;

  static const int recoveryThreshold = 2;

  static const Duration restartGracePeriod = Duration(minutes: 5);

  static const Duration connectTimeout = Duration(seconds: 6);
  static const Duration socksTimeout = Duration(seconds: 8);
  static const Duration httpProbeTimeout = Duration(seconds: 8);
}
