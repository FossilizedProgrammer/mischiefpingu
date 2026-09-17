// lib/services/auto_reconnect_manager.dart
//
// ═══════════════════════════════════════════════════════════════
//  AutoReconnectManager — زمان‌بندی auto-reconnect پس از مرگ پروسه
//
//  ⚠️ delay افزایش یافته چون در اینترنت ایران، پروسه ممکن است
//  به‌خاطر اختلال موقتی بمیرد و نباید فوراً reconnect شود.
// ═══════════════════════════════════════════════════════════════
import 'dart:async';
import 'process_service.dart';

class AutoReconnectManager {
  Timer? _psiphonTimer;
  Timer? _aetherTimer;
  Timer? _torTimer;
  Timer? _sstpTimer;

  /// ⚠️ افزایش از 5 به 15 ثانیه — برای اینترنت ناپایدار.
  static const Duration defaultDelay = Duration(seconds: 15);

  /// برای تونل‌هایی که کند boot می‌شوند (مثل Tor).
  static const Duration slowTunnelDelay = Duration(seconds: 30);

  void schedulePsiphonReconnect({
    Duration delay = defaultDelay,
    required bool Function() shouldReconnect,
    required void Function() onReconnect,
    required void Function(String, {String source}) log,
  }) {
    _psiphonTimer?.cancel();
    _psiphonTimer = Timer(delay, () {
      if (shouldReconnect()) {
        log('↻ Auto-reconnecting Psiphon...', source: LogSource.psiphon);
        onReconnect();
      }
    });
  }

  void scheduleAetherReconnect({
    Duration delay = defaultDelay,
    required bool Function() shouldReconnect,
    required void Function() onReconnect,
    required void Function(String, {String source}) log,
  }) {
    _aetherTimer?.cancel();
    _aetherTimer = Timer(delay, () {
      if (shouldReconnect()) {
        log('↻ Auto-reconnecting Aether...', source: LogSource.aether);
        onReconnect();
      }
    });
  }

  void scheduleTorReconnect({
    Duration delay = slowTunnelDelay,
    required bool Function() shouldReconnect,
    required void Function() onReconnect,
    required void Function(String, {String source}) log,
  }) {
    _torTimer?.cancel();
    _torTimer = Timer(delay, () {
      if (shouldReconnect()) {
        log('↻ Auto-reconnecting Tor...', source: LogSource.tor);
        onReconnect();
      }
    });
  }

  void scheduleSstpReconnect({
    Duration delay = defaultDelay,
    required bool Function() shouldReconnect,
    required void Function() onReconnect,
    required void Function(String, {String source}) log,
  }) {
    _sstpTimer?.cancel();
    _sstpTimer = Timer(delay, () {
      if (shouldReconnect()) {
        log('↻ Auto-reconnecting SSTP...', source: LogSource.sstp);
        onReconnect();
      }
    });
  }

  void cancelPsiphonTimer() {
    _psiphonTimer?.cancel();
    _psiphonTimer = null;
  }

  void cancelAetherTimer() {
    _aetherTimer?.cancel();
    _aetherTimer = null;
  }

  void cancelTorTimer() {
    _torTimer?.cancel();
    _torTimer = null;
  }

  void cancelSstpTimer() {
    _sstpTimer?.cancel();
    _sstpTimer = null;
  }

  void cancelAll() {
    cancelPsiphonTimer();
    cancelAetherTimer();
    cancelTorTimer();
    cancelSstpTimer();
  }
}
