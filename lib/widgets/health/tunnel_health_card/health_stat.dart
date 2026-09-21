library;

import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
///  HealthStat — یک آمار کوچک (label + value).
///
///  نقطه رنگی + label + value.
/// ═══════════════════════════════════════════════════════════════
class HealthStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const HealthStat({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
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
