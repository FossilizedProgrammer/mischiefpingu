// lib/services/core_update/shared/github_release_updater.dart
//
// ═══════════════════════════════════════════════════════════════
//  GitHubReleaseUpdater — منطق مشترک آپدیت از GitHub Releases
//
//  این کلاس تمام logic تکراری بین SstpProxyUpdater و
//  SunAndLionUpdater را یک‌جا جمع می‌کند:
//    • check: دریافت release + انتخاب asset بر اساس arch
//    • update: دانلود، استخراج، safe copy، نصب، defer اگر در حال اجرا
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
import 'asset_picker.dart';

/// تنظیمات یک core مبتنی بر GitHub Releases.
class GithubCoreSpec {
  /// شناسه core (برای لاگ و PendingCoreUpdate).
  final String coreId;

  /// نام نمایشی.
  final String displayName;

  /// مالک مخزن GitHub.
  final String owner;

  /// نام مخزن GitHub.
  final String repo;

  /// نام پایه باینری بدون پسوند (مثل `sstp-proxy`).
  final String binaryBaseName;

  /// الگوی fallback برای جستجوی باینری در آرشیو.
  final String fallbackPattern;

  /// مسیر ذخیره‌سازی نهایی (تابع async).
  final Future<String> Function() destPathResolver;

  /// پیشوند temp dir برای دانلود.
  final String tempPrefix;

  /// تخمین اندازه دانلود (بایت) اگر GitHub size نداشت.
  final int defaultDownloadSize;

  const GithubCoreSpec({
    required this.coreId,
    required this.displayName,
    required this.owner,
    required this.repo,
    required this.binaryBaseName,
    required this.fallbackPattern,
    required this.destPathResolver,
    required this.tempPrefix,
    required this.defaultDownloadSize,
  });
}

/// آپدیت‌کننده عمومی برای coreهای مبتنی بر GitHub Releases.
class GithubReleaseUpdater {
  final GithubCoreSpec spec;
  final CoreUpdateNetwork network;
  final CoreUpdatePendingManager pending;
  final CoreUpdateProcessUtils processUtils;
  final void Function(String)? log;

  late final ArchiveExtractor _extractor = ArchiveExtractor(
    processUtils: processUtils,
    log: log,
  );

  GithubReleaseUpdater({
    required this.spec,
    required this.network,
    required this.pending,
    required this.processUtils,
    this.log,
  });

  void _log(String m) => log?.call(m);
  bool get _isWin => AppDataService.isWindows;
  String get _exeExt => AppDataService.exeExt;

  // ═══════════════════════════════════════════
  //  CHECK
  // ═══════════════════════════════════════════
  Future<CoreUpdateInfo> check(String? proxy,
      {required String installed}) async {
    try {
      network.logRoute(proxy);
      final rel = await network.getJson(
        'https://api.github.com/repos/${spec.owner}/${spec.repo}/releases/latest',
        proxy,
      );

      final tag = (rel['tag_name'] as String? ?? '').trim();
      final latest = tag.replaceAll(RegExp(r'^[vV]'), '').trim();
      final notes = (rel['body'] as String? ?? '').trim();
      final assets = (rel['assets'] as List?) ?? [];

      _log('→ ${spec.displayName} release $tag has ${assets.length} asset(s):');
      for (final a in assets) {
        final m = a as Map<String, dynamic>;
        _log('   • ${m['name']} (${m['size']} bytes)');
      }

      String url = '';
      var size = 0;

      final arch = await network.detectArch();
      final asset = AssetPicker.pick(assets, arch);

      if (asset != null) {
        url = (asset['browser_download_url'] as String? ?? '');
        size = (asset['size'] as num? ?? 0).toInt();
        _log('→ ${spec.displayName} asset chosen: ${asset['name']} ($size bytes)');
      } else {
        _log('⚠ No matching ${spec.displayName} asset found for arch=$arch '
            '(${_isWin ? 'windows' : 'linux'})');
      }

      return CoreUpdateInfo(
        coreId: spec.coreId,
        displayName: spec.displayName,
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
      _log('✗ ${spec.displayName} update check failed: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════
  //  UPDATE
  // ═══════════════════════════════════════════
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
      _log('★ ${spec.displayName} is already up to date ($installed) — skipped');
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
        await _deferUpdate(
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

      await _verifyInstall(dest);
      await processUtils.updateExecutableDirBinary(spec.coreId, found);

      onProgress?.call(100);
      _log(
          '★ ${spec.displayName} updated: $installed → ${info.latestVersion} '
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

  Future<void> _deferUpdate({
    required String found,
    required String dest,
    required String binaryName,
    required String version,
  }) async {
    final stagingDir = await Directory.systemTemp
        .createTemp('${spec.tempPrefix}deferred_');
    final stagingPath = '${stagingDir.path}/$binaryName';
    await File(found).copy(stagingPath);
    if (!_isWin) {
      await Process.run('chmod', ['+x', stagingPath]);
    }
    await pending.add(PendingCoreUpdate(
      coreId: spec.coreId,
      stagingPath: stagingPath,
      destPath: dest,
      version: version,
      createdAt: DateTime.now(),
    ));
    _log(
        '★ ${spec.displayName} update downloaded ($version) — deferred, will apply on next startup');
  }

  Future<void> _verifyInstall(String dest) async {
    final exists = await File(dest).exists();
    final size = await CoreUpdateUtils.fileSize(dest);
    _log('→ VERIFY: file exists at $dest = $exists (size: $size bytes)');
    if (!exists || size == 0) {
      throw StateError(
          'Update reported success but file not found at $dest. '
          'Check dataDir permissions.');
    }
  }
}
