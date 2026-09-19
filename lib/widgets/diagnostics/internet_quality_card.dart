import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/diagnostics/diagnostic_models.dart';
import '../../services/diagnostics/quality_labels.dart';
import 'internet_quality/quality_cause_banner.dart';
import 'internet_quality/quality_details_panel.dart';
import 'internet_quality/quality_header.dart';
import 'internet_quality/quality_metric_row.dart';
import 'internet_quality/quality_monitoring_chips.dart';
import 'internet_quality/quality_time_footer.dart';

/// ═══════════════════════════════════════════════════════════════
///  کارت نمایش کیفیت اینترنت.
///
///  این فایل فقط shell است — بخش‌های مختلف در
///  `internet_quality/` جدا شده‌اند.
/// ═══════════════════════════════════════════════════════════════
class InternetQualityCard extends StatelessWidget {
  final InternetDiagnosticResult? result;
  final bool isLoading;
  final VoidCallback? onTest;
  final MonitoringLevel level;
  final ValueChanged<MonitoringLevel>? onLevelChanged;

  const InternetQualityCard({
    super.key,
    required this.result,
    required this.isLoading,
    required this.onTest,
    required this.level,
    this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final r = result;
    final overall = r?.overall ?? InternetQuality.unknown;
    final color = Color(QualityLabels.overallColorHex(overall));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QualityHeader(
              overall: overall,
              color: color,
              isLoading: isLoading,
              onTest: onTest,
            ),
            if (r != null && r.probableCause.isNotEmpty) ...[
              const SizedBox(height: 12),
              QualityCauseBanner(
                cause: r.probableCause,
                color: color,
              ),
            ],
            if (r != null) ...[
              const SizedBox(height: 16),
              QualityMetricRow(
                label: l10n.internetQualityDns,
                metric: r.dns,
                icon: Icons.dns_outlined,
                l10n: l10n,
              ),
              const SizedBox(height: 8),
              QualityMetricRow(
                label: l10n.internetQualityTcp,
                metric: r.tcp,
                icon: Icons.cable_outlined,
                l10n: l10n,
              ),
              const SizedBox(height: 8),
              QualityMetricRow(
                label: l10n.internetQualityHttps,
                metric: r.https,
                icon: Icons.lock_outline,
                l10n: l10n,
              ),
              const SizedBox(height: 8),
              QualityMetricRow(
                label: l10n.internetQualityQuality,
                metric: r.directQuality,
                icon: Icons.speed,
                l10n: l10n,
              ),
              const SizedBox(height: 12),
              QualityDetailsPanel(result: r, l10n: l10n),
            ],
            if (onLevelChanged != null) ...[
              const Divider(height: 24),
              QualityMonitoringChips(
                level: level,
                onLevelChanged: onLevelChanged!,
                l10n: l10n,
              ),
            ],
            if (r != null) ...[
              const SizedBox(height: 12),
              QualityTimeFooter(result: r, l10n: l10n),
            ],
          ],
        ),
      ),
    );
  }
}
