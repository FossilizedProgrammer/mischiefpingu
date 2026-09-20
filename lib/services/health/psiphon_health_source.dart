library;

import 'dart:async';

part 'psiphon/psiphon_log_parser.dart';
part 'psiphon/psiphon_report_emitter.dart';

/// ═══════════════════════════════════════════════════════════════
///  PsiphonHealthSource — استخراج metric از لاگ‌های Psiphon.
///
///  Psiphon با `EmitDiagnosticNotices: true` خیلی از اطلاعات
///  رو به صورت JSON می‌ده:
///
///    • BytesTransferred   → upstreamBytes / downstreamBytes
///    • TunnelConnected    → protocol / dialLatencyMs
///    • ActiveTunnel       → protocol / uptimeSeconds
///    • TunnelFailed       → error / reason
///    • EstablishingTunnel → progress
///
///  این کلاس این‌ها رو parse می‌کنه و به monitor می‌ده.
///
///  بخش‌های داخلی در `psiphon/` جدا شده‌اند:
///    • PsiphonLogParser      → parse کردن خطوط JSON
///    • PsiphonReportEmitter  → ساخت و ارسال report دوره‌ای
/// ═══════════════════════════════════════════════════════════════
class PsiphonHealthSource {
  final void Function(String message, {String source}) log;

  /// callback وقتی یک report جدید آماده شد.
  final void Function({
    required int latencyMs,
    required int jitterMs,
    required double packetLossPct,
    required int successCount,
    required int totalSamples,
    required Map<String, dynamic> extra,
  }) onReport;

  // ─── state ───
  int successCount = 0;
  int totalSamples = 0;
  int lastLatencyMs = 0;
  int currentLatencyMs = 0;
  int lastDialLatencyMs = 0;
  int consecutiveFailures = 0;
  int totalFailures = 0;
  int lastUpstreamBytes = 0;
  int lastDownstreamBytes = 0;
  String? currentProtocol;
  DateTime? lastBytesSampleAt;

  // ─── collaboratorها ───
  late final PsiphonLogParser _parser;
  late final PsiphonReportEmitter _emitter;

  PsiphonHealthSource({
    required this.log,
    required this.onReport,
  }) {
    _parser = PsiphonLogParser(source: this);
    _emitter = PsiphonReportEmitter(source: this);
  }

  void start() {
    successCount = 0;
    totalSamples = 0;
    lastLatencyMs = 0;
    currentLatencyMs = 0;
    consecutiveFailures = 0;
    totalFailures = 0;
    lastUpstreamBytes = 0;
    lastDownstreamBytes = 0;
    currentProtocol = null;
    lastBytesSampleAt = DateTime.now();

    _emitter.start();
  }

  void stop() {
    _emitter.stop();
  }

  void feed(String line) {
    if (!line.contains('"noticeType"')) return;
    _parser.feed(line);
  }

  void reset() {
    successCount = 0;
    totalSamples = 0;
    lastLatencyMs = 0;
    currentLatencyMs = 0;
    lastDialLatencyMs = 0;
    consecutiveFailures = 0;
    totalFailures = 0;
    lastUpstreamBytes = 0;
    lastDownstreamBytes = 0;
    currentProtocol = null;
    lastBytesSampleAt = null;
    _emitter.stop();
  }

  void dispose() {
    reset();
  }
}
