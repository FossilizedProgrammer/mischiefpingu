// lib/widgets/settings/settings_primitives.dart
import 'package:flutter/material.dart';

/// بخش ساده با عنوان (بدون کارت).
class SettingsSection extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.label,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

/// زیربخش با Divider و راهنمای اختیاری.
class SettingsSubSection extends StatelessWidget {
  final String label;
  final String? hint;
  final List<Widget> children;

  const SettingsSubSection({
    super.key,
    required this.label,
    this.hint,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 4),
          Text(
            hint!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

/// کانتینر با پس‌زمینه ملایم.
class SettingsContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const SettingsContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
