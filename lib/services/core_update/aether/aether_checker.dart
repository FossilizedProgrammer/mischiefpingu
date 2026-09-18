library;

import '../../core_update_models.dart';
import '../../core_update_utils.dart';
import '../aether_asset_resolver.dart';
import '../core_update_network.dart';

class AetherChecker {
  final CoreUpdateNetwork network;
  final void Function(String)? log;

  const AetherChecker({required this.network, this.log});

  void _log(String m) => log?.call(m);

  Future<CoreUpdateInfo> check(
    String? proxy, {
    required String installed,
  }) async {
    try {
      network.logRoute(proxy);
      final rel = await network.getJson(
        'https://api.github.com/repos/CluvexStudio/Aether/releases/latest',
        proxy,
      );
      final tag = (rel['tag_name'] as String? ?? '').trim();
      final latest = tag.replaceAll(RegExp(r'^[vV]'), '').trim();
      final notes = (rel['body'] as String? ?? '').trim();
      String url = '';
      var size = 0;
      final arch = await network.detectArch();
      final fallbacks = AetherAssetResolver.assetNames(arch);
      final assets = (rel['assets'] as List?) ?? [];
      for (final fb in fallbacks) {
        for (final a in assets) {
          final m = a as Map<String, dynamic>;
          if ((m['name'] as String? ?? '') == fb) {
            url = (m['browser_download_url'] as String? ?? '');
            size = (m['size'] as num? ?? 0).toInt();
            break;
          }
        }
        if (url.isNotEmpty) break;
      }
      url = url.isNotEmpty
          ? url
          : 'https://github.com/CluvexStudio/Aether/releases/download/$tag/${fallbacks.first}';
      return CoreUpdateInfo(
        coreId: 'aether',
        displayName: 'Aether (WARP / MASQUE)',
        installedVersion: installed,
        latestVersion: latest.isEmpty ? installed : latest,
        hasUpdate:
            latest.isNotEmpty &&
            (CoreUpdateUtils.isMissingVersion(installed) ||
                CoreUpdateUtils.isNewerVersion(installed, latest)),
        downloadUrl: url,
        releaseNotes: notes,
        downloadSizeBytes: size,
      );
    } catch (e) {
      _log('✗ Aether update check failed: $e');
      rethrow;
    }
  }
}
