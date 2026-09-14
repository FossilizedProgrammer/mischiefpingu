// lib/widgets/editable_list/editable_list_dialogs.dart
//
// ═══════════════════════════════════════════════════════════════
//  EditableListDialogs — دیالوگ‌های add/manage برای EditableListDropdown
//  (تفکیک شده از editable_list_dropdown.dart)
// ═══════════════════════════════════════════════════════════════
library;

import 'package:flutter/material.dart';

class EditableListDialogs {
  EditableListDialogs._();

  /// دیالوگ افزودن یک آیتم جدید. مقدار وارد‌شده را برمی‌گرداند.
  static Future<String?> showAdd(
    BuildContext context,
    String label,
  ) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add $label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter new value',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    return (result != null && result.isNotEmpty) ? result : null;
  }

  /// دیالوگ مدیریت لیست. نتیجه یک action است:
  ///   - null اگر بسته شد
  ///   - (action: 'delete', value) اگر آیتم حذف شد
  ///   - (action: 'select', value) اگر آیتم انتخاب شد
  ///   - (action: 'add') اگر add زده شد
  static Future<({String action, String? value})?> showManage(
    BuildContext context,
    String label,
    List<String> items,
  ) async {
    return showDialog<({String action, String? value})>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text('Manage $label list'),
              content: SizedBox(
                width: double.maxFinite,
                child: items.isEmpty
                    ? const Text('List is empty')
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
                              tooltip: 'Delete',
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
                  child: const Text('Close'),
                ),
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.pop(ctx, (action: 'add', value: null)),
                  icon: const Icon(Icons.add),
                  label: const Text('Add new'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
