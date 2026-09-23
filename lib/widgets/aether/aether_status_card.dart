// lib/widgets/aether/aether_status_card.dart

library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import 'aether_status_card/helpers.dart';
import 'aether_status_card/status_header.dart';
import 'aether_status_card/info_rows.dart';
import 'aether_status_card/metrics_row.dart';
import 'aether_status_card/reconnects_row.dart';
import 'aether_status_card/attempt_progress_row.dart';

/// ═══════════════════════════════════════════════════════════════
///  AetherStatusCard — نمایش وضعیت لحظه‌ای Aether (فاز ۶).
///
///  ⚠️ تغییرات این نسخه:
///    • AttemptProgressRow اضافه شد — نمایش شماره تلاش
///    • وقتی retry در جریانه، این ردیف بالای متریک‌ها نشون داده میشه
/// ═══════════════════════════════════════════════════════════════
class AetherStatusCard extends StatefulWidget {
  const AetherStatusCard({super.key});

  @override
  State<AetherStatusCard> createState() => _AetherStatusCardState();
}

class _AetherStatusCardState extends State<AetherStatusCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ticker = null;
    super.dispose();
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final ps = provider.processService;

    final isRunning = ps.isAetherRunning;
    final isTesting = provider.isAutoTesting;
    final isHealthy = isRunning &&
        !isTesting &&
        provider.aetherStatus.toLowerCase().contains('healthy');

    final statusColor = isTesting
        ? Colors.orange
        : isRunning
            ? (isHealthy ? Colors.green : Colors.amber)
            : theme.colorScheme.outline;

    final statusIcon = isTesting
        ? Icons.hourglass_top
        : isRunning
            ? (isHealthy ? Icons.check_circle : Icons.warning_amber_rounded)
            : Icons.cloud_off_outlined;

    final statusLabel = isTesting
        ? 'Testing…'
        : isRunning
            ? (isHealthy ? 'Connected' : 'Running (unverified)')
            : 'Stopped';

    final tracker = provider.aetherTestService.performanceTracker;
    final report = tracker?.lastReport;
    final lastKey = tracker?.lastMeasuredKey;

    final connectedAt = provider.lastAetherConnectedAt;

    // ═══════════════════════════════════════════════════════════
    //  🆕 RetryState برای نمایش شماره تلاش
    // ═══════════════════════════════════════════════════════════
    final retryState = provider.aetherRetryState;
    final showRetryProgress =
        isTesting && retryState != null && retryState.currentAttempt > 0;

    if (!isRunning && !isTesting) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AetherStatusHeader(
              statusColor: statusColor,
              statusIcon: statusIcon,
              statusLabel: statusLabel,
              isRunning: isRunning,
              connectedAt: connectedAt,
              theme: theme,
            ),

            // ═══════════════════════════════════════════════════
            //  🆕 شماره تلاش (فقط وقتی در حال تست هستیم)
            // ═══════════════════════════════════════════════════
            if (showRetryProgress) ...[
              const SizedBox(height: 12),
              AttemptProgressRow(state: retryState, theme: theme),
            ],

            if (isRunning) ...[
              const Divider(height: 24),
              AetherInfoRow(
                icon: Icons.hub_outlined,
                label: 'Protocol',
                value:
                    provider.lastAetherConnectedProtocol?.toUpperCase() ?? '—',
                theme: theme,
              ),
              const SizedBox(height: 6),
              AetherInfoRow(
                icon: Icons.dns_outlined,
                label: 'Gateway',
                value: AetherStatusHelpers.shortenKey(lastKey),
                theme: theme,
              ),
              const SizedBox(height: 16),
              if (report != null && report.isValid) ...[
                AetherMetricsRow(report: report, theme: theme),
                const SizedBox(height: 12),
              ] else ...[
                const _MeasuringPlaceholder(),
                const SizedBox(height: 12),
              ],
              AetherReconnectsRow(
                count: provider.aetherReconnectCount,
                theme: theme,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MeasuringPlaceholder extends StatelessWidget {
  const _MeasuringPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Measuring performance…',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
