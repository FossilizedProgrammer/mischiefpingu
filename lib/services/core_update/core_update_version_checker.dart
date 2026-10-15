// lib/services/core_update/core_update_version_checker.dart

library;

import 'dart:io';

import '../app_data_service.dart';
import '../core_update_utils.dart';

class CoreUpdateVersionChecker {
  final void Function(String)? log;
  CoreUpdateVersionChecker({this.log});

  void _log(String m) => log?.call(m);

  Future<String> getInstalledVersion(
    String coreId, {
    String psiphonRev = '',
  }) async {
    try {
      if (coreId == 'tor') {
        final exe = await AppDataService.findTorBinary() ??
            await AppDataService.getTorBinaryPath();
        final v = await _queryExeVersion(exe, ['--version']);
        return CoreUpdateUtils.parseTorVersion(v) ?? 'not installed';
      }

      if (coreId == 'psiphon') {
        final exe =
            await AppDataService.resolveBinaryPath('psiphon-tunnel-core') ??
                await AppDataService.getBinaryPath('psiphon-tunnel-core');
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
        final exe = await AppDataService.resolveBinaryPath(
              'psiphon-tunnel-core-sunandlion',
            ) ??
            await AppDataService.getBinaryPath(
              'psiphon-tunnel-core-sunandlion',
            );
        if (!await File(exe).exists()) return 'not installed';
        final v = await _queryExeVersion(exe, ['-v']);
        final parsed = CoreUpdateUtils.parsePsiphonVersion(v);
        if (parsed != null) return parsed;
        return 'installed';
      }

      if (coreId == 'ffvpn') {
        // ═══════════════════════════════════════════════════
        //  Firefox VPN (ffvpn)
        //
        //  باینری ffvpn پرچم `--version` ندارد، پس نسخهٔ دقیق از
        //  روی اندازهٔ فایل در برابر asset منتشرشده سنجیده می‌شود
        //  (نگاه کن به GithubCoreSpec.sizeBasedVersion).
        // ═══════════════════════════════════════════════════
        final exe = await AppDataService.resolveBinaryPath('ffvpn') ??
            await AppDataService.getBinaryPath('ffvpn');
        if (!await File(exe).exists()) return 'not installed';
        return 'installed';
      }

      // ═══════════════════════════════════════════════════
      //  🆕 لنترن (headless)
      //
      //  خروجی `lantern --version` این شکلی است:
      //    lantern-headless-iran v1.2.3 [Build Date: … Revision Date: …]
      //  باینری‌های محلی که بدون ldflags ساخته شده‌اند عدد ندارند.
      // ═══════════════════════════════════════════════════
      if (coreId == 'lantern') {
        final exe = await AppDataService.resolveBinaryPath('lantern') ??
            await AppDataService.getBinaryPath('lantern');
        if (!await File(exe).exists()) return 'not installed';
        final v = await _queryExeVersion(exe, ['--version']);
        if (v == null) return 'installed';
        final m = RegExp(r'\b(\d+\.\d+\.\d+(?:[-\+][\w\.]+)?)\b')
            .firstMatch(v);
        return m?.group(1) ?? 'installed';
      }

      if (coreId == 'sstp') {
        final exe = await AppDataService.getSstpBinaryPathForExecution();
        if (!await File(exe).exists()) return 'not installed';
        final v = await _queryExeVersion(exe, ['--version']);
        if (v == null) return 'installed';
        final m = RegExp(r'\b(\d+\.\d+\.\d+(?:[-\+][\w\.]+)?)\b').firstMatch(v);
        return m?.group(1) ?? 'installed';
      }

      // ═══════════════════════════════════════════════════════════
      //  WireGuard (wireproxy — Standard)
      //
      //  خروجی wireproxy --version این شکلی است:
      //    wireproxy version: v1.1.2
      //    wireproxy version: 1.1.2
      // ═══════════════════════════════════════════════════════════
      if (coreId == 'wireguard') {
        final exe = await AppDataService.resolveBinaryPath('wireproxy') ??
            await AppDataService.getBinaryPath('wireproxy');
        if (!await File(exe).exists()) return 'not installed';
        final v = await _queryExeVersion(exe, ['--version']);
        if (v == null) return 'installed';
        final m = RegExp(r'\b(\d+\.\d+\.\d+(?:[-\+][\w\.]+)?)\b').firstMatch(v);
        return m?.group(1) ?? 'installed';
      }

      // ═══════════════════════════════════════════════════════════
      //  🆕 WireGuard Amnezia (wireproxy-awg)
      //
      //  خروجی wireproxy-awg --version مشابه wireproxy است.
      // ═══════════════════════════════════════════════════════════
      if (coreId == 'wireguard-awg') {
        final exe = await AppDataService.resolveBinaryPath('wireproxy-awg') ??
            await AppDataService.getBinaryPath('wireproxy-awg');
        if (!await File(exe).exists()) return 'not installed';
        final v = await _queryExeVersion(exe, ['--version']);
        if (v == null) return 'installed';
        final m = RegExp(r'\b(\d+\.\d+\.\d+(?:[-\+][\w\.]+)?)\b').firstMatch(v);
        return m?.group(1) ?? 'installed';
      }

      return 'unknown';
    } catch (e) {
      _log('⚠ Could not detect $coreId version: $e');
      if (coreId == 'tor' ||
          coreId == 'sunandlion' ||
          coreId == 'ffvpn' ||
          coreId == 'lantern' ||
          coreId == 'sstp' ||
          coreId == 'wireguard' ||
          coreId == 'wireguard-awg') {
        return 'not installed';
      }
      return 'unknown';
    }
  }

  Future<String?> _queryExeVersion(String exe, List<String> args) async {
    try {
      if (!await File(exe).exists()) return null;
      final r = await Process.run(
        exe,
        args,
      ).timeout(const Duration(seconds: 10));
      final out = '${r.stdout}${r.stderr}'.trim();
      return out.isEmpty ? null : out;
    } catch (_) {
      return null;
    }
  }
}
