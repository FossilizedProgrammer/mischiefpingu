library;

import 'package:flutter/material.dart';

import 'helpers.dart';

/// ═══════════════════════════════════════════════════════════════
///  ردیف اول کارت: آیکن وضعیت + برچسب + uptime.
/// ═══════════════════════════════════════════════════════════════
class AetherStatusHeader extends StatelessWidget {
  final Color statusColor;
  final IconData statusIcon;
  final String statusLabel;
  final bool isRunning;
  final DateTime? connectedAt;
  final ThemeData theme;

  const AetherStatusHeader({
    super.key,
    required this.statusColor,
    required this.statusIcon,
    required this.statusLabel,
    required this.isRunning,
    required this.connectedAt,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aether Status',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                statusLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (isRunning && connectedAt != null)
          _UptimeBadge(connectedAt: connectedAt!, theme: theme),
      ],
    );
  }
}

class _UptimeBadge extends StatelessWidget {
  final DateTime connectedAt;
  final ThemeData theme;

  const _UptimeBadge({required this.connectedAt, required this.theme});

  @override
  Widget build(BuildContext context) {
    final uptime = DateTime.now().difference(connectedAt);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        // ⚠️ استفاده از helper مشترک به جای متد خصوصی محلی
        AetherStatusHelpers.formatDuration(uptime),
        style: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
