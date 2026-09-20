library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// ═══════════════════════════════════════════════════════════════
///  HealthPlaceholder — placeholder وقتی report آماده نیست.
/// ═══════════════════════════════════════════════════════════════
class HealthPlaceholder extends StatelessWidget {
  const HealthPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.hourglass_empty,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              l10n.tunnelHealthMeasuringHealth,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
