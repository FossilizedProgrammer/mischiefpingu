library;

import 'dart:io';
import '../models/bridge_line.dart';

class BridgeScanResult {
  final BridgeLine bridge;
  final bool isReachable;
  final int latencyMs;
  final String? error;

  BridgeScanResult({
    required this.bridge,
    required this.isReachable,
    required this.latencyMs,
    this.error,
  });
}

class BridgeReachabilityChecker {
  Future<BridgeScanResult> check(BridgeLine bridge,
      {Duration timeout = const Duration(seconds: 5)}) async {
    final sw = Stopwatch()..start();
    final host = bridge.targetHost;
    final port = bridge.targetPort;

    if (host == null || host.isEmpty) {
      return BridgeScanResult(
          bridge: bridge,
          isReachable: false,
          latencyMs: 0,
          error: 'No target host');
    }

    Socket? sock;
    try {
      sock = await Socket.connect(host, port, timeout: timeout);

      // برای ترنسپورت‌های fronted (مثل snowflake/meek/conjure) که روی پورت 443 هستند،
      // یک handshake ساده TLS انجام می‌دهیم تا از مسدود نبودن دامنه مطمئن شویم.
      if (port == 443) {
        try {
          final secure = await SecureSocket.secure(
            sock,
            host: host,
            onBadCertificate: (_) => true,
          );
          secure.close();
        } catch (_) {
          // اگر TLS شکست خورد اما TCP موفق بود، همچنان به عنوان "قابل دسترسی" در نظر گرفته می‌شود.
        }
      }

      sock.destroy();
      sw.stop();
      return BridgeScanResult(
        bridge: bridge,
        isReachable: true,
        latencyMs: sw.elapsedMilliseconds,
      );
    } catch (e) {
      sw.stop();
      try {
        sock?.destroy();
      } catch (_) {}
      return BridgeScanResult(
        bridge: bridge,
        isReachable: false,
        latencyMs: sw.elapsedMilliseconds,
        error: e.toString(),
      );
    }
  }
}
