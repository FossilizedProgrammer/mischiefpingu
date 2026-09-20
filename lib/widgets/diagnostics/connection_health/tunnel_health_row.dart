library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/health/tunnel_health_models.dart';
import 'tunnel_probe_result.dart';

/// ═══════════════════════════════════════════════════════════════
///  TunnelHealthRow — نمایش وضعیت یک تونل + دکمه «تست مجدد».
///
///  ⚠️ این widget Stateless است — auto-probe توسط
///  ConnectionHealthSection (parent) مدیریت می‌شود.
///  این widget فقط نمایش و دکمه رفرش دستی را می‌دهد.
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

    final (statusColor, statusIcon) = _resolveStatus(
      isRunning: isRunning,
      hasReport: hasReport,
      report: r,
      lastProbeResult: lastProbeResult,
      isProbing: isProbing,
      theme: theme,
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Icon(statusIcon, color: statusColor, size: 18),
              ),
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
                      _statusLabel(
                        isRunning: isRunning,
                        hasReport: hasReport,
                        report: r,
                        lastProbeResult: lastProbeResult,
                        isProbing: isProbing,
                        l10n: l10n,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              if (hasReport)
                _buildScoreBadge(r, l10n)
              else if (lastProbeResult != null &&
                  lastProbeResult!.success)
                _buildProbeLatencyBadge(lastProbeResult!.latencyMs),

              const SizedBox(width: 8),

              _buildProbeButton(theme, l10n),
            ],
          ),

          if (hasReport) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _MiniStat(
                  label: l10n.tunnelHealthLatency,
                  value: '${r.latencyMs}ms',
                  color: _latencyColor(r.latencyMs),
                  theme: theme,
                ),
                _MiniStat(
                  label: l10n.tunnelHealthLoss,
                  value: '${r.packetLossPct.toStringAsFixed(0)}%',
                  color: _lossColor(r.packetLossPct),
                  theme: theme,
                ),
                _MiniStat(
                  label: l10n.tunnelHealthUptime,
                  value: _formatUptime(r.uptime),
                  color: theme.colorScheme.primary,
                  theme: theme,
                ),
                if (r.reconnectCount > 0)
                  _MiniStat(
                    label: l10n.tunnelHealthReconnects,
                    value: r.reconnectCount.toString(),
                    color: Colors.orange,
                    theme: theme,
                  ),
              ],
            ),
          ],

          if (lastProbeResult != null) ...[
            const SizedBox(height: 6),
            _ProbeResultBadge(
              result: lastProbeResult!,
              theme: theme,
              l10n: l10n,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreBadge(TunnelHealthReport r, AppLocalizations l10n) {
    final color = Color(r.colorHex);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${r.score.toStringAsFixed(0)} / 100',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _levelLabel(r.level, l10n),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 8,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProbeLatencyBadge(int latencyMs) {
    final color = _latencyColor(latencyMs);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        '${latencyMs}ms',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  static String _levelLabel(HealthLevel level, AppLocalizations l10n) {
    switch (level) {
      case HealthLevel.excellent:
        return l10n.tunnelHealthExcellent;
      case HealthLevel.good:
        return l10n.tunnelHealthGood;
      case HealthLevel.fair:
        return l10n.tunnelHealthFair;
      case HealthLevel.degraded:
        return l10n.tunnelHealthDegraded;
      case HealthLevel.failing:
        return l10n.tunnelHealthFailing;
    }
  }

  Widget _buildProbeButton(ThemeData theme, AppLocalizations l10n) {
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

  (Color, IconData) _resolveStatus({
    required bool isRunning,
    required bool hasReport,
    required TunnelHealthReport? report,
    required TunnelProbeResult? lastProbeResult,
    required bool isProbing,
    required ThemeData theme,
  }) {
    // ─── تونل در حال اجرا نیست ───
    if (!isRunning) {
      return (theme.colorScheme.outline, Icons.cloud_off_outlined);
    }

    // ─── در حال probe ───
    if (isProbing) {
      return (Colors.blue, Icons.sync);
    }

    // ─── آخرین probe شکست خورده ───
    if (lastProbeResult != null && !lastProbeResult.success) {
      return (Colors.red, Icons.error_outline);
    }

    // ─── report معتبر ───
    if (hasReport) {
      final level = report!.level;
      final color = Color(report.colorHex);

      switch (level) {
        case HealthLevel.excellent:
          return (color, Icons.check_circle);
        case HealthLevel.good:
          return (color, Icons.check_circle_outline);
        case HealthLevel.fair:
          return (color, Icons.warning_amber_rounded);
        case HealthLevel.degraded:
          return (color, Icons.warning_amber_rounded);
        case HealthLevel.failing:
          return (color, Icons.error_outline);
      }
    }

    // ─── probe موفق ولی report نداریم ───
    if (lastProbeResult != null && lastProbeResult.success) {
      return (Colors.green, Icons.check_circle);
    }

    // ─── منتظر ───
    return (Colors.amber, Icons.hourglass_empty);
  }

  String _statusLabel({
    required bool isRunning,
    required bool hasReport,
    required TunnelHealthReport? report,
    required TunnelProbeResult? lastProbeResult,
    required bool isProbing,
    required AppLocalizations l10n,
  }) {
    if (!isRunning) return l10n.tunnelHealthStopped;
    if (isProbing) return l10n.tunnelHealthMeasuring;
    if (hasReport) return _levelLabel(report!.level, l10n);
    if (lastProbeResult != null && lastProbeResult.success) {
      return l10n.tunnelHealthReachable;
    }
    return l10n.tunnelHealthMeasuring;
  }

  static Color _latencyColor(int ms) {
    if (ms < 300) return Colors.green;
    if (ms < 800) return Colors.amber;
    return Colors.red;
  }

  static Color _lossColor(double pct) {
    if (pct < 1) return Colors.green;
    if (pct < 10) return Colors.amber;
    return Colors.red;
  }

  static String _formatUptime(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    if (d.inMinutes > 0) {
      return '${d.inMinutes}m';
    }
    return '${d.inSeconds}s';
  }
}

// ───────────────────────────────────────────────────────────────
//  _MiniStat
// ───────────────────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;

  const _MiniStat({
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

// ───────────────────────────────────────────────────────────────
//  _ProbeResultBadge
// ───────────────────────────────────────────────────────────────
class _ProbeResultBadge extends StatelessWidget {
  final TunnelProbeResult result;
  final ThemeData theme;
  final AppLocalizations l10n;

  const _ProbeResultBadge({
    required this.result,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final color = result.success ? Colors.green : Colors.red;
    final icon = result.success ? Icons.check : Icons.close;
    final text = result.success
        ? l10n.tunnelHealthLastProbeOk(result.latencyMs)
        : l10n.tunnelHealthLastProbeFailed(result.error ?? 'unknown');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
