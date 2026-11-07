library;

import '../app_data_service.dart';
import '../core_update_models.dart';
import 'core_update_network.dart';
import 'core_update_pending.dart';
import 'core_update_process_utils.dart';
import 'shared/github_release_updater.dart';

/// ═══════════════════════════════════════════════════════════════
///  LanternUpdater — آپدیت هستهٔ لنترن (headless + radiance)
///
///  مخزن: https://github.com/FossilizedProgrammer/lantern-headless-iran/releases
///
///  هر release یک آرشیو تک‌فایلی برای هر پلتفرم منتشر می‌کند که *هر دو*
///  باینری را در خود دارد:
///    lantern-headless-linux-amd64.tar.gz   → lantern + lantern-radiance
///    lantern-headless-windows-amd64.zip    → lantern.exe + lantern-radiance.exe
///
///  آپدیتر همان آرشیو را دانلود و هر دو باینری را نصب می‌کند (باینری دوم
///  از طریق [GithubCoreSpec.extraBinaries]).
///
///  نسخهٔ نصب‌شده از `lantern --version` خوانده می‌شود؛ باینری‌های محلی
///  که بدون ldflags ساخته شده‌اند نسخهٔ عددی ندارند، بنابراین مثل ffvpn
///  اندازهٔ فایل محلی با اندازهٔ asset منتشرشده مقایسه می‌شود
///  (sizeBasedVersion).
/// ═══════════════════════════════════════════════════════════════
class LanternUpdater {
  static const String _binaryBaseName = 'lantern';
  static const String _radianceBaseName = 'lantern-radiance';

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
            fallbackPattern: _binaryBaseName,
            destPathResolver: () =>
                AppDataService.getBinaryPathForWrite(_binaryBaseName),
            tempPrefix: 'mischiefpingu_lantern_',
            defaultDownloadSize: 110000000,
            sizeBasedVersion: true,
            extraBinaries: const [
              ExtraBinarySpec(
                baseName: _radianceBaseName,
                fallbackPattern: _radianceBaseName,
                coreId: _radianceBaseName,
              ),
            ],
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
