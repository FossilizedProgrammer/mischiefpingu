library;

import 'dart:io';
import '../app_data_service.dart';
import '../core_update_utils.dart';

class CoreUpdateVersionChecker {
  final void Function(String)? log;
  CoreUpdateVersionChecker({this.log});

  void _log(String m) => log?.call(m);

  Future<String> getInstalledVersion(String coreId,
      {String psiphonRev = ''}) async {
    try {
      if (coreId == 'aether') {
        final exe = await AppDataService.getBinaryPath('aether');
        final v = await _queryExeVersion(exe, ['--version']);
        return CoreUpdateUtils.parseAetherVersion(v) ?? 'unknown';
      }
      if (coreId == 'tor') {
        final exe = await AppDataService.findTorBinary() ??
            await AppDataService.getTorBinaryPath();
        final v = await _queryExeVersion(exe, ['--version']);
        return CoreUpdateUtils.parseTorVersion(v) ?? 'not installed';
      }
      if (coreId == 'psiphon') {
        final exe = await AppDataService.getBinaryPath('psiphon-tunnel-core');
        if (!await File(exe).exists()) return 'not installed';
        final v = await _queryExeVersion(exe, ['-v']);
        final parsed = CoreUpdateUtils.parsePsiphonVersion(v);
        if (parsed != null) return parsed;
        final rev = psiphonRev.trim();
        if (rev.isNotEmpty) {
          return 'rev ${rev.length > 10 ? rev.substring(0, 10) : rev}';
        }
        return 'installed';
      }
      if (coreId == 'sunandlion') {
        final exe = await AppDataService.getBinaryPath(
            'psiphon-tunnel-core-sunandlion');
        if (!await File(exe).exists()) return 'not installed';
        final v = await _queryExeVersion(exe, ['-v']);
        final parsed = CoreUpdateUtils.parsePsiphonVersion(v);
        if (parsed != null) return parsed;
        return 'installed';
      }
      if (coreId == 'sstp') {
        final exe = await AppDataService.getSstpBinaryPath();
        if (!await File(exe).exists()) return 'not installed';
        final v = await _queryExeVersion(exe, ['--version']);
        if (v == null) return 'installed';
        final m = RegExp(r'\b(\d+\.\d+\.\d+(?:[-\+][\w\.]+)?)\b').firstMatch(v);
        return m?.group(1) ?? 'installed';
      }
      return 'unknown';
    } catch (e) {
      _log('⚠ Could not detect $coreId version: $e');
      if (coreId == 'tor' || coreId == 'sunandlion' || coreId == 'sstp') {
        return 'not installed';
      }
      return 'unknown';
    }
  }

  Future<String?> _queryExeVersion(String exe, List<String> args) async {
    try {
      if (!await File(exe).exists()) return null;
      final r =
          await Process.run(exe, args).timeout(const Duration(seconds: 10));
      final out = '${r.stdout}${r.stderr}'.trim();
      return out.isEmpty ? null : out;
    } catch (_) {
      return null;
    }
  }
}
