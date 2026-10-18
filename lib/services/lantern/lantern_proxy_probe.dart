// lib/services/lantern/lantern_proxy_probe.dart
//
// بررسی دسترس‌پذیری یک سرور از «مسیر پروکسی»: یک اتصال CONNECT واقعی
// (SOCKS5 یا HTTP/HTTPS) به آدرس سرور می‌زند و موفقیت/شکست را برمی‌گرداند.
//
// این مکمل بررسی خود موتور است: وقتی کاربر آپ‌استریمی انتخاب کرده، درست‌ترین
// آزمون همان عبور از پروکسی است، نه تست TCP مستقیم (که وقتی IP سرورها بلاک
// است، همه را غیرقابل‌دسترس نشان می‌دهد).

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// بررسی سادهٔ دسترسی از طریق پروکسی.
class LanternProxyProbe {
  LanternProxyProbe._();

  /// آیا [target] (`host:port`) از طریق [proxyUrl] قابل‌دسترس است؟
  ///
  /// پشتیبانی از `socks5://host:port`, `socks5h://host:port`,
  /// `http://host:port` و `https://host:port`، همراه با نام کاربری/گذرواژه.
  static Future<bool> reachableThrough(
    String proxyUrl,
    String target, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final hp = _splitHostPort(target);
    if (hp == null) return false;
    final u = Uri.tryParse(proxyUrl);
    if (u == null || u.host.isEmpty || u.port <= 0) return false;

    _Conn? conn;
    try {
      switch (u.scheme.toLowerCase()) {
        case 'socks5':
        case 'socks5h':
          conn = await _connect(u, timeout);
          return await _socks5(conn, u, hp.$1, hp.$2, timeout);
        case 'http':
        case 'https':
          conn = await _connect(u, timeout);
          return await _httpConnect(conn, u, hp.$1, hp.$2, timeout);
        default:
          return false;
      }
    } catch (_) {
      return false;
    } finally {
      conn?.destroy();
    }
  }

  static Future<_Conn> _connect(Uri proxy, Duration timeout) async {
    if (proxy.scheme.toLowerCase() == 'https') {
      final s = await SecureSocket.connect(
        proxy.host,
        proxy.port,
        timeout: timeout,
      );
      return _Conn(s);
    }
    final s = await Socket.connect(proxy.host, proxy.port, timeout: timeout);
    s.setOption(SocketOption.tcpNoDelay, true);
    return _Conn(s);
  }

  static Future<bool> _socks5(
    _Conn conn,
    Uri proxy,
    String host,
    int port,
    Duration timeout,
  ) async {
    final hasCreds = proxy.userInfo.isNotEmpty;
    final methods = hasCreds ? [0x00, 0x02] : [0x00];
    conn.write([0x05, methods.length, ...methods]);
    await conn.flush();

    final greet = await conn.readExact(2, timeout);
    if (greet[0] != 0x05) return false;
    if (greet[1] == 0x02) {
      final parts = proxy.userInfo.split(':');
      final user = utf8.encode(Uri.decodeComponent(parts[0]));
      final pass = utf8.encode(
        Uri.decodeComponent(parts.length > 1 ? parts[1] : ''),
      );
      conn.write([0x01, user.length, ...user, pass.length, ...pass]);
      await conn.flush();
      final auth = await conn.readExact(2, timeout);
      if (auth[1] != 0x00) return false;
    } else if (greet[1] != 0x00) {
      return false;
    }

    final hb = utf8.encode(host);
    conn.write(
      [0x05, 0x01, 0x00, 0x03, hb.length, ...hb, (port >> 8) & 0xff, port & 0xff],
    );
    await conn.flush();

    final head = await conn.readExact(4, timeout);
    if (head[1] != 0x00) return false;
    // Address type of the bound address; consume it fully.
    switch (head[3]) {
      case 0x01:
        await conn.readExact(4 + 2, timeout);
        break;
      case 0x03:
        final l = await conn.readExact(1, timeout);
        await conn.readExact(l[0] + 2, timeout);
        break;
      case 0x04:
        await conn.readExact(16 + 2, timeout);
        break;
      default:
        return false;
    }
    return true;
  }

  static Future<bool> _httpConnect(
    _Conn conn,
    Uri proxy,
    String host,
    int port,
    Duration timeout,
  ) async {
    final target = '$host:$port';
    final b = StringBuffer()
      ..write('CONNECT $target HTTP/1.1\r\n')
      ..write('Host: $target\r\n');
    if (proxy.userInfo.isNotEmpty) {
      final cred = base64.encode(utf8.encode(proxy.userInfo));
      b.write('Proxy-Authorization: Basic $cred\r\n');
    }
    b.write('\r\n');
    conn.write(utf8.encode(b.toString()));
    await conn.flush();

    final statusLine = await conn.readLine(timeout);
    final parts = statusLine.split(' ');
    if (parts.length < 2) return false;
    final code = int.tryParse(parts[1]);
    return code != null && code >= 200 && code < 300;
  }

  static (String, int)? _splitHostPort(String addr) {
    final i = addr.lastIndexOf(':');
    if (i <= 0) return null;
    final host = addr.substring(0, i);
    final port = int.tryParse(addr.substring(i + 1));
    if (host.isEmpty || port == null || port <= 0) return null;
    return (host, port);
  }
}

/// پوشش بافرشدهٔ سوکت برای خواندن دقیق بایت‌ها/خطوط با مهلت.
class _Conn {
  _Conn(this._socket);

  final Socket _socket;
  late final StreamIterator<List<int>> _it = StreamIterator(_socket);
  final List<int> _buf = [];

  void write(List<int> bytes) => _socket.add(bytes);

  Future<void> flush() => _socket.flush();

  Future<List<int>> readExact(int n, Duration timeout) async {
    while (_buf.length < n) {
      await _fill(timeout);
    }
    final out = _buf.sublist(0, n);
    _buf.removeRange(0, n);
    return out;
  }

  Future<String> readLine(Duration timeout) async {
    while (true) {
      final idx = _indexOfCrlf(_buf);
      if (idx >= 0) {
        final line = utf8.decode(_buf.sublist(0, idx), allowMalformed: true);
        _buf.removeRange(0, idx + 2);
        return line;
      }
      await _fill(timeout);
    }
  }

  Future<void> _fill(Duration timeout) async {
    final more = await _it.moveNext().timeout(timeout);
    if (!more) throw const SocketException('connection closed by proxy');
    _buf.addAll(_it.current);
  }

  void destroy() => _socket.destroy();

  static int _indexOfCrlf(List<int> b) {
    for (var i = 0; i + 1 < b.length; i++) {
      if (b[i] == 13 && b[i + 1] == 10) return i;
    }
    return -1;
  }
}
