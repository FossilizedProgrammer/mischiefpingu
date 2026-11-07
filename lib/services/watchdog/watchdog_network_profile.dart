library;

/// ═══════════════════════════════════════════════════════════════
///  WatchdogNetworkProfile — پروفایل شبکه برای واچ‌داگ.
///
///  فقط سه حالت:
///    • stable  — کیفیت اینترنت خوب، سخت‌گیر
///    • normal  — متعادل
///    • harsh   — فیلترینگ شدید، آسان‌گیر (کمترین false-positive)
///
///  ⚠️ پیش‌فرض برنامه: harsh
///
///  دلیل: در شبکه‌های فیلترشده (ایران، چین، روسیه)، پروفایل
///  normal خیلی سریع restart می‌کنه و باعث می‌شه تونل‌ها
///  فرصت recover نداشته باشن. harsh:
///    • maxFailures = 9 (به جای 5)
///    • interval = 105s (به جای 75s)
///    • circuitBreakerCooldown = 20min (به جای 12min)
///    • requireHttpSuccess = false
///    • includeCloudflareTarget = false
///
///  ⚠️ Manual وجود ندارد — تصمیم عمدی برای سادگی UI.
/// ═══════════════════════════════════════════════════════════════
enum WatchdogNetworkProfile {
  stable,
  normal,
  harsh;

  static WatchdogNetworkProfile fromId(String id) {
    for (final p in values) {
      if (p.name == id) return p;
    }
    return WatchdogNetworkProfile.harsh;
  }

  String get id => name;
}
