library;

import '../process_service.dart';

/// probe محافظه‌کارانه بر اساس لاگ Aether.
class LogReadyProbe {
  final ProcessService processService;

  const LogReadyProbe({required this.processService});

  bool run(int port) {
    final logs = processService.fullLog;
    if (logs.isEmpty) return false;

    int startIdx = 0;
    for (int i = logs.length - 1; i >= 0; i--) {
      if (logs[i].contains('Starting Aether with args')) {
        startIdx = i;
        break;
      }
    }

    final relevant = logs.sublist(startIdx);
    if (relevant.isEmpty) return false;

    bool hasSocks = false;
    int lastValidatedIdx = -1;
    int lastDeadIdx = -1;

    for (int i = 0; i < relevant.length; i++) {
      final l = relevant[i];

      if (l.contains('tunnel validated')) {
        lastValidatedIdx = i;
      }

      if (l.contains('tunnel considered dead') ||
          l.contains('no valid data from peer') ||
          l.contains('WireGuard tunnel ended')) {
        lastDeadIdx = i;
      }

      if (!hasSocks &&
          l.toLowerCase().contains('socks5') &&
          l.contains('listening') &&
          (l.contains(':$port') || l.contains('127.0.0.1:$port'))) {
        hasSocks = true;
      }
    }

    if (lastValidatedIdx < 0) return false;
    if (lastDeadIdx > lastValidatedIdx) return false;

    final linesSinceValidation = relevant.length - lastValidatedIdx;
    if (linesSinceValidation > 10) return false;

    return hasSocks;
  }
}
