library;

import 'dart:io';
import 'package:path/path.dart' as p;

import '../../app_data_service.dart';
import '../../core_update_models.dart';
import '../../tor/tor_bundle_installer.dart';
import '../core_update_process_utils.dart';

/// اعمال آپدیت معلق Tor (نصب bundle از staging).
class TorBundleDeferredApplier {
  final CoreUpdateProcessUtils processUtils;
  final void Function(String)? log;

  TorBundleDeferredApplier({
    required this.processUtils,
    this.log,
  });

  void _log(String m) => log?.call(m);

  bool get _isWin => AppDataService.isWindows;

  Future<void> apply(PendingCoreUpdate update) async {
    final torDir = await AppDataService.ensureTorDir();
    final stagingDir = p.dirname(update.stagingPath);
    final stagingType =
        await FileSystemEntity.type(stagingDir, followLinks: false);

    String? bundleRoot;
    if (stagingType == FileSystemEntityType.directory) {
      if (await TorBundleInstaller.looksLikeBundle(stagingDir)) {
        bundleRoot = stagingDir;
      }
      if (bundleRoot == null) {
        final parent = p.dirname(stagingDir);
        final cand = p.join(parent, 'bundle');
        if (await Directory(cand).exists() &&
            await TorBundleInstaller.looksLikeBundle(cand)) {
          bundleRoot = cand;
        }
      }
      if (bundleRoot != null) {
        await TorBundleInstaller.installTree(
          srcRoot: bundleRoot,
          torDir: torDir,
          log: _log,
        );
        _log('→ Updated tor bundle tree (deferred) → $torDir');
        await AppDataService.fixDataDirOwnership();
        return;
      }
    }

    final searchName = 'tor${AppDataService.exeExt}';
    final dest = p.join(torDir, searchName);
    await processUtils.replaceBinary(update.stagingPath, dest);

    for (final extra in ['geoip', 'geoip6', 'lyrebird', 'conjure-client']) {
      final extraName = '$extra${AppDataService.exeExt}';
      final extraStaging = File(p.join(stagingDir, extraName));
      if (await extraStaging.exists()) {
        final extraDest = p.join(torDir, extraName);
        await extraStaging.copy(extraDest);
        if (!_isWin) {
          try {
            await Process.run('chmod', ['+x', extraDest]);
          } catch (_) {}
        }
        _log('→ Updated $extra (deferred)');
      }
    }
    await AppDataService.fixDataDirOwnership();
  }
}
