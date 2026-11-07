library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'watchdog_probe_target.dart';
import 'watchdog_profile_params.dart';
import 'watchdog_quality_metrics.dart';

/// ═══════════════════════════════════════════════════════════════
///  WatchdogProber — probe SOCKS + HTTPS با multi-target.
///
///  ⚠️ تغییرات مهم این نسخه:
///    • به جای یک هدف ثابت (Cloudflare)، چند هدف دارد
///    • موفقیت حداقل یک هدف = alive
///    • اگر همه هدف‌های همان دور fail شوند = failure
///    • در stable، HTTP موفق هم لازم است
///    • در normal/harsh، CONNECT موفق کافی است
///
///  ⚠️ نکته: منطق probe یک هدف کاملاً در همین فایل پیاده شده؛
///  فایل‌های prober/*.dart قبلی حذف شدند.
/// ═══════════════════════════════════════════════════════════════
class WatchdogProber {
  final int socksPort;
  final Duration connectTimeout;
  final Duration socksTimeout;
  final Duration httpProbeTimeout;
  final void Function(String message, {String source}) log;
  final String logSource;

  /// پارامترهای پروفایل.
  final WatchdogProfileParams profileParams;

  /// لیست اهداف probe (برای این دور).
  final List<WatchdogProbeTarget> targets;

  int lastLatencyMs = 0;

  /// شماره دور فعلی — برای چرخش targets.
  int _roundCounter = 0;

  WatchdogProber({
    required this.socksPort,
    required this.connectTimeout,
    required this.socksTimeout,
    required this.httpProbeTimeout,
    required this.log,
    required this.logSource,
    required this.profileParams,
    List<WatchdogProbeTarget>? targetsOverride,
  }) : targets = targetsOverride ??
            WatchdogProbeTargets.forRound(
              includeCloudflare: profileParams.includeCloudflareTarget,
              round: 0,
            );

  /// probe با multi-target.
  Future<WatchdogQualityMetrics> probeWithMetrics() async {
    final sw = Stopwatch()..start();

    // ─── چرخش targets ───
    final round = _roundCounter++;
    final roundTargets = WatchdogProbeTargets.forRound(
      includeCloudflare: profileParams.includeCloudflareTarget,
      round: round,
    );

    int totalAttempts = 0;
    final failedTargets = <String>[];

    for (final target in roundTargets) {
      totalAttempts++;
      final result = await _probeOneTarget(target, sw);

      // ─── موفقیت کامل SOCKS ───
      if (result.tcpOk && result.greetOk && result.connectOk) {
        // ─── در stable، HTTP هم باید موفق باشه ───
        if (profileParams.requireHttpSuccess) {
          if (result.httpStatusOk) {
            sw.stop();
            return _buildSuccessMetrics(
              latencyMs: sw.elapsedMilliseconds,
              target: target.label,
            );
          }
          // اگه HTTP fail شد ولی CONNECT موفق بود، به هدف بعدی برو
          failedTargets.add('${target.label} (http)');
        } else {
          // در normal/harsh، CONNECT موفق کافیه
          sw.stop();
          return _buildSuccessMetrics(
            latencyMs: sw.elapsedMilliseconds,
            target: target.label,
          );
        }
      } else {
        failedTargets.add(target.label);
      }
    }

    // ─── همه هدف‌ها fail شدند ───
    sw.stop();

    log(
      '⚠ probe round failed: '
      '${failedTargets.length}/$totalAttempts targets failed '
      '(${failedTargets.join(", ")})',
      source: logSource,
    );

    return WatchdogQualityMetrics(
      latencyMs: sw.elapsedMilliseconds,
      jitterMs: 0,
      tcpOk: false,
      socksGreetingOk: false,
      socksConnectOk: false,
      httpResponseOk: false,
      httpStatusOk: false,
    );
  }

  WatchdogQualityMetrics _buildSuccessMetrics({
    required int latencyMs,
    required String target,
  }) {
    int jitter = 0;
    if (lastLatencyMs > 0) {
      final diff = latencyMs - lastLatencyMs;
      jitter = diff.abs();
    }
    lastLatencyMs = latencyMs;

    log(
      '✓ probe OK via $target (${latencyMs}ms)',
      source: logSource,
    );

    return WatchdogQualityMetrics(
      latencyMs: latencyMs,
      jitterMs: jitter,
      tcpOk: true,
      socksGreetingOk: true,
      socksConnectOk: true,
      httpResponseOk: true,
      httpStatusOk: true,
    );
  }

  /// probe یک هدف واحد.
  Future<_SingleProbeResult> _probeOneTarget(
    WatchdogProbeTarget target,
    Stopwatch sw,
  ) async {
    Socket? sock;
    SecureSocket? secure;
    StreamIterator<List<int>>? iter;

    bool tcpOk = false;
    bool greetOk = false;
    bool connectOk = false;
    bool httpRespOk = false;
    bool httpStatusOk = false;

    try {
      // ─── مرحله 1: TCP connect ───
      try {
        sock = await Socket.connect(
          '127.0.0.1',
          socksPort,
          timeout: connectTimeout,
        );
        sock.setOption(SocketOption.tcpNoDelay, true);
        tcpOk = true;
      } catch (_) {
        return _SingleProbeResult(
          tcpOk: false,
          greetOk: false,
          connectOk: false,
          httpRespOk: false,
          httpStatusOk: false,
        );
      }

      iter = StreamIterator<List<int>>(sock.timeout(socksTimeout));

      // ─── مرحله 2: SOCKS greeting ───
      sock.add([0x05, 0x01, 0x00]);
      await sock.flush();

      if (!await iter.moveNext()) {
        return _SingleProbeResult(
          tcpOk: tcpOk,
          greetOk: false,
          connectOk: false,
          httpRespOk: false,
          httpStatusOk: false,
        );
      }
      final greet = iter.current;
      if (greet.isEmpty || greet[0] != 0x05) {
        return _SingleProbeResult(
          tcpOk: tcpOk,
          greetOk: false,
          connectOk: false,
          httpRespOk: false,
          httpStatusOk: false,
        );
      }
      if (greet.length >= 2 && greet[1] != 0x00) {
        return _SingleProbeResult(
          tcpOk: tcpOk,
          greetOk: false,
          connectOk: false,
          httpRespOk: false,
          httpStatusOk: false,
        );
      }
      greetOk = true;

      // ─── مرحله 3: SOCKS CONNECT ───
      final isIp = WatchdogProbeTargets.looksLikeIPv4(target.host);
      if (isIp) {
        final parts = target.host.split('.').map(int.parse).toList();
        sock.add(<int>[
          0x05,
          0x01,
          0x00,
          0x01,
          parts[0],
          parts[1],
          parts[2],
          parts[3],
          (target.port >> 8) & 0xFF,
          target.port & 0xFF,
        ]);
      } else {
        final hostBytes = utf8.encode(target.host);
        if (hostBytes.length > 255) {
          return _SingleProbeResult(
            tcpOk: tcpOk,
            greetOk: greetOk,
            connectOk: false,
            httpRespOk: false,
            httpStatusOk: false,
          );
        }
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
      }
      await sock.flush();

      if (!await iter.moveNext()) {
        return _SingleProbeResult(
          tcpOk: tcpOk,
          greetOk: greetOk,
          connectOk: false,
          httpRespOk: false,
          httpStatusOk: false,
        );
      }
      final connResp = iter.current;
      if (connResp.length < 2 || connResp[1] != 0x00) {
        return _SingleProbeResult(
          tcpOk: tcpOk,
          greetOk: greetOk,
          connectOk: false,
          httpRespOk: false,
          httpStatusOk: false,
        );
      }
      connectOk = true;

      // ─── مرحله 4: TLS + HTTPS (فقط اگر لازم باشد) ───
      if (profileParams.requireHttpSuccess) {
        // Cancel iterator چون SecureSocket خودش سوکت را می‌گیرد
        await iter.cancel();
        iter = null;

        try {
          secure = await SecureSocket.secure(
            sock,
            host: WatchdogProbeTargets.sniFor(target.host),
            onBadCertificate: (_) => true,
          ).timeout(httpProbeTimeout);
        } catch (_) {
          return _SingleProbeResult(
            tcpOk: tcpOk,
            greetOk: greetOk,
            connectOk: connectOk,
            httpRespOk: false,
            httpStatusOk: false,
          );
        }

        // HTTPS HEAD
        secure.write(
          'HEAD / HTTP/1.1\r\n'
          'Host: ${WatchdogProbeTargets.sniFor(target.host)}\r\n'
          'User-Agent: Mozilla/5.0\r\n'
          'Connection: close\r\n'
          '\r\n',
        );
        await secure.flush();

        final buffer = <int>[];
        try {
          await for (final chunk in secure.timeout(httpProbeTimeout)) {
            buffer.addAll(chunk);
            if (buffer.length >= 20) break;
          }
        } catch (_) {}

        if (buffer.isNotEmpty) {
          final head = String.fromCharCodes(buffer.take(20));
          if (head.startsWith('HTTP/')) {
            httpRespOk = true;
            httpStatusOk = head.contains(' 200 ') ||
                head.contains(' 204 ') ||
                head.contains(' 301 ') ||
                head.contains(' 302 ') ||
                head.contains(' 304 ') ||
                head.contains(' 400 ') ||
                head.contains(' 403 ') ||
                head.contains(' 404 ');
          }
        }
      } else {
        // در normal/harsh، CONNECT موفق کافی است
        httpRespOk = true;
        httpStatusOk = true;
      }

      return _SingleProbeResult(
        tcpOk: tcpOk,
        greetOk: greetOk,
        connectOk: connectOk,
        httpRespOk: httpRespOk,
        httpStatusOk: httpStatusOk,
      );
    } catch (_) {
      return _SingleProbeResult(
        tcpOk: tcpOk,
        greetOk: greetOk,
        connectOk: connectOk,
        httpRespOk: httpRespOk,
        httpStatusOk: httpStatusOk,
      );
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

  Future<bool> probeAlive() async {
    final m = await probeWithMetrics();
    return m.isFullyAlive;
  }
}

class _SingleProbeResult {
  final bool tcpOk;
  final bool greetOk;
  final bool connectOk;
  final bool httpRespOk;
  final bool httpStatusOk;

  const _SingleProbeResult({
    required this.tcpOk,
    required this.greetOk,
    required this.connectOk,
    required this.httpRespOk,
    required this.httpStatusOk,
  });
}
