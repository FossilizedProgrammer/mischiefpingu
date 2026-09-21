library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../services/health/tunnel_health_models.dart';
import 'tunnel_probe_result.dart';

/// ═══════════════════════════════════════════════════════════════
///  TunnelHealthTester — probe سریع روی SOCKS یک تونل.
///
///  فقط SOCKS5 greeting + CONNECT تست می‌شود.
///
///  اگر SOCKS greeting + CONNECT موفق شد، تونل زنده است.
/// ═══════════════════════════════════════════════════════════════
class TunnelHealthTester {
  static const String _probeHost = 'www.cloudflare.com';
  static const int _probePort = 443;

  static const Duration _socksConnectTimeout = Duration(seconds: 5);
  static const Duration _socksTotalTimeout = Duration(seconds: 12);

  const TunnelHealthTester();

  Future<TunnelProbeResult> probe({
    required TunnelKind kind,
    required int socksPort,
  }) async {
    final sw = Stopwatch()..start();
    Socket? sock;
    StreamIterator<List<int>>? iter;

    try {
      // ─── مرحله 1: TCP connect ───
      try {
        sock = await Socket.connect(
          '127.0.0.1',
          socksPort,
          timeout: _socksConnectTimeout,
        );
        sock.setOption(SocketOption.tcpNoDelay, true);
      } catch (e) {
        sw.stop();
        debugPrint('[TunnelHealthTester] TCP connect failed: $e');
        return TunnelProbeResult.failure(error: 'TCP connect failed: $e');
      }

      iter = StreamIterator<List<int>>(sock.timeout(_socksTotalTimeout));

      // ─── مرحله 2: SOCKS5 greeting ───
      sock.add([0x05, 0x01, 0x00]);
      await sock.flush();

      if (!await iter.moveNext()) {
        sw.stop();
        debugPrint('[TunnelHealthTester] greeting timeout');
        return TunnelProbeResult.failure(error: 'greeting timeout');
      }
      final greet = iter.current;
      if (greet.isEmpty || greet[0] != 0x05) {
        sw.stop();
        debugPrint('[TunnelHealthTester] greeting invalid');
        return TunnelProbeResult.failure(error: 'greeting invalid');
      }
      if (greet.length >= 2 && greet[1] != 0x00) {
        sw.stop();
        debugPrint('[TunnelHealthTester] auth rejected');
        return TunnelProbeResult.failure(error: 'auth rejected');
      }

      // ─── مرحله 3: SOCKS5 CONNECT ───
      final hostBytes = _probeHost.codeUnits;
      sock.add(<int>[
        0x05,
        0x01,
        0x00,
        0x03,
        hostBytes.length,
        ...hostBytes,
        (_probePort >> 8) & 0xFF,
        _probePort & 0xFF,
      ]);
      await sock.flush();

      if (!await iter.moveNext()) {
        sw.stop();
        debugPrint('[TunnelHealthTester] CONNECT timeout');
        return TunnelProbeResult.failure(error: 'CONNECT timeout');
      }
      final connResp = iter.current;
      if (connResp.length < 2 || connResp[1] != 0x00) {
        sw.stop();
        final code = connResp.length >= 2 ? connResp[1] : -1;
        debugPrint('[TunnelHealthTester] CONNECT failed (code=$code)');
        return TunnelProbeResult.failure(error: 'CONNECT failed (code=$code)');
      }

      // ═══════════════════════════════════════════════════════════
      //  ✅ تونل زنده است — SOCKS greeting + CONNECT موفق
      // ═══════════════════════════════════════════════════════════
      sw.stop();
      debugPrint('[TunnelHealthTester] SUCCESS in ${sw.elapsedMilliseconds}ms');
      return TunnelProbeResult.success(latencyMs: sw.elapsedMilliseconds);
    } catch (e) {
      sw.stop();
      debugPrint('[TunnelHealthTester] exception: $e');
      return TunnelProbeResult.failure(error: '$e');
    } finally {
      try {
        await iter?.cancel();
      } catch (_) {}
      try {
        sock?.destroy();
      } catch (_) {}
    }
  }
}
