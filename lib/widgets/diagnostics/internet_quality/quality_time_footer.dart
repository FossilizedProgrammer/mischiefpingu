import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/diagnostics/diagnostic_models.dart';

class QualityTimeFooter extends StatelessWidget {
  final InternetDiagnosticResult result;
  final AppLocalizations l10n;

  const QualityTimeFooter({
    super.key,
    required this.result,
    required this.l10n,
  });

  static String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    final s = t.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      '${l10n.internetQualityLastCheck}: '
      '${_formatTime(result.timestamp)} · ${result.totalDurationMs}ms',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: 11,
      ),
    );
  }
}
