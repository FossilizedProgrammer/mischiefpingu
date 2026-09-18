library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/app_provider.dart';
import '../../../widgets/editable_list_dropdown.dart';

class PsiphonFrontingFields extends StatelessWidget {
  final AppProvider provider;

  const PsiphonFrontingFields({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        EditableListDropdown(
          label: l10n.frontingIp,
          value: provider.settings.ip,
          items: provider.ipList,
          onChanged: (v) {
            provider.settings.ip = v;
            provider.saveSettings();
            provider.touch();
          },
          onListChanged: (list) {
            provider.saveIpList(list);
          },
        ),
        const SizedBox(height: 12),
        EditableListDropdown(
          label: l10n.httpHostHeader,
          value: provider.settings.httpHost,
          items: provider.httpHostList,
          onChanged: (v) {
            provider.settings.httpHost = v;
            provider.saveSettings();
            provider.touch();
          },
          onListChanged: (list) {
            provider.saveHttpHostList(list);
          },
        ),
        const SizedBox(height: 12),
        EditableListDropdown(
          label: l10n.tlsSni,
          value: provider.settings.tlsSni,
          items: provider.tlsSniList,
          onChanged: (v) {
            provider.settings.tlsSni = v;
            provider.saveSettings();
            provider.touch();
          },
          onListChanged: (list) {
            provider.saveTlsSniList(list);
          },
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.autoFindIpSni),
          value: provider.settings.autoFindIpAndSni,
          onChanged: (v) {
            provider.settings.autoFindIpAndSni = v;
            provider.saveSettings();
            provider.touch();
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.saveFoundIpsSni),
          value: provider.settings.saveFoundIpsAndSni,
          onChanged: (v) {
            provider.settings.saveFoundIpsAndSni = v;
            provider.saveSettings();
            provider.touch();
          },
        ),
      ],
    );
  }
}
