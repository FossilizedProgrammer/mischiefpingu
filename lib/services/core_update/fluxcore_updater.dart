library;

import '../app_data_service.dart';
import '../core_update_models.dart';
import 'core_update_network.dart';
import 'core_update_pending.dart';
import 'core_update_process_utils.dart';
import 'shared/github_release_updater.dart';
import 'shared/github_core_spec.dart';

/// ═══════════════════════════════════════════════════════════════
///  FluxcoreUpdater — آپdیت hist Fluxcore CLI
/// ═══════════════════════════════════════════════════════════════
///
///  مخزن: https://github.com/FossilizedProgrammer/fluxcore
///
///  releaseها بinaire fluxcore-linux-amd64 و fluxcore-windows-amd64.exe
///  منتشر می‌کنند. نسخه‌ی sốمتی از خروجی `fluxcore version` یا
///  sizeBasedVersion با اندازهٔ فایل محلی مقایسه می‌شود.
/// ════════════════════════════════════════════════════════════════
class FluxcoreUpdater {
  static const String _binaryBaseName = 'fluxcore';

  final GithubReleaseUpdater _updater;

  FluxcoreUpdater({
    required CoreUpdateNetwork network,
    required CoreUpdatePendingManager pending,
    required CoreUpdateProcessUtils processUtils,
    void Function(String)? log,
  }) : _updater = GithubReleaseUpdater(
          spec: GithubCoreSpec(
            coreId: 'fluxcore',
            displayName: 'Fluxcore CLI',
            owner: 'FossilizedProgrammer',
            repo: 'fluxcore',
            binaryBaseName: _binaryBaseName,
            fallbackPattern: 'fluxcore',
            destPathResolver: () => AppDataService.getBinaryPathForWrite(_binaryBaseName),
            tempPrefix: 'mischiefpingu_fluxcore_',
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
