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

  /// پوشه‌ی پلتفرم کنار باینری اصلی برنامه:
  ///   Linux:  `<exeDir>/linux`
  ///   Windows: `<exeDir>/windows`
  static String getPlatformDir() {
    final exeDir = p.dirname(Platform.resolvedExecutable);
    return p.join(exeDir, PlatformInfo.osFolder);
  }

  /// دایرکتوری که خود باینری اصلی برنامه در آن قرار دارد.
  static String getExeDir() {
    return p.dirname(Platform.resolvedExecutable);
  }

  /// لیست همهٔ مسیرهای ممکن برای یک باینری با نام [name].
  /// ترتیب = اولویت جستجو.
  static Future<List<String>> binaryCandidates(String name) async {
    final dataDir = await getDataDir();
    final exeDir = getExeDir();
    final platformDir = getPlatformDir();
    final fileName = '$name${PlatformInfo.exeExt}';

    return <String>[
      p.join(dataDir, fileName),
      p.join(platformDir, fileName),
      p.join(exeDir, fileName),
      p.normalize(p.join(dataDir, '..', fileName)),
      p.normalize(p.join(exeDir, '..', fileName)),
      p.join(exeDir, 'resources', fileName),
      p.join(exeDir, 'data', fileName),
      p.join(exeDir, 'bin', fileName),
      if (!PlatformInfo.isWindows) '/usr/local/bin/$name',
      if (!PlatformInfo.isWindows) '/usr/bin/$name',
    ];
  }

  /// اولین مسیر موجود از کاندیدها را برمی‌گرداند.
  /// اگر هیچ‌کدام نبود → null.
  static Future<String?> resolveBinaryPath(String name) async {
    final candidates = await binaryCandidates(name);
    for (final c in candidates) {
      try {
        final t = await FileSystemEntity.type(c, followLinks: true);
        if (t == FileSystemEntityType.file) {
          return c;
        }
      } catch (_) {}
    }
    return null;
  }

  /// مسیر باینری برای خواندن/اجرا.
  /// اگر پیدا نشد، مسیر پیش‌فرض (dataDir) را برمی‌گرداند تا
  /// پیام خطا معنادار باشد.
  static Future<String> getBinaryPath(String name) async {
    final found = await resolveBinaryPath(name);
    if (found != null) return found;

    final dataDir = await getDataDir();
    if (name == 'tor') {
      return p.join(dataDir, 'tor', 'tor${PlatformInfo.exeExt}');
    }
    return p.join(dataDir, '$name${PlatformInfo.exeExt}');
  }

  /// مسیر باینری برای نوشتن (Core Updates).
  /// ⚠️ همیشه dataDir — این تضمین می‌کند که آپدیت‌ها در یک
  /// مکان پایدار ذخیره شوند.
  static Future<String> getBinaryPathForWrite(String name) async {
    final dataDir = await getDataDir();
    if (name == 'tor') {
      return p.join(dataDir, 'tor', 'tor${PlatformInfo.exeExt}');
    }
    return p.join(dataDir, '$name${PlatformInfo.exeExt}');
  }

  /// لاگ همهٔ مسیرهای بررسی‌شده برای یک باینری.
  static Future<void> logBinaryCandidates(
    String name, {
    void Function(String)? log,
  }) async {
    final out = log ?? _log;
    final candidates = await binaryCandidates(name);
    out('Binary candidates for "$name":');
    for (final c in candidates) {
      final exists = await File(c).exists();
      out('   ${exists ? "✓" : "✗"} $c');
    }
  }

  /// مسیر ذخیره‌سازی SSTP (برای نوشتن — همیشه dataDir).
  static Future<String> getSstpBinaryPath() async {
    final dataDir = await getDataDir();
    final exeName = 'sstp-proxy${PlatformInfo.exeExt}';
    return p.join(dataDir, exeName);
  }

  /// مسیر واقعی فایل SSTP برای اجرا.
  /// اول همهٔ کاندیدها را چک می‌کند، در نهایت dataDir.
  static Future<String> getSstpBinaryPathForExecution() async {
    final found = await resolveBinaryPath('sstp-proxy');
    if (found != null) return found;
    return getSstpBinaryPath();
  }

  /// لیست تمام مسیرهای ممکن برای Tor (شامل زیرپوشه‌های bundle).
  static Future<List<String>> torBinaryCandidates() async {
    final dataDir = await getDataDir();
    final exeDir = getExeDir();
    final platformDir = getPlatformDir();
    final exe = 'tor${PlatformInfo.exeExt}';

    return <String>[
      p.join(dataDir, 'tor', exe),
      p.join(dataDir, exe),
      p.join(platformDir, 'tor', exe),
      p.join(platformDir, exe),
      p.join(exeDir, 'tor', exe),
      p.join(exeDir, exe),
      p.join(dataDir, 'tor', 'tor', exe),
      p.join(exeDir, 'tor', 'tor', exe),
      p.join(platformDir, 'tor', 'tor', exe),
      p.join(dataDir, 'Tor Browser', 'Browser', 'TorBrowser', 'Tor', exe),
      p.join(exeDir, 'Tor Browser', 'Browser', 'TorBrowser', 'Tor', exe),
      p.join(dataDir, 'Browser', 'TorBrowser', 'Tor', exe),
      p.join(exeDir, 'Browser', 'TorBrowser', 'Tor', exe),
      if (!PlatformInfo.isWindows) '/usr/bin/tor',
      if (!PlatformInfo.isWindows) '/usr/local/bin/tor',
    ];
  }

  static Future<String> getTorDir() async {
    final dataDir = await getDataDir();
    return p.join(dataDir, 'tor');
  }

  static Future<String> getTorBinaryPath() => getBinaryPath('tor');

  /// پیدا کردن باینری Tor در همهٔ مسیرهای ممکن.
  static Future<String?> findTorBinary() async {
    final candidates = await torBinaryCandidates();
    for (final c in candidates) {
      try {
        final t = await FileSystemEntity.type(c, followLinks: true);
        if (t == FileSystemEntityType.file) {
          return c;
        }
      } catch (_) {}
    }
    return null;
  }

  /// لاگ همهٔ مسیرهای بررسی‌شده برای Tor.
  static Future<void> logTorBinaryCandidates({
    void Function(String)? log,
  }) async {
    final out = log ?? _log;
    final candidates = await torBinaryCandidates();
    out('Tor binary candidates checked:');
    for (final c in candidates) {
      final exists = await File(c).exists();
      out('   ${exists ? "✓" : "✗"} $c');
    }
  }

  static Future<String> ensureTorDir() async {
    final dataDir = await getDataDir();
    final platformDir = getPlatformDir();
    return TorDirManager.ensureTorDir(
      dataDir: dataDir,
      platformDir: platformDir,
    );
  }

  /// لیست مسیرهای ممکن برای پوشه `pt` (Aether).
  static Future<List<String>> aetherPtCandidates() async {
    final dataDir = await getDataDir();
    final exeDir = getExeDir();
    final platformDir = getPlatformDir();

    return <String>[
      p.join(dataDir, 'pt'),
      p.join(platformDir, 'pt'),
      p.join(exeDir, 'pt'),
      p.normalize(p.join(dataDir, '..', 'pt')),
      p.normalize(p.join(exeDir, '..', 'pt')),
      p.join(exeDir, 'resources', 'pt'),
      p.join(exeDir, 'data', 'pt'),
    ];
  }

  /// پیدا کردن اولین پوشه `pt` موجود.
  static Future<String?> findAetherPtDir() async {
    final candidates = await aetherPtCandidates();
    for (final c in candidates) {
      try {
        final t = await FileSystemEntity.type(c, followLinks: true);
        if (t == FileSystemEntityType.directory) {
          return c;
        }
      } catch (_) {}
    }
    return null;
  }
}
