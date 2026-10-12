library;

import '../app_data_service.dart';
import '../core_update_models.dart';
import 'core_update_network.dart';
import 'core_update_pending.dart';
import 'core_update_process_utils.dart';
import 'shared/github_release_updater.dart';

/// ═══════════════════════════════════════════════════════════════
///  FfvpnUpdater — آپدیت هستهٔ Firefox VPN (ffvpn)
///
///  مخزن: https://github.com/FossilizedProgrammer/firefox-vpn-go/releases
///
///  releaseها باینری خام (بدون آرشیو) منتشر می‌کنند:
///    ffvpn-linux-amd64 / ffvpn-linux-arm64
///    ffvpn-windows-amd64.exe / ffvpn-windows-arm64.exe
///
///  ⚠️ ffvpn پرچم `--version` ندارد، بنابراین نسخهٔ نصب‌شده با
///  مقایسهٔ اندازهٔ باینری محلی با asset منتشرشده تعیین می‌شود
///  (sizeBasedVersion).
/// ═══════════════════════════════════════════════════════════════
class FfvpnUpdater {
  static const String _binaryBaseName = 'ffvpn';

  final GithubReleaseUpdater _updater;

  FfvpnUpdater({
    required CoreUpdateNetwork network,
    required CoreUpdatePendingManager pending,
    required CoreUpdateProcessUtils processUtils,
    void Function(String)? log,
  }) : _updater = GithubReleaseUpdater(
          spec: GithubCoreSpec(
            coreId: 'ffvpn',
            displayName: 'Firefox VPN (ffvpn)',
            owner: 'FossilizedProgrammer',
            repo: 'firefox-vpn-go',
            binaryBaseName: _binaryBaseName,
            fallbackPattern: 'ffvpn',
            destPathResolver: () =>
                AppDataService.getBinaryPathForWrite(_binaryBaseName),
            tempPrefix: 'mischiefpingu_ffvpn_',
            defaultDownloadSize: 6500000,
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
