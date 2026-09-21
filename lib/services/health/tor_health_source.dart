library;

import 'dart:async';

part 'tor/tor_log_parser.dart';
part 'tor/tor_report_emitter.dart';

/// ═══════════════════════════════════════════════════════════════
///  TorHealthSource — استخراج metric از لاگ‌های Tor.
///
///  Tor لاگ‌های خیلی غنی داره:
///    • "Bootstrapped 100% (done)"         → متصل
///    • "Circuit established (id=...)"     → circuit جدید
///    • "Stream closed (id=..., reason=)"  → stream بسته
///    • "Failed to get consensus"          → خطا
///    • "No usable guards"                 → خطا
///
///  بخش‌های داخلی در `tor/` جدا شده‌اند:
///    • TorLogParser      → parse کردن خطوط لاگ
///    • TorReportEmitter  → ساخت و ارسال report دوره‌ای
/// ═══════════════════════════════════════════════════════════════
class TorHealthSource {
  final void Function(String message, {String source}) log;

  final void Function({
    required int latencyMs,
    required int jitterMs,
    required double packetLossPct,
    required int successCount,
    required int totalSamples,
    required Map<String, dynamic> extra,
  })
  onReport;

  // ─── state ───
  int successCount = 0;
  int totalSamples = 0;
  int streamsOpened = 0;
  int streamsFailed = 0;
  int circuitsEstablished = 0;
  int circuitsFailed = 0;
  int lastLatencyMs = 0;
  int currentLatencyMs = 0;
  int bootstrapProgress = 0;

  // ─── collaboratorها ───
  late final TorLogParser _parser;
  late final TorReportEmitter _emitter;

  TorHealthSource({required this.log, required this.onReport}) {
    _parser = TorLogParser(source: this);
    _emitter = TorReportEmitter(source: this);
  }

  void start() {
    successCount = 0;
    totalSamples = 0;
    streamsOpened = 0;
    streamsFailed = 0;
    circuitsEstablished = 0;
    circuitsFailed = 0;
    lastLatencyMs = 0;
    currentLatencyMs = 0;
    bootstrapProgress = 0;

    _emitter.start();
  }

  void stop() {
    _emitter.stop();
  }

  void feed(String line) {
    if (line.isEmpty) return;
    _parser.feed(line);
  }

  void reset() {
    successCount = 0;
    totalSamples = 0;
    streamsOpened = 0;
    streamsFailed = 0;
    circuitsEstablished = 0;
    circuitsFailed = 0;
    lastLatencyMs = 0;
    currentLatencyMs = 0;
    bootstrapProgress = 0;
    _emitter.stop();
  }

  void dispose() {
    reset();
  }
}
