library;

import 'dart:io';
import 'package:path/path.dart' as p;
import '../platform_info.dart';

class AetherPtSeeder {
  AetherPtSeeder._();

  static void _log(String msg) {
    // ignore: avoid_print
    print(msg);
  }

  static Future<void> seed({
    required String dataDir,
    required String platformDir,
  }) async {
    final srcPt = Directory(p.join(platformDir, 'pt'));
    final destPt = Directory(p.join(dataDir, 'pt'));

    try {
      final srcType =
          await FileSystemEntity.type(srcPt.path, followLinks: false);
      if (srcType != FileSystemEntityType.directory) {
        _log(
            'No `pt` directory in platform dir ($platformDir/pt) — skipping Aether pt seed');
        return;
      }
    } catch (e) {
      _log('Failed to check platform `pt` dir: $e');
      return;
    }

    try {
      if (await destPt.exists()) {
        _log(
            'Aether `pt` directory already exists in data dir — preserving (Core Updates may have updated it)');
        return;
      }
    } catch (_) {}

    _log('→ Seeding Aether `pt` directory: ${srcPt.path} → ${destPt.path}');
    try {
      await destPt.create(recursive: true);
      var count = 0;
      await for (final entity
          in srcPt.list(recursive: true, followLinks: false)) {
        final rel = p.relative(entity.path, from: srcPt.path);
        if (rel == '.' || rel.isEmpty) continue;
        final dest = p.join(destPt.path, rel);
        if (entity is Directory) {
          await Directory(dest).create(recursive: true);
        } else if (entity is File) {
          await Directory(p.dirname(dest)).create(recursive: true);
          if (!await File(dest).exists()) {
            await entity.copy(dest);
            if (!PlatformInfo.isWindows) {
              try {
                await Process.run('chmod', ['+x', dest]);
              } catch (_) {}
            }
            count++;
          }
        }
      }
      _log('★ Seeded Aether `pt` directory: $count file(s) copied');
    } catch (e) {
      _log('⚠ Failed to seed Aether `pt` directory: $e');
    }
  }
}
