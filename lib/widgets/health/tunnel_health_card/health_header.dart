library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/health/tunnel_health_models.dart';

/// ═══════════════════════════════════════════════════════════════
///  HealthHeader — ردیف عنوان + score badge.
/// ═══════════════════════════════════════════════════════════════
class HealthHeader extends StatelessWidget {
  final TunnelHealthReport report;
  final Color color;

  const HealthHeader({super.key, required this.report, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Icon(Icons.monitor_heart_outlined, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          l10n.tunnelHealthTitle(report.kind.displayName),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Text(
            '${report.score.toStringAsFixed(0)}/100',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}
