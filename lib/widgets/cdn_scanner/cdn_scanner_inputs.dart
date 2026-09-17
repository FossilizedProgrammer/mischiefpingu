import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/cdn_scanner_provider.dart';
import '../../cdn_presets.dart';

class CdnScannerInputs extends StatelessWidget {
  final CdnScannerProvider scan;
  final TextEditingController inputCtrl;
  final TextEditingController sniCtrl;
  final ThemeData theme;

  const CdnScannerInputs({
    super.key,
    required this.scan,
    required this.inputCtrl,
    required this.sniCtrl,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.cdnPreset,
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CdnPresets.all.map((preset) {
            final selected = scan.selectedPresetId == preset.id;
            final isCustom = preset.id == 'custom';

            final Widget? avatar = isCustom
                ? _CustomAvatar(
                    selected: selected,
                    theme: theme,
                  )
                : null;

            return FilterChip(
              label: Text(preset.name),
              selected: selected,
              avatar: avatar,
              onSelected: scan.isRunning
                  ? null
                  : (v) {
                      if (v) {
                        scan.applyPreset(preset.id);
                      }
                    },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: inputCtrl,
          maxLines: 6,
          decoration: InputDecoration(
            labelText: l10n.ipsCidrRanges,
            hintText: '23.215.0.0/24\n1.2.3.4\n10.0.0.1-10.0.0.50',
            border: InputBorder.none,
            alignLabelWithHint: true,
          ),
          enabled: !scan.isRunning,
          onChanged: (v) => scan.customInput = v,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: sniCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.sniList,
            border: InputBorder.none,
            alignLabelWithHint: true,
          ),
          enabled: !scan.isRunning,
          onChanged: (v) {
            scan.snis = v
                .split('\n')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Spacer(),
            SizedBox(
              width: 110,
              child: TextFormField(
                initialValue: scan.concurrency.toString(),
                decoration: InputDecoration(
                  labelText: l10n.threads,
                  isDense: true,
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !scan.isRunning,
                onChanged: (v) {
                  scan.concurrency = int.tryParse(v) ?? 12;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CustomAvatar extends StatelessWidget {
  final bool selected;
  final ThemeData theme;

  const _CustomAvatar({
    required this.selected,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? theme.colorScheme.onSecondaryContainer
        : theme.colorScheme.primary;

    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '★',
        style: TextStyle(
          fontSize: 12,
          height: 1,
          color: color,
        ),
      ),
    );
  }
}
