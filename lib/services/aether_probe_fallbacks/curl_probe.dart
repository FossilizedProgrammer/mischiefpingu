library;

import 'dart:io';

/// probe با curl --socks5-hostname.
class CurlProbe {
  const CurlProbe();

  Future<bool> run(int port) async {
    try {
      final r = await Process.run('curl', [
        '--socks5-hostname',
        '127.0.0.1:$port',
        '--connect-timeout',
        '5',
        '--max-time',
        '8',
        '-s',
        '-o',
        '/dev/null',
        '-w',
        '%{http_code}',
        'https://1.1.1.1/cdn-cgi/trace',
      ]).timeout(const Duration(seconds: 11));
      return r.exitCode == 0 && r.stdout.toString().trim().startsWith('2');
    } catch (_) {
      return false;
    }
  }
}
