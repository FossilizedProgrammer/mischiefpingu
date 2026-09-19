library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../../app_data_service.dart';

/// کپی درخت دایرکتوری + نصب pt.
class DirectoryCopier {
  final void Function(String)? log;
  DirectoryCopier({this.log});

  void _log(String m) => log?.call(m);
  bool get _isWin => AppDataService.isWindows;

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

  Future<void> installAetherPtDirectory({
    required String dataDir,
    String? stagingSource,
    String? fallbackSource,
  }) async {
    final destPt = p.join(dataDir, 'pt');

    String? srcPt;

    if (stagingSource != null) {
      final candidate = p.join(stagingSource, 'pt');
      if (await Directory(candidate).exists()) {
        srcPt = candidate;
      }
    }

    if (srcPt == null && fallbackSource != null) {
      final candidate = p.join(fallbackSource, 'pt');
      if (await Directory(candidate).exists()) {
        srcPt = candidate;
      }
    }

    if (srcPt == null) {
      _log(
        '→ installAetherPtDirectory: no `pt` directory found '
        '(staging=$stagingSource, fallback=$fallbackSource)',
      );
      return;
    }

    final destPtDir = Directory(destPt);
    if (await destPtDir.exists()) {
      try {
        await destPtDir.delete(recursive: true);
        _log('→ Removed old `pt` directory before install');
      } catch (e) {
        _log('⚠ Could not remove old `pt`: $e — will overwrite in place');
      }
    }

    _log('→ Installing Aether `pt` directory: $srcPt → $destPt');
    final count = await copyDirectoryTree(src: srcPt, dest: destPt);
    _log('★ Aether `pt` directory installed ($count files) → $destPt');
  }
}
