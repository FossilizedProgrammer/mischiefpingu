library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../platform_info.dart';

class SharedFilesSeeder {
  SharedFilesSeeder._();

  static void _log(String msg) {
    // ignore: avoid_print
    print(msg);
  }

  static Future<void> seedSharedFiles({
    required String dataDir,
    required String exeDir,
  }) async {
    final sharedFiles = ['geoip', 'geoip6'];
    for (final fileName in sharedFiles) {
      final source = File(p.join(exeDir, fileName));
      final dest = File(p.join(dataDir, fileName));
      if (!await source.exists()) {
        _log('Shared file not found next to binary: $fileName');
        continue;
      }
      try {
        if (!await dest.exists()) {
          await source.copy(dest.path);
          _log('Copied shared data file: $fileName');
        } else {
          _log(
            'Shared data file already exists (preserving live updates): $fileName',
          );
        }
      } catch (e) {
        _log('Failed to copy shared file $fileName: $e');
      }
    }
  }

  /// کپی خودکار فایل `server_list.dat` از کنار باینری (یا پوشه platform)
  /// به پوشه داده. این فایل برای شروع کار Psiphon در محیط‌های فیلترشده
  /// حیاتی است، چون Psiphon نمی‌تواند لیست را از اینترنت مستقیم بگیرد.
  static Future<void> seedServerList({
    required String dataDir,
    required String exeDir,
    String? platformDir,
  }) async {
    final dest = File(p.join(dataDir, 'server_list.dat'));

    if (await dest.exists()) {
      final size = await dest.length();
      _log(
        'server_list.dat already present in data dir (${size}B) — preserving',
      );
      return;
    }

    final candidates = <String>[
      p.join(exeDir, 'server_list.dat'),
      if (platformDir != null) p.join(platformDir, 'server_list.dat'),
      p.join(exeDir, 'resources', 'server_list.dat'),
      p.join(exeDir, 'data', 'server_list.dat'),
    ];

    for (final candidate in candidates) {
      try {
        final source = File(candidate);
        if (!await source.exists()) continue;

        final size = await source.length();
        if (size == 0) {
          _log('server_list.dat candidate is empty, skipping: $candidate');
          continue;
        }

        await source.copy(dest.path);
        _log(
          '★ Copied server_list.dat ($size bytes) from $candidate → ${dest.path}',
        );
        return;
      } catch (e) {
        _log('Failed to copy server_list.dat from $candidate: $e');
      }
    }

    _log(
      '⚠ server_list.dat not found in any known location. '
      'Place it next to the app binary or in the data dir manually.',
    );
  }

  /// پاک‌سازی فایل `server_list.dat` فقط اگر کاملاً خالی باشد (0 بایت).
  ///
  /// ⚠️ نسخه قبلی این تابع فایل‌های کوچک‌تر از 5KB را حذف می‌کرد.
  /// این رفتار در محیط‌های فیلترشده مخرب بود، چون Psiphon نمی‌توانست
  /// لیست را از شبکه مستقیم دریافت کند و در حلقه بی‌پایان گیر می‌کرد.
  static Future<void> cleanupStaleServerList({required String dataDir}) async {
    try {
      final serverList = File(p.join(dataDir, 'server_list.dat'));
      if (!await serverList.exists()) return;

      final size = await serverList.length();
      if (size == 0) {
        await serverList.delete();
        _log('⚠ Removed empty server_list.dat (0 bytes)');
      } else {
        _log('Kept server_list.dat ($size bytes) — will be used by Psiphon');
      }
    } catch (e) {
      _log('Failed to check server_list.dat: $e');
    }
  }

  static Future<void> seedPlatformBinaries({
    required String dataDir,
    required String platformDir,
  }) async {
    final platformBinaries = [
      'psiphon-tunnel-core',
      'psiphon-tunnel-core-sunandlion',
      'aether',
      'sstp-proxy',
    ];
    for (final fileName in platformBinaries) {
      final sourceName = '$fileName${PlatformInfo.exeExt}';
      final source = File(p.join(platformDir, sourceName));
      final dest = File(p.join(dataDir, sourceName));
      if (!await source.exists()) {
        _log('Platform binary not found: $platformDir/$sourceName');
        continue;
      }
      try {
        bool shouldCopy = true;
        if (await dest.exists()) {
          final srcLen = await source.length();
          final dstLen = await dest.length();
          if (srcLen == dstLen) {
            shouldCopy = false;
            _log('Binary already up-to-date (same size): $sourceName');
          }
        }
        if (shouldCopy) {
          await source.copy(dest.path);
          _log('Copied/Updated platform binary: $sourceName');
          if (!PlatformInfo.isWindows) {
            try {
              await Process.run('chmod', ['+x', dest.path]);
            } catch (_) {}
          }
        }
      } catch (e) {
        _log('Failed to copy $sourceName: $e');
      }
    }
  }
}
