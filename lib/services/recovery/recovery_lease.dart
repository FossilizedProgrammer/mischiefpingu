library;

import 'recovery_timeouts.dart';

/// نوع actionی که recovery انجام می‌دهد.
enum RecoveryAction {
  none,
  autoReconnect,
  watchdogRestart,
  manualStart,
  manualStop,
}

/// یک lease فعال در RecoveryCoordinator.
class RecoveryLease {
  final String tunnel;
  final RecoveryAction action;
  final DateTime acquiredAt;
  final String reason;
  bool _released = false;

  RecoveryLease({
    required this.tunnel,
    required this.action,
    required this.reason,
  }) : acquiredAt = DateTime.now();

  bool get isReleased => _released;

  void markReleased() => _released = true;

  /// آیا این lease منقضی شده؟ (بر اساس timeout پیش‌فرض tunnel)
  bool isExpired(String tunnelName) {
    final timeout = RecoveryTimeouts.forTunnel(tunnelName);
    return DateTime.now().difference(acquiredAt) > timeout;
  }
}
