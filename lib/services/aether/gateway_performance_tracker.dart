library;

import 'dart:async';

import '../../models/gateway_record.dart';
import '../database/gateway_history_store.dart';
import '../process/log_source.dart';
import 'packet_loss_prober.dart';
import 'performance_sample.dart';

part 'gateway_performance/measurement_runner.dart';

/// ═══════════════════════════════════════════════════════════════
///  GatewayPerformanceTracker — اندازه‌گیری عملکرد Gateway.
///
///  ⚠️ تغییرات:
///    • sampleCount از 10 به 6 (سریع‌تر)
///    • interval از 1500ms به 2500ms (فشار کمتر روی تونل)
///    • probeTimeout از 8s به 12s (هم‌راستا با config جدید)
///
///  منطق اندازه‌گیری در `gateway_performance/measurement_runner.dart`.
/// ═══════════════════════════════════════════════════════════════
class GatewayPerformanceTracker {
  final GatewayHistoryStore store;
  final PacketLossProber prober;
  final void Function(String message, {String source}) log;

  final void Function(PerformanceReport report)? onReport;

  GatewayPerformanceTracker({
    required this.store,
    required this.log,
    this.onReport,
  }) : prober = PacketLossProber(log: log);

  static const int defaultSampleCount = 6;
  static const Duration defaultInterval = Duration(milliseconds: 2500);
  static const Duration defaultProbeTimeout = Duration(seconds: 12);

  int _generation = 0;
  Future<void>? _runningFuture;

  // ⚠️ این فیلد public می‌شه تا partها دسترسی داشته باشن
  //    و getter/setter اضافی لازم نباشه (رفع lint).
  bool cancelRequested = false;

  String? _lastMeasuredKey;
  bool get isRunning => _runningFuture != null;

  PerformanceReport? _lastReport;
  PerformanceReport? get lastReport => _lastReport;

  String? get lastMeasuredKey => _lastMeasuredKey;
  int get currentGeneration => _generation;

  Future<void> startFor({
    required int socksPort,
    required String ip,
    required int port,
    required String protocol,
    String masqueOption = '',
    String sni = '',
    String endpoint = '',
    String networkType = '',
    String networkName = '',
    int sampleCount = defaultSampleCount,
    Duration interval = defaultInterval,
    Duration probeTimeout = defaultProbeTimeout,
  }) async {
    await _cancelRunning();

    final myGen = ++_generation;
    cancelRequested = false;

    final key = GatewayRecord.buildKey(
      ip: ip,
      port: port,
      protocol: protocol,
      masqueOption: masqueOption,
      sni: sni,
    );

    final future = runMeasurement(
      generation: myGen,
      socksPort: socksPort,
      uniqueKey: key,
      ip: ip,
      port: port,
      protocol: protocol,
      masqueOption: masqueOption,
      sni: sni,
      endpoint: endpoint,
      networkType: networkType,
      networkName: networkName,
      sampleCount: sampleCount,
      interval: interval,
      probeTimeout: probeTimeout,
    );

    _runningFuture = future;
    future.whenComplete(() {
      if (identical(_runningFuture, future)) {
        _runningFuture = null;
      }
    });
  }

  Future<void> cancel() async {
    cancelRequested = true;
    await _cancelRunning();
  }

  Future<void> reset() async {
    await cancel();
    _lastReport = null;
    _lastMeasuredKey = null;
    _generation = 0;
  }

  Future<void> _cancelRunning() async {
    cancelRequested = true;
    final f = _runningFuture;
    if (f != null) {
      try {
        await f;
      } catch (_) {}
    }
  }

  /// ⚠️ Setterها برای دسترسی از part.
  void setLastReport(PerformanceReport report) => _lastReport = report;
  void setLastMeasuredKey(String key) => _lastMeasuredKey = key;
}
