library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../../app_data_service.dart';
import '../../core_update_models.dart';
import '../core_update_process_utils.dart';

/// اعمال آپدیت معلق Aether (کپی باینری + پوشهٔ `pt`).
class AetherPtDeferredApplier {
  final CoreUpdateProcessUtils processUtils;
  final void Function(String)? log;

  AetherPtDeferredApplier({required this.processUtils, this.log});

  void _log(String m) => log?.call(m);

  Future<void> apply(PendingCoreUpdate update) async {
    await processUtils.replaceBinary(update.stagingPath, update.destPath);

    final dataDir = await AppDataService.getDataDir();
    final stagingDir = p.dirname(update.stagingPath);
    final stagingPt = Directory(p.join(stagingDir, 'pt'));

    if (await stagingPt.exists()) {
      _log('→ Applying deferred Aether `pt` directory from $stagingDir');

      final destPtPath = p.join(dataDir, 'pt');
      final destPt = Directory(destPtPath);

      if (await destPt.exists()) {
        try {
          await destPt.delete(recursive: true);
          _log('→ Removed old `pt` directory before deferred update');
        } catch (e) {
          _log('⚠ Could not remove old `pt`: $e — will overwrite in place');
        }
      }

      final count = await processUtils.copyDirectoryTree(
        src: stagingPt.path,
        dest: destPtPath,
      );
      _log(
        '★ Aether `pt` directory updated (deferred) — '
        '$count file(s) copied',
      );
    } else {
      _log('→ No `pt` directory in Aether staging dir — skipped');
    }

    await AppDataService.fixDataDirOwnership();
  }
}
