library;

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/app_provider.dart';
import '../../../services/app_update_service.dart';
import '../../../services/app_version_service.dart';
import '../../../services/process/log_source.dart';

/// ═══════════════════════════════════════════════════════════════
///  مدیریت state برای AppUpdateTile.
///
///  مسئول:
///    • ساخت AppUpdateService
///    • چک کردن بروزرسانی
///    • دانلود با progress
///    • resolve کردن proxy فعال
///
///  ⚠️ نکته مهم (رفع lint use_build_context_synchronously):
///  برای استفاده ایمن از BuildContext بعد از await، همیشه با
///  `if (!context.mounted) return;` چک می‌کنیم. این الگویی هست
///  که analyzer کاملاً می‌شناسه.
/// ═══════════════════════════════════════════════════════════════
class AppUpdateStateManager {
  final VoidCallback onChanged;

  AppUpdateStateManager({required this.onChanged});

  static const String _owner = 'FossilizedProgrammer';
  static const String _repo = 'mischiefpingu';

  AppUpdateService? _service;
  bool serviceReady = false;
  AppUpdateInfo? info;
  bool checking = false;
  bool downloading = false;
  int progress = 0;
  String message = '';
  bool _cancelRequested = false;
  bool _initialized = false;

  void ensureInitialized(BuildContext context) {
    if (_initialized) return;
    _initialized = true;
    // ignore: discarded_futures
    _initService(context);
  }

  Future<void> _initService(BuildContext context) async {
    final app = context.read<AppProvider>();
    final currentVersion = await AppVersionService.getVersion();

    if (!context.mounted) return;

    _service = AppUpdateService(
      log: app.processService.addLog,
      source: AppUpdateSource(
        owner: _owner,
        repo: _repo,
        currentVersion: currentVersion,
      ),
    );
    serviceReady = true;
    onChanged();
    // ignore: discarded_futures
    check(context: context);
  }

  Future<String?> _resolveProxy(BuildContext context) async {
    final app = context.read<AppProvider>();
    final ps = app.processService;

    if (ps.isPsiphonConnected) return '127.0.0.1:${app.settings.socksPort}';
    if (ps.isAetherRunning) return '127.0.0.1:${app.settings.aetherLocalPort}';
    if (ps.isTorConnected) return '127.0.0.1:${app.settings.torSocksPort}';
    if (ps.isSstpConnected) return '127.0.0.1:${app.settings.sstpSocksPort}';
    // ═══════════════════════════════════════════════════════════
    //  ⚠️ اضافه شد: WireGuard
    // ═══════════════════════════════════════════════════════════
    if (ps.isWireGuardConnected) {
      return '127.0.0.1:${app.settings.wireguardSocksPort}';
    }
    return null;
  }

  Future<void> check({required BuildContext context}) async {
    if (checking || !serviceReady || _service == null) return;

    // ⚠️ چک mounted قبل از هر استفاده از context
    if (!context.mounted) return;

    // ─── مقادیر مورد نیاز رو قبل از await بگیر ───
    final l10n = AppLocalizations.of(context);
    final app = context.read<AppProvider>();
    final service = _service!;

    checking = true;
    message = l10n.appUpdateChecking;
    onChanged();

    try {
      final proxy = await _resolveProxy(context);
      if (!context.mounted) return;

      final result = await service.check(proxy: proxy);
      if (!context.mounted) return;

      info = result;
      message = '';
    } catch (e) {
      if (!context.mounted) return;
      message = '${AppLocalizations.of(context).appUpdateFailed}: $e';
    } finally {
      checking = false;
      app.processService.addLog(
        '→ App update: check finished',
        source: LogSource.app,
      );
      onChanged();
    }
  }

  void requestCancel() {
    _cancelRequested = true;
    onChanged();
  }

  Future<void> download({
    required BuildContext context,
    required AppLocalizations l10n,
    required AppProvider app,
    required void Function(String msg, SnackBarAction? action) onSnackBar,
  }) async {
    final infoRef = info;
    if (infoRef == null || !infoRef.hasUpdate) return;

    if (!context.mounted) return;

    String? initialDir;
    try {
      final downloads = await getDownloadsDirectory();
      initialDir = downloads?.path;
    } catch (_) {}

    if (!context.mounted) return;

    final chosenDir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: l10n.appUpdateSaveDialogTitle,
      initialDirectory: initialDir,
    );

    // ⚠️ چک mounted بعد از FilePicker
    if (!context.mounted) return;

    if (chosenDir == null || chosenDir.isEmpty) {
      app.processService.addLog(
        '→ App update: user cancelled folder selection',
        source: LogSource.app,
      );
      return;
    }

    final fileName = infoRef.assetName.isNotEmpty
        ? infoRef.assetName
        : p.basename(Uri.parse(infoRef.downloadUrl).path);
    final savePath = p.join(chosenDir, fileName);

    downloading = true;
    progress = 0;
    _cancelRequested = false;
    message = l10n.appUpdateDownloading;
    onChanged();

    try {
      final proxy = await _resolveProxy(context);
      if (!context.mounted) return;

      await _service!.download(
        info: infoRef,
        savePath: savePath,
        proxy: proxy,
        onProgress: (value) {
          progress = value;
          onChanged();
        },
        onCancelCheck: () => _cancelRequested,
      );

      if (!context.mounted) return;
      message = '${l10n.appUpdateDownloaded}\n$savePath';
      onSnackBar(
        '${l10n.appUpdateDownloaded}: $savePath',
        SnackBarAction(
          label: l10n.appUpdateOpenFolder,
          onPressed: () => _openFolder(chosenDir),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      message = '${l10n.appUpdateFailed}: $e';
    } finally {
      downloading = false;
      onChanged();
    }
  }

  void _openFolder(String path) {
    try {
      if (Platform.isWindows) {
        Process.run('explorer', [path]);
      } else if (Platform.isMacOS) {
        Process.run('open', [path]);
      } else {
        Process.run('xdg-open', [path]);
      }
    } catch (_) {}
  }

  void dispose() {
    // nothing to dispose
  }
}
