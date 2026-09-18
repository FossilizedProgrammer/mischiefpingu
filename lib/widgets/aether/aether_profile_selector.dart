import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/settings_model.dart';
import '../../providers/app_provider.dart';

class AetherProfileSelector extends StatelessWidget {
  final bool isRunning;

  const AetherProfileSelector({super.key, required this.isRunning});

  String _profileLabel(String id, AppLocalizations l10n) {
    switch (id) {
      case 'adaptive':
        return l10n.profileAdaptive;
      case 'patchy':
        return l10n.profilePatchy;
      case 'strict':
        return l10n.profileStrict;
      case 'manual':
        return l10n.profileManual;
      default:
        return id;
    }
  }

  String _profileDesc(String id, AppLocalizations l10n) {
    switch (id) {
      case 'adaptive':
        return l10n.profileAdaptiveDesc;
      case 'patchy':
        return l10n.profilePatchyDesc;
      case 'strict':
        return l10n.profileStrictDesc;
      case 'manual':
        return l10n.profileManualDesc;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final s = provider.settings;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final current = s.activeAetherProfile;

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
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: s.aetherProfile,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: aetherProfiles
              .map(
                (p) => DropdownMenuItem(
                  value: p.id,
                  child: Text(_profileLabel(p.id, l10n)),
                ),
              )
              .toList(),
          onChanged: isRunning
              ? null
              : (v) {
                  if (v == null) return;
                  s.applyAetherProfile(v);
                  provider.saveSettings();
                  provider.touch();
                },
        ),
        if (current != null) ...[
          const SizedBox(height: 6),
          Text(
            _profileDesc(current.id, l10n),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
