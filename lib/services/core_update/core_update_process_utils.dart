// lib/services/core_update/core_update_process_utils.dart
library;

import 'dart:io';
import 'package:path/path.dart' as p;
import '../app_data_service.dart';
import '../core_update_utils.dart';
import 'core_update_archive_extractor.dart';

/// ابزارهای مدیریت پروسه و جایگزینی باینری.
class CoreUpdateProcessUtils {
  final void Function(String)? log;
  CoreUpdateProcessUtils({this.log});

  late final CoreUpdateArchiveExtractor _archive = CoreUpdateArchiveExtractor(
    log: log,
  );

  void _log(String m) => log?.call(m);
  bool get _isWin => AppDataService.isWindows;

  // ─── delegate به archive extractor ───
  Future<void> extractArchive(String archive, String destDir) =>
      _archive.extract(archive, destDir);

  String binaryNameForCore(String coreId) => _archive.binaryNameForCore(coreId);

  // ─── process management ───
  Future<bool> isProcessRunning(String binaryName) async {
    try {
      if (_isWin) {
        final r =
            await Process.run('tasklist', ['/FI', 'IMAGENAME eq $binaryName']);
        if (r.exitCode == 0) {
          return (r.stdout as String).contains(binaryName);
        }
      } else {
        final pattern = '(^|/)${RegExp.escape(binaryName)}\$';
        final r = await Process.run('pgrep', ['-f', pattern]);
        if (r.exitCode == 0 && (r.stdout as String).trim().isNotEmpty) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<void> stopProcess(String binaryName, String label) async {
    try {
      final running = await isProcessRunning(binaryName);
      if (running) {
        _log('→ $label is running — stopping it for replacement …');
        if (_isWin) {
          await Process.run('taskkill', ['/F', '/IM', binaryName]);
        } else {
          await Process.run(
              'pkill', ['-f', '(^|/)${RegExp.escape(binaryName)}\$']);
        }
        await Future.delayed(const Duration(milliseconds: 600));
      }
    } catch (_) {}
  }

  /// کپی اتمیک فایل مبدأ به مقصد با staging.
  Future<int> replaceBinary(String src, String dest) async {
    if (!await CoreUpdateUtils.isRealFile(src)) {
      throw StateError('Source file does not exist or is invalid: $src');
    }
    final srcFile = File(src);
    final srcSize = await srcFile.length();
    if (srcSize == 0) {
      throw StateError('Source file is empty: $src');
    }
    _log('→ replaceBinary: src=$src ($srcSize bytes) → dest=$dest');

    final destDir = p.dirname(dest);
    try {
      await Directory(destDir).create(recursive: true);
    } catch (e) {
      throw StateError('Cannot create destination directory $destDir: $e');
    }

    final staging = '$dest.new';
    try {
      await srcFile.copy(staging);
    } catch (e) {
      try {
        await File(staging).delete();
      } catch (_) {}
      throw StateError('Failed to copy $src → $staging: $e');
    }

    if (!_isWin) {
      final r = await Process.run('chmod', ['+x', staging]);
      if (r.exitCode != 0) {
        _log('⚠ chmod +x failed: ${r.stderr}');
      }
    }

    try {
      if (await File(dest).exists()) {
        await File(dest).delete();
      }
    } catch (e) {
      _log('⚠ Could not delete old binary $dest: $e');
    }

    try {
      await File(staging).rename(dest);
    } catch (e) {
      _log('⚠ rename failed, trying direct copy: $e');
      try {
        await File(staging).copy(dest);
        await File(staging).delete();
      } catch (e2) {
        throw StateError('Failed to finalize $dest: $e2');
      }
    }

    await AppDataService.fixDataDirOwnership();
    final finalSize = await CoreUpdateUtils.fileSize(dest);
    _log('→ replaceBinary done: $dest ($finalSize bytes)');
    return finalSize;
  }

  /// کپی باینری به پوشهٔ کنار exe (linux/ یا windows/).
  Future<void> updateExecutableDirBinary(
      String coreId, String stagingPath) async {
    if (coreId == 'tor') {
      _log('→ Tor kept in data dir only (no exe-dir copy)');
      return;
    }
    if (AppDataService.isRunningInAppImage) {
      _log(
          '→ AppImage mode: $coreId kept in data dir only (exe dir is read-only)');
      return;
    }
    try {
      final exeDir = p.dirname(Platform.resolvedExecutable);
      final platformDir = p.join(exeDir, AppDataService.osFolder);
      final destPath = p.join(platformDir, binaryNameForCore(coreId));
      final destFile = File(destPath);
      if (await destFile.exists()) {
        await replaceBinary(stagingPath, destPath);
        _log('→ Also updated $coreId in platform directory');
      }
    } catch (e) {
      _log('⚠ Failed to update platform directory binary for $coreId: $e');
    }
  }
}
