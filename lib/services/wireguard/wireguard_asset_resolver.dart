library;

import '../app_data_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  WireGuardAssetResolver — انتخاب asset مناسب از releaseهای
///  `windtf/wireproxy`.
///
///  repo `windtf/wireproxy` در releaseهاش معمولاً این assetها
///  رو منتشر می‌کنه:
///    • wireproxy_linux_amd64
///    • wireproxy_linux_arm64
///    • wireproxy_linux_armv7
///    • wireproxy_windows_amd64.exe
///    • wireproxy_windows_arm64.exe
///    • Source code (zip)  ← این رو نباید انتخاب کنه
///    • Source code (tar.gz) ← این رو نباید انتخاب کنه
///
///  اگر repo در آینده اسم‌گذاری رو عوض کرد، فقط این فایل
///  باید تغییر کنه.
/// ═══════════════════════════════════════════════════════════════
class WireGuardAssetResolver {
  WireGuardAssetResolver._();

  /// انتخاب asset مناسب.
  ///
  /// خروجی:
  ///   • اولین asset مطابق → برگردانده می‌شه
  ///   • null → هیچ asset مناسبی پیدا نشد
  static Map<String, dynamic>? pick(
    List<dynamic> assets,
    String arch,
  ) {
    if (assets.isEmpty) return null;

    final isWin = AppDataService.isWindows;
    final archTags = _archTags(arch);
    final osTags = isWin ? const ['windows', 'win'] : const ['linux'];

    // ─── مرحله 1: نام دقیق `wireproxy_<os>_<arch>[.exe]` ───
    for (final a in assets) {
      final m = a as Map<String, dynamic>;
      final name = (m['name'] as String? ?? '').toLowerCase();
      if (_isSourceCode(name)) continue;

      if (name.startsWith('wireproxy_') &&
          osTags.any(name.contains) &&
          archTags.any(name.contains)) {
        return m;
      }
    }

    // ─── مرحله 2: فقط `wireproxy` در نام + OS + arch ───
    for (final a in assets) {
      final m = a as Map<String, dynamic>;
      final name = (m['name'] as String? ?? '').toLowerCase();
      if (_isSourceCode(name)) continue;
      if (!name.contains('wireproxy')) continue;

      if (osTags.any(name.contains) && archTags.any(name.contains)) {
        return m;
      }
    }

    // ─── مرحله 3: فقط `wireproxy` + OS ───
    for (final a in assets) {
      final m = a as Map<String, dynamic>;
      final name = (m['name'] as String? ?? '').toLowerCase();
      if (_isSourceCode(name)) continue;
      if (!name.contains('wireproxy')) continue;

      if (osTags.any(name.contains)) {
        return m;
      }
    }

    // ─── مرحله 4: هر asset با `wireproxy` در نام (بدون source) ───
    for (final a in assets) {
      final m = a as Map<String, dynamic>;
      final name = (m['name'] as String? ?? '').toLowerCase();
      if (_isSourceCode(name)) continue;
      if (name.contains('wireproxy')) {
        return m;
      }
    }

    // ─── مرحله 5: هر آرشیوی که source نباشه ───
    for (final a in assets) {
      final m = a as Map<String, dynamic>;
      final name = (m['name'] as String? ?? '').toLowerCase();
      if (_isSourceCode(name)) continue;
      if (_isArchive(name)) return m;
    }

    return null;
  }

  /// الگوهای معماری برای هر arch.
  static List<String> _archTags(String arch) {
    switch (arch) {
      case 'aarch64':
        return const ['arm64', 'aarch64'];
      case 'armv7':
        return const ['armv7', 'armhf'];
      default:
        return const ['amd64', 'x86_64'];
    }
  }

  /// آیا این asset سورس کد است؟ (نباید دانلود بشه)
  static bool _isSourceCode(String name) {
    return name.contains('source code') ||
        name == 'source code (zip)' ||
        name == 'source code (tar.gz)';
  }

  static bool _isArchive(String name) {
    return name.endsWith('.tar.gz') ||
        name.endsWith('.tgz') ||
        name.endsWith('.zip') ||
        name.endsWith('.tar.xz');
  }
}
