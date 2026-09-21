library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../services/process_service.dart';
import 'logo_mode.dart';

class LogoNotificationBridge {
  final ProcessService processService;
  final void Function(LogoMode mode) onModeRequested;

  VoidCallback? _listener;

  DateTime? _lastSeenSadTimestamp;
  DateTime? _lastSeenHappyTimestamp;

  LogoNotificationBridge({
    required this.processService,
    required this.onModeRequested,
  });

  /// اتصال به ProcessService. باید در postFrameCallback صدا زده بشه.
  void attach() {
    _listener = checkPendingNotifications;
    processService.addListener(_listener!);
    debugPrint('LogoNotificationBridge: attached');
  }

  /// بررسی notificationهای در انتظار (sad/happy).
  void checkPendingNotifications() {
    final ps = processService;

    final sadTs = ps.pendingSadTimestamp;
    if (sadTs != null) {
      final isNew =
          _lastSeenSadTimestamp == null ||
          sadTs.isAfter(_lastSeenSadTimestamp!);
      if (isNew) {
        _lastSeenSadTimestamp = sadTs;
        ps.clearSadNotification();
        debugPrint('LogoNotificationBridge: sad → mode requested');
        onModeRequested(LogoMode.sad);
      }
    }

    final happyTs = ps.pendingHappyTimestamp;
    if (happyTs != null) {
      final isNew =
          _lastSeenHappyTimestamp == null ||
          happyTs.isAfter(_lastSeenHappyTimestamp!);
      if (isNew) {
        _lastSeenHappyTimestamp = happyTs;
        ps.clearHappyNotification();
        debugPrint('LogoNotificationBridge: happy → mode requested');
        onModeRequested(LogoMode.happy);
      }
    }
  }

  void dispose() {
    if (_listener != null) {
      processService.removeListener(_listener!);
    }
    _listener = null;
    debugPrint('LogoNotificationBridge: disposed');
  }
}
