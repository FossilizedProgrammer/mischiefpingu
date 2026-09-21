library;

import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
///  AetherManualProfileHint — کادر هشدار برای حالت manual.
/// ═══════════════════════════════════════════════════════════════
class AetherManualProfileHint extends StatelessWidget {
  const AetherManualProfileHint({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.amber.shade800,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'حالت دستی: پروتکل، مبهم‌سازی، scan mode و '
              'اندپوینت سفارشی در پایین کاملاً در اختیار شماست.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.amber.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
