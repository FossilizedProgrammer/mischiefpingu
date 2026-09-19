import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/diagnostics/diagnostic_models.dart';
import '../../../services/diagnostics/quality_labels.dart';

class QualityHeader extends StatelessWidget {
  final InternetQuality overall;
  final Color color;
  final bool isLoading;
  final VoidCallback? onTest;

  const QualityHeader({
    super.key,
    required this.overall,
    required this.color,
    required this.isLoading,
    required this.onTest,
  });

  static IconData _iconForOverall(InternetQuality q) {
    switch (q) {
      case InternetQuality.excellent:
        return Icons.speed;
      case InternetQuality.good:
        return Icons.check_circle_outline;
      case InternetQuality.degraded:
        return Icons.warning_amber_rounded;
      case InternetQuality.unstable:
        return Icons.sync_problem;
      case InternetQuality.dead:
        return Icons.signal_wifi_off;
      case InternetQuality.unknown:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Icon(
            _iconForOverall(overall),
            color: color,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.internetQuality,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                QualityLabels.overallLabel(overall, l10n),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          FilledButton.tonalIcon(
            onPressed: onTest,
            icon: const Icon(Icons.speed, size: 16),
            label: Text(l10n.internetQualityTest),
          ),
      ],
    );
  }
}
