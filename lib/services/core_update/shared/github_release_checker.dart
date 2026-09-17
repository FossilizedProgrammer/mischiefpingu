// lib/services/core_update/shared/github_release_checker.dart
//
// ═══════════════════════════════════════════════════════════════
//  GithubReleaseChecker — منطق check برای GitHub Releases
// ═══════════════════════════════════════════════════════════════
library;

import '../../app_data_service.dart';
import '../../core_update_models.dart';
import '../../core_update_utils.dart';
import '../core_update_network.dart';
import 'asset_picker.dart';
import 'github_core_spec.dart';

class GithubReleaseChecker {
  final GithubCoreSpec spec;
  final CoreUpdateNetwork network;
  final void Function(String)? log;

  GithubReleaseChecker({
    required this.spec,
    required this.network,
    this.log,
  });

  void _log(String m) => log?.call(m);
  bool get _isWin => AppDataService.isWindows;

  Future<CoreUpdateInfo> check(String? proxy,
      {required String installed}) async {
    try {
      network.logRoute(proxy);
      final rel = await network.getJson(
        'https://api.github.com/repos/${spec.owner}/${spec.repo}/releases/latest',
        proxy,
      );

      final tag = (rel['tag_name'] as String? ?? '').trim();
      final latest = tag.replaceAll(RegExp(r'^[vV]'), '').trim();
      final notes = (rel['body'] as String? ?? '').trim();
      final assets = (rel['assets'] as List?) ?? [];

      _log('→ ${spec.displayName} release $tag has ${assets.length} asset(s):');
      for (final a in assets) {
        final m = a as Map<String, dynamic>;
        _log('   • ${m['name']} (${m['size']} bytes)');
      }

      String url = '';
      var size = 0;

      final arch = await network.detectArch();
      final asset = AssetPicker.pick(assets, arch);

      if (asset != null) {
        url = (asset['browser_download_url'] as String? ?? '');
        size = (asset['size'] as num? ?? 0).toInt();
        _log(
            '→ ${spec.displayName} asset chosen: ${asset['name']} ($size bytes)');
      } else {
        _log('⚠ No matching ${spec.displayName} asset found for arch=$arch '
            '(${_isWin ? 'windows' : 'linux'})');
      }

      return CoreUpdateInfo(
        coreId: spec.coreId,
        displayName: spec.displayName,
        installedVersion: installed,
        latestVersion: latest.isEmpty ? installed : latest,
        hasUpdate: latest.isNotEmpty &&
            (CoreUpdateUtils.isMissingVersion(installed) ||
                CoreUpdateUtils.isNewerVersion(installed, latest)),
        downloadUrl: url,
        releaseNotes: notes,
        downloadSizeBytes: size,
      );
    } catch (e) {
      _log('✗ ${spec.displayName} update check failed: $e');
      rethrow;
    }
  }
}
