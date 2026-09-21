library;

import 'dart:io';

import '../../app_data_service.dart';
import '../../core_update_utils.dart';
import '../core_update_process_utils.dart';

class ArchiveExtractor {
  final CoreUpdateProcessUtils processUtils;
  final void Function(String)? log;

  ArchiveExtractor({required this.processUtils, this.log});

  void _log(String m) => log?.call(m);

  bool get _isWin => AppDataService.isWindows;
  String get _exeExt => AppDataService.exeExt;

  /// استخراج آرشیو (zip / tar.gz / tar.xz) به [extractDir].
  Future<void> extract({
    required String archive,
    required Directory extractDir,
    required bool isZip,
    required bool isTarXz,
  }) async {
    if (isZip) {
      await processUtils.extractArchive(archive, extractDir.path);
      return;
    }
    final tarFlag = isTarXz ? '-xJf' : '-xzf';
    final r = await Process.run('tar', [
      tarFlag,
      archive,
      '-C',
      extractDir.path,
    ]);
    if (r.exitCode != 0) {
      throw StateError('tar extract failed: ${r.stderr}');
    }
  }

  /// لاگ تمام فایل‌های استخراج‌شده (برای دیباگ).
  Future<void> logExtractedFiles(Directory extractDir) async {
    _log('→ Extracted files:');
    await for (final e in extractDir.list(
      recursive: true,
      followLinks: false,
    )) {
      if (e is File) {
        final size = await CoreUpdateUtils.fileSize(e.path);
        _log('   • ${e.path.replaceFirst(extractDir.path, '.')} ($size bytes)');
      }
    }
  }

  /// پیدا کردن باینری داخل آرشیو استخراج‌شده.
  /// [binaryBaseName] اسم بدون پسوند (مثل `sstp-proxy`).
  /// [fallbackPattern] الگوی جایگزین برای جستجو (مثل `sunandlion`).
  Future<String> findBinary({
    required Directory extractDir,
    required String binaryBaseName,
    required String fallbackPattern,
  }) async {
    final binaryName = '$binaryBaseName$_exeExt';

    var found = await CoreUpdateUtils.findFile(extractDir, binaryName);
    if (found != null) {
      _log('→ [match-1] exact name: $found');
      return found;
    }

    found = await CoreUpdateUtils.findFileByPrefix(extractDir, binaryBaseName);
    if (found != null) {
      _log('→ [match-2] prefix match: $found');
      return found;
    }

    found = await CoreUpdateUtils.findFileContaining(
      extractDir,
      fallbackPattern,
    );
    if (found != null) {
      _log('→ [match-3] contains match: $found');
      return found;
    }

    throw StateError(
      'No executable matching `$binaryBaseName` found in archive. '
      'Check the archive contents above.',
    );
  }

  /// تشخیص نوع آرشیو از روی URL.
  ({bool isZip, bool isTarXz, bool isArchive, String archiveName})
  classifyArchive(String url, String baseName) {
    final lower = url.toLowerCase();
    final isZip = lower.endsWith('.zip');
    final isTarball = lower.endsWith('.tar.gz') || lower.endsWith('.tgz');
    final isTarXz = lower.endsWith('.tar.xz');
    final isArchive = isZip || isTarball || isTarXz;
    final archiveName = isZip
        ? '$baseName.zip'
        : isTarball
        ? '$baseName.tar.gz'
        : isTarXz
        ? '$baseName.tar.xz'
        : '$baseName.bin';
    return (
      isZip: isZip,
      isTarXz: isTarXz,
      isArchive: isArchive,
      archiveName: archiveName,
    );
  }

  /// بررسی و "safe copy" از فایل باینری برای اطمینان از سالم بودن.
  /// (برای SSTP مهم است چون ممکن است symlink شکسته باشد)
  Future<String> safeCopyBinary({
    required String source,
    required String tmpPath,
  }) async {
    _log('→ Verifying source file: $source');
    final srcType = await FileSystemEntity.type(source, followLinks: true);
    _log('   • type (followLinks=true): $srcType');
    if (srcType != FileSystemEntityType.file) {
      throw StateError('Source is not a regular file (type=$srcType): $source');
    }

    final List<int> bytes;
    try {
      bytes = await File(source).readAsBytes();
    } catch (e) {
      throw StateError('Cannot read source file $source: $e');
    }
    if (bytes.isEmpty) {
      throw StateError('Source file is empty: $source');
    }
    _log('   • read ${bytes.length} bytes');

    final safeCopy = '$tmpPath/_safe_binary$_exeExt';
    try {
      await File(safeCopy).writeAsBytes(bytes, flush: true);
    } catch (e) {
      throw StateError('Cannot write safe copy $safeCopy: $e');
    }
    if (!_isWin) {
      try {
        await Process.run('chmod', ['+x', safeCopy]);
      } catch (_) {}
    }
    _log('   • safe copy created: $safeCopy');
    return safeCopy;
  }
}
