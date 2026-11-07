import 'package:flutter/material.dart';

class PresetRadioTile extends StatelessWidget {
  final int value;
  final String title;
  final String subtitle;

  const PresetRadioTile({
    super.key,
    required this.value,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RadioListTile<int>(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      value: value,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
