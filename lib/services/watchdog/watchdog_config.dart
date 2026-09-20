library;

/// ═══════════════════════════════════════════════════════════════
///  WatchdogConfig — پیکربندی مرکزی watchdog.
/// ═══════════════════════════════════════════════════════════════
class WatchdogConfig {
  WatchdogConfig._();

  // ═══════════════════════════════════════════════════════════════
  //  بازه‌های probe
  // ═══════════════════════════════════════════════════════════════

  static const Duration psiphonInterval = Duration(seconds: 60);
  static const Duration aetherInterval = Duration(seconds: 60);
  static const Duration torInterval = Duration(seconds: 90);
  static const Duration sstpInterval = Duration(seconds: 60);

  // ═══════════════════════════════════════════════════════════════
  //  آستانه‌های failure
  // ═══════════════════════════════════════════════════════════════

  static const int maxFailures = 5;
  static const int recoveryThreshold = 2;
  static const Duration restartGracePeriod = Duration(minutes: 2);

  // ═══════════════════════════════════════════════════════════════
  //  timeoutهای probe
  // ═══════════════════════════════════════════════════════════════

  static const Duration connectTimeout = Duration(seconds: 6);
  static const Duration socksTimeout = Duration(seconds: 8);
  static const Duration httpProbeTimeout = Duration(seconds: 12);

  // ═══════════════════════════════════════════════════════════════
  //  Circuit Breaker
  // ═══════════════════════════════════════════════════════════════

  static const int circuitBreakerMaxRestarts = 2;
  static const Duration circuitBreakerWindow = Duration(minutes: 10);
  static const Duration circuitBreakerCooldown = Duration(minutes: 15);

  // ═══════════════════════════════════════════════════════════════
  //  Internet Gate
  // ═══════════════════════════════════════════════════════════════

  static const bool suppressRestartWhenInternetDead = true;

  // ═══════════════════════════════════════════════════════════════
  //  کیفیت‌سنجی
  //
  //  ⚠️ تغییرات مهم:
  //    • enableQualityBasedRestart = false (موقتاً)
  //      دلیل: در شبکه‌های فیلترشده، probeهای HTTP اغلب
  //      false-positive می‌دن و باعث restart بی‌مورد می‌شن.
  //      بعد از اینکه حلقه شکست، با مقادیر جدید دوباره فعال کن.
  //    • highLatencyMs از 3000 به 8000 (کمتر تهاجمی)
  //    • degradedConsecutiveLimit از 3 به 5
  // ═══════════════════════════════════════════════════════════════

  static const int highLatencyMs = 8000;

  /// ⚠️ موقتاً خاموش — بعد از دیباگ دوباره true کن.
  static const bool enableQualityBasedRestart = false;

  static const int degradedConsecutiveLimit = 5;

  // ═══════════════════════════════════════════════════════════════
  //  Helper
  // ═══════════════════════════════════════════════════════════════

  static Duration intervalFor(String tunnelName) {
    switch (tunnelName.toLowerCase()) {
      case 'psiphon':
        return psiphonInterval;
      case 'aether':
        return aetherInterval;
      case 'tor':
        return torInterval;
      case 'sstp':
        return sstpInterval;
      default:
        return psiphonInterval;
    }
  }
}

class WatchdogConfigGrace {
  WatchdogConfigGrace._();

  static const Duration gracePeriod = WatchdogConfig.restartGracePeriod;
}
