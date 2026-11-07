import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class ShowMoreButton extends StatelessWidget {
  final bool showMore;
  final VoidCallback onTap;

  const ShowMoreButton({
    super.key,
    required this.showMore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: showMore
                  ? [
                      theme.colorScheme.secondaryContainer.withValues(
                        alpha: 0.5,
                      ),
                      theme.colorScheme.tertiaryContainer.withValues(
                        alpha: 0.3,
                      ),
                    ]
                  : [
                      theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.45,
                      ),
                      theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.25,
                      ),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (showMore
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.primary)
                  .withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (showMore
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.primary)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedRotation(
                  turns: showMore ? 0.5 : 0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: showMore
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      showMore ? l10n.showLess : l10n.showMore,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      showMore ? l10n.showLessSubtitle : l10n.showMoreSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                showMore ? Icons.unfold_less : Icons.unfold_more,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
