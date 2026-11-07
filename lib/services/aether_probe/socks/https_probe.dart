part of '../socks_diagnose.dart';

/// ═══════════════════════════════════════════════════════════════
///  probe یک هدف HTTPS از طریق SOCKS.
///
///  جریان (مثل `curl --socks5-hostname`):
///   1. SOCKS5 greeting
///   2. SOCKS5 CONNECT با ATYP=domain
///   3. TLS handshake با SNI = hostname
///   4. HTTPS HEAD
///   5. خواندن پاسخ
///
///  ⚠️ نکته مهم: از StreamIterator استفاده می‌کنیم چون
///  Socket یک Stream تک‌مصرف است و نمی‌شود روی آن چند بار
///  .first یا .listen صدا زد.
/// ═══════════════════════════════════════════════════════════════
extension SocksDiagnoserHttpsProbe on SocksDiagnoser {
  Future<bool> probeOneHttpsTarget(
    int socksPort,
    ({String host, int port}) target,
  ) async {
    Socket? sock;
    SecureSocket? secure;
    StreamIterator<List<int>>? iter;

    try {
      // ─── اتصال به SOCKS محلی ───
      sock = await Socket.connect(
        '127.0.0.1',
        socksPort,
        timeout: const Duration(seconds: 4),
      );

      // یک iterator مشترک برای کل مکالمه
      iter = StreamIterator<List<int>>(
        sock.timeout(SocksDiagnoser.socksReadTimeout),
      );

      // ─── SOCKS5 greeting ───
      sock.add([0x05, 0x01, 0x00]);
      await sock.flush();

      if (!await iter.moveNext()) return false;
      final greet = iter.current;
      if (greet.isEmpty || greet[0] != 0x05) return false;
      if (greet.length >= 2 && greet[1] != 0x00) return false;

      // ─── SOCKS5 CONNECT با hostname (ATYP=0x03) ───
      final hostBytes = utf8.encode(target.host);
      if (hostBytes.length > 255) return false;

      sock.add(<int>[
        0x05,
        0x01,
        0x00,
        0x03,
        hostBytes.length,
        ...hostBytes,
        (target.port >> 8) & 0xFF,
        target.port & 0xFF,
      ]);
      await sock.flush();

      if (!await iter.moveNext()) {
        processService.addLog(
          '→ SOCKS CONNECT ${target.host}:${target.port} '
          'closed before response',
        );
        return false;
      }
      final resp = iter.current;
      if (resp.length < 2 || resp[1] != 0x00) {
        processService.addLog(
          '→ SOCKS CONNECT ${target.host}:${target.port} '
          'refused (code=${resp.length >= 2 ? resp[1] : "?"})',
        );
        return false;
      }

      // ─── TLS handshake با SNI ───
      // بعد از این، iter دیگر استفاده نمی‌شود چون SecureSocket
      // خودش روی raw socket سوار می‌شود.
      await iter.cancel();
      iter = null;

      try {
        secure = await SecureSocket.secure(
          sock,
          host: target.host,
          onBadCertificate: (_) => true,
        ).timeout(SocksDiagnoser.tlsTimeout);
      } catch (e) {
        processService.addLog('✗ TLS handshake ${target.host} failed: $e');
        return false;
      }

      // ─── HTTPS HEAD ───
      secure.write(
        'HEAD / HTTP/1.1\r\n'
        'Host: ${target.host}\r\n'
        'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36\r\n'
        'Accept: */*\r\n'
        'Connection: close\r\n'
        '\r\n',
      );
      await secure.flush();

      // ─── خواندن پاسخ ───
      final buffer = <int>[];
      final secureIter = StreamIterator<List<int>>(
        secure.timeout(SocksDiagnoser.httpReadTimeout),
      );
      try {
        while (await secureIter.moveNext()) {
          buffer.addAll(secureIter.current);
          if (buffer.length >= 20) break;
        }
      } finally {
        await secureIter.cancel();
      }

      if (buffer.isEmpty) {
        processService.addLog('✗ probe ${target.host} — 0 bytes response');
        return false;
      }

      final head = String.fromCharCodes(buffer.take(20));
      if (!head.startsWith('HTTP/')) {
        processService.addLog(
          '✗ probe ${target.host} — non-HTTP response '
          '(${buffer.take(12).toList()})',
        );
        return false;
      }

      final firstLine = head.split("\r\n").first;
      final statusOk = head.contains(' 200 ') ||
          head.contains(' 204 ') ||
          head.contains(' 301 ') ||
          head.contains(' 302 ') ||
          head.contains(' 304 ') ||
          head.contains(' 400 ') ||
          head.contains(' 403 ') ||
          head.contains(' 404 ');

      if (!statusOk) {
        processService.addLog('✗ probe ${target.host} — status $firstLine');
        return false;
      }

      processService.addLog('✓ probe ${target.host} — CONFIRMED ($firstLine)');
      return true;
    } catch (e) {
      processService.addLog('✗ probe ${target.host} — exception: $e');
      return false;
    } finally {
      try {
        await iter?.cancel();
      } catch (_) {}
      try {
        await secure?.close();
      } catch (_) {}
      try {
        sock?.destroy();
      } catch (_) {}
    }
  }
}
