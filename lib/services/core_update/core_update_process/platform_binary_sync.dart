library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../../app_data_service.dart';
import 'binary_replacer.dart';

/// همگام‌سازی باینری در پوشهٔ platform (کنار exe اصلی).
class PlatformBinarySync {
  final void Function(String)? log;
  final BinaryReplacer replacer;
  final String Function(String coreId) binaryNameForCore;

  PlatformBinarySync({
    required this.log,
    required this.replacer,
    required this.binaryNameForCore,
  });

  void _log(String m) => log?.call(m);

  Future<void> updateExecutableDirBinary(
    String coreId,
    String stagingPath,
  ) async {
    if (coreId == 'tor') {
      _log('→ Tor kept in data dir only (no exe-dir copy)');
      return;
    }
    if (AppDataService.isRunningInAppImage) {
      _log(
        '→ AppImage mode: $coreId kept in data dir only '
        '(exe dir is read-only)',
      );
      return;
    }
    try {
      final exeDir = p.dirname(Platform.resolvedExecutable);
      final platformDir = p.join(exeDir, AppDataService.osFolder);
      final destPath = p.join(platformDir, binaryNameForCore(coreId));
      final destFile = File(destPath);
      if (await destFile.exists()) {
        await replacer.replaceBinary(stagingPath, destPath);
        _log('→ Also updated $coreId in platform directory');
      }
    } catch (e) {
      _log('⚠ Failed to update platform directory binary for $coreId: $e');
    }
  }
}
