// lib/services/core_update_utils.dart
library;

import 'dart:io';
import 'package:path/path.dart' as p;

class CoreUpdateUtils {
  static bool isMissingVersion(String v) {
    final t = v.trim().toLowerCase();
    return t.isEmpty || t == 'unknown' || t == 'not installed';
  }

  static String? parseAetherVersion(String? output) {
    if (output == null || output.isEmpty) return null;
    final parts = output.split(RegExp(r'\s+'));
    for (final pt in parts.reversed) {
      if (RegExp(r'^\d+\.\d+').hasMatch(pt)) return pt.trim();
    }
    return output.trim().split('\n').first.trim();
  }

  static String? parsePsiphonVersion(String? output) {
    if (output == null || output.isEmpty) return null;
    final revMatch =
        RegExp(r'Revision:\s*([0-9a-f]{7,40})', caseSensitive: false)
            .firstMatch(output);
    final rev = revMatch?.group(1)?.trim();
    if (rev == null || rev.isEmpty) return null;
    final short = rev.length > 10 ? rev.substring(0, 10) : rev;
    final dateMatch = RegExp(r'Build Date:\s*([0-9]{4}-[0-9]{2}-[0-9]{2})')
        .firstMatch(output);
    final date = dateMatch?.group(1);
    return date != null ? '$short ($date)' : short;
  }

  static String? parseTorVersion(String? output) {
    if (output == null || output.isEmpty) return null;
    final m = RegExp(r'version\s+([0-9][\w.\-]+)', caseSensitive: false)
        .firstMatch(output);
    if (m != null) return m.group(1)!.trim();
    return output.trim().split('\n').first.trim();
  }

  static bool isNewerVersion(String installed, String latest) {
    List<int> parse(String v) => v
        .split(RegExp(r'[.\-+]'))
        .map((e) =>
            int.tryParse(RegExp(r'\d+').firstMatch(e)?.group(0) ?? '0') ?? 0)
        .toList();
    final a = parse(installed);
    final b = parse(latest);
    for (var i = 0; i < b.length; i++) {
      final ai = i < a.length ? a[i] : 0;
      if (b[i] > ai) return true;
      if (b[i] < ai) return false;
    }
    return false;
  }

  static String formatBytes(int bytes) {
    if (bytes >= 1048576) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '$bytes B';
  }

  static Future<int> fileSize(String path) async {
    try {
      return await File(path).length();
    } catch (_) {
      return 0;
    }
  }

  /// بررسی می‌کند که مسیر یک فایل واقعی و قابل خواندن است
  /// (نه symlink شکسته، نه دایرکتوری).
  static Future<bool> isRealFile(String path) async {
    try {
      final type = await FileSystemEntity.type(path, followLinks: true);
      if (type != FileSystemEntityType.file) return false;
      final f = File(path);
      final size = await f.length();
      if (size == 0) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// فایل را با نام دقیق پیدا می‌کند.
  static Future<String?> findFile(Directory root, String name) async {
    await for (final e in root.list(recursive: true, followLinks: false)) {
      if (e is! File) continue;
      if (p.basename(e.path) != name) continue;
      if (await isRealFile(e.path)) return e.path;
    }
    return null;
  }

  /// فایل را با پیشوند مشخص پیدا می‌کند.
  /// اولویت: بدون پسوند `.exe` اول، سپس کوتاه‌ترین اسم.
  static Future<String?> findFileByPrefix(Directory root, String prefix) async {
    final candidates = <String>[];
    await for (final e in root.list(recursive: true, followLinks: false)) {
      if (e is! File) continue;
      final base = p.basename(e.path);
      if (base.startsWith(prefix)) {
        candidates.add(e.path);
      }
    }

    candidates.sort((a, b) {
      final ba = p.basename(a).toLowerCase();
      final bb = p.basename(b).toLowerCase();
      final sa = ba.endsWith('.exe') ? 1 : 0;
      final sb = bb.endsWith('.exe') ? 1 : 0;
      if (sa != sb) return sa.compareTo(sb);
      return ba.length.compareTo(bb.length);
    });

    for (final c in candidates) {
      if (await isRealFile(c)) return c;
    }
    return null;
  }

  /// هر فایلی که در اسم یا مسیرش الگوی مشخصی داشته باشد پیدا می‌کند.
  static Future<String?> findFileContaining(
      Directory root, String pattern) async {
    final lower = pattern.toLowerCase();
    await for (final e in root.list(recursive: true, followLinks: false)) {
      if (e is! File) continue;
      if (e.path.toLowerCase().contains(lower) &&
          await isRealFile(e.path)) {
        return e.path;
      }
    }
    return null;
  }
}
