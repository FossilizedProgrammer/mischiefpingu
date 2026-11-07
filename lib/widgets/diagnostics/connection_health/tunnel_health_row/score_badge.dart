library;

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../services/health/tunnel_health_models.dart';

/// ═══════════════════════════════════════════════════════════════
///  ScoreBadge — badge امتیاز سلامت (score + level).
/// ═══════════════════════════════════════════════════════════════
class ScoreBadge extends StatelessWidget {
  final TunnelHealthReport report;
  final AppLocalizations l10n;

  const ScoreBadge({super.key, required this.report, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final color = Color(report.colorHex);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${report.score.toStringAsFixed(0)} / 100',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _levelLabel(report.level),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 8,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _levelLabel(HealthLevel level) {
    switch (level) {
      case HealthLevel.excellent:
        return l10n.tunnelHealthExcellent;
      case HealthLevel.good:
        return l10n.tunnelHealthGood;
      case HealthLevel.fair:
        return l10n.tunnelHealthFair;
      case HealthLevel.degraded:
        return l10n.tunnelHealthDegraded;
      case HealthLevel.failing:
        return l10n.tunnelHealthFailing;
    }
  }
}
