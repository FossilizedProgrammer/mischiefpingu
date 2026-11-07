library;

import '../core_update_models.dart';
import 'core_update_network.dart';
import 'core_update_pending.dart';
import 'core_update_process_utils.dart';
import 'psiphon/psiphon_checker.dart';
import 'psiphon/psiphon_installer.dart';

class PsiphonUpdater {
  final PsiphonChecker _checker;
  final PsiphonInstaller _installer;

  PsiphonUpdater({
    required CoreUpdateNetwork network,
    required CoreUpdatePendingManager pending,
    required CoreUpdateProcessUtils processUtils,
    void Function(String)? log,
  })  : _checker = PsiphonChecker(network: network, log: log),
        _installer = PsiphonInstaller(
          network: network,
          pending: pending,
          processUtils: processUtils,
          log: log,
        );

  Future<CoreUpdateInfo> check(
    String? proxy, {
    required String installed,
    required String psiphonBinSha,
  }) =>
      _checker.check(proxy, installed: installed, psiphonBinSha: psiphonBinSha);

  Future<bool> update(
    CoreUpdateInfo info, {
    required String installed,
    String? proxy,
    required String psiphonBinSha,
    void Function(int percent)? onProgress,
    bool Function()? onCancelCheck,
  }) =>
      _installer.update(
        info,
        installed: installed,
        proxy: proxy,
        psiphonBinSha: psiphonBinSha,
        onProgress: onProgress,
        onCancelCheck: onCancelCheck,
      );
}
