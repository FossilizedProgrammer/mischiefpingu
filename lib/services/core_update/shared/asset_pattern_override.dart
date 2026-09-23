library;

/// ═══════════════════════════════════════════════════════════════
///  AssetPatternOverride — امکان override کردن منطق انتخاب asset.
///
///  وقتی تنظیم بشه، `GithubReleaseChecker` و
///  `GithubReleaseUpdater` از این callback استفاده می‌کنن
///  به جای AssetPicker عمومی.
///
///  این برای coreهایی مثل WireGuard لازمه که اسم‌گذاری
///  assetهاشون خاص است (بدون پسوند، یا با الگوی خاص).
/// ═══════════════════════════════════════════════════════════════
typedef AssetPickerFn = Map<String, dynamic>? Function(
  List<dynamic> assets,
  String arch,
);

class AssetPatternOverride {
  final AssetPickerFn picker;

  const AssetPatternOverride(this.picker);
}
