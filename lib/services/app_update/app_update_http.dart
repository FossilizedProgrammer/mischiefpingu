library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// ═══════════════════════════════════════════════════════════════
///  لایهٔ HTTP برای AppUpdateService.
/// ═══════════════════════════════════════════════════════════════
class AppUpdateHttp {
  final void Function(String message, {String source}) log;

  const AppUpdateHttp({required this.log});

  static const String userAgent = 'mischiefpingu-AppUpdater/1.0';

  Future<Map<String, dynamic>> getJson(String url, String? proxy) async {
    final text = await getText(url, proxy);
    return jsonDecode(text) as Map<String, dynamic>;
  }

  Future<String> getText(String url, String? proxy) async {
    if (proxy != null && proxy.isNotEmpty) {
      final r = await Process.run('curl', [
        '-sSL',
        '--fail',
        '--max-time',
        '60',
        '--socks5-hostname',
        proxy,
        '-H',
        'User-Agent: $userAgent',
        '-H',
        'Accept: application/vnd.github+json',
        url,
      ]).timeout(const Duration(seconds: 90));
      if (r.exitCode != 0) {
        throw HttpException(
          'curl failed for $url: ${(r.stderr as String).trim()}',
        );
      }
      return r.stdout as String;
    }

    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set('User-Agent', userAgent);
      req.headers.set('Accept', 'application/vnd.github+json');
      final res = await req.close().timeout(const Duration(seconds: 30));
      if (res.statusCode != 200) {
        throw HttpException('HTTP ${res.statusCode} for $url');
      }
      return await res.transform(utf8.decoder).join();
    } finally {
      client.close();
    }
  }
}
