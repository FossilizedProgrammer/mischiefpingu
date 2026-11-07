import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/diagnostics/diagnostic_models.dart';

class QualityMonitoringChips extends StatelessWidget {
  final MonitoringLevel level;
  final ValueChanged<MonitoringLevel> onLevelChanged;
  final AppLocalizations l10n;

  const QualityMonitoringChips({
    super.key,
    required this.level,
    required this.onLevelChanged,
    required this.l10n,
  });

  static String _levelLabel(MonitoringLevel l, AppLocalizations l10n) {
    switch (l) {
      case MonitoringLevel.idle:
        return l10n.internetQualityOff;
      case MonitoringLevel.light:
        return l10n.internetQualityLight;
      case MonitoringLevel.normal:
        return l10n.internetQualityNormal;
      case MonitoringLevel.deep:
        return l10n.internetQualityDeep;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.internetQualityMonitoring,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: MonitoringLevel.values
              .where((l) => l != MonitoringLevel.deep)
              .map(
                (l) => ChoiceChip(
                  label: Text(_levelLabel(l, l10n)),
                  selected: level == l,
                  onSelected: (v) {
                    if (v) onLevelChanged(l);
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
