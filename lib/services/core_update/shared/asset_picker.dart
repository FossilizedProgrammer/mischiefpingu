library;

import '../../app_data_service.dart';

class AssetPicker {
  AssetPicker._();

  /// پسوندهای آرشیو شناخته‌شده.
  static const List<String> archiveExts = [
    '.tar.gz',
    '.tgz',
    '.zip',
    '.tar.xz',
    '.tar.bz2',
  ];

  /// انتخاب بهترین asset از لیست release های GitHub.
  ///
  /// [arch] یکی از: 'x86_64' | 'aarch64' | 'armv7'
  static Map<String, dynamic>? pick(List<dynamic> assets, String arch) {
    if (assets.isEmpty) return null;

    final isWin = AppDataService.isWindows;
    final archPatterns = _archPatterns(arch);

    bool looksWindows(String name) {
      if (name.contains('windows')) return true;
      if (name.contains('win')) return true;
      if (name.endsWith('.exe')) return true;
      return false;
    }

    bool looksLinux(String name) {
      if (name.contains('linux')) return true;
      if (name.contains('windows') || name.contains('.exe')) return false;
      return true;
    }

    bool matchesOs(String name) =>
        isWin ? looksWindows(name) : looksLinux(name);

    // ─── مرحله 1: OS + arch + آرشیو ───
    for (final a in assets) {
      final m = a as Map<String, dynamic>;
      final name = (m['name'] as String? ?? '').toLowerCase();
      if (name.isEmpty) continue;
      if (matchesOs(name) &&
          archPatterns.any(name.contains) &&
          archiveExts.any(name.endsWith)) {
        return m;
      }
    }

    // ─── مرحله 2: OS + arch (بدون پسوند آرشیو — برای باینری خام) ───
    for (final a in assets) {
      final m = a as Map<String, dynamic>;
      final name = (m['name'] as String? ?? '').toLowerCase();
      if (name.isEmpty) continue;
      if (matchesOs(name) && archPatterns.any(name.contains)) {
        return m;
      }
    }

    // ─── مرحله 3: OS + آرشیو ───
    for (final a in assets) {
      final m = a as Map<String, dynamic>;
      final name = (m['name'] as String? ?? '').toLowerCase();
      if (name.isEmpty) continue;
      if (matchesOs(name) && archiveExts.any(name.endsWith)) {
        return m;
      }
    }

    // ─── مرحله 4: فقط OS ───
    for (final a in assets) {
      final m = a as Map<String, dynamic>;
      final name = (m['name'] as String? ?? '').toLowerCase();
      if (name.isEmpty) continue;
      if (matchesOs(name)) return m;
    }

    // ─── مرحله 5: هر آرشیو ───
    final extOnly = <Map<String, dynamic>>[];
    for (final a in assets) {
      final m = a as Map<String, dynamic>;
      final name = (m['name'] as String? ?? '').toLowerCase();
      if (name.isEmpty) continue;
      if (archiveExts.any(name.endsWith)) extOnly.add(m);
    }
    if (extOnly.isNotEmpty) {
      extOnly.sort((a, b) {
        final na = (a['name'] as String? ?? '').toLowerCase();
        final nb = (b['name'] as String? ?? '').toLowerCase();
        final wa = na.contains('.exe') ? 1 : 0;
        final wb = nb.contains('.exe') ? 1 : 0;
        return isWin ? wb.compareTo(wa) : wa.compareTo(wb);
      });
      return extOnly.first;
    }

    // ─── مرحله 6: هر asset ───
    for (final a in assets) {
      final m = a as Map<String, dynamic>;
      final name = (m['name'] as String? ?? '').toLowerCase();
      if (name.isEmpty) continue;
      if (matchesOs(name)) return m;
    }

    return assets.first as Map<String, dynamic>;
  }

  /// الگوهای معماری — پوشش‌دهنده نام‌گذاری‌های مختلف.
  static List<String> _archPatterns(String arch) {
    switch (arch) {
      case 'aarch64':
        return ['aarch64', 'arm64'];
      case 'armv7':
        return ['armv7', 'armhf', 'arm'];
      default:
        // x86_64
        return ['x86_64', 'amd64', 'x64'];
    }
  }
}
