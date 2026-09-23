library;

import 'core_update/core_update_aether.dart';
import 'core_update/core_update_network.dart';
import 'core_update/core_update_pending.dart';
import 'core_update/core_update_process_utils.dart';
import 'core_update/core_update_psiphon.dart';
import 'core_update/core_update_sstp.dart';
import 'core_update/core_update_sunandlion.dart';
import 'core_update/core_update_tor.dart';
import 'core_update/core_update_version_checker.dart';
import 'core_update/core_updater_registry.dart';
import 'core_update/wireguard/wireguard_updater.dart';
import 'core_update_models.dart';
import 'core_update_utils.dart';

export 'core_update_models.dart';

/// ═══════════════════════════════════════════════════════════════
///  Facade — API عمومی CoreUpdateService
/// ═══════════════════════════════════════════════════════════════
class CoreUpdateService {
  final void Function(String)? log;
  CoreUpdateService({this.log});

  late final CoreUpdateNetwork _network = CoreUpdateNetwork(log: log);
  late final CoreUpdateProcessUtils _process = CoreUpdateProcessUtils(log: log);
  late final CoreUpdatePendingManager _pending = CoreUpdatePendingManager(
    log: log,
    processUtils: _process,
  );
  late final CoreUpdateVersionChecker _versions = CoreUpdateVersionChecker(
    log: log,
  );

  late final CoreUpdaterRegistry _registry = CoreUpdaterRegistry(
    aether: AetherUpdater(
      network: _network,
      pending: _pending,
      processUtils: _process,
      log: log,
    ),
    tor: TorUpdater(
      network: _network,
      pending: _pending,
      processUtils: _process,
      log: log,
    ),
    psiphon: PsiphonUpdater(
      network: _network,
      pending: _pending,
      processUtils: _process,
      log: log,
    ),
    sunAndLion: SunAndLionUpdater(
      network: _network,
      pending: _pending,
      processUtils: _process,
      log: log,
    ),
    sstp: SstpProxyUpdater(
      network: _network,
      pending: _pending,
      processUtils: _process,
      log: log,
    ),
    wireguard: WireGuardUpdater(
      network: _network,
      pending: _pending,
      processUtils: _process,
      log: log,
    ),
  );

  static bool isMissingVersion(String v) => CoreUpdateUtils.isMissingVersion(v);

  Future<void> applyPendingUpdates() => _pending.applyAll();

  Future<String> getInstalledVersion(String coreId, {String psiphonRev = ''}) =>
      _versions.getInstalledVersion(coreId, psiphonRev: psiphonRev);

  Future<CoreUpdateInfo> checkForUpdate(
    String coreId, {
    String? proxy,
    String psiphonRev = '',
    String psiphonBinSha = '',
  }) async {
    final updater = _registry.byId(coreId);
    if (updater == null) {
      final installed = await _versions.getInstalledVersion(
        coreId,
        psiphonRev: psiphonRev,
      );
      return CoreUpdateInfo(
        coreId: coreId,
        displayName: coreId,
        installedVersion: installed,
        latestVersion: installed,
        hasUpdate: false,
        downloadUrl: '',
        releaseNotes: 'Unknown core.',
        downloadSizeBytes: 0,
      );
    }

    final installed = await _versions.getInstalledVersion(
      coreId,
      psiphonRev: psiphonRev,
    );
    return updater.check(
      proxy,
      installed: installed,
      psiphonBinSha: psiphonBinSha,
    );
  }

  Future<bool> updateCore(
    String coreId, {
    void Function(int percent)? onProgress,
    String? proxy,
    String psiphonRev = '',
    String psiphonBinSha = '',
    bool Function()? onCancelCheck,
  }) async {
    final updater = _registry.byId(coreId);
    if (updater == null) {
      throw UnsupportedError("Updating core '$coreId' is not supported.");
    }

    final installed = await _versions.getInstalledVersion(
      coreId,
      psiphonRev: psiphonRev,
    );
    final info = await updater.check(
      proxy,
      installed: installed,
      psiphonBinSha: psiphonBinSha,
    );
    return updater.update(
      info,
      installed: installed,
      proxy: proxy,
      psiphonBinSha: psiphonBinSha,
      onProgress: onProgress,
      onCancelCheck: onCancelCheck,
    );
  }
}
