library;

import 'dart:async';
import 'dart:io';

import '../process/log_source.dart';

/// ═══════════════════════════════════════════════════════════════
///  NetworkChangeDetector — تشخیص تغییر شبکه (WiFi ↔ Mobile ↔ ...)
///
///  هر N ثانیه `NetworkInterface.list()` را چک می‌کند و اگر
///  ترکیب IPهای غیر-loopback عوض شده باشد، callback را صدا می‌زند.
///
///  ⚠️ این کلاس عمداً restart نمی‌کند. فقط cache‌ها را invalidate
///  می‌کند و log می‌نویسد. تصمیم restart به watchdog و
///  auto-reconnect سپرده می‌شود.
///
///  چرا؟ چون ممکنه شبکه لحظه‌ای قطع شده باشه و بلافاصله برگرده.
///  اگه ما فوری restart بزنیم، watchdog ممکنه circuit breaker
///  بزنه و UX بد بشه.
/// ═══════════════════════════════════════════════════════════════
class NetworkChangeDetector {
  final void Function(String message, {String source}) log;

  /// callback وقتی تغییر شبکه دیده شد.
  final void Function()? onChange;

  /// بازهٔ پیش‌فرض چک.
  static const Duration defaultInterval = Duration(seconds: 10);

  /// حداقل فاصله بین دو event متوالی (جلوگیری از spam).
  static const Duration _minEventSpacing = Duration(seconds: 3);

  final Duration interval;

  Timer? _timer;

  /// signature قبلی — لیست مرتب IPهای غیر-loopback.
  List<String> _lastSignature = const [];

  /// آخرین باری که event fire کردیم.
  DateTime? _lastEventAt;

  /// آیا اولین چک انجام شده؟ (اولین چک event نمی‌زنه)
  bool _firstCheckDone = false;

  bool _disposed = false;

  NetworkChangeDetector({
    required this.log,
    this.onChange,
    this.interval = defaultInterval,
  });

  /// شروع مانیتورینگ.
  void start() {
    if (_disposed) return;
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _check());
    log(
      '→ NetworkChangeDetector: started (interval=${interval.inSeconds}s)',
      source: LogSource.app,
    );
  }

  /// توقف مانیتورینگ.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// dispose کامل.
  void dispose() {
    _disposed = true;
    stop();
  }

  /// چک فوری (مثلاً از user action).
  Future<void> checkNow() => _check();

  Future<void> _check() async {
    if (_disposed) return;

    try {
      final signature = await _buildSignature();

      // اولین چک فقط baseline رو ست می‌کنه
      if (!_firstCheckDone) {
        _lastSignature = signature;
        _firstCheckDone = true;
        log(
          '→ NetworkChangeDetector: baseline set '
          '(${signature.length} interface(s))',
          source: LogSource.app,
        );
        return;
      }

      if (_signaturesEqual(signature, _lastSignature)) return;

      // ─── تغییر دیده شد ───
      final now = DateTime.now();
      final lastEvent = _lastEventAt;
      if (lastEvent != null && now.difference(lastEvent) < _minEventSpacing) {
        // spam — signature رو آپدیت کن ولی event نزن
        _lastSignature = signature;
        return;
      }

      _lastEventAt = now;
      final oldCount = _lastSignature.length;
      final newCount = signature.length;
      _lastSignature = signature;

      log(
        '⚠ NetworkChangeDetector: network changed '
        '($oldCount → $newCount interface(s))',
        source: LogSource.app,
      );

      // جزئیات برای دیباگ
      for (final ip in signature) {
        log('   • $ip', source: LogSource.app);
      }

      try {
        onChange?.call();
      } catch (e) {
        log(
          '⚠ NetworkChangeDetector: onChange threw: $e',
          source: LogSource.app,
        );
      }
    } catch (e) {
      // بعضی وقتا NetworkInterface.list() در لینوکس استثنا می‌ده
      // وقتی interface در حال خاموش شدنه. نادیده بگیر.
      if (!_disposed) {
        log('⚠ NetworkChangeDetector: check failed: $e', source: LogSource.app);
      }
    }
  }

  /// ساخت signature از interfaceهای غیر-loopback.
  ///
  /// signature = لیست مرتب `name:ip`ها.
  /// ترتیب رو sort می‌کنیم تا تغییرات کوچیک (مثل ترتیب enumeration)
  /// false positive ندن.
  Future<List<String>> _buildSignature() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
      includeLinkLocal: false,
    );

    final entries = <String>[];
    for (final iface in interfaces) {
      final addrs = iface.addresses
          .map((a) => a.address)
          .where((s) => s.isNotEmpty)
          .toList()
        ..sort();
      for (final addr in addrs) {
        entries.add('${iface.name}:$addr');
      }
    }
    entries.sort();
    return entries;
  }

  bool _signaturesEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
