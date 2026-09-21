library;

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../services/health/tunnel_health_models.dart';
import '../tunnel_probe_result.dart';

/// ═══════════════════════════════════════════════════════════════
///  HealthStatus — نتیجهٔ resolved وضعیت (color + icon + label).
/// ═══════════════════════════════════════════════════════════════
class HealthStatus {
  final Color color;
  final IconData icon;
  final String label;

  const HealthStatus({
    required this.color,
    required this.icon,
    required this.label,
  });
}

/// ═══════════════════════════════════════════════════════════════
///  HealthStatusResolver — منطق resolve وضعیت یک تونل.
///
///  ورودی‌ها:
///    • isRunning         — آیا تونل در حال اجراست
///    • hasReport         — آیا report معتبر داریم
///    • report            — self-report
///    • lastProbeResult   — نتیجه آخرین probe دستی
///    • isProbing         — آیا در حال probe است
///
///  خروجی: HealthStatus (color + icon + label)
/// ═══════════════════════════════════════════════════════════════
class HealthStatusResolver {
  HealthStatusResolver._();

  static HealthStatus resolve({
    required bool isRunning,
    required bool hasReport,
    required TunnelHealthReport? report,
    required TunnelProbeResult? lastProbeResult,
    required bool isProbing,
    required ThemeData theme,
    required AppLocalizations l10n,
  }) {
    // ─── تونل در حال اجرا نیست ───
    if (!isRunning) {
      return HealthStatus(
        color: theme.colorScheme.outline,
        icon: Icons.cloud_off_outlined,
        label: l10n.tunnelHealthStopped,
      );
    }

    // ─── در حال probe ───
    if (isProbing) {
      return HealthStatus(
        color: Colors.blue,
        icon: Icons.sync,
        label: l10n.tunnelHealthMeasuring,
      );
    }

    // ─── آخرین probe شکست خورده ───
    if (lastProbeResult != null && !lastProbeResult.success) {
      return HealthStatus(
        color: Colors.red,
        icon: Icons.error_outline,
        label: l10n.tunnelHealthFailing,
      );
    }

    // ─── report معتبر ───
    if (hasReport && report != null) {
      return _fromReport(report, l10n);
    }

    // ─── probe موفق ولی report نداریم ───
    if (lastProbeResult != null && lastProbeResult.success) {
      return HealthStatus(
        color: Colors.green,
        icon: Icons.check_circle,
        label: l10n.tunnelHealthReachable,
      );
    }

    // ─── منتظر ───
    return HealthStatus(
      color: Colors.amber,
      icon: Icons.hourglass_empty,
      label: l10n.tunnelHealthMeasuring,
    );
  }

  static HealthStatus _fromReport(
    TunnelHealthReport report,
    AppLocalizations l10n,
  ) {
    final color = Color(report.colorHex);

    switch (report.level) {
      case HealthLevel.excellent:
        return HealthStatus(
          color: color,
          icon: Icons.check_circle,
          label: l10n.tunnelHealthExcellent,
        );
      case HealthLevel.good:
        return HealthStatus(
          color: color,
          icon: Icons.check_circle_outline,
          label: l10n.tunnelHealthGood,
        );
      case HealthLevel.fair:
        return HealthStatus(
          color: color,
          icon: Icons.warning_amber_rounded,
          label: l10n.tunnelHealthFair,
        );
      case HealthLevel.degraded:
        return HealthStatus(
          color: color,
          icon: Icons.warning_amber_rounded,
          label: l10n.tunnelHealthDegraded,
        );
      case HealthLevel.failing:
        return HealthStatus(
          color: color,
          icon: Icons.error_outline,
          label: l10n.tunnelHealthFailing,
        );
    }
  }
}
