library;

import '../app_data_service.dart';
import '../core_update_models.dart';
import 'core_update_network.dart';
import 'core_update_pending.dart';
import 'core_update_process_utils.dart';
import 'shared/github_release_updater.dart';
import 'shared/github_core_spec.dart';

/// ═══════════════════════════════════════════════════════════════
///  CumulusUpdater — آپdیت hist CumulusVPN CLI
/// ═══════════════════════════════════════════════════════════════
///
///  مخزن: https://github.com/FossilizedProgrammer/cumulus
///
///  releaseها بinaire cumulusvpn-linux-amd64 و cumulusvpn-windows-amd64.exe
///  منتشر می‌کنند. نسخه‌ی sốمتی از خروجی `cumulusvpn version` یا
///  sizeBasedVersion با اندازهٔ فایل محلی مقایسه می‌شود.
/// ════════════════════════════════════════════════════════════════
class CumulusUpdater {
  static const String _binaryBaseName = 'cumulusvpn';

  final GithubReleaseUpdater _updater;

  CumulusUpdater({
    required CoreUpdateNetwork network,
    required CoreUpdatePendingManager pending,
    required CoreUpdateProcessUtils processUtils,
    void Function(String)? log,
  }) : _updater = GithubReleaseUpdater(
          spec: GithubCoreSpec(
            coreId: 'cumulus',
            displayName: 'CumulusVPN CLI',
            owner: 'FossilizedProgrammer',
            repo: 'cumulus',
            binaryBaseName: _binaryBaseName,
            fallbackPattern: 'cumulusvpn',
            destPathResolver: () => AppDataService.getBinaryPathForWrite(_binaryBaseName),
            tempPrefix: 'mischiefpingu_cumulus_',
            defaultDownloadSize: 5000000,
            sizeBasedVersion: true,
          ),
          network: network,
          pending: pending,
          processUtils: processUtils,
          log: log,
        );

  Future<CoreUpdateInfo> check(String? proxy, {required String installed}) =>
      _updater.check(proxy, installed: installed);

  Future<bool> update(
    CoreUpdateInfo info, {
    required String installed,
    String? proxy,
    void Function(int percent)? onProgress,
    bool Function()? onCancelCheck,
  }) =>
      _updater.update(
        info,
        installed: installed,
        proxy: proxy,
        onProgress: onProgress,
        onCancelCheck: onCancelCheck,
      );
}
