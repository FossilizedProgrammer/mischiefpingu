library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../platform_info.dart';
import 'data_dir_resolver.dart';

class BinaryPathsService {
  BinaryPathsService._();

  static void _log(String msg) {
    // ignore: avoid_print
    print(msg);
  }

  static Future<List<String>> binaryCandidates(String name) async {
    final dataDir = await DataDirResolver.getDataDir();
    final exeDir = DataDirResolver.getExeDir();
    final platformDir = DataDirResolver.getPlatformDir();
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

  static Future<String> getBinaryPath(String name) async {
    final found = await resolveBinaryPath(name);
    if (found != null) return found;

    final dataDir = await DataDirResolver.getDataDir();
    if (name == 'tor') {
      return p.join(dataDir, 'tor', 'tor${PlatformInfo.exeExt}');
    }
    return p.join(dataDir, '$name${PlatformInfo.exeExt}');
  }

  static Future<String> getBinaryPathForWrite(String name) async {
    final dataDir = await DataDirResolver.getDataDir();
    if (name == 'tor') {
      return p.join(dataDir, 'tor', 'tor${PlatformInfo.exeExt}');
    }
    return p.join(dataDir, '$name${PlatformInfo.exeExt}');
  }

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

  static Future<String> getSstpBinaryPath() async {
    final dataDir = await DataDirResolver.getDataDir();
    final exeName = 'sstp-proxy${PlatformInfo.exeExt}';
    return p.join(dataDir, exeName);
  }

  static Future<String> getSstpBinaryPathForExecution() async {
    final found = await resolveBinaryPath('sstp-proxy');
    if (found != null) return found;
    return getSstpBinaryPath();
  }
}
