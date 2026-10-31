// lib/widgets/aether/aether_endpoint_pinning_selector.dart

library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AetherEndpointPinningSelector — انتخاب حالت endpoint pinning.
///
///  سه حالت:
///    • Automatic     → همیشه اسکن خودکار
///    • Custom-first  → اول endpoint سفارشی
///    • Custom-only   → فقط endpoint سفارشی
///
///  ⚠️ تغییر UX:
///  دکمه‌های Custom-first و Custom-only حالا **همیشه فعال** هستند.
///  اگر کاربر روی آن‌ها کلیک کند و custom endpoint خالی باشد،
///  یک دیالوگ برای وارد کردن endpoint باز می‌شود. بعد از وارد
///  کردن، حالت pinning خودکار اعمال می‌شود.
///
///  این از سردرگمی «چرا دکمه‌ها غیرفعالند؟» جلوگیری می‌کند.
/// ═══════════════════════════════════════════════════════════════
class AetherEndpointPinningSelector extends StatelessWidget {
  final bool isRunning;

  const AetherEndpointPinningSelector({super.key, required this.isRunning});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final s = provider.settings;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final hasCustom = s.hasCustomEndpointForPinning;

    void save() {
      provider.saveSettings();
      provider.touch();
    }

    /// ─────────────────────────────────────────────────────────
    ///  وقتی کاربر روی یکی از حالت‌های custom کلیک می‌کند:
    ///   • اگر endpoint دارد → فقط حالت را عوض کن
    ///   • اگر endpoint ندارد → دیالوگ ورودی باز کن، بعد
    ///     حالت را عوض کن
    /// ─────────────────────────────────────────────────────────
    Future<void> handleSelection(String mode) async {
      if (mode == 'automatic') {
        s.aetherEndpointPinning = 'automatic';
        save();
        return;
      }

      if (hasCustom) {
        s.aetherEndpointPinning = mode;
        save();
        return;
      }

      // endpoint خالی است → دیالوگ ورودی
      final entered = await _promptForEndpoint(context, l10n);
      if (entered == null || entered.isEmpty) return;

      s.aetherCustomEndpoint = entered;
      s.aetherEndpointPinning = mode;
      save();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.push_pin_outlined,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.endpointPinning,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.endpointPinningSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        SegmentedButton<String>(
          segments: [
            ButtonSegment<String>(
              value: 'automatic',
              label: Text(l10n.endpointPinningAutomatic),
              icon: const Icon(Icons.auto_awesome, size: 16),
            ),
            ButtonSegment<String>(
              value: 'custom_first',
              label: Text(l10n.endpointPinningCustomFirst),
              icon: const Icon(Icons.looks_one, size: 16),
            ),
            ButtonSegment<String>(
              value: 'custom_only',
              label: Text(l10n.endpointPinningCustomOnly),
              icon: const Icon(Icons.lock_outline, size: 16),
            ),
          ],
          selected: {s.aetherEndpointPinning},
          onSelectionChanged: isRunning
              ? null
              : (set) {
                  if (set.isEmpty) return;
                  handleSelection(set.first);
                },
          showSelectedIcon: false,
        ),

        // ─── راهنمای کمکی (به جای disable کردن) ───
        if (!hasCustom) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Colors.amber.shade800,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.endpointPinningNeedsCustom,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.amber.shade900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 8),
        Text(
          _descriptionFor(s.aetherEndpointPinning, l10n),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _descriptionFor(String mode, AppLocalizations l10n) {
    switch (mode) {
      case 'custom_first':
        return l10n.endpointPinningCustomFirstDesc;
      case 'custom_only':
        return l10n.endpointPinningCustomOnlyDesc;
      default:
        return l10n.endpointPinningAutomaticDesc;
    }
  }

  /// ─────────────────────────────────────────────────────────
  ///  دیالوگ ورودی endpoint.
  ///
  ///  خروجی:
  ///    • رشته‌ی endpoint اگر کاربر ذخیره کرد
  ///    • null اگر لغو کرد
  /// ─────────────────────────────────────────────────────────
  Future<String?> _promptForEndpoint(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final controller = TextEditingController();

    // اگه endpoint فعلی وجود داره (که نباید، ولی برای احتیاط)
    // مقدارش رو پیش‌فرض بذار
    try {
      final provider = context.read<AppProvider>();
      final existing = provider.settings.aetherCustomEndpoint.trim();
      if (existing.isNotEmpty) {
        controller.text = existing;
      }
    } catch (_) {}

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.push_pin_outlined, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.customEndpoint)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.customEndpointHint,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '1.2.3.4:2408',
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (v) {
                  final trimmed = v.trim();
                  if (trimmed.isNotEmpty) {
                    Navigator.pop(ctx, trimmed);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancelBtn),
            ),
            FilledButton(
              onPressed: () {
                final trimmed = controller.text.trim();
                if (trimmed.isEmpty) return;
                Navigator.pop(ctx, trimmed);
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );

    // ⚠️ dispose کردن controller پس از بسته شدن دیالوگ
    controller.dispose();
    return result;
  }
}
