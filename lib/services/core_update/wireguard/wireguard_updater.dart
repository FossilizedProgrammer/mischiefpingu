// lib/services/core_update/wireguard/wireguard_updater.dart

import '../../core_update_models.dart';
import '../core_update_network.dart';
import '../core_update_pending.dart';
import '../core_update_process_utils.dart';
import '../shared/github_release_updater.dart';
import '../../app_data_service.dart';
import '../../wireguard/wireguard_asset_resolver.dart';

/// ═══════════════════════════════════════════════════════════════
///  WireGuardUpdater — آپدیت core برای wireproxy (Standard).
///
///  مخزن: https://github.com/windtf/wireproxy
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
            assetPicker: WireGuardAssetResolver.pickStandard,
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

/// ═══════════════════════════════════════════════════════════════
///  🆕 WireGuardAwgUpdater — آپدیت core برای wireproxy-awg.
///
///  مخزن: https://github.com/artem-russkikh/wireproxy-awg
/// ═══════════════════════════════════════════════════════════════
class WireGuardAwgUpdater {
  final GithubReleaseUpdater _updater;

  WireGuardAwgUpdater({
    required CoreUpdateNetwork network,
    required CoreUpdatePendingManager pending,
    required CoreUpdateProcessUtils processUtils,
    void Function(String)? log,
  }) : _updater = GithubReleaseUpdater(
          spec: GithubCoreSpec(
            coreId: 'wireguard-awg',
            displayName: 'WireGuard Amnezia (wireproxy-awg)',
            owner: 'artem-russkikh',
            repo: 'wireproxy-awg',
            binaryBaseName: 'wireproxy-awg',
            fallbackPattern: 'wireproxy',
            destPathResolver: () =>
                AppDataService.getBinaryPathForWrite('wireproxy-awg'),
            tempPrefix: 'mischiefpingu_wireproxy_awg_',
            defaultDownloadSize: 4000000,
            assetPicker: WireGuardAssetResolver.pickAwg,
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
