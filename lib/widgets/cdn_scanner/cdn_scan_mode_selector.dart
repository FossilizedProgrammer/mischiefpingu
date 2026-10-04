import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/ip_range_parser.dart';  // ← این IpScanMode را می‌آورد

class CdnScanModeSelector extends StatelessWidget {
  final IpScanMode selected;
  final ValueChanged<IpScanMode> onChanged;
  final bool enabled;
  final ThemeData theme;

  const CdnScanModeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.theme,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.tune,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.scanMode,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SegmentedButton<IpScanMode>(
          segments: [
            ButtonSegment<IpScanMode>(
              value: IpScanMode.quick,
              label: Text(_labelFor(IpScanMode.quick, l10n)),
              icon: const Icon(Icons.flash_on, size: 16),
            ),
            ButtonSegment<IpScanMode>(
              value: IpScanMode.balanced,
              label: Text(_labelFor(IpScanMode.balanced, l10n)),
              icon: const Icon(Icons.balance, size: 16),
            ),
            ButtonSegment<IpScanMode>(
              value: IpScanMode.deep,
              label: Text(_labelFor(IpScanMode.deep, l10n)),
              icon: const Icon(Icons.hourglass_bottom, size: 16),
            ),
          ],
          selected: {selected},
          onSelectionChanged: enabled
              ? (set) {
                  if (set.isEmpty) return;
                  onChanged(set.first);
                }
              : null,
          showSelectedIcon: false,
        ),
        const SizedBox(height: 6),
        Text(
          _descriptionFor(selected, l10n),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  String _labelFor(IpScanMode mode, AppLocalizations l10n) {
    switch (mode) {
      case IpScanMode.quick:
        return l10n.cdnScanModeQuick;
      case IpScanMode.balanced:
        return l10n.cdnScanModeBalanced;
      case IpScanMode.deep:
        return l10n.cdnScanModeDeep;
    }
  }

  String _descriptionFor(IpScanMode mode, AppLocalizations l10n) {
    switch (mode) {
      case IpScanMode.quick:
        return l10n.cdnScanModeQuickDesc(
          mode.samplesPerCidr.toString(),
          mode.maxTotalIps.toString(),
        );
      case IpScanMode.balanced:
        return l10n.cdnScanModeBalancedDesc(
          mode.samplesPerCidr.toString(),
          mode.maxTotalIps.toString(),
        );
      case IpScanMode.deep:
        return l10n.cdnScanModeDeepDesc(mode.maxTotalIps.toString());
    }
  }
}
