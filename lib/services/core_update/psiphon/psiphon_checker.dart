library;

import 'dart:io';

import '../../app_data_service.dart';
import '../../core_update_models.dart';
import '../../core_update_utils.dart';
import '../core_update_network.dart';
import '../psiphon_binaries_head.dart';

class PsiphonChecker {
  final CoreUpdateNetwork network;
  final void Function(String)? log;

  late final PsiphonBinariesHead _binariesHead = PsiphonBinariesHead(
    network: network,
    log: log,
  );

  PsiphonChecker({required this.network, this.log});

  void _log(String m) => log?.call(m);

  Future<CoreUpdateInfo> check(
    String? proxy, {
    required String installed,
    required String psiphonBinSha,
  }) async {
    try {
      network.logRoute(proxy);
      final exe = await AppDataService.getBinaryPath('psiphon-tunnel-core');
      final missing = !await File(exe).exists();
      final remote = await _binariesHead.fetch(proxy);
      if (remote.sha.isEmpty) {
        throw StateError('Binaries repo unreachable (empty tree).');
      }
      final stored = psiphonBinSha.trim();
      var hasUpdate = missing;
      var note = '';
      if (!missing) {
        if (stored.isNotEmpty) {
          hasUpdate = stored != remote.sha;
          note = hasUpdate
              ? 'Upstream republished the official binary.'
              : 'Matches the published official binary.';
        } else {
          final localSize = await CoreUpdateUtils.fileSize(exe);
          hasUpdate = remote.size > 0 ? localSize != remote.size : true;
          note = hasUpdate
              ? 'Local binary differs from the published one.'
              : 'Local binary matches the published one by size.';
        }
      }
      final short = remote.sha.length > 7
          ? remote.sha.substring(0, 7)
          : remote.sha;
      return CoreUpdateInfo(
        coreId: 'psiphon',
        displayName: 'Psiphon (official core)',
        installedVersion: installed,
        latestVersion: 'published $short',
        hasUpdate: hasUpdate,
        downloadUrl: remote.url,
        releaseNotes: note.isEmpty ? 'Official binary.' : note,
        downloadSizeBytes: remote.size,
        latestCommit: remote.sha,
      );
    } catch (e) {
      _log('✗ Psiphon update check failed: $e');
      rethrow;
    }
  }
}
