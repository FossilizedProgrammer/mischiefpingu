import 'dart:io';
import 'package:path/path.dart' as p;
import 'platform_info.dart';
import 'ownership_service.dart';
import 'data_paths_service.dart';
import 'tor_bundle_seeder.dart';
import 'psiphon_data_seeder.dart';

/// مقداردهی اولیه فایل‌های داده (کپی باینری‌ها و فایل‌های مشترک)
class DataInitializerService {
  DataInitializerService._();

  static final List<String> _initLogs = [];
  static List<String> get initLogs => List.unmodifiable(_initLogs);

  static void _log(String msg) {
    _initLogs.add(msg);
    // ignore: avoid_print
    print(msg);
  }

  static Future<void> initializeDataFiles() async {
    _initLogs.clear();
    final dataDir = await DataPathsService.getDataDir();
    final exeDir = p.dirname(Platform.resolvedExecutable);
    final platformDir = p.join(exeDir, PlatformInfo.osFolder);
    _log('Executable directory: $exeDir');
    _log('Platform-specific binaries directory: $platformDir');
    _log('Data directory: $dataDir');
    _log('Platform: ${Platform.operatingSystem}');
    _log('Elevated (root/admin): ${PlatformInfo.isRoot}');
    if (PlatformInfo.realUsername != null) {
      _log(
          'Real user: ${PlatformInfo.realUsername} (home: ${PlatformInfo.realUserHome ?? '?'})');
    }
    if (PlatformInfo.isRunningInAppImage) {
      _log('Running inside AppImage');
    }

    // ─── فایل‌های مشترک ───
    final sharedFiles = ['server_list.dat', 'geoip', 'geoip6'];
    for (final fileName in sharedFiles) {
      final source = File(p.join(exeDir, fileName));
      final dest = File(p.join(dataDir, fileName));
      if (!await source.exists()) {
        _log('Shared file not found next to binary: $fileName');
        continue;
      }
      try {
        if (!await dest.exists()) {
          await source.copy(dest.path);
          _log('Copied shared data file: $fileName');
        } else {
          _log(
              'Shared data file already exists (preserving live updates): $fileName');
        }
      } catch (e) {
        _log('Failed to copy shared file $fileName: $e');
      }
    }

    // ─── باینری‌های پلتفرم-مخصوص ───
    final platformBinaries = [
      'psiphon-tunnel-core',
      'psiphon-tunnel-core-sunandlion',
      'aether',
      'sstp-proxy', // ← اضافه شد
    ];
    for (final fileName in platformBinaries) {
      final sourceName = '$fileName${PlatformInfo.exeExt}';
      final source = File(p.join(platformDir, sourceName));
      final dest = File(p.join(dataDir, sourceName));
      if (!await source.exists()) {
        _log('Platform binary not found: $platformDir/$sourceName');
        continue;
      }
      try {
        bool shouldCopy = true;
        if (await dest.exists()) {
          final srcLen = await source.length();
          final dstLen = await dest.length();
          if (srcLen == dstLen) {
            shouldCopy = false;
            _log('Binary already up-to-date (same size): $sourceName');
          }
        }
        if (shouldCopy) {
          await source.copy(dest.path);
          _log('Copied/Updated platform binary: $sourceName');
          if (!PlatformInfo.isWindows) {
            try {
              await Process.run('chmod', ['+x', dest.path]);
            } catch (_) {}
          }
        }
      } catch (e) {
        _log('Failed to copy $sourceName: $e');
      }
    }

    await OwnershipService.fixOwnership(dataDir);
    await DataPathsService.ensureTorDir();
    await _seedTorBundleFromPlatformDir(dataDir, platformDir);
    await _seedPsiphonDataDirFromExeDir(dataDir, exeDir);
    try {
      await File(p.join(dataDir, 'app.pid')).writeAsString('$pid\n');
    } catch (_) {}
  }

  static Future<void> _seedTorBundleFromPlatformDir(
    String dataDir,
    String platformDir,
  ) async {
    await TorBundleSeeder.seedFullBundle(
      dataTorDir: p.join(dataDir, 'tor'),
      platformTorDir: p.join(platformDir, 'tor'),
      log: _log,
      fixOwnership: OwnershipService.fixOwnership,
    );
  }

  static Future<void> _seedPsiphonDataDirFromExeDir(
    String dataDir,
    String exeDir,
  ) async {
    await PsiphonDataSeeder.seedFromExeDir(
      dataDir: dataDir,
      exeDir: exeDir,
      log: _log,
      fixOwnership: OwnershipService.fixOwnership,
    );
  }
}
