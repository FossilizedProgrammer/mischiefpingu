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
        '★ ${spec.displayName} is already up to date ($installed) — skipped',
      );
      return false;
    }

    _log(
      '→ Downloading ${spec.displayName} ${info.latestVersion} from '
      '${info.downloadUrl.split('/').last} …',
    );
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

      final extractDir = Directory('${tmp.path}/extract');
      await extractDir.create(recursive: true);

      if (cls.isArchive) {
        await _extractor.extract(
          archive: archive,
          extractDir: extractDir,
          isZip: cls.isZip,
          isTarXz: cls.isTarXz,
        );
        await _extractor.logExtractedFiles(extractDir);
      }

      // وقتی asset باینری خام است (بدون آرشیو)، خودِ فایل دانلودشده باینری است.
      final String? mainRawPath = cls.isArchive ? null : archive;

      var updatedAny = false;

      // ─── باینری اصلی ───
      updatedAny |= await _installOne(
        extractDir: extractDir,
        baseName: spec.binaryBaseName,
        fallbackPattern: spec.fallbackPattern,
        coreId: spec.coreId,
        displayName: spec.displayName,
        dest: await spec.destPathResolver(),
        rawFilePath: mainRawPath,
        version: info.latestVersion,
        skeleton: tmp.path,
      );

      // ─── باینری‌های اضافی که در همان آرشیو هستند (مثل lantern-radiance) ───
      for (final extra in spec.extraBinaries) {
        try {
          updatedAny |= await _installOne(
            extractDir: extractDir,
            baseName: extra.baseName,
            fallbackPattern: extra.fallbackPattern,
            coreId: extra.coreId,
            displayName: '${spec.displayName} / ${extra.baseName}',
            dest: await AppDataService.getBinaryPathForWrite(extra.baseName),
            rawFilePath: null,
            version: info.latestVersion,
            skeleton: tmp.path,
          );
        } catch (e) {
          _log(
            '⚠ ${spec.displayName}: extra binary ${extra.baseName} '
            'not installed: $e',
          );
        }
      }

      onProgress?.call(100);
      if (!updatedAny) {
        _log('★ ${spec.displayName}: all targets were running — deferred');
      }
      return true;
    } finally {
      try {
        await tmp.delete(recursive: true);
      } catch (_) {}
    }
  }

  /// یک باینری را از [extractDir] پیدا، در صورت نیاز rename و در [dest] نصب می‌کند.
  ///
  /// اگر پروسه‌اش در حال اجرا باشد، آپدیت را معلق (defer) می‌کند.
  /// خروجی: true اگر چیزی تغییر کرد (نصب یا معلق‌سازی).
  Future<bool> _installOne({
    required Directory extractDir,
    required String baseName,
    required String fallbackPattern,
    required String coreId,
    required String displayName,
    required String dest,
    required String? rawFilePath,
    required String version,
    required String skeleton,
  }) async {
    _log('→ $displayName destination: $dest');

    final targetBinaryName = '$baseName$_exeExt';

    var found = await _extractor.findBinary(
      extractDir: extractDir,
      binaryBaseName: baseName,
      fallbackPattern: fallbackPattern,
      targetBinaryBaseName: baseName,
      rawFilePath: rawFilePath,
    );

    // ─── اطمینان از نام نهایی برای raw binary ها ───
    if (rawFilePath != null && rawFilePath.isNotEmpty) {
      final currentName = found.split(Platform.pathSeparator).last;
      if (currentName != targetBinaryName) {
        final newPath =
            '${File(found).parent.path}${Platform.pathSeparator}$targetBinaryName';
        _log('→ Renaming raw binary: $currentName → $targetBinaryName');
        await File(found).rename(newPath);
        found = newPath;
      }
    }

    found = await _extractor.safeCopyBinary(source: found, tmpPath: skeleton);

    if (!await CoreUpdateUtils.isRealFile(found)) {
      throw StateError('Safe copy verification failed: $found');
    }

    final isRunning = await processUtils.isProcessRunning(targetBinaryName);
    if (isRunning) {
      await _deferred.defer(
        found: found,
        dest: dest,
        binaryName: targetBinaryName,
        version: version,
        coreId: coreId,
        displayName: displayName,
      );
      return true;
    }

    final oldSize = await CoreUpdateUtils.fileSize(dest);
    final newSize = await processUtils.replaceBinary(found, dest);
    if (newSize == 0) throw StateError('Replacement failed (0 bytes).');

    await _deferred.verify(dest);
    await processUtils.updateExecutableDirBinary(coreId, found);

    _log(
      '★ $displayName updated: $version '
      '(${CoreUpdateUtils.formatBytes(oldSize)} → '
      '${CoreUpdateUtils.formatBytes(newSize)}) → $dest',
    );
    return true;
  }
}
