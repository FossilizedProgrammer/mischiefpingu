import 'dart:io';

import 'package:path/path.dart' as p;

/// عملیات کپی فایل‌های Psiphon از دایرکتوری exe به data
class PsiphonDataSeeder {
  PsiphonDataSeeder._();

  static Future<void> seedFromExeDir({
    required String dataDir,
    required String exeDir,
    required void Function(String) log,
    required Future<void> Function(String) fixOwnership,
  }) async {
    const psiDirName = 'ca.psiphon.PsiphonTunnel.tunnel-core';
    final exePsiDir = p.join(exeDir, psiDirName);
    final dataPsiDir = p.join(dataDir, psiDirName);

    try {
      final type = await FileSystemEntity.type(exePsiDir, followLinks: false);
      if (type != FileSystemEntityType.directory) {
        log('No Psiphon data directory next to executable — skipping seed');
        return;
      }
    } catch (_) {
      return;
    }

    try {
      if (await Directory(dataPsiDir).exists()) {
        log(
          'Psiphon data directory already exists in data dir — skipping exe-dir seed',
        );
        return;
      }
    } catch (_) {}

    log('→ Seeding Psiphon data directory from $exePsiDir → $dataPsiDir');
    try {
      await Directory(dataPsiDir).create(recursive: true);
      var count = 0;
      await for (final entity in Directory(
        exePsiDir,
      ).list(recursive: true, followLinks: false)) {
        final rel = p.relative(entity.path, from: exePsiDir);
        if (rel == '.' || rel.isEmpty) continue;
        final dest = p.join(dataPsiDir, rel);
        if (entity is Directory) {
          await Directory(dest).create(recursive: true);
        } else if (entity is File) {
          await Directory(p.dirname(dest)).create(recursive: true);
          if (!await File(dest).exists()) {
            await entity.copy(dest);
            count++;
          }
        }
      }
      log('★ Seeded Psiphon data directory: $count files copied from exe-dir');
      await fixOwnership(dataPsiDir);
    } catch (e) {
      log('⚠ Failed to seed Psiphon data directory from exe-dir: $e');
    }
  }
}
