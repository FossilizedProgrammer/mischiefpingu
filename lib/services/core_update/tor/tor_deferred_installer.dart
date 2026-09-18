library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core_update_models.dart';
import '../core_update_pending.dart';
import '../../tor/tor_bundle_installer.dart';

class TorDeferredInstaller {
  final CoreUpdatePendingManager pending;
  final void Function(String)? log;

  TorDeferredInstaller({required this.pending, this.log});

  void _log(String m) => log?.call(m);

  Future<void> defer({
    required String srcRoot,
    required String torBin,
    required String dest,
    void Function(int percent)? onProgress,
  }) async {
    final stagingDir = await Directory.systemTemp.createTemp(
      'mischiefpingu_deferred_tor_',
    );
    final stagingRoot = Directory(p.join(stagingDir.path, 'bundle'));
    await stagingRoot.create(recursive: true);
    await TorBundleInstaller.installTree(
      srcRoot: srcRoot,
      torDir: stagingRoot.path,
      log: _log,
    );
    final stagingPath = p.join(
      stagingRoot.path,
      p.relative(torBin, from: srcRoot),
    );
    await pending.add(
      PendingCoreUpdate(
        coreId: 'tor',
        stagingPath: stagingPath,
        destPath: dest,
        version: 'bundle',
        createdAt: DateTime.now(),
      ),
    );
    onProgress?.call(100);
    _log('★ Tor update downloaded — deferred, will apply on next startup');
  }
}
