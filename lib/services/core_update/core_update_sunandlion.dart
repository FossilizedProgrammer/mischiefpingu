// lib/services/core_update/core_update_sunandlion.dart
library;

import 'dart:io';
import '../app_data_service.dart';
import '../core_update_models.dart';
import '../core_update_utils.dart';
import 'core_update_network.dart';
import 'core_update_pending.dart';
import 'core_update_process_utils.dart';
import 'shared/archive_extractor.dart';
import 'shared/asset_picker.dart';

/// ═══════════════════════════════════════════════════════════════
///  SunAndLion Psiphon Core Updater
///  مخزن: https://github.com/FossilizedProgrammer/sunandlion
/// ═══════════════════════════════════════════════════════════════
class SunAndLionUpdater {
  static const String _owner = 'FossilizedProgrammer';
  static const String _repo = 'sunandlion';
  static const String _binaryBaseName = 'psiphon-tunnel-core-sunandlion';

  final CoreUpdateNetwork network;
  final CoreUpdatePendingManager pending;
  final CoreUpdateProcessUtils processUtils;
  final void Function(String)? log;

  late final ArchiveExtractor _extractor = ArchiveExtractor(
    processUtils: processUtils,
    log: log,
  );

  SunAndLionUpdater({
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
        'https://api.github.com/repos/$_owner/$_repo/releases/latest',
        proxy,
      );

      final tag = (rel['tag_name'] as String? ?? '').trim();
      final latest = tag.replaceAll(RegExp(r'^[vV]'), '').trim();
      final notes = (rel['body'] as String? ?? '').trim();
      final assets = (rel['assets'] as List?) ?? [];

      _log('→ SunAndLion release $tag has ${assets.length} asset(s):');
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
        _log('→ SunAndLion asset chosen: ${asset['name']} ($size bytes)');
      } else {
        _log('⚠ No matching SunAndLion asset found for arch=$arch '
            '(${_isWin ? 'windows' : 'linux'})');
      }

      return CoreUpdateInfo(
        coreId: 'sunandlion',
        displayName: 'SunAndLion Psiphon Core',
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
      _log('✗ SunAndLion update check failed: $e');
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
      throw StateError('Could not find SunAndLion download URL.');
    }
    if (!CoreUpdateUtils.isMissingVersion(installed) && !info.hasUpdate) {
      _log('★ SunAndLion core is already up to date ($installed) — skipped');
      return false;
    }

    _log('→ Downloading SunAndLion ${info.latestVersion} from '
        '${info.downloadUrl.split('/').last} …');
    final tmp = await Directory.systemTemp.createTemp('mischiefpingu_sunlion_');
    try {
      final cls = _extractor.classifyArchive(info.downloadUrl, 'sunlion');
      final archive = '${tmp.path}/${cls.archiveName}';

      await network.download(
        info.downloadUrl,
        archive,
        proxy: proxy,
        onProgress: onProgress,
        onCancelCheck: onCancelCheck,
        totalHint: info.downloadSizeBytes > 0
            ? info.downloadSizeBytes
            : 12000000,
      );
      onProgress?.call(80);

      final binaryName = '$_binaryBaseName$_exeExt';
      final dest = await AppDataService.getBinaryPath(_binaryBaseName);

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
          binaryBaseName: _binaryBaseName,
          fallbackPattern: 'sunandlion',
        );
        _log('→ Chosen binary: $found');
      } else {
        found = archive;
        _log('→ Raw binary (not archive): $archive');
      }

      if (!await CoreUpdateUtils.isRealFile(found)) {
        throw StateError('Source file does not exist or is invalid: $found');
      }
      final foundSize = await CoreUpdateUtils.fileSize(found);
      _log('→ Source file size: $foundSize bytes ($found)');

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

      await processUtils.updateExecutableDirBinary('sunandlion', found);
      onProgress?.call(100);
      _log(
          '★ SunAndLion updated: $installed → ${info.latestVersion} '
          '(${CoreUpdateUtils.formatBytes(oldSize)} → '
          '${CoreUpdateUtils.formatBytes(newSize)})');
      _log('★ SunAndLion binary saved at: $dest');
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
        .createTemp('mischiefpingu_deferred_sunlion_');
    final stagingPath = '${stagingDir.path}/$binaryName';
    await File(found).copy(stagingPath);
    if (!_isWin) {
      await Process.run('chmod', ['+x', stagingPath]);
    }
    await pending.add(PendingCoreUpdate(
      coreId: 'sunandlion',
      stagingPath: stagingPath,
      destPath: dest,
      version: version,
      createdAt: DateTime.now(),
    ));
    _log(
        '★ SunAndLion update downloaded ($version) — deferred, will apply on next startup');
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
