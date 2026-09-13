// lib/services/core_update_service.dart
library;

import 'core_update/core_update_aether.dart';
import 'core_update/core_update_network.dart';
import 'core_update/core_update_pending.dart';
import 'core_update/core_update_process_utils.dart';
import 'core_update/core_update_psiphon.dart';
import 'core_update/core_update_sstp.dart'; // ✅ فایل جدید
import 'core_update/core_update_sunandlion.dart'; // ✅ فایل جدید
import 'core_update/core_update_tor.dart';
import 'core_update/core_update_version_checker.dart';
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
  late final CoreUpdatePendingManager _pending =
      CoreUpdatePendingManager(log: log, processUtils: _process);
  late final CoreUpdateVersionChecker _versions =
      CoreUpdateVersionChecker(log: log);

  late final AetherUpdater _aether = AetherUpdater(
    network: _network,
    pending: _pending,
    processUtils: _process,
    log: log,
  );
  late final TorUpdater _tor = TorUpdater(
    network: _network,
    pending: _pending,
    processUtils: _process,
    log: log,
  );
  late final PsiphonUpdater _psiphon = PsiphonUpdater(
    network: _network,
    pending: _pending,
    processUtils: _process,
    log: log,
  );
  late final SunAndLionUpdater _sunAndLion = SunAndLionUpdater( // ✅ جدید
    network: _network,
    pending: _pending,
    processUtils: _process,
    log: log,
  );
  late final SstpProxyUpdater _sstp = SstpProxyUpdater( // ✅ جدید
    network: _network,
    pending: _pending,
    processUtils: _process,
    log: log,
  );

  static bool isMissingVersion(String v) => CoreUpdateUtils.isMissingVersion(v);

  // ═══════════════════════════════════════════
  //  Public API
  // ═══════════════════════════════════════════

  Future<void> applyPendingUpdates() => _pending.applyAll();

  Future<String> getInstalledVersion(String coreId, {String psiphonRev = ''}) =>
      _versions.getInstalledVersion(coreId, psiphonRev: psiphonRev);

  Future<CoreUpdateInfo> checkForUpdate(
    String coreId, {
    String? proxy,
    String psiphonRev = '',
    String psiphonBinSha = '',
  }) async {
    final installed = await _versions.getInstalledVersion(
      coreId,
      psiphonRev: psiphonRev,
    );
    switch (coreId) {
      case 'aether':
        return _aether.check(proxy, installed: installed);
      case 'tor':
        return _tor.check(proxy, installed: installed);
      case 'psiphon':
        return _psiphon.check(
          proxy,
          installed: installed,
          psiphonBinSha: psiphonBinSha,
        );
      case 'sunandlion': // ✅ استفاده از آپدیت‌کننده جدید
        return _sunAndLion.check(proxy, installed: installed);
      case 'sstp': // ✅ استفاده از آپدیت‌کننده جدید
        return _sstp.check(proxy, installed: installed);
      default:
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
  }

  Future<bool> updateCore(
    String coreId, {
    void Function(int percent)? onProgress,
    String? proxy,
    String psiphonRev = '',
    String psiphonBinSha = '',
    bool Function()? onCancelCheck,
  }) async {
    final installed = await _versions.getInstalledVersion(
      coreId,
      psiphonRev: psiphonRev,
    );
    switch (coreId) {
      case 'aether':
        final info = await _aether.check(proxy, installed: installed);
        return _aether.update(
          info,
          installed: installed,
          proxy: proxy,
          onProgress: onProgress,
          onCancelCheck: onCancelCheck,
        );
      case 'tor':
        return _tor.update(
          installed: installed,
          proxy: proxy,
          onProgress: onProgress,
          onCancelCheck: onCancelCheck,
        );
      case 'psiphon':
        final info = await _psiphon.check(
          proxy,
          installed: installed,
          psiphonBinSha: psiphonBinSha,
        );
        return _psiphon.update(
          info,
          installed: installed,
          proxy: proxy,
          psiphonBinSha: psiphonBinSha,
          onProgress: onProgress,
          onCancelCheck: onCancelCheck,
        );
      case 'sunandlion': // ✅ استفاده از آپدیت‌کننده جدید
        final info = await _sunAndLion.check(proxy, installed: installed);
        return _sunAndLion.update(
          info,
          installed: installed,
          proxy: proxy,
          onProgress: onProgress,
          onCancelCheck: onCancelCheck,
        );
      case 'sstp': // ✅ استفاده از آپدیت‌کننده جدید
        final info = await _sstp.check(proxy, installed: installed);
        return _sstp.update(
          info,
          installed: installed,
          proxy: proxy,
          onProgress: onProgress,
          onCancelCheck: onCancelCheck,
        );
      default:
        throw UnsupportedError("Updating core '$coreId' is not supported.");
    }
  }
}
