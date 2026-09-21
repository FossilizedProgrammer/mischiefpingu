import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/app_provider.dart';
import '../../../services/process/log_source.dart';

/// بخش فیلتر منابع لاگ.
///
/// این widget از `LogTile` جدا شده تا فایل اصلی کوتاه‌تر بشه.
/// انتخاب/عدم انتخاب هر منبع، از طریق `provider.setLogSources` اعمال می‌شه.
class LogFilterSection extends StatelessWidget {
  final AppProvider provider;
  final AppLocalizations l10n;

  const LogFilterSection({
    super.key,
    required this.provider,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabledSources = provider.processService.enabledLogSources;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.logSourceFilter,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                // انتخاب همه
                provider.setLogSources(Set.from(LogSource.all));
              },
              icon: const Icon(Icons.select_all, size: 16),
              label: Text(l10n.selectAll),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
            TextButton.icon(
              onPressed: () {
                // پاک کردن همه
                provider.setLogSources(<String>{});
              },
              icon: const Icon(Icons.deselect, size: 16),
              label: Text(l10n.clearAll),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: LogSource.all.map((source) {
            final isSelected = enabledSources.contains(source);
            return FilterChip(
              label: Text(_labelForSource(source, l10n)),
              selected: isSelected,
              onSelected: (selected) {
                final newSources = Set<String>.from(enabledSources);
                if (selected) {
                  newSources.add(source);
                } else {
                  newSources.remove(source);
                }
                provider.setLogSources(newSources);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String _labelForSource(String source, AppLocalizations l10n) {
    switch (source) {
      case LogSource.psiphon:
        return l10n.logSourcePsiphon;
      case LogSource.aether:
        return l10n.logSourceAether;
      case LogSource.tor:
        return l10n.logSourceTor;
      case LogSource.sstp:
        return l10n.logSourceSstp;
      case LogSource.app:
        return l10n.logSourceApp;
      case LogSource.system:
        return l10n.logSourceSystem;
      default:
        return source;
    }
  }
}
