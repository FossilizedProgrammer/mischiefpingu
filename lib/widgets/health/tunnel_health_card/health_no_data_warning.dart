library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// ═══════════════════════════════════════════════════════════════
///  HealthNoDataWarning — هشدار "tunnel up but no data".
///
///  وقتی تونل زنده است ولی داده‌ای عبور نمی‌کند نمایش داده می‌شود.
/// ═══════════════════════════════════════════════════════════════
class HealthNoDataWarning extends StatelessWidget {
  const HealthNoDataWarning({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber.shade800,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.tunnelHealthNoDataWarning,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.amber.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
