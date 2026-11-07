library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../ownership_service.dart';
import '../platform_info.dart';

class DataDirResolver {
  DataDirResolver._();

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
        'Failed to use dedicated data dir: $e. '
        'Falling back to system default.',
      );
      final supportDir = await getApplicationSupportDirectory();
      final fallback = p.join(supportDir.path, 'com.mischiefpingu.app');
      await Directory(fallback).create(recursive: true);
      await OwnershipService.fixOwnership(fallback);
      _dataDir = fallback;
      return _dataDir!;
    }
  }

  static String getPlatformDir() {
    final exeDir = p.dirname(Platform.resolvedExecutable);
    return p.join(exeDir, PlatformInfo.osFolder);
  }

  static String getExeDir() {
    return p.dirname(Platform.resolvedExecutable);
  }
}
