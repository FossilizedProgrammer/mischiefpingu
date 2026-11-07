library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

class VpngateFetcher {
  final void Function(String message, {String source}) log;
  VpngateFetcher({required this.log});

  static const String _ua =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36';

  Future<String?> fetch(String url, {String? proxy}) async {
    if (proxy != null && proxy.isNotEmpty) {
      return _fetchViaCurl(proxy, url);
    }
    return _fetchViaHttpClient(url);
  }

  Future<String?> _fetchViaHttpClient(String url) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 25);
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set('User-Agent', _ua);
      req.headers.set('Accept', 'text/html,application/xhtml+xml');
      req.headers.set('Accept-Language', 'en-US,en;q=0.9');
      final res = await req.close().timeout(const Duration(seconds: 40));
      if (res.statusCode != 200) {
        log('✗ HTTP ${res.statusCode}', source: 'Vpngate');
        return null;
      }
      return await res.transform(utf8.decoder).join();
    } catch (e) {
      log('✗ fetch failed: $e', source: 'Vpngate');
      return null;
    } finally {
      client.close();
    }
  }

  Future<String?> _fetchViaCurl(String proxy, String url) async {
    try {
      final r = await Process.run('curl', [
        '-sSL',
        '--fail',
        '--max-time',
        '60',
        '--socks5-hostname',
        proxy,
        '-H',
        'User-Agent: $_ua',
        url,
      ]).timeout(const Duration(seconds: 70));

      if (r.exitCode != 0) {
        log('✗ curl failed: ${(r.stderr as String).trim()}', source: 'Vpngate');
        return null;
      }
      return r.stdout as String;
    } catch (e) {
      log('✗ curl error: $e', source: 'Vpngate');
      return null;
    }
  }
}
