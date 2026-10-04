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
    final isCustom = scan.selectedPresetId == 'custom';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.cdnPreset,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CdnPresets.all.map((preset) {
            final selected = scan.selectedPresetId == preset.id;
            final isCustomChip = preset.id == 'custom';

            final Widget? avatar = isCustomChip
                ? _CustomAvatar(selected: selected, theme: theme)
                : null;

            return FilterChip(
              label: Text(preset.name),
              selected: selected,
              avatar: avatar,
              onSelected: scan.isRunning
                  ? null
                  : (v) {
                      if (v) {
                        if (preset.id == 'custom') {
                          final customText = scan.customIps.join('\n');
                          if (inputCtrl.text != customText) {
                            inputCtrl.text = customText;
                          }
                        } else {
                          final presetText = preset.ranges.join('\n');
                          if (inputCtrl.text != presetText) {
                            inputCtrl.text = presetText;
                          }
                          final sniText = preset.snis.join('\n');
                          if (sniCtrl.text != sniText) {
                            sniCtrl.text = sniText;
                          }
                        }
                        scan.applyPreset(preset.id);
                      }
                    },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // ═══════════════════════════════════════════════════════════
        //  🆕 دکمه Scout SNIs
        //
        //  این دکمه SNIهای فیلترنشده رو در شبکه فعلی پیدا می‌کنه.
        //  ⚠️ قبل از اسکن، حتماً Scout بزنید اگه IP پیدا نمی‌کنید.
        // ═══════════════════════════════════════════════════════════
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.radar,
                    size: 16,
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.cdnScoutTitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          scan.isScouting
                              ? l10n.cdnScoutProgress(
                                  scan.scoutDone.toString(),
                                  scan.scoutTotal.toString(),
                                )
                              : l10n.cdnScoutHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (scan.isScouting)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    FilledButton.tonalIcon(
                      onPressed: scan.isRunning ? null : scan.scoutSnis,
                      icon: const Icon(Icons.search, size: 16),
                      label: Text(l10n.cdnScoutButton),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (isCustom) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer.withValues(
                alpha: 0.35,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.tertiary.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${scan.customIps.length} ${l10n.customIps} '
                    '(${l10n.save} → ${l10n.startScan})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

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
          onChanged: (v) {
            scan.customInput = v;
          },
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
                  final c = int.tryParse(v) ?? 8;
                  scan.concurrency = c.clamp(1, 15);
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

  const _CustomAvatar({required this.selected, required this.theme});

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
      child: Text('★', style: TextStyle(fontSize: 12, height: 1, color: color)),
    );
  }
}
