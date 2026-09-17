// lib/services/core_update/core_update_aether.dart
library;

import 'dart:io';
import 'package:path/path.dart' as p;
import '../app_data_service.dart';
import '../core_update_models.dart';
import '../core_update_utils.dart';
import 'aether_asset_resolver.dart';
import 'core_update_network.dart';
import 'core_update_pending.dart';
import 'core_update_process_utils.dart';

class AetherUpdater {
  final CoreUpdateNetwork network;
  final CoreUpdatePendingManager pending;
  final CoreUpdateProcessUtils processUtils;
  final void Function(String)? log;

  AetherUpdater({
    required this.network,
    required this.pending,
    required this.processUtils,
    this.log,
  });

  void _log(String m) => log?.call(m);

  Future<CoreUpdateInfo> check(String? proxy,
      {required String installed}) async {
    try {
      network.logRoute(proxy);
      final rel = await network.getJson(
          'https://api.github.com/repos/CluvexStudio/Aether/releases/latest',
          proxy);
      final tag = (rel['tag_name'] as String? ?? '').trim();
      final latest = tag.replaceAll(RegExp(r'^[vV]'), '').trim();
      final notes = (rel['body'] as String? ?? '').trim();
      String url = '';
      var size = 0;
      final arch = await network.detectArch();
      final fallbacks = AetherAssetResolver.assetNames(arch);
      final assets = (rel['assets'] as List?) ?? [];
      for (final fb in fallbacks) {
        for (final a in assets) {
          final m = a as Map<String, dynamic>;
          if ((m['name'] as String? ?? '') == fb) {
            url = (m['browser_download_url'] as String? ?? '');
            size = (m['size'] as num? ?? 0).toInt();
            break;
          }
        }
        if (url.isNotEmpty) break;
      }
      url = url.isNotEmpty
          ? url
          : 'https://github.com/CluvexStudio/Aether/releases/download/$tag/${fallbacks.first}';
      return CoreUpdateInfo(
        coreId: 'aether',
        displayName: 'Aether (WARP / MASQUE)',
        installedVersion: installed,
        latestVersion: latest.isEmpty ? installed : latest,
        hasUpdate: latest.isNotEmpty &&
            (CoreUpdateUtils.isMissingVersion(installed) ||
                CoreUpdateUtils.isNewerVersion(installed, latest)),
        downloadUrl: url,
        releaseNotes: notes,
        downloadSizeBytes: size,
      );
    } catch (e) {
      _log('✗ Aether update check failed: $e');
      rethrow;
    }
  }

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
      await network.download(info.downloadUrl, archive,
          proxy: proxy,
          onProgress: onProgress,
          onCancelCheck: onCancelCheck,
          totalHint:
              info.downloadSizeBytes > 0 ? info.downloadSizeBytes : 4500000);
      onProgress?.call(80);
      await processUtils.extractArchive(archive, tmp.path);
      final searchName = 'aether${AppDataService.exeExt}';
      final found = await CoreUpdateUtils.findFile(tmp, searchName);
      if (found == null) {
        throw StateError('`$searchName` binary not found inside the archive.');
      }
      onProgress?.call(90);
      final dest = await AppDataService.getBinaryPath('aether');
      final binName = p.basename(dest);
      final isRunning = await processUtils.isProcessRunning(binName);
      if (isRunning) {
        final stagingDir = await Directory.systemTemp
            .createTemp('mischiefpingu_deferred_aether_');
        final stagingPath = '${stagingDir.path}/$binName';
        await File(found).copy(stagingPath);
        if (!AppDataService.isWindows) {
          await Process.run('chmod', ['+x', stagingPath]);
        }
        await pending.add(PendingCoreUpdate(
          coreId: 'aether',
          stagingPath: stagingPath,
          destPath: dest,
          version: info.latestVersion,
          createdAt: DateTime.now(),
        ));
        onProgress?.call(100);
        _log(
            '★ Aether update downloaded (${info.latestVersion}) — deferred, will apply on next startup');
        return true;
      }
      final oldSize = await CoreUpdateUtils.fileSize(dest);
      final newSize = await processUtils.replaceBinary(found, dest);
      if (newSize == 0) throw StateError('Replacement failed (0 bytes).');
      await processUtils.updateExecutableDirBinary('aether', found);
      final newVer = CoreUpdateUtils.parseAetherVersion(
              await AetherAssetResolver.queryVersion(dest)) ??
          info.latestVersion;
      onProgress?.call(100);
      _log(
          '★ Aether updated: $installed → $newVer (${CoreUpdateUtils.formatBytes(oldSize)} → ${CoreUpdateUtils.formatBytes(newSize)})');
      return true;
    } finally {
      try {
        await tmp.delete(recursive: true);
      } catch (_) {}
    }
  }
}
