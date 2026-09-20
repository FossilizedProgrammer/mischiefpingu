library;

import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
///  ردیف تعداد reconnect.
/// ═══════════════════════════════════════════════════════════════
class AetherReconnectsRow extends StatelessWidget {
  final int count;
  final ThemeData theme;

  const AetherReconnectsRow({
    super.key,
    required this.count,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.refresh,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          'Reconnects: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '$count',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
