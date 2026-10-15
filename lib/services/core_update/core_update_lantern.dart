library;

import '../app_data_service.dart';
import '../core_update_models.dart';
import 'core_update_network.dart';
import 'core_update_pending.dart';
import 'core_update_process_utils.dart';
import 'shared/github_release_updater.dart';

/// ═══════════════════════════════════════════════════════════════
///  LanternUpdater — آپدیت هستهٔ لنترن (headless)
///
///  مخزن: https://github.com/FossilizedProgrammer/lantern-headless-iran/releases
///
///  releaseها باینری خام (بدون آرشیو) منتشر می‌کنند:
///    lantern-headless-linux-amd64 / lantern-headless-linux-arm64
///    lantern-headless-windows-amd64.exe / …
///
///  نسخهٔ نصب‌شده از `lantern --version` خوانده می‌شود؛ باینری‌های محلی
///  که بدون ldflags ساخته شده‌اند نسخهٔ عددی ندارند، بنابراین مثل ffvpn
///  اندازهٔ فایل محلی با اندازهٔ asset منتشرشده مقایسه می‌شود
///  (sizeBasedVersion).
/// ═══════════════════════════════════════════════════════════════
class LanternUpdater {
  static const String _binaryBaseName = 'lantern';

  final GithubReleaseUpdater _updater;

  LanternUpdater({
    required CoreUpdateNetwork network,
    required CoreUpdatePendingManager pending,
    required CoreUpdateProcessUtils processUtils,
    void Function(String)? log,
  }) : _updater = GithubReleaseUpdater(
          spec: GithubCoreSpec(
            coreId: 'lantern',
            displayName: 'Lantern (headless)',
            owner: 'FossilizedProgrammer',
            repo: 'lantern-headless-iran',
            binaryBaseName: _binaryBaseName,
            fallbackPattern: 'lantern',
            destPathResolver: () =>
                AppDataService.getBinaryPathForWrite(_binaryBaseName),
            tempPrefix: 'mischiefpingu_lantern_',
            defaultDownloadSize: 65000000,
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
