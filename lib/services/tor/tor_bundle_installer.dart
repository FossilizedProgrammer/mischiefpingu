library;

import 'dart:io';
import 'package:path/path.dart' as p;
import '../app_data_service.dart';
import '../core_update_utils.dart';
import 'tor_types.dart';

class TorBundleInstaller {
  static const _runtimeKeep = {'torrc', 'tordata', 'cached-certs'};

  static String bundleRoot(Directory extractDir, String torBinPath) {
    final dir = p.dirname(torBinPath);
    if (p.equals(dir, extractDir.path)) return extractDir.path;
    final rel = p.relative(dir, from: extractDir.path);
    final first = rel.split(p.separator).first;
    return p.join(extractDir.path, first);
  }

  static Future<bool> looksLikeBundle(String dir) async {
    for (final name in [
      'tor',
      'tor.exe',
      'geoip',
      'geoip6',
      'lyrebird',
      'lyrebird.exe',
      'pluggable_transports'
    ]) {
      try {
        if (await File(p.join(dir, name)).exists()) return true;
        if (await Directory(p.join(dir, name)).exists()) return true;
      } catch (_) {}
    }
    return false;
  }

  static Future<int> installTree({
    required String srcRoot,
    required String torDir,
    required TorLogFn log,
  }) async {
    final src = Directory(srcRoot);
    if (!await src.exists()) {
      throw StateError('Tor bundle source missing: $srcRoot');
    }

    await Directory(torDir).create(recursive: true);
    var count = 0;

    await for (final e in src.list(recursive: true, followLinks: false)) {
      final rel = p.relative(e.path, from: srcRoot);
      if (rel == '.' || rel.isEmpty) continue;

      final first = rel.split(p.separator).first;
      if (_runtimeKeep.contains(first)) continue;
      if (e.path.endsWith('.tar.gz') || e.path.endsWith('.zip')) continue;

      final destPath = p.join(torDir, rel);

      if (e is Directory) {
        await Directory(destPath).create(recursive: true);
      } else if (e is File) {
        await Directory(p.dirname(destPath)).create(recursive: true);
        await e.copy(destPath);
        if (_shouldChmodX(destPath)) {
          if (!AppDataService.isWindows) {
            try {
              await Process.run('chmod', ['+x', destPath]);
            } catch (_) {}
          }
        }
        count++;
        log('→ Installed tor/$rel');
      }
    }

    if (!AppDataService.isWindows) {
      for (final name in [
        'tor',
        'lyrebird',
        'conjure-client',
        'tor-gencert',
        'tor-resolve'
      ]) {
        final f = await CoreUpdateUtils.findFile(Directory(torDir), name);
        if (f != null) {
          try {
            await Process.run('chmod', ['+x', f]);
          } catch (_) {}
        }
      }
    }

    return count;
  }

  static bool _shouldChmodX(String destPath) {
    if (AppDataService.isWindows) return false;
    final base = p.basename(destPath).toLowerCase();
    const executables = {
      'tor',
      'lyrebird',
      'conjure-client',
      'tor-gencert',
      'tor-resolve',
      'torify',
      'snowflake-client',
      'webtunnel-client',
      'obfs4proxy',
    };
    if (executables.contains(base)) return true;
    if (destPath.contains('pluggable_transports')) return true;
    if (!base.contains('.')) return true;
    return false;
  }
}
