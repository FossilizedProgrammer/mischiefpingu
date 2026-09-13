// lib/services/tor_dir_manager.dart
//
// ═══════════════════════════════════════════════════════════════
//  TorDirManager — مدیریت دایرکتوری Tor و seed فایل‌ها
//  (تفکیک شده از data_paths_service.dart)
// ═══════════════════════════════════════════════════════════════
library;

import 'dart:io';
import 'package:path/path.dart' as p;
import 'platform_info.dart';
import 'tor_bundle_seeder.dart';

class TorDirManager {
  TorDirManager._();

  static void _log(String msg) {
    // ignore: avoid_print
    print(msg);
  }

  /// اطمینان از وجود دایرکتوری Tor و seed فایل‌های لازم.
  static Future<String> ensureTorDir({
    required String dataDir,
    required String platformDir,
  }) async {
    final torDir = p.join(dataDir, 'tor');

    try {
      final type = await FileSystemEntity.type(torDir, followLinks: false);
      if (type == FileSystemEntityType.file) {
        await _migrateLegacyTorFile(torDir);
      } else {
        await Directory(torDir).create(recursive: true);
      }
    } catch (e) {
      _log('ensureTorDir failed: $e');
    }

    await _seedAllFiles(
      torDir: torDir,
      dataDir: dataDir,
      platformDir: platformDir,
    );

    return torDir;
  }

  static Future<void> _migrateLegacyTorFile(String torDir) async {
    final tmp = '$torDir.legacy-tmp';
    try {
      await File(torDir).rename(tmp);
    } catch (_) {}
    await Directory(torDir).create(recursive: true);
    try {
      final dest = p.join(torDir, 'tor${PlatformInfo.exeExt}');
      if (await File(tmp).exists() && !await File(dest).exists()) {
        await File(tmp).rename(dest);
        if (!PlatformInfo.isWindows) {
          try {
            await Process.run('chmod', ['+x', dest]);
          } catch (_) {}
        }
        _log('Migrated legacy tor binary → $dest');
      } else {
        try {
          await File(tmp).delete();
        } catch (_) {}
      }
    } catch (e) {
      _log('Tor migration failed: $e');
    }
  }

  static Future<void> _seedAllFiles({
    required String torDir,
    required String dataDir,
    required String platformDir,
  }) async {
    final exeExt = PlatformInfo.exeExt;

    // tor binary
    await TorBundleSeeder.seedFile(
      torDir: torDir,
      dataDir: dataDir,
      platformDir: platformDir,
      name: 'tor$exeExt',
      destRel: 'tor$exeExt',
      executable: true,
      log: _log,
    );

    // lyrebird (root + pluggable_transports)
    for (final destRel in [
      'lyrebird$exeExt',
      p.join('pluggable_transports', 'lyrebird$exeExt'),
    ]) {
      await TorBundleSeeder.seedFile(
        torDir: torDir,
        dataDir: dataDir,
        platformDir: platformDir,
        name: 'lyrebird$exeExt',
        destRel: destRel,
        executable: true,
        log: _log,
      );
    }

    // conjure-client (root + pluggable_transports)
    for (final destRel in [
      'conjure-client$exeExt',
      p.join('pluggable_transports', 'conjure-client$exeExt'),
    ]) {
      await TorBundleSeeder.seedFile(
        torDir: torDir,
        dataDir: dataDir,
        platformDir: platformDir,
        name: 'conjure-client$exeExt',
        destRel: destRel,
        executable: true,
        log: _log,
      );
    }

    // geoip + geoip6
    for (final name in ['geoip', 'geoip6']) {
      await TorBundleSeeder.seedFile(
        torDir: torDir,
        dataDir: dataDir,
        platformDir: platformDir,
        name: name,
        destRel: name,
        executable: false,
        log: _log,
      );
    }
  }
}
