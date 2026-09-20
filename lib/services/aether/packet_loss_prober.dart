library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

part 'packet_loss/probe_target.dart';
part 'packet_loss/probe_helpers.dart';

/// ═══════════════════════════════════════════════════════════════
///  PacketLossProber — اندازه‌گیری عملکرد تونل Aether.
///
///  ⚠️ نسخهٔ v2:
///    • hostname + HTTPS 443 برای probe
///    • اگه hostname timeout شد، به IP سریع fallback می‌کنه
///    • timeout کوتاه‌تر روی هر هدف ولی تلاش بیشتر
///
///  بخش‌های داخلی در `packet_loss/` جدا شده‌اند:
///    • ProbeTarget  → probe یک هدف خاص
///    • ProbeHelpers → توابع کمکی static
/// ═══════════════════════════════════════════════════════════════
class PacketLossProber {
  final void Function(String message, {String source}) log;

  PacketLossProber({required this.log});

  /// هدف‌های probe — hostname + پورت ۴۴۳.
  static const List<({String host})> targets = [
    (host: 'www.cloudflare.com'),
    (host: 'www.google.com'),
    (host: 'www.microsoft.com'),
    (host: 'www.wikipedia.org'),
  ];

  /// fallback IPها — اگه hostname timeout شد، مستقیم به IP وصل می‌شیم.
  static const Map<String, String> ipFallback = {
    'www.cloudflare.com': '104.16.132.229',
    'www.google.com': '142.250.185.78',
    'www.microsoft.com': '23.192.228.80',
    'www.wikipedia.org': '208.80.154.224',
  };

  static const int targetPort = 443;

  Future<({bool success, int latencyMs, String target, String? error})> probe(
    int socksPort, {
    int targetIndex = 0,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final target = targets[targetIndex % targets.length];
    final targetLabel = '${target.host}:$targetPort';
    final sw = Stopwatch()..start();

    // ─── تلاش اول: با hostname ───
    final first = await probeOneTarget(
      socksPort: socksPort,
      host: target.host,
      port: targetPort,
      timeout: const Duration(seconds: 6),
    );

    if (first.success) {
      sw.stop();
      return (
        success: true,
        latencyMs: sw.elapsedMilliseconds,
        target: targetLabel,
        error: null,
      );
    }

    // ─── تلاش دوم: با IP مستقیم ───
    final fallbackIp = ipFallback[target.host];
    if (fallbackIp != null) {
      log(
        '→ Perf probe: hostname failed (${first.error}), retrying via IP $fallbackIp',
        source: 'Aether',
      );

      final second = await probeOneTarget(
        socksPort: socksPort,
        host: fallbackIp,
        port: targetPort,
        timeout: const Duration(seconds: 6),
      );

      if (second.success) {
        sw.stop();
        return (
          success: true,
          latencyMs: sw.elapsedMilliseconds,
          target: '$targetLabel (via IP)',
          error: null,
        );
      }
    }

    sw.stop();
    return (
      success: false,
      latencyMs: sw.elapsedMilliseconds,
      target: targetLabel,
      error: first.error ?? 'unknown',
    );
  }
}
