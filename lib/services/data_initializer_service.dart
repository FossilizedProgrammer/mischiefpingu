library;

import 'dart:io';
import 'package:path/path.dart' as p;
import 'platform_info.dart';
import 'ownership_service.dart';
import 'data_paths_service.dart';
import 'tor_bundle_seeder.dart';
import 'psiphon_data_seeder.dart';
import 'data_init/aether_pt_seeder.dart';
import 'data_init/shared_files_seeder.dart';

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

    await SharedFilesSeeder.seedSharedFiles(
      dataDir: dataDir,
      exeDir: exeDir,
    );

    await SharedFilesSeeder.cleanupStaleServerList(dataDir: dataDir);

    await SharedFilesSeeder.seedPlatformBinaries(
      dataDir: dataDir,
      platformDir: platformDir,
    );

    await AetherPtSeeder.seed(
      dataDir: dataDir,
      platformDir: platformDir,
    );

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
