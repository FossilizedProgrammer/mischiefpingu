import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/diagnostics/diagnostic_models.dart';
import '../../../services/diagnostics/quality_labels.dart';

class QualityMetricRow extends StatelessWidget {
  final String label;
  final DiagnosticMetric metric;
  final IconData icon;
  final AppLocalizations l10n;

  const QualityMetricRow({
    super.key,
    required this.label,
    required this.metric,
    required this.icon,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(QualityLabels.metricColorHex(metric.status));
    final hasData = metric.totalCount > 0;

    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            QualityLabels.metricLabel(metric.status, l10n),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const Spacer(),
        if (hasData)
          Text(
            '${metric.successCount}/${metric.totalCount} · '
            '${metric.avgLatencyMs}ms',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
      ],
    );
  }
}
