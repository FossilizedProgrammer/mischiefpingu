import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/diagnostics/diagnostic_models.dart';

class QualityDetailsPanel extends StatelessWidget {
  final InternetDiagnosticResult result;
  final AppLocalizations l10n;

  const QualityDetailsPanel({
    super.key,
    required this.result,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = result.directQuality;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.internetQualityDirectDetails,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              QualityDetailChip(
                label: l10n.internetQualityMin,
                value: '${q.minLatencyMs}ms',
              ),
              QualityDetailChip(
                label: l10n.internetQualityMed,
                value: '${q.medianLatencyMs}ms',
              ),
              QualityDetailChip(
                label: l10n.internetQualityAvg,
                value: '${q.avgLatencyMs}ms',
              ),
              QualityDetailChip(
                label: l10n.internetQualityP95,
                value: '${q.p95LatencyMs}ms',
              ),
              QualityDetailChip(
                label: l10n.internetQualityMax,
                value: '${q.maxLatencyMs}ms',
              ),
              QualityDetailChip(
                label: l10n.internetQualityJitter,
                value: '${q.jitterMs}ms',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QualityDetailChip extends StatelessWidget {
  final String label;
  final String value;

  const QualityDetailChip({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
