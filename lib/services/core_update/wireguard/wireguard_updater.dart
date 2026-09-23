// lib/services/core_update/wireguard/wireguard_updater.dart

import '../../core_update_models.dart';
import '../core_update_network.dart';
import '../core_update_pending.dart';
import '../core_update_process_utils.dart';
import '../shared/github_release_updater.dart';
import '../../app_data_service.dart';
import '../../wireguard/wireguard_asset_resolver.dart';

/// ═══════════════════════════════════════════════════════════════
///  WireGuardUpdater — آپدیت core برای wireproxy.
///
///  مخزن: https://github.com/windtf/wireproxy
///
///  ⚠️ از `WireGuardAssetResolver` به عنوان picker سفارشی
///  استفاده می‌کنه چون assetهای این repo نام‌گذاری خاصی دارن
///  (`wireproxy_linux_amd64`, بدون پسوند آرشیو).
///
///  ⚠️ نکته: wireproxy در releaseهاش **باینری خام** منتشر
///  می‌کنه (نه آرشیو). `GithubReleaseInstaller` این رو
///  با `classifyArchive` تشخیص می‌ده و فایل رو مستقیم کپی می‌کنه.
/// ═══════════════════════════════════════════════════════════════
class WireGuardUpdater {
  final GithubReleaseUpdater _updater;

  WireGuardUpdater({
    required CoreUpdateNetwork network,
    required CoreUpdatePendingManager pending,
    required CoreUpdateProcessUtils processUtils,
    void Function(String)? log,
  }) : _updater = GithubReleaseUpdater(
          spec: GithubCoreSpec(
            coreId: 'wireguard',
            displayName: 'WireGuard (wireproxy)',
            owner: 'windtf',
            repo: 'wireproxy',
            binaryBaseName: 'wireproxy',
            fallbackPattern: 'wireproxy',
            destPathResolver: () =>
                AppDataService.getBinaryPathForWrite('wireproxy'),
            tempPrefix: 'mischiefpingu_wireproxy_',
            defaultDownloadSize: 4000000,
            // ═══════════════════════════════════════════════════
            //  🆕 picker سفارشی برای WireGuard
            // ═══════════════════════════════════════════════════
            assetPicker: WireGuardAssetResolver.pick,
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
