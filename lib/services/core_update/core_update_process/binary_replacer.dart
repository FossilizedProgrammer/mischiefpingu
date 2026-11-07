library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../../app_data_service.dart';
import '../../core_update_utils.dart';

/// جایگزینی ایمن باینری با atomic rename.
class BinaryReplacer {
  final void Function(String)? log;
  BinaryReplacer({this.log});

  void _log(String m) => log?.call(m);
  bool get _isWin => AppDataService.isWindows;

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
}
