// lib/widgets/aether/aether_connection_mode_section.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_provider.dart';
import 'aether_endpoint_pinning_selector.dart';

class AetherConnectionModeSection extends StatelessWidget {
  final bool isRunning;

  const AetherConnectionModeSection({super.key, required this.isRunning});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final s = provider.settings;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    void save() {
      provider.saveSettings();
      provider.touch();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.connectionMode,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.tryLastEndpointFirst),
          subtitle: Text(
            l10n.tryLastEndpointFirstSubtitle,
            style: const TextStyle(fontSize: 11),
          ),
          value: s.aetherTryLastEndpointFirst,
          onChanged: isRunning
              ? null
              : (v) {
                  s.aetherTryLastEndpointFirst = v;
                  save();
                },
        ),
        const SizedBox(height: 12),
        Text(
          l10n.customEndpoint,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: s.aetherCustomEndpoint,
          decoration: InputDecoration(
            labelText: 'Endpoint (e.g., 1.2.3.4:2408)',
            border: InputBorder.none,
            hintText: l10n.customEndpointHint,
          ),
          enabled: !isRunning,
          onChanged: (v) {
            s.aetherCustomEndpoint = v.trim();
            // اگه custom خالی شد و در حالت custom-first/only بودیم،
            // خودکار به automatic برگرد
            if (s.aetherCustomEndpoint.isEmpty &&
                s.aetherEndpointPinning != 'automatic') {
              s.aetherEndpointPinning = 'automatic';
            }
            save();
          },
        ),
        const SizedBox(height: 16),

        // ═══════════════════════════════════════════════════════
        //  🆕 Endpoint Pinning Selector
        // ═══════════════════════════════════════════════════════
        AetherEndpointPinningSelector(isRunning: isRunning),
      ],
    );
  }
}
