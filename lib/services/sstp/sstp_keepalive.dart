library;

import 'dart:async';
import 'dart:io';

/// ═══════════════════════════════════════════════════════════════
///  SstpKeepalive — ارسال پینگ دوره‌ای از SOCKS برای جلوگیری
///  از idle timeout سرور / NAT / ISP.
///
///  هر ۲۰ ثانیه یک SOCKS5 CONNECT کوتاه به یه هدف سبک می‌زنه،
///  100ms صبر می‌کنه، بعد می‌بنده. هدف فقط زنده نگه داشتن
///  TCP connection تونل است.
/// ═══════════════════════════════════════════════════════════════
class SstpKeepalive {
  final void Function(String message, {String source}) log;

  static const Duration _interval = Duration(seconds: 20);
  static const int _targetPort = 443;

  /// هدف‌ها — از یه دامنه سبک استفاده می‌کنیم.
  /// می‌تونه هر چیزی باشه، فقط نباید فیلتر باشه.
  static const List<String> _targets = [
    'www.google.com',
    'www.cloudflare.com',
    '1.1.1.1',
  ];

  Timer? _timer;
  int _targetIndex = 0;
  bool _running = false;

  SstpKeepalive({required this.log});

  void start(int socksPort) {
    stop();
    _running = true;
    _targetIndex = 0;

    log(
      '→ SSTP keepalive started (every ${_interval.inSeconds}s)',
      source: 'SSTP',
    );

    _timer = Timer.periodic(_interval, (_) => _ping(socksPort));
  }

  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _ping(int socksPort) async {
    if (!_running) return;

    final host = _targets[_targetIndex % _targets.length];
    _targetIndex++;

    Socket? sock;
    StreamIterator<List<int>>? iter;

    try {
      sock = await Socket.connect(
        '127.0.0.1',
        socksPort,
        timeout: const Duration(seconds: 3),
      );

      // ─── SOCKS5 greeting ───
      iter = StreamIterator<List<int>>(
        sock.timeout(const Duration(seconds: 3)),
      );

      sock.add([0x05, 0x01, 0x00]);
      await sock.flush();

      if (!await iter.moveNext()) return;
      final greet = iter.current;
      if (greet.isEmpty || greet[0] != 0x05) return;
      if (greet.length >= 2 && greet[1] != 0x00) return;

      // ─── SOCKS5 CONNECT ───
      final hostBytes = host.codeUnits;
      sock.add(<int>[
        0x05,
        0x01,
        0x00,
        0x03,
        hostBytes.length,
        ...hostBytes,
        (_targetPort >> 8) & 0xFF,
        _targetPort & 0xFF,
      ]);
      await sock.flush();

      if (!await iter.moveNext()) return;
      final resp = iter.current;
      if (resp.length < 2 || resp[1] != 0x00) return;

      // ─── موفق — یه ذره صبر کن بعد ببند ───
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (_) {
      // خطا مهم نیست — watchdog اصلی مسئول مرگه
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
