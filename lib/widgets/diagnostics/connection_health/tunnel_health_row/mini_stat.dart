library;

import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
///  MiniStat — یک آمار کوچک (نقطه رنگی + label + value).
///
///  در Wrap آمار (StatsWrap) استفاده می‌شه.
/// ═══════════════════════════════════════════════════════════════
class MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;

  const MiniStat({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
