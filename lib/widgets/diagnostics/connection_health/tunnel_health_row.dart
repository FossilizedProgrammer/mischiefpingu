library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/health/tunnel_health_models.dart';
import 'tunnel_probe_result.dart';

import 'tunnel_health_row/health_status_resolver.dart';
import 'tunnel_health_row/probe_latency_badge.dart';
import 'tunnel_health_row/probe_result_badge.dart';
import 'tunnel_health_row/score_badge.dart';
import 'tunnel_health_row/stats_wrap.dart';

/// ═══════════════════════════════════════════════════════════════
///  TunnelHealthRow — نمایش وضعیت یک تونل + دکمه «تست مجدد».
///
///  ⚠️ این widget Stateless است — auto-probe توسط
///  ConnectionHealthSection (parent) مدیریت می‌شود.
///  این widget فقط نمایش و دکمه رفرش دستی را می‌دهد.
///
///  ⚠️ بازآرایی: این فایل حالا shell است.
///  بخش‌های داخلی در `tunnel_health_row/` جدا شده‌اند:
///    • HealthStatusResolver → منطق (color, icon, label)
///    • ScoreBadge           → score badge
///    • ProbeLatencyBadge    → latency badge
///    • ProbeResultBadge     → نتیجه probe
///    • MiniStat             → آمار کوچک
///    • StatsWrap            → Wrap آمار
/// ═══════════════════════════════════════════════════════════════
class TunnelHealthRow extends StatelessWidget {
  final TunnelKind kind;
  final TunnelHealthReport? report;
  final bool isRunning;
  final bool isProbing;
  final TunnelProbeResult? lastProbeResult;
  final VoidCallback? onProbe;

  const TunnelHealthRow({
    super.key,
    required this.kind,
    required this.report,
    required this.isRunning,
    required this.isProbing,
    required this.lastProbeResult,
    required this.onProbe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final r = report;
    final hasReport = r != null && r.isValid;

    final status = HealthStatusResolver.resolve(
      isRunning: isRunning,
      hasReport: hasReport,
      report: r,
      lastProbeResult: lastProbeResult,
      isProbing: isProbing,
      theme: theme,
      l10n: l10n,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusIcon(status: status),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kind.displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      status.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: status.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasReport)
                ScoreBadge(report: r, l10n: l10n)
              else if (lastProbeResult != null && lastProbeResult!.success)
                ProbeLatencyBadge(latencyMs: lastProbeResult!.latencyMs),
              const SizedBox(width: 8),
              _ProbeButton(
                isProbing: isProbing,
                onProbe: onProbe,
                theme: theme,
                l10n: l10n,
              ),
            ],
          ),
          if (hasReport) ...[
            const SizedBox(height: 8),
            StatsWrap(report: r, theme: theme),
          ],
          if (lastProbeResult != null) ...[
            const SizedBox(height: 6),
            ProbeResultBadge(
              result: lastProbeResult!,
              theme: theme,
              l10n: l10n,
            ),
          ],
        ],
      ),
    );
  }
}

/// آیکن دایره‌ای وضعیت.
class _StatusIcon extends StatelessWidget {
  final HealthStatus status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: status.color.withValues(alpha: 0.4)),
      ),
      child: Icon(status.icon, color: status.color, size: 18),
    );
  }
}

/// دکمه probe (refresh یا progress).
class _ProbeButton extends StatelessWidget {
  final bool isProbing;
  final VoidCallback? onProbe;
  final ThemeData theme;
  final AppLocalizations l10n;

  const _ProbeButton({
    required this.isProbing,
    required this.onProbe,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (isProbing) {
      return SizedBox(
        width: 32,
        height: 32,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
      );
    }

    return IconButton(
      onPressed: onProbe,
      icon: const Icon(Icons.refresh, size: 18),
      tooltip: l10n.tunnelHealthProbeAgain,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}
