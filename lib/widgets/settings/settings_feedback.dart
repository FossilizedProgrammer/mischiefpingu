import 'package:flutter/material.dart';

class SettingsActionRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment alignment;

  const SettingsActionRow({
    super.key,
    required this.children,
    this.alignment = MainAxisAlignment.end,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: alignment, children: children);
  }
}

class SettingsInfoCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? color;

  const SettingsInfoCard({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: c, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: 12, color: c)),
          ),
        ],
      ),
    );
  }
}
