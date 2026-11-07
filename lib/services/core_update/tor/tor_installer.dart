library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../../app_data_service.dart';
import '../../core_update_utils.dart';
import '../core_update_network.dart';
import '../core_update_process_utils.dart';
import '../core_update_tor_version.dart';
import '../../tor/tor_bundle_installer.dart';
import 'tor_deferred_installer.dart';

class TorInstaller {
  final CoreUpdateNetwork network;
  final CoreUpdateProcessUtils processUtils;
  final TorDeferredInstaller deferred;
  final void Function(String)? log;

  TorInstaller({
    required this.network,
    required this.processUtils,
    required this.deferred,
    this.log,
  });

  void _log(String m) => log?.call(m);
  String get _exeExt => AppDataService.exeExt;

  Future<bool> install({
    required String installed,
    required String downloadUrl,
    String? proxy,
    void Function(int percent)? onProgress,
    bool Function()? onCancelCheck,
  }) async {
    _log('→ Downloading Tor bundle from: ${downloadUrl.split('/').last}');
    final tmp = await Directory.systemTemp.createTemp('mischiefpingu_tor_');
    try {
      final isZip = downloadUrl.toLowerCase().endsWith('.zip');
      final archiveName = isZip ? 'tor.zip' : 'tor.tar.gz';
      final archive = '${tmp.path}/$archiveName';
      await network.download(
        downloadUrl,
        archive,
        proxy: proxy,
        onProgress: onProgress,
        onCancelCheck: onCancelCheck,
      );
      onProgress?.call(80);
      final extractDir = Directory('${tmp.path}/extract');
      await extractDir.create(recursive: true);
      await processUtils.extractArchive(archive, extractDir.path);
      final searchName = 'tor$_exeExt';
      final torBin = await CoreUpdateUtils.findFile(extractDir, searchName);
      if (torBin == null) {
        throw StateError('`$searchName` binary not found inside the bundle.');
      }
      final srcRoot = TorBundleInstaller.bundleRoot(extractDir, torBin);
      onProgress?.call(90);
      final torDir = await AppDataService.ensureTorDir();
      final dest = p.join(torDir, searchName);
      final isRunning = await processUtils.isProcessRunning(searchName);
      if (isRunning) {
        await deferred.defer(
          srcRoot: srcRoot,
          torBin: torBin,
          dest: dest,
          onProgress: onProgress,
        );
        return true;
      }
      final oldSize = await CoreUpdateUtils.fileSize(dest);
      final count = await TorBundleInstaller.installTree(
        srcRoot: srcRoot,
        torDir: torDir,
        log: _log,
      );
      if (count == 0) {
        throw StateError('Tor bundle install failed (0 files copied).');
      }
      await processUtils.updateExecutableDirBinary('tor', torBin);
      await AppDataService.fixDataDirOwnership();
      var installedBin = dest;
      if (!await File(installedBin).exists()) {
        final found = await CoreUpdateUtils.findFile(
          Directory(torDir),
          searchName,
        );
        if (found != null) installedBin = found;
      }
      final newSize = await CoreUpdateUtils.fileSize(installedBin);
      if (newSize == 0) throw StateError('Replacement failed (0 bytes).');
      final newVer =
          await TorVersionQuery.queryAndParse(installedBin) ?? 'bundle';
      onProgress?.call(100);
      _log(
        '★ Tor installed: $installed → $newVer ($count files, ${CoreUpdateUtils.formatBytes(oldSize)} → ${CoreUpdateUtils.formatBytes(newSize)}) → $torDir',
      );
      return true;
    } finally {
      try {
        await tmp.delete(recursive: true);
      } catch (_) {}
    }
  }
}
