library;

import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/app_provider.dart';
import '../../../widgets/editable_list_dropdown.dart';
import '../../../widgets/editable_list/editable_list_dialogs.dart';

class PsiphonFrontingFields extends StatelessWidget {
  final AppProvider provider;

  const PsiphonFrontingFields({super.key, required this.provider});

  /// یک ردیف «اکشن‌های لیست» شامل کپی همه / ورود از کلیپ‌بورد / حذف همه.
  Widget _actions(
    BuildContext context,
    List<String> items,
    ValueChanged<List<String>> onListChanged,
    ValueChanged<String> onSelected,
  ) {
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: items.isEmpty
              ? null
              : () => EditableListClipboard.copyAll(context, items),
          icon: const Icon(Icons.copy_all, size: 16),
          label: Text(l10n.copyAllToClipboard),
          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
        ),
        const SizedBox(width: 4),
        TextButton.icon(
          onPressed: () async {
            final fresh = await EditableListClipboard.readNew(context, items);
            if (fresh == null || fresh.isEmpty) return;

            onListChanged([...items, ...fresh]);
            onSelected(fresh.first);

            if (!context.mounted) return;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('${l10n.itemsAddedCount}: ${fresh.length}'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          },
          icon: const Icon(Icons.content_paste_go, size: 16),
          label: Text(l10n.importFromClipboard),
          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
        ),
        const SizedBox(width: 4),
        TextButton.icon(
          onPressed: items.isEmpty
              ? null
              : () async {
                  final ok = await EditableListClipboard.confirmClearAll(
                    context,
                    items,
                  );
                  if (!ok) return;

                  onListChanged([]);
                  onSelected('');
                },
          icon: const Icon(Icons.delete_sweep_outlined, size: 16),
          label: Text(l10n.clearAll),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

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
        _actions(
          context,
          provider.ipList,
          (list) => provider.saveIpList(list),
          (v) {
            provider.settings.ip = v;
            provider.saveSettings();
            provider.touch();
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
        _actions(
          context,
          provider.httpHostList,
          (list) => provider.saveHttpHostList(list),
          (v) {
            provider.settings.httpHost = v;
            provider.saveSettings();
            provider.touch();
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
        _actions(
          context,
          provider.tlsSniList,
          (list) => provider.saveTlsSniList(list),
          (v) {
            provider.settings.tlsSni = v;
            provider.saveSettings();
            provider.touch();
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
