import 'package:flutter/material.dart';

import '../../../services/sstp_health_checker.dart';

/// ═══════════════════════════════════════════════════════════════
///  Helperهای وضعیت سلامت SSTP
/// ═══════════════════════════════════════════════════════════════
class SstpHealthHelpers {
  SstpHealthHelpers._();

  static Color color(SstpHealth h, ThemeData theme) {
    switch (h) {
      case SstpHealth.alive:
        return Colors.green;
      case SstpHealth.tcpOnly:
        return Colors.orange;
      case SstpHealth.dead:
        return Colors.red;
      case SstpHealth.checking:
        return theme.colorScheme.primary;
      case SstpHealth.unknown:
        return theme.colorScheme.outline;
    }
  }

  static IconData icon(SstpHealth h) {
    switch (h) {
      case SstpHealth.alive:
        return Icons.check_circle;
      case SstpHealth.tcpOnly:
        return Icons.warning_amber_rounded;
      case SstpHealth.dead:
        return Icons.cancel;
      case SstpHealth.checking:
        return Icons.hourglass_top;
      case SstpHealth.unknown:
        return Icons.help_outline;
    }
  }
}
