library;

import 'dart:async';
import 'dart:io';

import 'app_update/app_update_models.dart';
import 'app_update/app_update_asset_picker.dart';
import 'app_update/app_update_http.dart';
import 'app_update/app_update_version_utils.dart';
import 'core_update/version_parsers.dart';
import 'process/log_source.dart';

export 'app_update/app_update_models.dart' show AppUpdateSource, AppUpdateInfo;

/// ═══════════════════════════════════════════════════════════════
///  AppUpdateService — بررسی و دانلود نسخه جدید خود برنامه
///
///  از GitHub Releases یک repo مشخص استفاده می‌کند.
///  بخش‌های داخلی در `app_update/` جدا شده‌اند:
///    • AppUpdateModels       → مدل‌ها
///    • AppUpdateAssetPicker  → انتخاب asset مناسب
///    • AppUpdateHttp         → درخواست‌های HTTP
///    • AppUpdateVersionUtils → مقایسه نسخه
/// ═══════════════════════════════════════════════════════════════
class AppUpdateService {
  final void Function(String message, {String source}) log;
  final AppUpdateSource source;

  late final AppUpdateHttp _http = AppUpdateHttp(log: log);

  AppUpdateService({required this.log, required this.source});

  Future<AppUpdateInfo> check({String? proxy}) async {
    log('→ App update: checking GitHub releases…', source: LogSource.app);

    final rel = await _http.getJson(
      'https://api.github.com/repos/${source.owner}/${source.repo}/releases/latest',
      proxy,
    );

    final tag = (rel['tag_name'] as String? ?? '').trim();
    final latest = tag.replaceAll(RegExp(r'^[vV]'), '').trim();
    final notes = (rel['body'] as String? ?? '').trim();
    final assets = (rel['assets'] as List?) ?? [];

    if (latest.isEmpty) {
      log('⚠ App update: empty tag_name', source: LogSource.app);
      return AppUpdateInfo.none;
    }

    final picked = AppUpdateAssetPicker.pick(
      assets,
      preferredPattern: source.preferredAssetPattern,
    );

    final hasUpdate = AppUpdateVersionUtils.isNewer(
      source.currentVersion,
      latest,
    );

    log(
      '→ App update: current=${source.currentVersion}, '
      'latest=$latest, hasUpdate=$hasUpdate',
      source: LogSource.app,
    );

    return AppUpdateInfo(
      currentVersion: source.currentVersion,
      latestVersion: latest,
      hasUpdate: hasUpdate,
      downloadUrl: picked.url,
      releaseNotes: notes,
      downloadSizeBytes: picked.size,
      assetName: picked.name,
    );
  }

  /// دانلود فایل آپدیت به مسیر مشخص‌شده توسط کاربر.
  Future<bool> download({
    required AppUpdateInfo info,
    required String savePath,
    String? proxy,
    void Function(int percent)? onProgress,
    bool Function()? onCancelCheck,
  }) async {
    if (info.downloadUrl.isEmpty) {
      throw StateError('App update: download URL is empty');
    }

    log(
      '→ App update: downloading ${info.assetName} → $savePath',
      source: LogSource.app,
    );

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 30);
    try {
      final req = await client.getUrl(Uri.parse(info.downloadUrl));
      req.headers.set('User-Agent', AppUpdateHttp.userAgent);
      final res = await req.close();

      if (res.statusCode != 200) {
        throw HttpException('HTTP ${res.statusCode} downloading app update');
      }

      final total =
          res.contentLength > 0 ? res.contentLength : info.downloadSizeBytes;

      final sink = File(savePath).openWrite();
      var done = 0;

      await for (final chunk in res) {
        if (onCancelCheck?.call() ?? false) {
          await sink.close();
          throw StateError('Download cancelled by user');
        }
        sink.add(chunk);
        done += chunk.length;
        if (total > 0) {
          onProgress?.call(((done * 100) ~/ total).clamp(0, 100));
        }
      }

      await sink.flush();
      await sink.close();

      if (done == 0) {
        throw StateError('Downloaded file is empty.');
      }

      log(
        '★ App update: downloaded ${VersionParsers.formatBytes(done)} → $savePath',
        source: LogSource.app,
      );
      return true;
    } finally {
      client.close();
    }
  }
}
