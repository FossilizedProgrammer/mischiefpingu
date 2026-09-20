library;

import 'aether_attempts.dart';
import 'aether_socks_probe.dart';
import 'process_service.dart';

/// نتیجهٔ خام اجرای یک attempt (قبل از تصمیم‌گیری).
enum AttemptOutcome {
  /// SOCKS پاسخ داد و تونل سالم است.
  success,

  /// پورت listen می‌کند ولی SOCKS نمی‌دهد / refused.
  refused,

  /// SOCKS greeting داد ولی data-plane مرده (قطعی).
  tunnelDead,

  /// ⚠️ جدید: SOCKS زنده است ولی همه هدف‌های HTTP timeout دادن.
  /// این احتمالاً یعنی شبکه هدف‌ها رو بلاک کرده، نه تونل.
  allTargetsFailed,

  /// timeout در اتصال به پورت.
  timeout,

  /// اصلاً Aether بالا نیامد (binary missing, spawn error, ...).
  startFailed,
}

class AttemptResult {
  final AttemptOutcome outcome;
  final SocksDiag? diag;
  final int usedPort;

  const AttemptResult({
    required this.outcome,
    required this.usedPort,
    this.diag,
  });

  bool get isSuccess => outcome == AttemptOutcome.success;
}

class AetherAttemptRunner {
  final ProcessService processService;
  final SocksProber prober;

  AetherAttemptRunner({required this.processService, required this.prober});

  /// اجرای کامل یک attempt:
  ///   1. اگر Aether قبلاً روشن است، آن را متوقف کن
  ///   2. باینری را با args شروع کن
  ///   3. منتظر سلامت SOCKS بمان
  ///   4. نتیجه را برگردان (بدون تصمیم‌گیری)
  ///
  /// ⚠️ نکات بهینه‌سازی:
  ///   • تأخیر بین stop و start از ۶۰۰ms به ۳۰۰ms کاهش یافت
  ///   • timeout پیش‌فرض waitForHealthy از ۹۰s به ۴۵s کاهش یافت
  ///     (چون اکثر endpointهای معتبر در ۳۰s اول ready می‌شوند)
  Future<AttemptResult> run({
    required EndpointAttempt attempt,
    required List<String> args,
    required int port,
    Duration healthyTimeout = const Duration(seconds: 45),
  }) async {
    if (processService.isAetherRunning) {
      await processService.stopAether();
      // ⚠️ کاهش از 600ms به 300ms
      await Future.delayed(const Duration(milliseconds: 300));
    }

    final started = await processService.startAether(args);
    if (!started) {
      return AttemptResult(outcome: AttemptOutcome.startFailed, usedPort: port);
    }

    final diag = await prober.waitForHealthy(port, timeout: healthyTimeout);

    processService.addLog(
      prober.diagText(diag, port),
      source: LogSource.aether,
    );

    return AttemptResult(
      outcome: _translate(diag),
      diag: diag,
      usedPort: port,
    );
  }

  AttemptOutcome _translate(SocksDiag diag) {
    switch (diag) {
      case SocksDiag.healthy:
        return AttemptOutcome.success;
      case SocksDiag.connectRefused:
      case SocksDiag.appListenerBaselineFailed:
        return AttemptOutcome.refused;
      case SocksDiag.tunnelDead:
        return AttemptOutcome.tunnelDead;
      case SocksDiag.allTargetsFailed:
        return AttemptOutcome.allTargetsFailed;
      case SocksDiag.connectTimeout:
      case SocksDiag.notSocks:
        return AttemptOutcome.timeout;
    }
  }
}
