// lib/services/core_update/core_update_sstp.dart
library;

import '../app_data_service.dart';
import '../core_update_models.dart';
import 'core_update_network.dart';
import 'core_update_pending.dart';
import 'core_update_process_utils.dart';
import 'shared/github_release_updater.dart';

/// ═══════════════════════════════════════════════════════════════
///  SSTP Proxy Updater
///  مخزن: https://github.com/FossilizedProgrammer/sstp-proxy
///
///  این فایل حالا فقط spec را تعریف می‌کند و منطق را به
///  GithubReleaseUpdater delegate می‌دهد.
/// ═══════════════════════════════════════════════════════════════
class SstpProxyUpdater {
  final GithubReleaseUpdater _updater;

  SstpProxyUpdater({
    required CoreUpdateNetwork network,
    required CoreUpdatePendingManager pending,
    required CoreUpdateProcessUtils processUtils,
    void Function(String)? log,
  }) : _updater = GithubReleaseUpdater(
          spec: GithubCoreSpec(
            coreId: 'sstp',
            displayName: 'SSTP Proxy',
            owner: 'FossilizedProgrammer',
            repo: 'sstp-proxy',
            binaryBaseName: 'sstp-proxy',
            fallbackPattern: 'sstp',
            destPathResolver: AppDataService.getSstpBinaryPath,
            tempPrefix: 'mischiefpingu_sstp_',
            defaultDownloadSize: 8000000,
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
