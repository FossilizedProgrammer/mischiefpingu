part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Tor Asset Discovery — پیدا کردن مسیر فایل‌های کمکی Tor
///  (lyrebird / conjure-client / geoip / geoip6)
///  (تفکیک شده از app_provider_tor.dart)
/// ═══════════════════════════════════════════════════════════════
extension AppProviderTorAssets on AppProvider {
  /// پیدا کردن مسیر تمام assetهای Tor در dataDir یا torDir.
  ///
  /// اگر فایلی پیدا نشه، مقدار null برمی‌گرده و core خودش
  /// مسیر پیش‌فرض رو امتحان می‌کنه.
  Future<TorAssetPaths> resolveTorAssets({
    required String dataDir,
    required String torDir,
  }) async {
    return TorAssetPaths(
      lyrebirdPath: await _firstExisting([
        '$dataDir/lyrebird',
        '$torDir/pluggable_transports/lyrebird',
        '$torDir/lyrebird',
      ]),
      conjurePath: await _firstExisting([
        '$dataDir/conjure-client',
        '$torDir/pluggable_transports/conjure-client',
        '$torDir/conjure-client',
      ]),
      geoipPath: await _firstExisting(['$torDir/geoip', '$dataDir/geoip']),
      geoip6Path: await _firstExisting(['$torDir/geoip6', '$dataDir/geoip6']),
    );
  }

  /// اولین مسیر موجود از لیست کاندیدها رو برمی‌گردونه.
  Future<String?> _firstExisting(List<String> candidates) async {
    for (final cand in candidates) {
      if (await File(cand).exists()) return cand;
    }
    return null;
  }
}

/// مسیر فایل‌های کمکی Tor.
class TorAssetPaths {
  final String? lyrebirdPath;
  final String? conjurePath;
  final String? geoipPath;
  final String? geoip6Path;

  const TorAssetPaths({
    this.lyrebirdPath,
    this.conjurePath,
    this.geoipPath,
    this.geoip6Path,
  });
}
