import 'dart:io';
import 'package:path/path.dart' as p;
import 'platform_info.dart';

/// عملیات کپی و آماده‌سازی فایل‌های Tor bundle
class TorBundleSeeder {
  TorBundleSeeder._();

  /// seed یک فایل منفرد به torDir
  static Future<void> seedFile({
    required String torDir,
    required String dataDir,
    required String platformDir,
    required String name,
    required String destRel,
    required bool executable,
    required void Function(String) log,
  }) async {
    try {
      final dest = p.join(torDir, destRel);
      if (await File(dest).exists()) return;

      final fromPlatform = File(p.join(platformDir, name));
      final fromRoot = File(p.join(dataDir, name));

      File? src;
      if (await fromPlatform.exists()) {
        src = fromPlatform;
      } else if (await fromRoot.exists()) {
        if (name != 'tor') src = fromRoot;
      }
      if (src == null) return;

      await Directory(p.dirname(dest)).create(recursive: true);
      await src.copy(dest);

      if (executable && !PlatformInfo.isWindows) {
        try {
          await Process.run('chmod', ['+x', dest]);
        } catch (_) {}
      }
      log('Seeded tor dir file: $destRel');
    } catch (e) {
      log('Failed to seed tor dir ($name): $e');
    }
  }

  /// کپی کامل bundle از platformDir به dataTorDir
  static Future<void> seedFullBundle({
    required String dataTorDir,
    required String platformTorDir,
    required void Function(String) log,
    required Future<void> Function(String) fixOwnership,
  }) async {
    try {
      final type =
          await FileSystemEntity.type(platformTorDir, followLinks: false);
      if (type != FileSystemEntityType.directory) {
        log('No tor bundle directory in $platformTorDir — skipping seed');
        return;
      }
    } catch (_) {
      return;
    }

    try {
      final existingTor = p.join(dataTorDir, 'tor${PlatformInfo.exeExt}');
      if (await File(existingTor).exists()) {
        log('Tor bundle already installed in data dir — skipping platform-dir seed');
        return;
      }
    } catch (_) {}

    log('→ Seeding full tor bundle from $platformTorDir → $dataTorDir');
    try {
      await Directory(dataTorDir).create(recursive: true);
      var count = 0;
      await for (final entity in Directory(platformTorDir)
          .list(recursive: true, followLinks: false)) {
        final rel = p.relative(entity.path, from: platformTorDir);
        if (rel == '.' || rel.isEmpty) continue;
        final first = rel.split(p.separator).first;
        if (first == 'tordata' || first == 'torrc' || first == 'cached-certs') {
          continue;
        }
        final dest = p.join(dataTorDir, rel);
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

      const executables = {
        'tor',
        'lyrebird',
        'conjure-client',
        'tor-gencert',
        'tor-resolve',
        'torify',
        'snowflake-client',
        'webtunnel-client',
        'obfs4proxy',
      };

      await for (final entity
          in Directory(dataTorDir).list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final base = p.basename(entity.path).toLowerCase();
          final baseNoExt = PlatformInfo.isWindows && base.endsWith('.exe')
              ? base.substring(0, base.length - 4)
              : base;
          final shouldChmod = !PlatformInfo.isWindows &&
              (executables.contains(baseNoExt) ||
                  entity.path.contains('pluggable_transports') ||
                  !base.contains('.'));
          if (shouldChmod) {
            try {
              await Process.run('chmod', ['+x', entity.path]);
            } catch (_) {}
          }
        }
      }

      log('★ Seeded tor bundle: $count files copied from platform-dir');
      await fixOwnership(dataTorDir);
    } catch (e) {
      log('⚠ Failed to seed tor bundle from platform-dir: $e');
    }
  }
}
