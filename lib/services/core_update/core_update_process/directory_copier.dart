library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../../app_data_service.dart';

part 'aether_pt_installer.dart';

/// ═══════════════════════════════════════════════════════════════
///  DirectoryCopier — کپی درخت دایرکتوری.
///
///  نصب پوشه `pt` مخصوص Aether به `aether_pt_installer.dart`
///  منتقل شده و از طریق extension `AetherPtInstaller`
///  در دسترسه.
/// ═══════════════════════════════════════════════════════════════
class DirectoryCopier {
  final void Function(String)? log;
  DirectoryCopier({this.log});

  void _log(String m) => log?.call(m);
  bool get _isWin => AppDataService.isWindows;

  /// کپی درخت دایرکتوری از src به dest.
  ///
  /// اگر [skipIfExists] true باشه، فایل‌های موجود بازنویسی نمی‌شن.
  /// خروجی: تعداد فایل‌های کپی‌شده.
  Future<int> copyDirectoryTree({
    required String src,
    required String dest,
    bool skipIfExists = false,
  }) async {
    final srcDir = Directory(src);
    if (!await srcDir.exists()) {
      _log('→ copyDirectoryTree: source does not exist → $src');
      return 0;
    }

    await Directory(dest).create(recursive: true);
    var count = 0;

    await for (final entity in srcDir.list(
      recursive: true,
      followLinks: false,
    )) {
      final rel = p.relative(entity.path, from: src);
      if (rel == '.' || rel.isEmpty) continue;

      final destPath = p.join(dest, rel);

      if (entity is Directory) {
        await Directory(destPath).create(recursive: true);
      } else if (entity is File) {
        if (skipIfExists && await File(destPath).exists()) continue;
        await Directory(p.dirname(destPath)).create(recursive: true);
        await entity.copy(destPath);

        if (!_isWin) {
          final base = p.basename(destPath).toLowerCase();
          final relParts = p.split(rel);
          final isInsidePt = relParts.contains('pt');
          final shouldChmod = base == 'aether' ||
              base == 'aether.exe' ||
              !base.contains('.') ||
              isInsidePt;
          if (shouldChmod) {
            try {
              await Process.run('chmod', ['+x', destPath]);
            } catch (_) {}
          }
        }
        count++;
      }
    }

    _log('→ copyDirectoryTree: $count file(s) copied → $dest');
    return count;
  }
}
