library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../platform_info.dart';
import '../tor_dir_manager.dart';
import 'data_dir_resolver.dart';

class TorPathsService {
  TorPathsService._();

  static void _log(String msg) {
    // ignore: avoid_print
    print(msg);
  }

  static Future<List<String>> torBinaryCandidates() async {
    final dataDir = await DataDirResolver.getDataDir();
    final exeDir = DataDirResolver.getExeDir();
    final platformDir = DataDirResolver.getPlatformDir();
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
    final dataDir = await DataDirResolver.getDataDir();
    return p.join(dataDir, 'tor');
  }

  static Future<String> getTorBinaryPath() async {
    final dataDir = await DataDirResolver.getDataDir();
    return p.join(dataDir, 'tor', 'tor${PlatformInfo.exeExt}');
  }

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
    final dataDir = await DataDirResolver.getDataDir();
    final platformDir = DataDirResolver.getPlatformDir();
    return TorDirManager.ensureTorDir(
      dataDir: dataDir,
      platformDir: platformDir,
    );
  }
}
