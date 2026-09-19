library;

import 'network/core_update_http.dart';
import 'network/core_update_arch.dart';
import 'network/core_update_downloader.dart';

/// ═══════════════════════════════════════════════════════════════
///  Facade — API عمومی CoreUpdateNetwork حفظ می‌شود،
///  پیاده‌سازی به زیرسرویس‌های تخصصی delegate شده است.
/// ═══════════════════════════════════════════════════════════════
class CoreUpdateNetwork {
  final void Function(String)? log;

  late final CoreUpdateHttp _http = CoreUpdateHttp(log: log);
  late final CoreUpdateDownloader _downloader = CoreUpdateDownloader(log: log);

  CoreUpdateNetwork({this.log});

  Future<void> ensureCurl() => _http.ensureCurl();
  void logRoute(String? proxy) => _http.logRoute(proxy);
  Future<Map<String, dynamic>> getJson(String url, String? proxy) =>
      _http.getJson(url, proxy);
  Future<String> getText(
    String url,
    String? proxy, {
    String accept = '*/*',
    String userAgent = 'mischiefpingu-CoreUpdater/1.0',
  }) =>
      _http.getText(url, proxy, accept: accept, userAgent: userAgent);
  Future<({int status, int length})?> headRequest(
    String url,
    String? proxy, {
    int timeoutSec = 15,
  }) =>
      _http.headRequest(url, proxy, timeoutSec: timeoutSec);

  Future<String> detectArch() => CoreUpdateArch.detect();

  Future<void> download(
    String url,
    String dest, {
    String? proxy,
    void Function(int percent)? onProgress,
    bool Function()? onCancelCheck,
    int base = 5,
    int span = 70,
    int? totalHint,
  }) =>
      _downloader.download(
        url,
        dest,
        proxy: proxy,
        onProgress: onProgress,
        onCancelCheck: onCancelCheck,
        base: base,
        span: span,
        totalHint: totalHint,
      );
}
