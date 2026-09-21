part of '../packet_loss_prober.dart';

/// ═══════════════════════════════════════════════════════════════
///  probe یک هدف از طریق SOCKS با hostname یا IP.
///
///  ⚠️ نکته: از StreamIterator استفاده می‌کنیم چون Socket
///  یک Stream تک‌مصرف است و چند بار .first یا .listen روی
///  آن خطای "already listened" می‌ده.
/// ═══════════════════════════════════════════════════════════════
extension PacketLossProberTarget on PacketLossProber {
  Future<({bool success, String? error})> probeOneTarget({
    required int socksPort,
    required String host,
    required int port,
    required Duration timeout,
  }) async {
    Socket? sock;
    SecureSocket? secure;
    StreamIterator<List<int>>? iter;

    try {
      // ─── اتصال به SOCKS ───
      sock = await Socket.connect(
        '127.0.0.1',
        socksPort,
        timeout: const Duration(seconds: 4),
      );
      sock.setOption(SocketOption.tcpNoDelay, true);

      iter = StreamIterator<List<int>>(sock.timeout(timeout));

      // ─── SOCKS5 greeting ───
      sock.add([0x05, 0x01, 0x00]);
      await sock.flush();

      if (!await iter.moveNext()) {
        return (success: false, error: 'SOCKS greeting timeout');
      }
      final greet = iter.current;
      if (greet.isEmpty || greet[0] != 0x05 || greet.length < 2) {
        return (success: false, error: 'SOCKS greeting invalid');
      }
      if (greet[1] != 0x00) {
        return (success: false, error: 'SOCKS method rejected');
      }

      // ─── SOCKS5 CONNECT ───
      final isIp = ProbeHelpers.looksLikeIPv4(host);
      if (isIp) {
        final parts = host.split('.').map(int.parse).toList();
        sock.add(<int>[
          0x05,
          0x01,
          0x00,
          0x01,
          parts[0],
          parts[1],
          parts[2],
          parts[3],
          (port >> 8) & 0xFF,
          port & 0xFF,
        ]);
      } else {
        final hostBytes = utf8.encode(host);
        if (hostBytes.length > 255) {
          return (success: false, error: 'hostname too long');
        }
        sock.add(<int>[
          0x05,
          0x01,
          0x00,
          0x03,
          hostBytes.length,
          ...hostBytes,
          (port >> 8) & 0xFF,
          port & 0xFF,
        ]);
      }
      await sock.flush();

      if (!await iter.moveNext()) {
        return (success: false, error: 'SOCKS CONNECT timeout');
      }
      final connResp = iter.current;
      if (connResp.length < 2 || connResp[1] != 0x00) {
        final code = connResp.length >= 2 ? connResp[1] : -1;
        return (success: false, error: 'SOCKS CONNECT failed ($code)');
      }

      // ─── TLS handshake ───
      await iter.cancel();
      iter = null;

      final sniHost = ProbeHelpers.sniFor(host);
      try {
        secure = await SecureSocket.secure(
          sock,
          host: sniHost,
          onBadCertificate: (_) => true,
        ).timeout(timeout);
      } catch (e) {
        return (success: false, error: 'TLS: $e');
      }

      // ─── HTTPS HEAD ───
      secure.write(
        'HEAD / HTTP/1.1\r\n'
        'Host: ${ProbeHelpers.hostHeaderFor(host)}\r\n'
        'User-Agent: Mozilla/5.0\r\n'
        'Connection: close\r\n'
        '\r\n',
      );
      await secure.flush();

      final secureIter = StreamIterator<List<int>>(secure.timeout(timeout));
      final buffer = <int>[];
      try {
        while (await secureIter.moveNext()) {
          buffer.addAll(secureIter.current);
          if (buffer.length >= 20) break;
        }
      } finally {
        await secureIter.cancel();
      }

      if (buffer.isEmpty) {
        return (success: false, error: 'empty response');
      }
      final head = String.fromCharCodes(buffer.take(20));
      if (!head.startsWith('HTTP/')) {
        return (success: false, error: 'non-HTTP response');
      }

      return (success: true, error: null);
    } catch (e) {
      return (success: false, error: '$e');
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
