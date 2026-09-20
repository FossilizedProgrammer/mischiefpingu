library;

import 'package:flutter/material.dart';

import '../../../services/health/tunnel_health_models.dart';

/// ═══════════════════════════════════════════════════════════════
///  HealthProgressBar — progress bar امتیاز سلامت.
/// ═══════════════════════════════════════════════════════════════
class HealthProgressBar extends StatelessWidget {
  final TunnelHealthReport report;
  final Color color;

  const HealthProgressBar({
    super.key,
    required this.report,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: report.score / 100.0,
        minHeight: 6,
        backgroundColor: color.withValues(alpha: 0.1),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
