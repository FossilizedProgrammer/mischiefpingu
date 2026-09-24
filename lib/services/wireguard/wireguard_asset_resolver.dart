// lib/services/wireguard/wireguard_asset_resolver.dart

import '../app_data_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  WireGuardAssetResolver — انتخاب asset مناسب از releaseهای
///  windtf/wireproxy و artem-russkikh/wireproxy-awg.
///
///  ⚠️ هر دو repo از الگوی نام‌گذاری مشابه استفاده می‌کنند:
///    • windtf/wireproxy:       wireproxy_linux_amd64
///    • artem-russkikh/wireproxy-awg: wireproxy-awg_linux_amd64
///
///  🆕 متد pick حالا با هر دو prefix (wireproxy و wireproxy-awg)
///  کار می‌کند تا کد ساده‌تر بماند.
/// ═══════════════════════════════════════════════════════════════
class WireGuardAssetResolver {
  WireGuardAssetResolver._();

  /// پیشوندهای شناخته‌شده — به ترتیب اولویت.
  static const List<String> _knownPrefixes = [
    'wireproxy-awg',
    'wireproxy',
  ];

  /// ─────────────────────────────────────────────────────────
  ///  انتخاب asset برای wireproxy (Standard)
  /// ─────────────────────────────────────────────────────────
  static Map<String, dynamic>? pickStandard(
    List<dynamic> assets,
    String arch,
  ) =>
      _pickWithPrefixes(assets, arch, preferredPrefix: 'wireproxy');

  /// ─────────────────────────────────────────────────────────
  ///  انتخاب asset برای wireproxy-awg (Amnezia)
  /// ─────────────────────────────────────────────────────────
  static Map<String, dynamic>? pickAwg(
    List<dynamic> assets,
    String arch,
  ) =>
      _pickWithPrefixes(assets, arch, preferredPrefix: 'wireproxy-awg');

  /// ─────────────────────────────────────────────────────────
  ///  منطق مشترک انتخاب asset با prefix دلخواه.
  ///
  ///  ⚠️ اگر [preferredPrefix] موجود نبود، به ترتیب از
  ///  `_knownPrefixes` استفاده می‌کند. این باعث می‌شود اگر repo
  ///  اسم‌گذاری asset را عوض کرد، باز هم کار کند.
  /// ─────────────────────────────────────────────────────────
  static Map<String, dynamic>? _pickWithPrefixes(
    List<dynamic> assets,
    String arch, {
    String? preferredPrefix,
  }) {
    if (assets.isEmpty) return null;

    final isWin = AppDataService.isWindows;
    final archTags = _archTags(arch);
    final osTags = isWin ? const ['windows', 'win'] : const ['linux'];

    // ترتیب prefixها: اول prefix ترجیحی، بعد بقیه
    final prefixes = <String>[
      if (preferredPrefix != null) preferredPrefix,
      ..._knownPrefixes.where((p) => p != preferredPrefix),
    ];

    // ─── مرحله 1: prefix + OS + arch (با _ یا -) ───
    for (final prefix in prefixes) {
      for (final a in assets) {
        final m = a as Map<String, dynamic>;
        final name = (m['name'] as String? ?? '').toLowerCase();
        if (_isSourceCode(name)) continue;
        if (!name.startsWith(prefix)) continue;

        // جلوگیری از match نادرست: wireproxy نباید wireproxy-awg را match کند
        final rest = name.substring(prefix.length);
        if (prefix == 'wireproxy' && rest.startsWith('-awg')) continue;

        if (osTags.any(name.contains) && archTags.any(name.contains)) {
          return m;
        }
      }
    }

    // ─── مرحله 2: prefix + OS ───
    for (final prefix in prefixes) {
      for (final a in assets) {
        final m = a as Map<String, dynamic>;
        final name = (m['name'] as String? ?? '').toLowerCase();
        if (_isSourceCode(name)) continue;
        if (!name.startsWith(prefix)) continue;

        final rest = name.substring(prefix.length);
        if (prefix == 'wireproxy' && rest.startsWith('-awg')) continue;

        if (osTags.any(name.contains)) return m;
      }
    }

    // ─── مرحله 3: فقط prefix ───
    for (final prefix in prefixes) {
      for (final a in assets) {
        final m = a as Map<String, dynamic>;
        final name = (m['name'] as String? ?? '').toLowerCase();
        if (_isSourceCode(name)) continue;
        if (!name.startsWith(prefix)) continue;

        final rest = name.substring(prefix.length);
        if (prefix == 'wireproxy' && rest.startsWith('-awg')) continue;

        return m;
      }
    }

    // ─── مرحله 4: هر آرشیوی که source نباشه ───
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

  /// آیا این asset سورس کد است؟
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
