library;

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class EditableListDialogs {
  EditableListDialogs._();

  static Future<String?> showAdd(
    BuildContext context,
    String label,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${l10n.addNew} · $label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancelBtn),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.add),
          ),
        ],
      ),
    );
    return (result != null && result.isNotEmpty) ? result : null;
  }

  static Future<({String action, String? value})?> showManage(
    BuildContext context,
    String label,
    List<String> items,
  ) async {
    final l10n = AppLocalizations.of(context);
    return showDialog<({String action, String? value})>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(label),
              content: SizedBox(
                width: double.maxFinite,
                child: items.isEmpty
                    ? Text(l10n.listIsEmpty)
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (ctx, index) {
                          final item = items[index];
                          return ListTile(
                            title: Text(item),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              tooltip: l10n.delete,
                              onPressed: () {
                                items.removeAt(index);
                                setDialogState(() {});
                                Navigator.pop(
                                  ctx,
                                  (action: 'delete', value: item),
                                );
                              },
                            ),
                            onTap: () => Navigator.pop(
                              ctx,
                              (action: 'select', value: item),
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.close),
                ),
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.pop(ctx, (action: 'add', value: null)),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addNew),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
