library;

import 'dart:io';

/// ═══════════════════════════════════════════════════════════════
///  انتخاب asset مناسب از لیست GitHub Releases.
/// ═══════════════════════════════════════════════════════════════
class AppUpdateAssetPicker {
  AppUpdateAssetPicker._();

  static ({String url, int size, String name}) pick(
    List<dynamic> assets, {
    String? preferredPattern,
  }) {
    final isWin = Platform.isWindows;

    // ۱. اگر الگوی مشخصی داده شده، همان را ترجیح بده.
    if (preferredPattern != null && preferredPattern.isNotEmpty) {
      for (final a in assets) {
        final m = a as Map<String, dynamic>;
        final name = (m['name'] as String? ?? '').toLowerCase();
        if (name.contains(preferredPattern.toLowerCase())) {
          return (
            url: m['browser_download_url'] as String? ?? '',
            size: (m['size'] as num? ?? 0).toInt(),
            name: m['name'] as String? ?? '',
          );
        }
      }
    }

    // ۲. asset مناسب پلتفرم.
    for (final a in assets) {
      final m = a as Map<String, dynamic>;
      final name = (m['name'] as String? ?? '').toLowerCase();
      if (name.isEmpty) continue;
      final looksWin = name.contains('windows') || name.endsWith('.exe');
      final looksLinux = name.contains('linux') || name.contains('appimage');
      final ok = isWin ? looksWin : looksLinux;
      if (ok && _isArchive(name)) {
        return (
          url: m['browser_download_url'] as String? ?? '',
          size: (m['size'] as num? ?? 0).toInt(),
          name: m['name'] as String? ?? '',
        );
      }
    }

    // ۳. هر آرشیوی.
    for (final a in assets) {
      final m = a as Map<String, dynamic>;
      final name = (m['name'] as String? ?? '').toLowerCase();
      if (_isArchive(name)) {
        return (
          url: m['browser_download_url'] as String? ?? '',
          size: (m['size'] as num? ?? 0).toInt(),
          name: m['name'] as String? ?? '',
        );
      }
    }

    return (url: '', size: 0, name: '');
  }

  static bool _isArchive(String name) =>
      name.endsWith('.tar.gz') ||
      name.endsWith('.tgz') ||
      name.endsWith('.zip') ||
      name.endsWith('.tar.xz') ||
      name.endsWith('.appimage') ||
      name.endsWith('.exe') ||
      name.endsWith('.msi') ||
      name.endsWith('.deb') ||
      name.endsWith('.rpm');
}
