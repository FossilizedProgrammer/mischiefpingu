library;

import 'package:package_info_plus/package_info_plus.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppVersionService — تنها منبع حقیقت برای نسخهٔ برنامه.
///
///  نسخه از `pubspec.yaml` خوانده می‌شود (package_info_plus).
///  نتیجه کش می‌شود تا فقط یک بار خوانده شود.
/// ═══════════════════════════════════════════════════════════════
class AppVersionService {
  AppVersionService._();

  static String? _cachedVersion;
  static String? _cachedBuild;
  static String? _cachedFullVersion;

  /// نسخه به شکل `1.2.3` (بدون build number).
  static Future<String> getVersion() async {
    await _ensureLoaded();
    return _cachedVersion ?? '0.0.0';
  }

  /// شماره build (بخش بعد از `+` در pubspec).
  static Future<String> getBuildNumber() async {
    await _ensureLoaded();
    return _cachedBuild ?? '0';
  }

  /// نسخه کامل به شکل `1.2.3+4`.
  static Future<String> getFullVersion() async {
    await _ensureLoaded();
    return _cachedFullVersion ?? '0.0.0+0';
  }

  /// نسخه کش‌شده — فقط اگر قبلاً load شده باشد (sync).
  /// در غیر این صورت `null`.
  static String? get cachedVersion => _cachedVersion;

  static Future<void> _ensureLoaded() async {
    if (_cachedVersion != null) return;
    try {
      final info = await PackageInfo.fromPlatform();
      _cachedVersion = info.version;
      _cachedBuild = info.buildNumber;
      _cachedFullVersion = info.buildNumber.isEmpty
          ? info.version
          : '${info.version}+${info.buildNumber}';
    } catch (_) {
      _cachedVersion = '0.0.0';
      _cachedBuild = '0';
      _cachedFullVersion = '0.0.0+0';
    }
  }

  /// پاک‌کردن cache (مثلاً در تست‌ها).
  static void reset() {
    _cachedVersion = null;
    _cachedBuild = null;
    _cachedFullVersion = null;
  }
}
