import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// دانلود فایل با پشتیبانی از proxy و progress.
class CoreUpdateDownloader {
  final void Function(String)? log;
  CoreUpdateDownloader({this.log});

  void _log(String m) => log?.call(m);

  bool get _isWin => Platform.isWindows;

  Future<void> ensureCurl() async {
    try {
      final cmd = _isWin ? 'where' : 'which';
      final r = await Process.run(cmd, ['curl']);
      if (r.exitCode == 0) return;
    } catch (_) {}
    throw StateError(
      'curl not found — install curl to download via proxy (or use Direct).',
    );
  }

  /// دانلود فایل. اگر proxy داده شود، از curl استفاده می‌کند.
  Future<void> download(
    String url,
    String dest, {
    String? proxy,
    void Function(int percent)? onProgress,
    bool Function()? onCancelCheck,
    int base = 5,
    int span = 70,
    int? totalHint,
  }) async {
    if (proxy != null && proxy.isNotEmpty) {
      await ensureCurl();
      _log('→ Fetching ${url.split('/').last} via proxy $proxy …');
      final errBuf = StringBuffer();
      final proc = await Process.start('curl', [
        '-sSL',
        '--fail',
        '--max-time',
        '900',
        '--socks5-hostname',
        proxy,
        '-o',
        dest,
        url,
      ]);
      proc.stderr.transform(utf8.decoder).listen(errBuf.write);
      var exited = false;
      proc.exitCode.then((_) => exited = true);
      while (!exited) {
        if (onCancelCheck?.call() ?? false) {
          proc.kill(ProcessSignal.sigterm);
          throw StateError('Download cancelled by user');
        }
        await Future.delayed(const Duration(milliseconds: 500));
        if (totalHint != null && totalHint > 0) {
          try {
            final size = await File(dest).length();
            onProgress?.call(base + (size * span ~/ totalHint).clamp(0, span));
          } catch (_) {}
        }
      }
      final code = await proc.exitCode;
      if (code != 0) {
        throw HttpException(
          'curl download failed (code $code): ${errBuf.toString().trim()}',
        );
      }
      try {
        final size = await File(dest).length();
        if (size == 0) throw StateError('Downloaded file is empty.');
      } catch (e) {
        throw StateError('Download verification failed: $e');
      }
      return;
    }
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set('User-Agent', 'mischiefpingu-CoreUpdater/1.0');
      final res = await req.close();
      if (res.statusCode != 200) {
        throw HttpException('HTTP ${res.statusCode} downloading $url');
      }
      final total =
          res.contentLength > 0 ? res.contentLength : (totalHint ?? 0);
      final file = File(dest).openWrite();
      var done = 0;
      await for (final chunk in res) {
        if (onCancelCheck?.call() ?? false) {
          throw StateError('Download cancelled by user');
        }
        file.add(chunk);
        done += chunk.length;
        if (total > 0) {
          onProgress?.call(base + (done * span ~/ total).clamp(0, span));
        }
      }
      await file.close();
      if (done == 0) throw StateError('Downloaded file is empty.');
    } finally {
      client.close();
    }
  }
}
