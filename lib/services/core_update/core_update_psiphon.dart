// lib/services/core_update/core_update_psiphon.dart
library;

import 'dart:io';
import 'package:path/path.dart' as p;
import '../app_data_service.dart';
import '../core_update_models.dart';
import '../core_update_utils.dart';
import 'core_update_network.dart';
import 'core_update_pending.dart';
import 'core_update_process_utils.dart';
import 'psiphon_binaries_head.dart';

class PsiphonUpdater {
  final CoreUpdateNetwork network;
  final CoreUpdatePendingManager pending;
  final CoreUpdateProcessUtils processUtils;
  final void Function(String)? log;

  late final PsiphonBinariesHead _binariesHead = PsiphonBinariesHead(
    network: network,
    log: log,
  );

  PsiphonUpdater({
    required this.network,
    required this.pending,
    required this.processUtils,
    this.log,
  });

  void _log(String m) => log?.call(m);
  bool get _isWin => AppDataService.isWindows;
  String get _exeExt => AppDataService.exeExt;

  Future<CoreUpdateInfo> check(
    String? proxy, {
    required String installed,
    required String psiphonBinSha,
  }) async {
    try {
      network.logRoute(proxy);
      final exe = await AppDataService.getBinaryPath('psiphon-tunnel-core');
      final missing = !await File(exe).exists();
      final remote = await _binariesHead.fetch(proxy);
      if (remote.sha.isEmpty) {
        throw StateError('Binaries repo unreachable (empty tree).');
      }
      final stored = psiphonBinSha.trim();
      var hasUpdate = missing;
      var note = '';
      if (!missing) {
        if (stored.isNotEmpty) {
          hasUpdate = stored != remote.sha;
          note = hasUpdate
              ? 'Upstream republished the official binary.'
              : 'Matches the published official binary.';
        } else {
          final localSize = await CoreUpdateUtils.fileSize(exe);
          hasUpdate = remote.size > 0 ? localSize != remote.size : true;
          note = hasUpdate
              ? 'Local binary differs from the published one.'
              : 'Local binary matches the published one by size.';
        }
      }
      final short =
          remote.sha.length > 7 ? remote.sha.substring(0, 7) : remote.sha;
      return CoreUpdateInfo(
        coreId: 'psiphon',
        displayName: 'Psiphon (official core)',
        installedVersion: installed,
        latestVersion: 'published $short',
        hasUpdate: hasUpdate,
        downloadUrl: remote.url,
        releaseNotes: note.isEmpty ? 'Official binary.' : note,
        downloadSizeBytes: remote.size,
        latestCommit: remote.sha,
      );
    } catch (e) {
      _log('✗ Psiphon update check failed: $e');
      rethrow;
    }
  }

  Future<bool> update(
    CoreUpdateInfo info, {
    required String installed,
    String? proxy,
    required String psiphonBinSha,
    void Function(int percent)? onProgress,
    bool Function()? onCancelCheck,
  }) async {
    if (info.downloadUrl.isEmpty) {
      throw StateError('Could not determine Psiphon download URL.');
    }
    if (!CoreUpdateUtils.isMissingVersion(installed) && !info.hasUpdate) {
      _log('★ Psiphon core is already up to date ($installed) — skipped');
      return false;
    }
    network.logRoute(proxy);
    _log('→ Downloading official psiphon-tunnel-core …');
    final tmp = await Directory.systemTemp.createTemp('mischiefpingu_psi_');
    try {
      final incoming = '${tmp.path}/psiphon-tunnel-core-new$_exeExt';
      await network.download(
        info.downloadUrl,
        incoming,
        proxy: proxy,
        onProgress: onProgress,
        onCancelCheck: onCancelCheck,
        totalHint:
            info.downloadSizeBytes > 0 ? info.downloadSizeBytes : 10435684,
      );
      onProgress?.call(85);

      var newSize = await CoreUpdateUtils.fileSize(incoming);
      if (info.downloadSizeBytes > 0 && newSize != info.downloadSizeBytes) {
        throw StateError(
          'Size mismatch: got ${CoreUpdateUtils.formatBytes(newSize)}, '
          'expected ${CoreUpdateUtils.formatBytes(info.downloadSizeBytes)}. Aborted.',
        );
      }
      if (newSize == 0) throw StateError('Downloaded file is empty.');

      final dest = await AppDataService.getBinaryPath('psiphon-tunnel-core');
      final binName = p.basename(dest);
      final isRunning = await processUtils.isProcessRunning(binName);

      if (isRunning) {
        final stagingDir = await Directory.systemTemp
            .createTemp('mischiefpingu_deferred_psi_');
        final stagingPath = '${stagingDir.path}/$binName';
        await File(incoming).copy(stagingPath);
        if (!_isWin) {
          await Process.run('chmod', ['+x', stagingPath]);
        }
        await pending.add(PendingCoreUpdate(
          coreId: 'psiphon',
          stagingPath: stagingPath,
          destPath: dest,
          version: info.latestVersion,
          createdAt: DateTime.now(),
        ));
        onProgress?.call(100);
        _log(
          '★ Official Psiphon core update downloaded (${info.latestVersion}) '
          '— deferred, will apply on next startup',
        );
        return true;
      }

      await processUtils.stopProcess(binName, 'Psiphon core');
      final oldSize = await CoreUpdateUtils.fileSize(dest);
      newSize = await processUtils.replaceBinary(incoming, dest);
      if (newSize == 0) throw StateError('Replacement failed (0 bytes).');
      await processUtils.updateExecutableDirBinary('psiphon', incoming);
      onProgress?.call(100);
      _log(
        '★ Official Psiphon core synced (${info.latestVersion}) '
        '(${CoreUpdateUtils.formatBytes(oldSize)} → '
        '${CoreUpdateUtils.formatBytes(newSize)}).',
      );
      return true;
    } finally {
      try {
        await tmp.delete(recursive: true);
      } catch (_) {}
    }
  }
}
