library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/settings_model.dart';
import '../../providers/app_provider.dart';
import 'aether_manual_profile_hint.dart';
import 'aether_profile_labels.dart';

/// ═══════════════════════════════════════════════════════════════
///  AetherQuickProfileSelector — انتخاب پروفایل با SegmentedButton.
///
///  سه پروفایل اصلی به صورت دکمه:
///    • Adaptive
///    • Patchy signal
///    • Strict network
///
///  و یک دکمهٔ جدا برای:
///    • رفتن به Manual (وقتی در preset هستیم)
///    • برگشت به Adaptive (وقتی در Manual هستیم)
///
///  در حالت Manual، تمام dropdownهای پایین (protocol،
///  obfuscation، scanMode، custom endpoint) فعال می‌شن.
///
///  ⚠️ توابع label/desc/icon به AetherProfileLabels منتقل شدن
///  تا این فایل فقط UI بمونه.
/// ═══════════════════════════════════════════════════════════════
class AetherQuickProfileSelector extends StatelessWidget {
  final bool isRunning;

  const AetherQuickProfileSelector({super.key, required this.isRunning});

  static const List<String> _quickProfiles = ['adaptive', 'patchy', 'strict'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final s = provider.settings;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final isManual = s.aetherProfile == 'manual';
    final currentId = s.aetherProfile;

    void select(String id) {
      s.applyAetherProfile(id);
      provider.saveSettings();
      provider.touch();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profile,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 10),

        // ─── SegmentedButton برای پروفایل‌های سریع ───
        SegmentedButton<String>(
          segments: _quickProfiles
              .map(
                (id) => ButtonSegment<String>(
                  value: id,
                  label: Text(AetherProfileLabels.label(id, l10n)),
                  icon: Icon(AetherProfileLabels.icon(id), size: 16),
                ),
              )
              .toList(),
          selected: _quickProfiles.contains(currentId)
              ? {currentId}
              : const <String>{},
          emptySelectionAllowed: true,
          onSelectionChanged: isRunning
              ? null
              : (set) {
                  if (set.isEmpty) return;
                  select(set.first);
                },
          multiSelectionEnabled: false,
          showSelectedIcon: false,
        ),

        const SizedBox(height: 8),

        // ─── توضیح پروفایل فعلی ───
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            AetherProfileLabels.description(currentId, l10n),
            key: ValueKey(currentId),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ═══════════════════════════════════════════════════════════
        //  دکمهٔ Manual:
        //    • اگر در preset هستیم → برو به Manual
        //    • اگر در Manual هستیم → برگرد به Adaptive
        // ═══════════════════════════════════════════════════════════
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isRunning
                ? null
                : () {
                    if (isManual) {
                      select('adaptive');
                    } else {
                      select('manual');
                    }
                  },
            icon: Icon(isManual ? Icons.auto_awesome : Icons.tune, size: 16),
            label: Text(isManual ? l10n.backToPresets : l10n.profileManual),
            style: OutlinedButton.styleFrom(
              foregroundColor: isManual
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        // ═══════════════════════════════════════════════════════════
        //  هشدار برای Manual
        // ═══════════════════════════════════════════════════════════
        if (isManual && !isRunning) ...[
          const SizedBox(height: 12),
          const AetherManualProfileHint(),
        ],
      ],
    );
  }
}
