// lib/services/aether_probe_fallbacks.dart
//
// ═══════════════════════════════════════════════════════════════
//  AetherProbeFallbacks — probeهای جایگزین برای Aether
//  (curl + log-based check)
//  (تفکیک شده از aether_socks_probe.dart)
// ═══════════════════════════════════════════════════════════════
library;

import 'dart:io';

import 'process_service.dart';

class AetherProbeFallbacks {
  final ProcessService processService;

  const AetherProbeFallbacks({required this.processService});

  /// بررسی سلامت از طریق curl --socks5-hostname.
  Future<bool> curlProbe(int port) async {
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

  /// بررسی سلامت از روی لاگ‌های core.
  bool coreSaysReady(int port) {
    final logs = processService.fullLog;
    final tail = logs.length > 80 ? logs.sublist(logs.length - 80) : logs;
    final hasTunnel = tail.any((l) => l.contains('tunnel validated'));
    final hasSocks = tail.any((l) =>
        l.toLowerCase().contains('socks5') &&
        l.contains('listening') &&
        (l.contains(':$port') || l.contains('127.0.0.1:$port')));
    return hasTunnel && hasSocks;
  }
}
