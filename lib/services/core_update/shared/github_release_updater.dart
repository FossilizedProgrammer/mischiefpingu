library;

import '../../core_update_models.dart';
import '../core_update_network.dart';
import '../core_update_pending.dart';
import '../core_update_process_utils.dart';
import 'github_core_spec.dart';
import 'github_release_checker.dart';
import 'github_release_installer.dart';

export 'github_core_spec.dart' show GithubCoreSpec;

class GithubReleaseUpdater {
  final GithubCoreSpec spec;
  final CoreUpdateNetwork network;
  final CoreUpdatePendingManager pending;
  final CoreUpdateProcessUtils processUtils;
  final void Function(String)? log;

  late final GithubReleaseChecker _checker = GithubReleaseChecker(
    spec: spec,
    network: network,
    log: log,
  );

  late final GithubReleaseInstaller _installer = GithubReleaseInstaller(
    spec: spec,
    network: network,
    pending: pending,
    processUtils: processUtils,
    log: log,
  );

  GithubReleaseUpdater({
    required this.spec,
    required this.network,
    required this.pending,
    required this.processUtils,
    this.log,
  });

  Future<CoreUpdateInfo> check(String? proxy, {required String installed}) =>
      _checker.check(proxy, installed: installed);

  Future<bool> update(
    CoreUpdateInfo info, {
    required String installed,
    String? proxy,
    void Function(int percent)? onProgress,
    bool Function()? onCancelCheck,
  }) =>
      _installer.update(
        info,
        installed: installed,
        proxy: proxy,
        onProgress: onProgress,
        onCancelCheck: onCancelCheck,
      );
}
