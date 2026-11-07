library;

import 'dart:io';

import '../app_data_service.dart';

class CoreUpdateArchiveExtractor {
  final void Function(String)? log;
  CoreUpdateArchiveExtractor({this.log});

  bool get _isWin => AppDataService.isWindows;

  /// استخراج آرشیو به destDir.
  Future<void> extract(String archive, String destDir) async {
    log?.call('→ Extracting archive: $archive → $destDir');
    if (_isWin && archive.toLowerCase().endsWith('.zip')) {
      final r = await Process.run('powershell', [
        '-NoProfile',
        '-Command',
        'Expand-Archive',
        '-Path',
        archive,
        '-DestinationPath',
        destDir,
        '-Force',
      ]);
      if (r.exitCode != 0) {
        throw StateError('PowerShell Expand-Archive failed: ${r.stderr}');
      }
    } else {
      final r = await Process.run('tar', ['-xzf', archive, '-C', destDir]);
      if (r.exitCode != 0) {
        throw StateError('tar extract failed: ${r.stderr}');
      }
    }
  }

  /// نام باینری متناظر با یک core.
  String binaryNameForCore(String coreId) {
    final ext = AppDataService.exeExt;
    switch (coreId) {
      case 'aether':
        return 'aether$ext';
      case 'tor':
        return 'tor$ext';
      case 'psiphon':
        return 'psiphon-tunnel-core$ext';
      case 'sunandlion':
        return 'psiphon-tunnel-core-sunandlion$ext';
      case 'sstp':
        return 'sstp-proxy$ext';
      default:
        return '$coreId$ext';
    }
  }
}
