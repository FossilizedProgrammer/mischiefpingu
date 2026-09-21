library;

import '../core_update_models.dart';
import 'core_update_network.dart';
import 'core_update_pending.dart';
import 'core_update_process_utils.dart';
import 'tor/tor_checker.dart';
import 'tor/tor_deferred_installer.dart';
import 'tor/tor_installer.dart';

class TorUpdater {
  final TorChecker _checker;
  final TorInstaller _installer;

  TorUpdater({
    required CoreUpdateNetwork network,
    required CoreUpdatePendingManager pending,
    required CoreUpdateProcessUtils processUtils,
    void Function(String)? log,
  }) : _checker = TorChecker(network: network, log: log),
       _installer = TorInstaller(
         network: network,
         processUtils: processUtils,
         deferred: TorDeferredInstaller(pending: pending, log: log),
         log: log,
       );

  Future<CoreUpdateInfo> check(String? proxy, {required String installed}) =>
      _checker.check(proxy, installed: installed);

  Future<bool> update({
    required String installed,
    String? proxy,
    void Function(int percent)? onProgress,
    bool Function()? onCancelCheck,
  }) async {
    final info = await _checker.check(proxy, installed: installed);
    if (info.downloadUrl.isEmpty) {
      throw StateError(
        'Could not locate a stable Tor expert-bundle from torproject.org.',
      );
    }
    return _installer.install(
      installed: installed,
      downloadUrl: info.downloadUrl,
      proxy: proxy,
      onProgress: onProgress,
      onCancelCheck: onCancelCheck,
    );
  }
}
