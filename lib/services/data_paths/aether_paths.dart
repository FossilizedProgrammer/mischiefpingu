library;

import 'dart:io';

import 'package:path/path.dart' as p;

import 'data_dir_resolver.dart';

class AetherPathsService {
  AetherPathsService._();

  static Future<List<String>> aetherPtCandidates() async {
    final dataDir = await DataDirResolver.getDataDir();
    final exeDir = DataDirResolver.getExeDir();
    final platformDir = DataDirResolver.getPlatformDir();

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
