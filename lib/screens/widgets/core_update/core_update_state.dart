import 'package:flutter/foundation.dart';

import '../../../services/core_update_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  State قابل استفاده برای هر core (aether / tor / psiphon)
///  منطق مشترک check/update را یک‌جا جمع می‌کند.
/// ═══════════════════════════════════════════════════════════════
class CoreUpdateEntryState extends ChangeNotifier {
  final String coreId;
  final CoreUpdateService Function() serviceFactory;
  final String Function() proxyResolver;

  String installed = '…';
  String latest = '…';
  String downloadUrl = '';
  String checkMessage = '';
  bool checking = false;
  bool updating = false;
  int progress = 0;

  CoreUpdateEntryState({
    required this.coreId,
    required this.serviceFactory,
    required this.proxyResolver,
  });

  bool get missing => CoreUpdateService.isMissingVersion(installed);

  Future<void> refreshInstalled({String psiphonRev = ''}) async {
    try {
      final svc = serviceFactory();
      installed = await svc.getInstalledVersion(coreId, psiphonRev: psiphonRev);
      if (latest == '…') latest = installed;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> check({
    required Future<CoreUpdateInfo> Function(String? proxy) runCheck,
  }) async {
    checking = true;
    checkMessage = '';
    notifyListeners();
    try {
      final proxy = proxyResolver();
      final info = await runCheck(proxy);
      installed = info.installedVersion;
      latest = info.latestVersion;
      downloadUrl = info.downloadUrl;
      checkMessage = info.hasUpdate
          ? '$coreId update available: ${info.installedVersion} → ${info.latestVersion}'
          : '$coreId is up to date (${info.installedVersion})';
    } catch (e) {
      checkMessage = '$coreId check failed: $e';
    } finally {
      checking = false;
      notifyListeners();
    }
  }

  Future<void> update({
    required Future<bool> Function(
      String? proxy,
      void Function(int percent) onProgress,
    ) runUpdate,
    required Future<void> Function() afterUpdate,
  }) async {
    if (!missing && latest != '…' && installed == latest) {
      checkMessage = '$coreId is already up to date';
      notifyListeners();
      return;
    }
    updating = true;
    progress = 0;
    checkMessage = '';
    notifyListeners();
    try {
      final proxy = proxyResolver();
      final ok = await runUpdate(proxy, (p) {
        progress = p;
        notifyListeners();
      });
      await afterUpdate();
      checkMessage =
          ok ? '★ $coreId updated successfully' : '$coreId update skipped';
    } catch (e) {
      checkMessage = '$coreId update failed: $e';
    } finally {
      updating = false;
      progress = 0;
      notifyListeners();
    }
  }
}
