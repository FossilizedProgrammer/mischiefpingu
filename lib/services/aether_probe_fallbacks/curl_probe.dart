library;

import 'dart:io';

/// probe با curl --socks5-hostname.
///
/// ⚠️ این نسخه دقیقاً همون چیزی رو اجرا می‌کنه که user با
/// دست تست کرد و جواب داد:
///
///   curl --socks5-hostname 127.0.0.1:1819 \
///        https://www.cloudflare.com/cdn-cgi/trace
///
///  کلید: --socks5-hostname یعنی DNS از طریق SOCKS resolve می‌شه
///  (نه توسط خود curl). این دقیقاً کاریست که مرورگر هم می‌کنه.
class CurlProbe {
  const CurlProbe();

  Future<bool> run(int port) async {
    try {
      final r = await Process.run('curl', [
        '--socks5-hostname',
        '127.0.0.1:$port',
        '--connect-timeout',
        '8',
        '--max-time',
        '15',
        '-s',
        '-o',
        '/dev/null',
        '-w',
        '%{http_code}',
        'https://www.cloudflare.com/cdn-cgi/trace',
      ]).timeout(const Duration(seconds: 20));

      if (r.exitCode != 0) return false;

      final code = r.stdout.toString().trim();
      if (code.isEmpty || code == '000') return false;

      final status = int.tryParse(code);
      if (status == null) return false;

      // هر status بین 200 و 499 = تونل زنده
      return status >= 200 && status < 500;
    } catch (_) {
      return false;
    }
  }
}
