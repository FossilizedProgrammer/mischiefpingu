// lib/services/core_update/core_update_sunandlion.dart
library;

import '../app_data_service.dart';
import '../core_update_models.dart';
import 'core_update_network.dart';
import 'core_update_pending.dart';
import 'core_update_process_utils.dart';
import 'shared/github_release_updater.dart';

/// ═══════════════════════════════════════════════════════════════
///  SunAndLion Psiphon Core Updater
///  مخزن: https://github.com/FossilizedProgrammer/sunandlion
///
///  این فایل حالا فقط spec را تعریف می‌کند و منطق را به
///  GithubReleaseUpdater delegate می‌دهد.
/// ═══════════════════════════════════════════════════════════════
class SunAndLionUpdater {
  static const String _binaryBaseName = 'psiphon-tunnel-core-sunandlion';

  final GithubReleaseUpdater _updater;

  SunAndLionUpdater({
    required CoreUpdateNetwork network,
    required CoreUpdatePendingManager pending,
    required CoreUpdateProcessUtils processUtils,
    void Function(String)? log,
  }) : _updater = GithubReleaseUpdater(
          spec: GithubCoreSpec(
            coreId: 'sunandlion',
            displayName: 'SunAndLion Psiphon Core',
            owner: 'FossilizedProgrammer',
            repo: 'sunandlion',
            binaryBaseName: _binaryBaseName,
            fallbackPattern: 'sunandlion',
            destPathResolver: () =>
                AppDataService.getBinaryPath(_binaryBaseName),
            tempPrefix: 'mischiefpingu_sunlion_',
            defaultDownloadSize: 12000000,
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
