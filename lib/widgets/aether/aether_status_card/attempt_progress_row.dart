// lib/widgets/aether/aether_status_card/attempt_progress_row.dart

library;

import 'package:flutter/material.dart';

import '../../../services/aether/retry/retry_state.dart';

/// ═══════════════════════════════════════════════════════════════
///  AttemptProgressRow — نمایش شماره تلاش Aether.
///
///  وقتی Aether در حال retry است، این ردیف شماره تلاش فعلی
///  و پروتکل در حال تست رو نشون میده.
/// ═══════════════════════════════════════════════════════════════
class AttemptProgressRow extends StatelessWidget {
  final RetryState state;
  final ThemeData theme;

  const AttemptProgressRow({
    super.key,
    required this.state,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (state.currentAttempt == 0) return const SizedBox.shrink();

    final progress = state.progress;
    final protocol = state.currentProtocol.toUpperCase();
    final masque =
        state.currentMasque.isNotEmpty ? '/${state.currentMasque}' : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.refresh,
                size: 14,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Attempt ${state.currentAttempt}/${state.maxAttempts}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$protocol$masque',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
