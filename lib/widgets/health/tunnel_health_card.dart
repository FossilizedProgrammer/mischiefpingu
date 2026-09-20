library;

import 'package:flutter/material.dart';

import '../../services/health/tunnel_health_models.dart';
import 'tunnel_health_card/health_header.dart';
import 'tunnel_health_card/health_progress_bar.dart';
import 'tunnel_health_card/health_stats.dart';
import 'tunnel_health_card/health_no_data_warning.dart';
import 'tunnel_health_card/health_placeholder.dart';

/// ═══════════════════════════════════════════════════════════════
///  TunnelHealthCard — کارت نمایش health برای هر تونل.
///
///  این کارت مشترکه بین Psiphon/Aether/Tor/SSTP.
///  برای هر تونل یک instance بساز و report رو بده.
///
///  بخش‌های داخلی در `tunnel_health_card/` جدا شده‌اند:
///    • HealthHeader          → ردیف عنوان + score badge
///    • HealthProgressBar     → progress bar امتیاز
///    • HealthStats           → ردیف آمار (latency/jitter/loss/...)
///    • HealthNoDataWarning   → هشدار "tunnel up but no data"
///    • HealthPlaceholder     → placeholder وقتی report نیست
///    • HealthHelpers         → توابع کمکی رنگ و فرمت
/// ═══════════════════════════════════════════════════════════════
class TunnelHealthCard extends StatelessWidget {
  final TunnelHealthReport? report;

  /// اگر true باشد، در صورت نبود report چیزی نمایش نمی‌ده.
  final bool hideWhenEmpty;

  const TunnelHealthCard({
    super.key,
    required this.report,
    this.hideWhenEmpty = true,
  });

  @override
  Widget build(BuildContext context) {
    final r = report;

    if (r == null || !r.isValid) {
      if (hideWhenEmpty) return const SizedBox.shrink();
      return const HealthPlaceholder();
    }

    final theme = Theme.of(context);
    final color = Color(r.colorHex);

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HealthHeader(report: r, color: color),
            const SizedBox(height: 12),
            HealthProgressBar(report: r, color: color),
            const SizedBox(height: 12),
            HealthStats(report: r, theme: theme),
            if (r.isAliveButNoData) ...[
              const SizedBox(height: 12),
              const HealthNoDataWarning(),
            ],
          ],
        ),
      ),
    );
  }
}
