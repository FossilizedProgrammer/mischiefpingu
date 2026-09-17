import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/app_provider.dart';
import 'psiphon_fronting_fields.dart';
import 'psiphon_upstream_selector.dart';

class PsiphonFrontingTile extends StatelessWidget {
  final ThemeData theme;
  final AppProvider provider;
  final bool isFronted;
  final ValueChanged<bool> onFrontedChanged;
  final int upstreamType;
  final ValueChanged<int?> onUpstreamTypeChanged;
  final bool autoReconnectPsiphon;
  final ValueChanged<bool> onAutoReconnectChanged;

  const PsiphonFrontingTile({
    super.key,
    required this.theme,
    required this.provider,
    required this.isFronted,
    required this.onFrontedChanged,
    required this.upstreamType,
    required this.onUpstreamTypeChanged,
    required this.autoReconnectPsiphon,
    required this.onAutoReconnectChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.useFronting),
          value: isFronted,
          onChanged: onFrontedChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<bool>(
          initialValue: provider.settings.useSunAndLion,
          decoration: InputDecoration(
            labelText: l10n.tunnelCore,
            isDense: true,
          ),
          items: [
            DropdownMenuItem(
              value: false,
              child: Text(l10n.officialCore),
            ),
            DropdownMenuItem(
              value: true,
              child: Text(l10n.sunandlionCore),
            ),
          ],
          onChanged: (v) {
            provider.settings.useSunAndLion = v ?? false;
            provider.saveSettings();
            provider.touch();
          },
        ),
        if (isFronted) PsiphonFrontingFields(provider: provider),
        PsiphonUpstreamSelector(
          upstreamType: upstreamType,
          onUpstreamTypeChanged: onUpstreamTypeChanged,
          autoReconnectPsiphon: autoReconnectPsiphon,
          onAutoReconnectChanged: onAutoReconnectChanged,
        ),
      ],
    );
  }
}
