library;

import 'dart:io';

import 'package:path/path.dart' as p;

import 'core_update_process_utils.dart';

class CoreUpdateProcessUtilsPt {
  final CoreUpdateProcessUtils utils;

  CoreUpdateProcessUtilsPt(this.utils);

  Future<void> installAetherPtDirectory({
    required String dataDir,
    String? stagingSource,
    String? fallbackSource,
  }) async {
    final destPt = p.join(dataDir, 'pt');

    String? srcPt;

    if (stagingSource != null) {
      final candidate = p.join(stagingSource, 'pt');
      if (await Directory(candidate).exists()) {
        srcPt = candidate;
      }
    }

    if (srcPt == null && fallbackSource != null) {
      final candidate = p.join(fallbackSource, 'pt');
      if (await Directory(candidate).exists()) {
        srcPt = candidate;
      }
    }

    if (srcPt == null) {
      return;
    }

    final destPtDir = Directory(destPt);
    if (await destPtDir.exists()) {
      try {
        await destPtDir.delete(recursive: true);
      } catch (_) {}
    }

    await utils.copyDirectoryTree(src: srcPt, dest: destPt);
  }
}
