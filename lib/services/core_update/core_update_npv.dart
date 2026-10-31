library;

import '../app_data_service.dart';
import '../core_update_models.dart';
import 'core_update_network.dart';
import 'core_update_pending.dart';
import 'core_update_process_utils.dart';
import 'shared/github_release_updater.dart';

/// ═══════════════════════════════════════════════════════════════
///  NpvUpdater — آپدیت هستهٔ NPV (باینری npv از NPV Tunnel)
///
///  مخزن: https://github.com/FossilizedProgrammer/npv-go/releases
///
///  هر release دو آرشیو منتشر می‌کند:
///    npv-linux-amd64.tar.gz   → npv + LICENSE + README
///    npv-windows-amd64.zip    → npv.exe + LICENSE + README
///
///  باینری‌های رلیز نسخه را با ldflags داخل خودشان stamp می‌کنند، پس
///  `npv --version` عدد می‌دهد و مقایسهٔ نسخهٔ عددی ممکن است. بیلدهای
///  محلی و باینری‌های قدیمی‌تر عدد ندارند؛ برای آن‌ها اندازهٔ فایل در
///  برابر asset سنجیده می‌شود (sizeBasedVersion).
/// ═══════════════════════════════════════════════════════════════
class NpvUpdater {
  static const String _binaryBaseName = 'npv';

  final GithubReleaseUpdater _updater;

  NpvUpdater({
    required CoreUpdateNetwork network,
    required CoreUpdatePendingManager pending,
    required CoreUpdateProcessUtils processUtils,
    void Function(String)? log,
  }) : _updater = GithubReleaseUpdater(
          spec: GithubCoreSpec(
            coreId: 'npv',
            displayName: 'NPV Tunnel (npv)',
            owner: 'FossilizedProgrammer',
            repo: 'npv-go',
            binaryBaseName: _binaryBaseName,
            fallbackPattern: _binaryBaseName,
            destPathResolver: () =>
                AppDataService.getBinaryPathForWrite(_binaryBaseName),
            tempPrefix: 'mischiefpingu_npv_',
            defaultDownloadSize: 13000000,
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
