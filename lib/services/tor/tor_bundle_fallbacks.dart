library;

import '../app_data_service.dart';
import 'tor_types.dart';

class TorBundleFallbacks {
  TorBundleFallbacks._();

  /// نسخه‌های پایداری که اگر discovery زنده شکست خورد، امتحان می‌شوند.
  static const List<String> stableVersions = [
    '15.0.21',
    '15.0.20',
    '15.0.19',
    '14.0.8',
    '14.0.4',
    '13.5.9',
  ];

  static const List<String> mirrors = [
    'https://www.torproject.org/dist/torbrowser',
    'https://archive.torproject.org/tor-package-archive/torbrowser',
  ];

  /// نام‌های ممکن فایل bundle بر اساس نسخه و پلتفرم.
  static List<String> bundleNames(String version, String archTag, bool isWin) {
    if (isWin) {
      return [
        'tor-expert-bundle-windows-x86_64-$version.tar.gz',
        'tor-expert-bundle-windows-i686-$version.tar.gz',
      ];
    }
    return [
      'tor-expert-bundle-linux-$archTag-$version.tar.gz',
      'tor-expert-bundle-$version-linux-$archTag.tar.gz',
      'tor-browser-linux-$archTag-$version.tar.gz',
    ];
  }

  /// مقایسه دو نسخه (برای مرتب‌سازی نزولی).
  static int compareVersions(String a, String b) {
    List<int> parts(String v) =>
        RegExp(r'\d+')
            .allMatches(v)
            .map((m) => int.parse(m.group(0)!))
            .toList();
    final pa = parts(a);
    final pb = parts(b);
    for (var i = 0; i < pa.length && i < pb.length; i++) {
      if (pa[i] != pb[i]) return pa[i].compareTo(pb[i]);
    }
    return pa.length.compareTo(pb.length);
  }

  /// تلاش برای پیدا کردن bundle از لیست نسخه‌های hardcoded.
  static Future<String?> tryStable({
    required String? proxy,
    required String archTag,
    required TorHeadFn headRequest,
    required TorLogFn log,
  }) async {
    final isWin = AppDataService.isWindows;
    for (final version in stableVersions) {
      final names = bundleNames(version, archTag, isWin);
      for (final mirror in mirrors) {
        for (final name in names) {
          final url = '$mirror/$version/$name';
          log('→ Probing stable fallback: $url');
          final head = await headRequest(url, proxy, timeoutSec: 8);
          if (head != null && head.status == 200) {
            log('→ ✓ Found Tor expert bundle (fallback): $name');
            return url;
          }
        }
      }
    }
    log('✗ All Tor expert bundle discovery attempts exhausted');
    return null;
  }

  /// تبدیل arch به tag مناسب URL.
  static String archTag(String arch) {
    switch (arch) {
      case 'aarch64':
        return 'aarch64';
      case 'armv7':
        return 'armv7';
      default:
        return 'x86_64';
    }
  }
}
