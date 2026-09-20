library;

import 'dart:async';
import 'dart:io';

import '../process/log_source.dart';

/// ═══════════════════════════════════════════════════════════════
///  ConnectivityProbe — probe سبک برای تشخیص Internet vs Tunnel
///
///  هدف: قبل از restart کردن tunnel، بفهمیم آیا Internet پایه سالم است.
///  اگر Internet قطع باشد، restart کردن tunnel بی‌فایده است.
///
///  این کلاس عمداً ساده است — فقط یک TCP connect به یک IP پایدار.
///  برای diagnostic کامل‌تر، InternetDiagnosticService جدا باید ساخته شود.
/// ═══════════════════════════════════════════════════════════════

class ConnectivityProbe {
  final void Function(String message, {String source}) log;

  ConnectivityProbe({required this.log});

  /// IPهای پایدار برای probe — بدون DNS.
  static const List<String> _stableTargets = ['1.1.1.1', '8.8.8.8', '9.9.9.9'];

  static const int _targetPort = 443;
  static const Duration _probeTimeout = Duration(seconds: 3);

  /// cache برای جلوگیری از probeهای تکراری.
  DateTime? _lastProbeTime;
  bool? _lastResult;
  static const Duration _cacheTtl = Duration(seconds: 10);

  /// یک probe سریع. true = Internet به احتمال زیاد سالم است.
  Future<bool> isInternetAlive({bool useCache = true}) async {
    if (useCache &&
        _lastResult != null &&
        _lastProbeTime != null &&
        DateTime.now().difference(_lastProbeTime!) < _cacheTtl) {
      return _lastResult!;
    }

    final result = await _probeMultiple();
    _lastResult = result;
    _lastProbeTime = DateTime.now();
    return result;
  }

  Future<bool> _probeMultiple() async {
    final futures = _stableTargets.take(2).map(_probeOne).toList();
    final results = await Future.wait(futures);
    final successCount = results.where((r) => r).length;
    return successCount >= 1;
  }

  Future<bool> _probeOne(String ip) async {
    Socket? sock;
    try {
      sock = await Socket.connect(ip, _targetPort, timeout: _probeTimeout);
      return true;
    } catch (_) {
      return false;
    } finally {
      try {
        sock?.destroy();
      } catch (_) {}
    }
  }

  /// probe با جزئیات (برای log).
  ///
  /// ⚠️ همه probeها موازی هستند تا زمان کل = max(هر probe)
  /// به جای sum(همه).
  Future<ConnectivityProbeResult> probeDetailed() async {
    final sw = Stopwatch()..start();

    final futures = _stableTargets.map((ip) async {
      final ok = await _probeOne(ip);
      return MapEntry(ip, ok);
    }).toList();

    final entries = await Future.wait(futures);
    sw.stop();

    final results = Map.fromEntries(entries);
    final success = results.values.where((r) => r).length;
    final total = results.length;

    return ConnectivityProbeResult(
      successCount: success,
      totalCount: total,
      elapsedMs: sw.elapsedMilliseconds,
      perTarget: results,
      isAlive: success >= 1,
    );
  }

  void invalidateCache() {
    _lastResult = null;
    _lastProbeTime = null;
  }

  /// log یک خلاصه از وضعیت Internet (برای snapshot قبل از restart).
  Future<ConnectivityProbeResult> logAndReturn() async {
    final result = await probeDetailed();
    log(
      '→ Internet probe: ${result.successCount}/${result.totalCount} OK, '
      '${result.elapsedMs}ms — ${result.isAlive ? "ALIVE" : "DEAD"}',
      source: LogSource.app,
    );
    return result;
  }
}

class ConnectivityProbeResult {
  final int successCount;
  final int totalCount;
  final int elapsedMs;
  final Map<String, bool> perTarget;
  final bool isAlive;

  const ConnectivityProbeResult({
    required this.successCount,
    required this.totalCount,
    required this.elapsedMs,
    required this.perTarget,
    required this.isAlive,
  });

  @override
  String toString() => 'ConnectivityProbeResult($successCount/$totalCount, '
      '${elapsedMs}ms, alive=$isAlive)';
}
