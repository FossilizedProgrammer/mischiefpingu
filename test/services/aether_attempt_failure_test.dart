// test/services/aether_attempt_failure_test.dart
//
// با endpoint سنجاق‌شده (`--peer`) هستهٔ Aether در صورت رد شدن (مثلاً
// `connect-ip status: 400`) فقط reconnect می‌کند و هرگز SOCKS باز نمی‌کند.
// پروب باید به‌محض دیدن این خطای خودِ هسته تلاش را تمام کند، نه بعد از
// ۴۵ ثانیه انتظار — همان اتلاف وقتی که اتصال را کند می‌کرد.

import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/services/aether_socks_probe.dart';
import 'package:mischiefpingu/services/process_service.dart';

void main() {
  test('waitForHealthy aborts as soon as the core rejects the attempt',
      () async {
    final ps = ProcessService()
      ..isAetherRunning = true
      ..aetherAttemptError = '[h2] connect-ip status: 400';
    final prober = SocksProber(ps, isCancelled: () => false);

    final watch = Stopwatch()..start();
    final diag = await prober.waitForHealthy(
      1819,
      timeout: const Duration(seconds: 45),
    );

    expect(diag, SocksDiag.tunnelDead);
    expect(watch.elapsed, lessThan(const Duration(seconds: 5)));
  });

  test('a stopped core still reports connectRefused', () async {
    final ps = ProcessService();
    final prober = SocksProber(ps, isCancelled: () => false);

    final diag = await prober.waitForHealthy(
      1819,
      timeout: const Duration(seconds: 2),
    );

    expect(diag, SocksDiag.connectRefused);
  });
}
