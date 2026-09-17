// lib/services/watchdog/watchdog_config.dart
//
// ═══════════════════════════════════════════════════════════════
//  WatchdogConfig — تنظیمات محافظه‌کارانه برای اینترنت ناپایدار
//
//  ⚠️ اینترنت ایران دچار اختلالات مکرر و کوتاه است. تنظیمات
//  پیش‌فرض باید بسیار محافظه‌کارانه باشند تا در اثر یک اختلال
//  ۱۰ ثانیه‌ای، tunnel بی‌دلیل restart نشود.
//
//  معیار: در بدترین حالت، باید ۲۰ دقیقه قطعی مداوم طول بکشد تا
//  watchdog تصمیم به restart بگیرد.
// ═══════════════════════════════════════════════════════════════
library;

class WatchdogConfig {
  WatchdogConfig._();

  // ═══════════════════════════════════════════
  //  Interval بین probeها
  // ═══════════════════════════════════════════
  static const Duration psiphonInterval = Duration(seconds: 120);
  static const Duration aetherInterval = Duration(seconds: 120);
  static const Duration torInterval = Duration(seconds: 180);
  static const Duration sstpInterval = Duration(seconds: 120);

  // ═══════════════════════════════════════════
  //  تعداد failure برای restart
  //  interval × maxFailures = زمان قطعی مداوم قبل از restart
  //  مثلاً: 120s × 10 = 20 دقیقه
  // ═══════════════════════════════════════════
  static const int maxFailures = 10;

  // ═══════════════════════════════════════════
  //  تعداد probe موفق برای reset شدن counter
  //  (الان استفاده نمی‌شود ولی برای آینده نگه می‌داریم)
  // ═══════════════════════════════════════════
  static const int recoveryThreshold = 2;

  // ═══════════════════════════════════════════
  //  Grace period بعد از هر restart
  //  بعد از اینکه watchdog یک tunnel را restart کرد،
  //  تا این مدت هیچ probe جدیدی انجام نمی‌شود.
  // ═══════════════════════════════════════════
  static const Duration restartGracePeriod = Duration(minutes: 5);

  // ═══════════════════════════════════════════
  //  Timeout برای probe
  // ═══════════════════════════════════════════
  static const Duration connectTimeout = Duration(seconds: 6);
  static const Duration socksTimeout = Duration(seconds: 8);
  static const Duration httpProbeTimeout = Duration(seconds: 8);
}
