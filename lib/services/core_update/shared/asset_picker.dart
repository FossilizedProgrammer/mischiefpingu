library;

import '../../app_data_service.dart';

class AssetPicker {
  AssetPicker._();

  static const List<String> archiveExts = [
    '.tar.gz',
    '.tgz',
    '.zip',
    '.tar.xz',
    '.tar.bz2',
  ];

  /// انتخاب بهترین asset از لیست release های GitHub.
  /// [arch] یکی از: 'x86_64' | 'aarch64' | 'armv7'
  static Map<String, dynamic>? pick(List<dynamic> assets, String arch) {
    if (assets.isEmpty) return null;

    final isWin = AppDataService.isWindows;
    final archPatterns = _archPatterns(arch);

    bool looksWindows(String name) {
      if (name.contains('windows') || name.contains('win')) return true;
      return name.contains('.exe');
    }

    bool looksLinux(String name) {
      if (name.contains('linux')) return true;
      if (name.contains('windows') || name.contains('.exe')) return false;
      return true;
    }

    bool matchesOs(String name) =>
        isWin ? looksWindows(name) : looksLinux(name);

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

    for (final a in assets) {
      final m = a as Map<String, dynamic>;
      final name = (m['name'] as String? ?? '').toLowerCase();
      if (name.isEmpty) continue;
      if (matchesOs(name) && archiveExts.any(name.endsWith)) {
        return m;
      }
    }

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

    for (final a in assets) {
      final m = a as Map<String, dynamic>;
      final name = (m['name'] as String? ?? '').toLowerCase();
      if (name.isEmpty) continue;
      if (matchesOs(name)) return m;
    }

    return assets.first as Map<String, dynamic>;
  }

  static List<String> _archPatterns(String arch) {
    switch (arch) {
      case 'aarch64':
        return ['aarch64', 'arm64'];
      case 'armv7':
        return ['armv7', 'armhf', 'arm'];
      default:
        return ['x86_64', 'amd64', 'x64'];
    }
  }
}
