library;

import '../core_update_models.dart';
import 'aether/aether_checker.dart';
import 'aether/aether_installer.dart';
import 'core_update_network.dart';
import 'core_update_pending.dart';
import 'core_update_process_utils.dart';

class AetherUpdater {
  final AetherChecker _checker;
  final AetherInstaller _installer;

  AetherUpdater({
    required CoreUpdateNetwork network,
    required CoreUpdatePendingManager pending,
    required CoreUpdateProcessUtils processUtils,
    void Function(String)? log,
  }) : _checker = AetherChecker(network: network, log: log),
       _installer = AetherInstaller(
         network: network,
         pending: pending,
         processUtils: processUtils,
         log: log,
       );

  Future<CoreUpdateInfo> check(String? proxy, {required String installed}) =>
      _checker.check(proxy, installed: installed);

  Future<bool> update(
    CoreUpdateInfo info, {
    required String installed,
    String? proxy,
    void Function(int percent)? onProgress,
    bool Function()? onCancelCheck,
  }) => _installer.update(
    info,
    installed: installed,
    proxy: proxy,
    onProgress: onProgress,
    onCancelCheck: onCancelCheck,
  );
}
