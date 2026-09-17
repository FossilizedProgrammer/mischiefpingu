import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// لایهٔ HTTP برای درخواست‌های سبک (getJson / getText / headRequest).
class CoreUpdateHttp {
  final void Function(String)? log;
  CoreUpdateHttp({this.log});

  void _log(String m) => log?.call(m);

  bool get _isWin => Platform.isWindows;

  Future<void> ensureCurl() async {
    try {
      final cmd = _isWin ? 'where' : 'which';
      final r = await Process.run(cmd, ['curl']);
      if (r.exitCode == 0) return;
    } catch (_) {}
    throw StateError(
        'curl not found — install curl to download via proxy (or use Direct).');
  }

  void logRoute(String? proxy) {
    if (proxy == null || proxy.isEmpty) {
      _log('→ Direct connection (no proxy)');
    } else {
      _log('→ Downloading via app proxy $proxy');
    }
  }

  Future<Map<String, dynamic>> getJson(String url, String? proxy) async {
    final body =
        await getText(url, proxy, accept: 'application/vnd.github+json');
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<String> getText(
    String url,
    String? proxy, {
    String accept = '*/*',
    String userAgent = 'mischiefpingu-CoreUpdater/1.0',
  }) async {
    if (proxy != null && proxy.isNotEmpty) {
      await ensureCurl();
      final r = await Process.run('curl', [
        '-sSL',
        '--fail',
        '--max-time',
        '90',
        '--socks5-hostname',
        proxy,
        '-H',
        'User-Agent: $userAgent',
        '-H',
        'Accept: $accept',
        url,
      ]).timeout(const Duration(seconds: 120));
      if (r.exitCode != 0) {
        throw HttpException(
            'curl failed for $url (via $proxy): ${(r.stderr as String).trim()}');
      }
      return r.stdout as String;
    }
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set('User-Agent', userAgent);
      req.headers.set('Accept', accept);
      final res = await req.close().timeout(const Duration(seconds: 30));
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode != 200) {
        throw HttpException('HTTP ${res.statusCode} for $url');
      }
      return body;
    } finally {
      client.close();
    }
  }

  Future<({int status, int length})?> headRequest(
    String url,
    String? proxy, {
    int timeoutSec = 15,
  }) async {
    if (proxy != null && proxy.isNotEmpty) {
      await ensureCurl();
      try {
        final r = await Process.run('curl', [
          '-sSL',
          '--fail',
          '--head',
          '--max-time',
          '$timeoutSec',
          '--socks5-hostname',
          proxy,
          '-H',
          'User-Agent: mischiefpingu-CoreUpdater/1.0',
          '-o',
          '/dev/null',
          '-w',
          '%{http_code} %{size_download}',
          url,
        ]).timeout(Duration(seconds: timeoutSec + 5));
        if (r.exitCode != 0) return null;
        final out = (r.stdout as String).trim();
        final parts = out.split(RegExp(r'\s+'));
        final code = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
        return (status: code, length: 0);
      } catch (_) {
        return null;
      }
    }
    try {
      final client = HttpClient();
      final req = await client.headUrl(Uri.parse(url));
      req.headers.set('User-Agent', 'mischiefpingu-CoreUpdater/1.0');
      final res = await req.close().timeout(Duration(seconds: timeoutSec));
      final status = res.statusCode;
      final length = res.contentLength > 0 ? res.contentLength : 0;
      client.close();
      return (status: status, length: length);
    } catch (_) {
      return null;
    }
  }
}
