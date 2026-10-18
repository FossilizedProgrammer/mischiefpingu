library;

/// ═══════════════════════════════════════════════════════════════
///  AssetPickerFn — callback برای انتخاب asset سفارشی.
/// ═══════════════════════════════════════════════════════════════
typedef AssetPickerFn = Map<String, dynamic>? Function(
  List<dynamic> assets,
  String arch,
);

/// باینری اضافی که از همان آرشیو استخراج و در data dir نصب می‌شود.
///
/// مثال: لنترن آرشیو تک‌فایلی منتشر می‌کند که هم `lantern` (CLI) و هم
/// `lantern-radiance` (موتور Radiance) را در خود دارد.
class ExtraBinarySpec {
  /// نام پایهٔ باینری بدون پسوند (مثل `lantern-radiance`).
  final String baseName;

  /// الگوی fallback برای جستجو در آرشیو.
  final String fallbackPattern;

  /// شناسهٔ مستقل برای لاگ/PendingCoreUpdate (مثل `lantern-radiance`).
  ///
  /// باید با [GithubCoreSpec.coreId] متفاوت باشد تا آپدیت‌های معلق
  /// هر دو باینری جدا ثبت شوند.
  final String coreId;

  const ExtraBinarySpec({
    required this.baseName,
    required this.fallbackPattern,
    required this.coreId,
  });
}

/// تنظیمات یک core مبتنی بر GitHub Releases.
class GithubCoreSpec {
  /// شناسه core (برای لاگ و PendingCoreUpdate).
  final String coreId;

  /// نام نمایشی.
  final String displayName;

  /// مالک مخزن GitHub.
  final String owner;

  /// نام مخزن GitHub.
  final String repo;

  /// نام پایه باینری بدون پسوند (مثل `sstp-proxy`).
  final String binaryBaseName;

  /// الگوی fallback برای جستجوی باینری در آرشیو.
  final String fallbackPattern;

  /// مسیر ذخیره‌سازی نهایی (تابع async).
  final Future<String> Function() destPathResolver;

  /// پیشوند temp dir برای دانلود.
  final String tempPrefix;

  /// تخمین اندازه دانلود (بایت) اگر GitHub size نداشت.
  final int defaultDownloadSize;

  // ═══════════════════════════════════════════════════════════
  //  فیلد picker سفارشی برای انتخاب asset
  //
  //  اگر null باشه، از AssetPicker.pick() عمومی استفاده می‌شه.
  //  اگر غیر null باشه، از این picker استفاده می‌شه.
  // ═══════════════════════════════════════════════════════════
  final AssetPickerFn? assetPicker;

  /// ═══════════════════════════════════════════════════════════
  ///  برای coreهایی که باینری‌شان نسخهٔ نصب‌شده را گزارش نمی‌کند
  ///  (مثل ffvpn که پرچم `--version` ندارد).
  ///
  ///  اگر true باشد، checker اندازهٔ فایل محلی را با اندازهٔ
  ///  asset منتشرشده مقایسه می‌کند:
  ///    • برابر  → همان نسخهٔ release نصب است (بدون آپدیت)
  ///    • متفاوت → آپدیت پیشنهاد می‌شود
  /// ═══════════════════════════════════════════════════════════
  final bool sizeBasedVersion;

  /// باینری‌های اضافی که از همان آرشیو استخراج و نصب می‌شوند.
  final List<ExtraBinarySpec> extraBinaries;

  const GithubCoreSpec({
    required this.coreId,
    required this.displayName,
    required this.owner,
    required this.repo,
    required this.binaryBaseName,
    required this.fallbackPattern,
    required this.destPathResolver,
    required this.tempPrefix,
    required this.defaultDownloadSize,
    this.assetPicker,
    this.sizeBasedVersion = false,
    this.extraBinaries = const [],
  });
}
