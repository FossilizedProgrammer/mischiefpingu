library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// probe واقعی data-plane از طریق SOCKS Aether.
class DataPlaneProbe {
  const DataPlaneProbe();

  Future<bool> run(int port) async {
    Socket? sock;
    try {
      sock = await Socket.connect(
        '127.0.0.1',
        port,
        timeout: const Duration(seconds: 3),
      );

      sock.add([0x05, 0x01, 0x00]);
      await sock.flush();
      final greet = await sock.timeout(const Duration(seconds: 3)).first;
      if (greet.isEmpty || greet[0] != 0x05) return false;
      if (greet.length >= 2 && greet[1] != 0x00) return false;

      sock.add([0x05, 0x01, 0x00, 0x01, 1, 1, 1, 1, 0x00, 0x50]);
      await sock.flush();
      final conn = await sock.timeout(const Duration(seconds: 3)).first;
      if (conn.length < 2 || conn[1] != 0x00) return false;

      sock.add(
        utf8.encode(
          'GET /cdn-cgi/trace HTTP/1.0\r\n'
          'Host: 1.1.1.1\r\n'
          'User-Agent: Mozilla/5.0\r\n'
          'Connection: close\r\n'
          '\r\n',
        ),
      );
      await sock.flush();

      final buffer = <int>[];
      await for (final chunk in sock.timeout(const Duration(seconds: 6))) {
        buffer.addAll(chunk);
        if (buffer.length >= 16) break;
        if (buffer.length >= 12) break;
      }

      if (buffer.isEmpty) return false;

      final head = String.fromCharCodes(buffer.take(20));
      if (!head.startsWith('HTTP/')) return false;

      return head.contains(' 200 ') ||
          head.contains(' 204 ') ||
          head.contains(' 301 ') ||
          head.contains(' 302 ') ||
          head.contains(' 304 ');
    } catch (_) {
      return false;
    } finally {
      try {
        sock?.destroy();
      } catch (_) {}
    }
  }
}
