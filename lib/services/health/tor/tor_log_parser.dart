part of '../tor_health_source.dart';

/// ═══════════════════════════════════════════════════════════════
///  TorLogParser — parse کردن خطوط لاگ Tor.
///
///  این کلاس مستقیماً روی state والد (TorHealthSource) کار
///  می‌کند تا نیازی به getter/setter اضافی نباشد.
/// ═══════════════════════════════════════════════════════════════
class TorLogParser {
  final TorHealthSource source;

  const TorLogParser({required this.source});

  // ─── regex ───
  static final _circuitEstablishedRe = RegExp(
    r'Circuit established \(id=(\d+),\s*purpose=([^)]+)\)',
    caseSensitive: false,
  );
  static final _circuitFailedRe = RegExp(
    r'Circuit closed.*?reason=([A-Z_]+)',
    caseSensitive: false,
  );
  static final _streamOpenedRe = RegExp(
    r'Stream\s+(?:opened|connected).*?id=(\d+)',
    caseSensitive: false,
  );
  static final _streamFailedRe = RegExp(
    r'Stream closed.*?reason=([A-Z_]+)',
    caseSensitive: false,
  );
  static final _bootstrapRe = RegExp(
    r'Bootstrapped\s+(\d+)%',
    caseSensitive: false,
  );

  void feed(String line) {
    final lower = line.toLowerCase();

    // ─── Bootstrapped ───
    final bootstrapMatch = _bootstrapRe.firstMatch(line);
    if (bootstrapMatch != null) {
      final progress = int.tryParse(bootstrapMatch.group(1) ?? '0') ?? 0;
      source.bootstrapProgress = progress;
      if (progress == 100) {
        source.successCount++;
        source.totalSamples++;
      }
      return;
    }

    // ─── Circuit established ───
    final circuitMatch = _circuitEstablishedRe.firstMatch(line);
    if (circuitMatch != null) {
      source.circuitsEstablished++;
      source.successCount++;
      source.totalSamples++;
      source.currentLatencyMs = source.currentLatencyMs > 0
          ? source.currentLatencyMs
          : 500;
      return;
    }

    // ─── Circuit failed ───
    if (_circuitFailedRe.hasMatch(line)) {
      source.circuitsFailed++;
      source.totalSamples++;
      return;
    }

    // ─── Stream opened ───
    if (_streamOpenedRe.hasMatch(line)) {
      source.streamsOpened++;
      source.successCount++;
      source.totalSamples++;
      return;
    }

    // ─── Stream failed ───
    final streamFailMatch = _streamFailedRe.firstMatch(line);
    if (streamFailMatch != null) {
      final reason = streamFailMatch.group(1) ?? '';
      // فقط errorها حساب می‌شن، نه END (که بسته شدن طبیعی است)
      if (reason != 'END' && reason != 'DONE') {
        source.streamsFailed++;
        source.totalSamples++;
      }
      return;
    }

    // ─── failures ───
    if (lower.contains('failed to get consensus') ||
        lower.contains('no usable guards') ||
        lower.contains('all directory servers are failing')) {
      source.totalSamples++;
    }
  }
}
