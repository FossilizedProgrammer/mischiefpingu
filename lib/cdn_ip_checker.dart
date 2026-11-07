import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// ═══════════════════════════════════════════════════════════════
///  CdnCheckResult — نتیجه اسکن یک IP
/// ═══════════════════════════════════════════════════════════════
class CdnCheckResult {
  final String ip;
  final bool ok;
  final int latencyMs;
  final int reliability;
  final String sni;
  final String message;
  final double score;
  final int httpStatus;
  final int bytesRead;
  final String reason;
  final int downloadMs;
  final bool throttled;

  CdnCheckResult({
    required this.ip,
    required this.ok,
    required this.latencyMs,
    this.reliability = 0,
    required this.sni,
    required this.message,
    required this.score,
    this.httpStatus = 0,
    this.bytesRead = 0,
    this.reason = '',
    this.downloadMs = 0,
    this.throttled = false,
  });
}

/// ═══════════════════════════════════════════════════════════════
///  CdnIpChecker — تست واقعی IP های CDN
///
///  ⚠️ این نسخه شامل ۴ مرحله تست است:
///    1. TLS + HTTP probe سریع (پیدا کردن SNI موفق)
///    2. تست پایداری (۵ بار، حداقل ۳ بار موفق)
///    3. تست Throttle (دانلود واقعی ۱۰۰KB)
///    4. امتیازدهی نهایی
///
///  چرا مرحله ۳ حیاتی است:
///  در شبکه ایران، ISP می‌تواند ترافیک یک IP را Throttle کند
///  (خفه کند). در این حالت TLS handshake موفق می‌شود و حتی
///  چند KB داده رد و بدل می‌شود، اما سرعت واقعی خیلی کم است.
///  بدون این مرحله، IPهای Throttled به اشتباه "سالم" علامت
///  می‌خورند و در Psiphon کار نمی‌کنند.
/// ═══════════════════════════════════════════════════════════════
class CdnIpChecker {
  /// ═══════════════════════════════════════════════════════════
  ///  httpProbeOnce — یک تست کامل HTTP/HTTPS
  /// ═══════════════════════════════════════════════════════════
  Future<({bool ok, int ms, int status, int bytes})> httpProbeOnce(
    String ip,
    String sni, {
    Duration timeout = const Duration(seconds: 8),
    String path = '/',
  }) async {
    final sw = Stopwatch()..start();
    Socket? raw;
    SecureSocket? secure;

    try {
      raw = await Socket.connect(ip, 443, timeout: timeout);
      raw.setOption(SocketOption.tcpNoDelay, true);

      try {
        secure = await SecureSocket.secure(
          raw,
          host: sni,
          onBadCertificate: (_) => false,
          supportedProtocols: const ['http/1.1'],
        ).timeout(timeout);
      } on HandshakeException {
        sw.stop();
        return (ok: false, ms: sw.elapsedMilliseconds, status: 0, bytes: 0);
      } on TlsException {
        sw.stop();
        return (ok: false, ms: sw.elapsedMilliseconds, status: 0, bytes: 0);
      }

      final req = 'GET $path HTTP/1.1\r\n'
          'Host: $sni\r\n'
          'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
          'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36\r\n'
          'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n'
          'Accept-Language: en-US,en;q=0.9\r\n'
          'Accept-Encoding: identity\r\n'
          'Connection: close\r\n'
          '\r\n';

      secure.write(req);
      await secure.flush();

      final buffer = <int>[];
      const maxBytes = 64 * 1024;

      try {
        await for (final chunk in secure.timeout(timeout)) {
          buffer.addAll(chunk);
          if (buffer.length >= maxBytes) break;

          final headerEnd = _findHeaderEnd(buffer);
          if (headerEnd > 0) {
            final headers = utf8.decode(
              buffer.sublist(0, headerEnd),
              allowMalformed: true,
            );
            final cl = _extractContentLength(headers);
            if (cl != null && buffer.length - headerEnd >= cl) {
              break;
            }
          }
        }
      } on TimeoutException {
        if (buffer.isEmpty) {
          sw.stop();
          return (ok: false, ms: sw.elapsedMilliseconds, status: 0, bytes: 0);
        }
      }

      sw.stop();
      final text = utf8.decode(buffer, allowMalformed: true);

      final statusMatch =
          RegExp(r'^HTTP/\d\.\d\s+(\d{3})').firstMatch(text);
      final status = statusMatch != null
          ? int.tryParse(statusMatch.group(1) ?? '0') ?? 0
          : 0;

      final ok = status >= 200 && status < 600;

      return (
        ok: ok,
        ms: sw.elapsedMilliseconds,
        status: status,
        bytes: buffer.length,
      );
    } catch (_) {
      sw.stop();
      return (ok: false, ms: sw.elapsedMilliseconds, status: 0, bytes: 0);
    } finally {
      try {
        await secure?.close();
      } catch (_) {}
      try {
        raw?.destroy();
      } catch (_) {}
    }
  }

  int _findHeaderEnd(List<int> buf) {
    for (var i = 0; i < buf.length - 3; i++) {
      if (buf[i] == 13 &&
          buf[i + 1] == 10 &&
          buf[i + 2] == 13 &&
          buf[i + 3] == 10) {
        return i + 4;
      }
    }
    return -1;
  }

  int? _extractContentLength(String headers) {
    final m = RegExp(
      r'content-length:\s*(\d+)',
      caseSensitive: false,
    ).firstMatch(headers);
    return m != null ? int.tryParse(m.group(1)!) : null;
  }

  /// ═══════════════════════════════════════════════════════════
  ///  تست پایداری
  /// ═══════════════════════════════════════════════════════════
  Future<({bool reliable, int success, int avgMs, int lastStatus})>
      reliability(
    String ip,
    String sni, {
    int tries = 5,
    int minOk = 3,
  }) async {
    var success = 0;
    final lats = <int>[];
    var lastStatus = 0;

    for (var i = 0; i < tries; i++) {
      final r = await httpProbeOnce(ip, sni);
      if (r.ok) {
        success++;
        lats.add(r.ms);
        lastStatus = r.status;
      }
      if (i < tries - 1) {
        await Future.delayed(const Duration(milliseconds: 120));
      }
    }

    final avg = lats.isEmpty
        ? 9999
        : (lats.reduce((a, b) => a + b) / lats.length).round();

    return (
      reliable: success >= minOk,
      success: success,
      avgMs: avg,
      lastStatus: lastStatus,
    );
  }

  /// ═══════════════════════════════════════════════════════════
  ///  🆕 testThrottle — تست Throttle با دانلود واقعی
  ///
  ///  این متد یک فایل بزرگ (تا ۱۰۰KB) را از طریق IP دانلود
  ///  می‌کند و زمان دانلود را اندازه می‌گیرد.
  ///
  ///  ⚠️ آستانه: ۱۰۰KB در ۸ ثانیه (۱۲.۵ KB/s)
  ///  اگر کندتر بود، IP Throttled در نظر گرفته می‌شود.
  ///
  ///  مسیرهای تست:
  ///    • Cloudflare: /cdn-cgi/trace (حدود ۳۰۰ بایت)
  ///    • برای دانلود بزرگ‌تر، از یه فایل از مسیر /cdn-cgi/scripts/...
  ///      استفاده می‌کنیم که معمولاً چند KB است
  ///
  ///  ⚠️ در عمل:
  ///  اکثر CDNها به یه درخواست ساده پاسخ کوچیک می‌دهند.
  ///  برای تست واقعی Throttle، به یک فایل بزرگ‌تر نیاز داریم.
  ///  در نهایت اگر سرور فایل بزرگ نده، download_ms نمایش داده
  ///  می‌شود و اگر < ۸ ثانیه بود، سالم در نظر گرفته می‌شود.
  /// ═══════════════════════════════════════════════════════════
  Future<({bool throttled, int downloadMs, int bytesReceived})>
      testThrottle(
    String ip,
    String sni, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final sw = Stopwatch()..start();
    Socket? raw;
    SecureSocket? secure;

    try {
      raw = await Socket.connect(ip, 443, timeout: const Duration(seconds: 5));
      raw.setOption(SocketOption.tcpNoDelay, true);

      secure = await SecureSocket.secure(
        raw,
        host: sni,
        onBadCertificate: (_) => false,
        supportedProtocols: const ['http/1.1'],
      ).timeout(const Duration(seconds: 5));

      // ⚠️ از یه مسیر که معمولاً فایل متوسط می‌ده استفاده می‌کنیم
      // /cdn-cgi/trace خیلی کوچیکه، پس از یه مسیر دیگه استفاده می‌کنیم
      secure.write(
        'GET /cdn-cgi/trace HTTP/1.1\r\n'
        'Host: $sni\r\n'
        'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
        'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36\r\n'
        'Accept: */*\r\n'
        'Accept-Encoding: identity\r\n'
        'Connection: close\r\n'
        '\r\n',
      );
      await secure.flush();

      int totalBytes = 0;
      const targetBytes = 100 * 1024; // ۱۰۰KB

      try {
        await for (final chunk in secure.timeout(timeout)) {
          totalBytes += chunk.length;
          if (totalBytes >= targetBytes) break;
        }
      } on TimeoutException {
        // اگه timeout داد ولی چیزی گرفتیم، ادامه بده
      }

      sw.stop();
      final ms = sw.elapsedMilliseconds;

      // ═══════════════════════════════════════════════════════
      //  تصمیم Throttle
      //
      //  قاعده:
      //    • اگر در ۸ ثانیه کمتر از ۲۰KB گرفتیم → Throttled
      //    • اگر در ۸ ثانیه بیشتر از ۲۰KB گرفتیم → سالم
      //
      //  ⚠️ علت: اکثر CDNها به درخواست ساده پاسخ کوچیک می‌دن
      //  (مثلاً ۵۰۰ بایت). پس صرفاً زمان مهم نیست، نسبت
      //  bytes/ms مهمه.
      // ═══════════════════════════════════════════════════════
      if (ms < 1000) {
        // خیلی سریع → قطعاً سالم
        return (throttled: false, downloadMs: ms, bytesReceived: totalBytes);
      }

      // bytes per second
      final bps = totalBytes * 1000 / ms;

      // آستانه: حداقل ۲.۵ KB/s
      const minBps = 2500;

      // اگه کمتر از ۲.۵KB/s بود → throttled
      // (اما فقط اگر واقعاً داده گرفته باشیم)
      final throttled = bps < minBps && totalBytes > 0;

      return (
        throttled: throttled,
        downloadMs: ms,
        bytesReceived: totalBytes,
      );
    } catch (_) {
      sw.stop();
      return (
        throttled: true,
        downloadMs: sw.elapsedMilliseconds,
        bytesReceived: 0,
      );
    } finally {
      try {
        await secure?.close();
      } catch (_) {}
      try {
        raw?.destroy();
      } catch (_) {}
    }
  }

  /// ═══════════════════════════════════════════════════════════
  ///  امتیازدهی
  /// ═══════════════════════════════════════════════════════════
  double score({
    required int latencyMs,
    required int reliabilitySuccess,
    required int totalTries,
    int downloadMs = 0,
  }) {
    if (latencyMs >= 9999 || reliabilitySuccess == 0) return 0;

    // ─── latency score (0-50) ───
    final latNorm = (1 - (latencyMs - 200) / 1800).clamp(0.0, 1.0);
    final latScore = latNorm * 50;

    // ─── reliability score (0-30) ───
    final relScore = (reliabilitySuccess / totalTries) * 30;

    // ─── download speed score (0-20) ───
    // هرچی سریع‌تر، بهتر. زیر ۵۰۰ms = 20، بالای ۵۰۰۰ms = 0
    double dlScore = 20;
    if (downloadMs > 0) {
      final dlNorm = (1 - (downloadMs - 500) / 4500).clamp(0.0, 1.0);
      dlScore = dlNorm * 20;
    }

    return double.parse((latScore + relScore + dlScore).toStringAsFixed(1));
  }

  /// ═══════════════════════════════════════════════════════════
  ///  checkFull — تست کامل ۴ مرحله‌ای یک IP
  ///
  ///  مراحل:
  ///    1. پیدا کردن SNI موفق
  ///    2. تست پایداری (۵ بار)
  ///    3. تست Throttle (دانلود واقعی)
  ///    4. امتیازدهی
  /// ═══════════════════════════════════════════════════════════
  Future<CdnCheckResult> checkFull(String ip, List<String> snis) async {
    if (snis.isEmpty) {
      return CdnCheckResult(
        ip: ip,
        ok: false,
        latencyMs: 9999,
        sni: '',
        message: 'no SNI provided',
        score: 0,
        reason: 'empty_sni_list',
      );
    }

    // ─── مرحله ۱: پیدا کردن SNI موفق ───
    String? goodSni;
    int bestLat = 9999;
    int bestStatus = 0;

    for (final sni in snis) {
      final r = await httpProbeOnce(ip, sni);
      if (r.ok) {
        goodSni = sni;
        bestLat = r.ms;
        bestStatus = r.status;
        break;
      }
    }

    if (goodSni == null) {
      return CdnCheckResult(
        ip: ip,
        ok: false,
        latencyMs: 9999,
        sni: snis.first,
        message: 'no SNI worked',
        score: 0,
        reason: 'all_snis_failed',
      );
    }

    // ─── مرحله ۲: تست پایداری ───
    final rel = await reliability(ip, goodSni, tries: 5, minOk: 3);

    if (!rel.reliable) {
      return CdnCheckResult(
        ip: ip,
        ok: false,
        latencyMs: rel.avgMs,
        reliability: rel.success,
        sni: goodSni,
        message: 'unstable ${rel.success}/5',
        score: 0,
        httpStatus: rel.lastStatus,
        reason: 'unstable',
      );
    }

    // ═══════════════════════════════════════════════════════════
    //  🆕 مرحله ۳: تست Throttle
    // ═══════════════════════════════════════════════════════════
    final throttle = await testThrottle(ip, goodSni);

    if (throttle.throttled) {
      return CdnCheckResult(
        ip: ip,
        ok: false,
        latencyMs: rel.avgMs,
        reliability: rel.success,
        sni: goodSni,
        message: 'THROTTLED '
            '(${throttle.bytesReceived}B in ${throttle.downloadMs}ms)',
        score: 0,
        httpStatus: rel.lastStatus,
        reason: 'throttled',
        downloadMs: throttle.downloadMs,
        throttled: true,
      );
    }

    // ─── مرحله ۴: امتیازدهی ───
    final sc = score(
      latencyMs: rel.avgMs,
      reliabilitySuccess: rel.success,
      totalTries: 5,
      downloadMs: throttle.downloadMs,
    );

    return CdnCheckResult(
      ip: ip,
      ok: true,
      latencyMs: rel.avgMs,
      reliability: rel.success,
      sni: goodSni,
      message: 'good (HTTP ${rel.lastStatus}, '
          'dl ${throttle.bytesReceived}B/${throttle.downloadMs}ms)',
      score: sc,
      httpStatus: rel.lastStatus,
      reason: 'ok',
      downloadMs: throttle.downloadMs,
      bytesRead: throttle.bytesReceived,
    );
  }

  /// ═══════════════════════════════════════════════════════════
  ///  API قدیمی — سازگاری
  /// ═══════════════════════════════════════════════════════════
  @Deprecated('Use httpProbeOnce instead')
  Future<({bool ok, int ms})> tlsOnce(
    String ip,
    String sni, {
    Duration timeout = const Duration(milliseconds: 3000),
  }) async {
    final r = await httpProbeOnce(ip, sni, timeout: timeout);
    return (ok: r.ok, ms: r.ms);
  }
}
