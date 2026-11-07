library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../../app_data_service.dart';
import '../../core_update_models.dart';
import '../../core_update_utils.dart';
import '../aether_asset_resolver.dart';
import '../core_update_network.dart';
import '../core_update_pending.dart';
import '../core_update_process_utils.dart';

class AetherInstaller {
  final CoreUpdateNetwork network;
  final CoreUpdatePendingManager pending;
  final CoreUpdateProcessUtils processUtils;
  final void Function(String)? log;

  AetherInstaller({
    required this.network,
    required this.pending,
    required this.processUtils,
    this.log,
  });

  void _log(String m) => log?.call(m);

  Future<bool> update(
    CoreUpdateInfo info, {
    required String installed,
    String? proxy,
    void Function(int percent)? onProgress,
    bool Function()? onCancelCheck,
  }) async {
    if (info.downloadUrl.isEmpty) {
      throw StateError('Could not find Aether download URL.');
    }
    if (!CoreUpdateUtils.isMissingVersion(installed) && !info.hasUpdate) {
      _log('★ Aether is already up to date ($installed) — download skipped');
      return false;
    }
    _log('→ Downloading Aether ${info.latestVersion} …');
    final tmp = await Directory.systemTemp.createTemp('mischiefpingu_aether_');
    try {
      final isZip = info.downloadUrl.toLowerCase().endsWith('.zip');
      final archiveName = isZip ? 'aether.zip' : 'aether.tar.gz';
      final archive = '${tmp.path}/$archiveName';
      await network.download(
        info.downloadUrl,
        archive,
        proxy: proxy,
        onProgress: onProgress,
        onCancelCheck: onCancelCheck,
        totalHint:
            info.downloadSizeBytes > 0 ? info.downloadSizeBytes : 4500000,
      );
      onProgress?.call(80);
      await processUtils.extractArchive(archive, tmp.path);
      final searchName = 'aether${AppDataService.exeExt}';
      final found = await CoreUpdateUtils.findFile(tmp, searchName);
      if (found == null) {
        throw StateError('`$searchName` binary not found inside the archive.');
      }
      onProgress?.call(90);

      final dest = await AppDataService.getBinaryPathForWrite('aether');
      final binName = p.basename(dest);
      final isRunning = await processUtils.isProcessRunning(binName);

      if (isRunning) {
        final stagingDir = await Directory.systemTemp.createTemp(
          'mischiefpingu_deferred_aether_',
        );
        final stagingPath = '${stagingDir.path}/$binName';
        await File(found).copy(stagingPath);
        if (!AppDataService.isWindows) {
          await Process.run('chmod', ['+x', stagingPath]);
        }

        final srcPt = Directory(p.join(tmp.path, 'pt'));
        if (await srcPt.exists()) {
          final destPtPath = p.join(stagingDir.path, 'pt');
          _log(
            '→ Staging Aether `pt` directory for deferred update: '
            '${srcPt.path} → $destPtPath',
          );
          final count = await processUtils.copyDirectoryTree(
            src: srcPt.path,
            dest: destPtPath,
          );
          _log('→ Staged $count file(s) of `pt` in deferred staging dir');
        } else {
          _log(
            '⚠ No `pt` directory found in downloaded archive — '
            'only binary will be applied on next startup',
          );
        }

        await pending.add(
          PendingCoreUpdate(
            coreId: 'aether',
            stagingPath: stagingPath,
            destPath: dest,
            version: info.latestVersion,
            createdAt: DateTime.now(),
          ),
        );
        onProgress?.call(100);
        _log(
          '★ Aether update downloaded (${info.latestVersion}) — deferred, will apply on next startup',
        );
        return true;
      }

      final oldSize = await CoreUpdateUtils.fileSize(dest);
      final newSize = await processUtils.replaceBinary(found, dest);
      if (newSize == 0) throw StateError('Replacement failed (0 bytes).');
      await processUtils.updateExecutableDirBinary('aether', found);

      final dataDir = await AppDataService.getDataDir();
      final exeDir = p.dirname(Platform.resolvedExecutable);
      final platformDir = p.join(exeDir, AppDataService.osFolder);
      await processUtils.installAetherPtDirectory(
        dataDir: dataDir,
        stagingSource: tmp.path,
        fallbackSource: platformDir,
      );

      final newVer = CoreUpdateUtils.parseAetherVersion(
            await AetherAssetResolver.queryVersion(dest),
          ) ??
          info.latestVersion;
      onProgress?.call(100);
      _log(
        '★ Aether updated: $installed → $newVer (${CoreUpdateUtils.formatBytes(oldSize)} → ${CoreUpdateUtils.formatBytes(newSize)})',
      );
      return true;
    } finally {
      try {
        await tmp.delete(recursive: true);
      } catch (_) {}
    }
  }
}
