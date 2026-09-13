// lib/services/data_paths_service.dart

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'platform_info.dart';
import 'ownership_service.dart';
import 'tor_dir_manager.dart';

/// مدیریت مسیرهای داده، باینری‌ها و دایرکتوری Tor
class DataPathsService {
  DataPathsService._();

  static String? _dataDir;

  static void _log(String msg) {
    // ignore: avoid_print
    print(msg);
  }

  // ═══════════════════════════════════════════
  //  Data directory
  // ═══════════════════════════════════════════
  static Future<String> getDataDir() async {
    if (_dataDir != null) return _dataDir!;
    String candidate;
    if (PlatformInfo.isWindows) {
      final appData = Platform.environment['APPDATA'];
      if (appData != null && appData.isNotEmpty) {
        candidate = p.join(appData, 'com.mischiefpingu.app');
      } else {
        final supportDir = await getApplicationSupportDirectory();
        candidate = p.join(supportDir.path, 'com.mischiefpingu.app');
      }
    } else {
      final home = Platform.environment['HOME'];
      if (home != null && home.isNotEmpty) {
        candidate = p.join(home, '.local', 'share', 'com.mischiefpingu.app');
      } else {
        final supportDir = await getApplicationSupportDirectory();
        candidate = p.join(supportDir.path, 'com.mischiefpingu.app');
      }
    }
    try {
      final dir = Directory(candidate);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        _log('Created dedicated data directory: $candidate');
      } else {
        _log('Using dedicated data directory: $candidate');
      }
      await OwnershipService.fixOwnership(candidate);
      _dataDir = candidate;
      return _dataDir!;
    } catch (e) {
      _log(
          'Failed to use dedicated data dir: $e. Falling back to system default.');
      final supportDir = await getApplicationSupportDirectory();
      final fallback = p.join(supportDir.path, 'com.mischiefpingu.app');
      await Directory(fallback).create(recursive: true);
      await OwnershipService.fixOwnership(fallback);
      _dataDir = fallback;
      return _dataDir!;
    }
  }

  // ═══════════════════════════════════════════
  //  Platform directory (linux/ یا windows/ کنار باینری برنامه)
  // ═══════════════════════════════════════════
  /// مسیر پوشه‌ی پلتفرم که باینری‌ها کنار باینری اصلی برنامه قرار دارند:
  ///   Linux:  `<exeDir>/linux`
  ///   Windows: `<exeDir>/windows`
  static String getPlatformDir() {
    final exeDir = p.dirname(Platform.resolvedExecutable);
    return p.join(exeDir, PlatformInfo.osFolder);
  }

  // ═══════════════════════════════════════════
  //  Binary paths
  // ═══════════════════════════════════════════
  static Future<String> getBinaryPath(String name) async {
    final dataDir = await getDataDir();
    if (name == 'tor') {
      return p.join(dataDir, 'tor', 'tor${PlatformInfo.exeExt}');
    }
    return p.join(dataDir, '$name${PlatformInfo.exeExt}');
  }

  /// مسیر باینری SSTP.
  ///
  /// ⚠️ مهم: این متد **همیشه** مسیر داخل dataDir را برمی‌گرداند،
  /// حتی اگر فایل هنوز وجود نداشته باشد. این کار تضمین می‌کند که
  /// آپدیت‌ها و دانلودها همیشه در dataDir ذخیره شوند.
  ///
  /// اگر فایل در dataDir نباشد ولی در platformDir موجود باشد،
  /// فقط به عنوان fallback خوانده می‌شود (برای اجرا)، اما مسیر
  /// برگشتی برای نوشتن همیشه dataDir است.
  static Future<String> getSstpBinaryPath() async {
    final dataDir = await getDataDir();
    final exeName = 'sstp-proxy${PlatformInfo.exeExt}';
    return p.join(dataDir, exeName);
  }

  /// مسیر واقعی فایل SSTP برای اجرا (اول dataDir، بعد platformDir).
  /// این متد را برای اجرا استفاده کنید، نه برای نوشتن.
  static Future<String> getSstpBinaryPathForExecution() async {
    final dataDir = await getDataDir();
    final exeName = 'sstp-proxy${PlatformInfo.exeExt}';

    final dataPath = p.join(dataDir, exeName);
    if (await File(dataPath).exists()) return dataPath;

    // fallback: پوشه linux/ یا windows/ کنار باینری برنامه
    final platformPath = p.join(getPlatformDir(), exeName);
    return platformPath;
  }

  // ═══════════════════════════════════════════
  //  Tor directory
  // ═══════════════════════════════════════════
  static Future<String> getTorDir() async {
    final dataDir = await getDataDir();
    return p.join(dataDir, 'tor');
  }

  static Future<String> getTorBinaryPath() => getBinaryPath('tor');

  static Future<String?> findTorBinary() async {
    final dataDir = await getDataDir();
    final candidates = [
      p.join(dataDir, 'tor', 'tor${PlatformInfo.exeExt}'),
      p.join(dataDir, 'tor${PlatformInfo.exeExt}'),
    ];
    for (final c in candidates) {
      try {
        final t = await FileSystemEntity.type(c, followLinks: false);
        if (t == FileSystemEntityType.file && await File(c).exists()) {
          return c;
        }
      } catch (_) {}
    }
    return null;
  }

  // ═══════════════════════════════════════════
  //  Tor directory ensure (delegating)
  // ═══════════════════════════════════════════
  static Future<String> ensureTorDir() async {
    final dataDir = await getDataDir();
    final platformDir = getPlatformDir();
    return TorDirManager.ensureTorDir(
      dataDir: dataDir,
      platformDir: platformDir,
    );
  }
}
