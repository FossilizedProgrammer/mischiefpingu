library;

/// ═══════════════════════════════════════════════════════════════
///  AssetPickerFn — callback برای انتخاب asset سفارشی.
/// ═══════════════════════════════════════════════════════════════
typedef AssetPickerFn = Map<String, dynamic>? Function(
  List<dynamic> assets,
  String arch,
);

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
  });
}
