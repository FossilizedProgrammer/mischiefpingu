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

/// ═══════════════════════════════════════════════════════════════
///  AetherStatusCard — نمایش وضعیت لحظه‌ای Aether (فاز ۶).
///
///  اطلاعات نمایش‌داده‌شده:
///    • وضعیت اتصال (Connected / Testing / Stopped)
///    • پروتکل فعلی
///    • Gateway فعلی
///    • Latency / Jitter / Packet loss
///    • تعداد reconnect
///    • مدت زمان اتصال
///
///  این کارت فقط برای نمایش است — هیچ تنظیمی اینجا نیست.
///
///  ⚠️ وقتی isRunning=false، کارت اصلاً نمایش داده نمی‌شه.
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

  /// هر ۱۰ ثانیه یک rebuild می‌زند تا uptime زنده بماند.
  ///
  /// ⚠️ تغییر: از Timer.periodic استفاده می‌کنیم (به جای Future.doWhile)
  /// که idiom استاندارد Dart است و cancel در dispose رو ساده می‌کنه.
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

    // ─── وضعیت رنگ و آیکن ───
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

    // ─── داده‌های عملکرد از tracker ───
    final tracker = provider.aetherTestService.performanceTracker;
    final report = tracker?.lastReport;
    final lastKey = tracker?.lastMeasuredKey;

    // ─── زمان اتصال ───
    final connectedAt = provider.lastAetherConnectedAt;

    // ═══════════════════════════════════════════════════════════════
    //  ⚠️ اگر Aether در حال اجرا نیست، کارت نمایش داده نشه.
    //  این کار از شلوغ شدن UI جلوگیری می‌کنه.
    // ═══════════════════════════════════════════════════════════════
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
            // ─── ردیف اول: وضعیت ───
            AetherStatusHeader(
              statusColor: statusColor,
              statusIcon: statusIcon,
              statusLabel: statusLabel,
              isRunning: isRunning,
              connectedAt: connectedAt,
              theme: theme,
            ),

            if (isRunning) ...[
              const Divider(height: 24),

              // ─── پروتکل ───
              AetherInfoRow(
                icon: Icons.hub_outlined,
                label: 'Protocol',
                value:
                    provider.lastAetherConnectedProtocol?.toUpperCase() ?? '—',
                theme: theme,
              ),
              const SizedBox(height: 6),

              // ─── Gateway ───
              AetherInfoRow(
                icon: Icons.dns_outlined,
                label: 'Gateway',
                value: AetherStatusHelpers.shortenKey(lastKey),
                theme: theme,
              ),

              const SizedBox(height: 16),

              // ─── متریک‌های عملکرد ───
              if (report != null && report.isValid) ...[
                AetherMetricsRow(report: report, theme: theme),
                const SizedBox(height: 12),
              ] else ...[
                const _MeasuringPlaceholder(),
                const SizedBox(height: 12),
              ],

              // ─── reconnect count ───
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

/// placeholder ساده برای زمانی که report آماده نیست.
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
