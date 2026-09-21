library;

/// ═══════════════════════════════════════════════════════════════
///  WatchdogNetworkProfile — پروفایل شبکه برای واچ‌داگ.
///
///  فقط سه حالت:
///    • stable  — کیفیت اینترنت خوب، سخت‌گیر
///    • normal  — پیش‌فرض، متعادل
///    • harsh   — فیلترینگ شدید، آسان‌گیر (کمترین false-positive)
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
    return WatchdogNetworkProfile.normal;
  }

  String get id => name;
}
