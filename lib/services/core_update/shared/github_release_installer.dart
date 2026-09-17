// lib/services/core_update/shared/github_release_installer.dart
//
// ═══════════════════════════════════════════════════════════════
//  GithubReleaseInstaller — منطق update برای GitHub Releases
//  (دانلود، استخراج، safe copy، نصب)
//  منطق defer/verify به GithubReleaseDeferred منتقل شده.
// ═══════════════════════════════════════════════════════════════
library;

import 'dart:io';

import '../../app_data_service.dart';
import '../../core_update_models.dart';
import '../../core_update_utils.dart';
import '../core_update_network.dart';
import '../core_update_pending.dart';
import '../core_update_process_utils.dart';
import 'archive_extractor.dart';
import 'github_core_spec.dart';
import 'github_release_deferred.dart';

class GithubReleaseInstaller {
  final GithubCoreSpec spec;
  final CoreUpdateNetwork network;
  final CoreUpdatePendingManager pending;
  final CoreUpdateProcessUtils processUtils;
  final void Function(String)? log;

  late final ArchiveExtractor _extractor = ArchiveExtractor(
    processUtils: processUtils,
    log: log,
  );

  late final GithubReleaseDeferred _deferred = GithubReleaseDeferred(
    spec: spec,
    pending: pending,
    log: log,
  );

  GithubReleaseInstaller({
    required this.spec,
    required this.network,
    required this.pending,
    required this.processUtils,
    this.log,
  });

  void _log(String m) => log?.call(m);
  String get _exeExt => AppDataService.exeExt;

  Future<bool> update(
    CoreUpdateInfo info, {
    required String installed,
    String? proxy,
    void Function(int percent)? onProgress,
    bool Function()? onCancelCheck,
  }) async {
    if (info.downloadUrl.isEmpty) {
      throw StateError('Could not find ${spec.displayName} download URL.');
    }
    if (!CoreUpdateUtils.isMissingVersion(installed) && !info.hasUpdate) {
      _log(
          '★ ${spec.displayName} is already up to date ($installed) — skipped');
      return false;
    }

    _log('→ Downloading ${spec.displayName} ${info.latestVersion} from '
        '${info.downloadUrl.split('/').last} …');
    final tmp = await Directory.systemTemp.createTemp(spec.tempPrefix);
    try {
      final cls = _extractor.classifyArchive(info.downloadUrl, spec.coreId);
      final archive = '${tmp.path}/${cls.archiveName}';

      await network.download(
        info.downloadUrl,
        archive,
        proxy: proxy,
        onProgress: onProgress,
        onCancelCheck: onCancelCheck,
        totalHint: info.downloadSizeBytes > 0
            ? info.downloadSizeBytes
            : spec.defaultDownloadSize,
      );
      onProgress?.call(80);

      final binaryName = '${spec.binaryBaseName}$_exeExt';
      final dest = await spec.destPathResolver();
      _log('→ ${spec.displayName} destination: $dest');

      final extractDir = Directory('${tmp.path}/extract');
      await extractDir.create(recursive: true);

      String found;
      if (cls.isArchive) {
        await _extractor.extract(
          archive: archive,
          extractDir: extractDir,
          isZip: cls.isZip,
          isTarXz: cls.isTarXz,
        );
        await _extractor.logExtractedFiles(extractDir);
        found = await _extractor.findBinary(
          extractDir: extractDir,
          binaryBaseName: spec.binaryBaseName,
          fallbackPattern: spec.fallbackPattern,
        );
      } else {
        found = archive;
        _log('→ Raw binary (not archive): $archive');
      }

      found = await _extractor.safeCopyBinary(
        source: found,
        tmpPath: tmp.path,
      );

      if (!await CoreUpdateUtils.isRealFile(found)) {
        throw StateError('Safe copy verification failed: $found');
      }
      final foundSize = await CoreUpdateUtils.fileSize(found);
      _log('→ Source file ready: $found ($foundSize bytes)');

      onProgress?.call(90);

      final isRunning = await processUtils.isProcessRunning(binaryName);
      if (isRunning) {
        await _deferred.defer(
          found: found,
          dest: dest,
          binaryName: binaryName,
          version: info.latestVersion,
        );
        onProgress?.call(100);
        return true;
      }

      final oldSize = await CoreUpdateUtils.fileSize(dest);
      final newSize = await processUtils.replaceBinary(found, dest);
      if (newSize == 0) throw StateError('Replacement failed (0 bytes).');

      await _deferred.verify(dest);
      await processUtils.updateExecutableDirBinary(spec.coreId, found);

      onProgress?.call(100);
      _log('★ ${spec.displayName} updated: $installed → ${info.latestVersion} '
          '(${CoreUpdateUtils.formatBytes(oldSize)} → '
          '${CoreUpdateUtils.formatBytes(newSize)})');
      _log('★ ${spec.displayName} binary saved at: $dest');
      return true;
    } finally {
      try {
        await tmp.delete(recursive: true);
      } catch (_) {}
    }
  }
}
