library;

import 'dart:io';

import 'package:path/path.dart' as p;

class FileFinder {
  FileFinder._();

  /// آیا مسیر یک فایل واقعی و قابل خواندن است؟
  static Future<bool> isRealFile(String path) async {
    try {
      final type = await FileSystemEntity.type(path, followLinks: true);
      if (type != FileSystemEntityType.file) return false;
      final size = await File(path).length();
      return size > 0;
    } catch (_) {
      return false;
    }
  }

  /// اندازه فایل (0 اگر خطا).
  static Future<int> fileSize(String path) async {
    try {
      return await File(path).length();
    } catch (_) {
      return 0;
    }
  }

  /// فایل با نام دقیق.
  static Future<String?> byName(Directory root, String name) async {
    await for (final e in root.list(recursive: true, followLinks: false)) {
      if (e is! File) continue;
      if (p.basename(e.path) != name) continue;
      if (await isRealFile(e.path)) return e.path;
    }
    return null;
  }

  /// فایل با پیشوند مشخص.
  static Future<String?> byPrefix(Directory root, String prefix) async {
    final candidates = <String>[];
    await for (final e in root.list(recursive: true, followLinks: false)) {
      if (e is! File) continue;
      final base = p.basename(e.path);
      if (base.startsWith(prefix)) candidates.add(e.path);
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

  /// فایل با الگو در مسیر.
  static Future<String?> byContaining(Directory root, String pattern) async {
    final lower = pattern.toLowerCase();
    await for (final e in root.list(recursive: true, followLinks: false)) {
      if (e is! File) continue;
      if (e.path.toLowerCase().contains(lower) && await isRealFile(e.path)) {
        return e.path;
      }
    }
    return null;
  }
}
