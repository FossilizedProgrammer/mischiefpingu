library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';

/// ═══════════════════════════════════════════════════════════════
///  کمک‌تابع‌های کلیپ‌بورد برای لیست‌های قابل ویرایش
///  (آی‌پی‌ها / host header / TLS SNI).
///
///  متدها static و بدون state هستند تا در dialogها قابل استفاده باشند.
/// ═══════════════════════════════════════════════════════════════
class EditableListClipboard {
  EditableListClipboard._();

  /// متن یک لیست را برای کپی آماده می‌کند (هر آیتم در یک خط).
  static String encode(List<String> items) => items.join('\n');

  /// متن کلیپ‌بورد را به لیست تبدیل می‌کند.
  /// خطوط خالی، کامنت‌ها و فاصله‌های اضافی حذف می‌شوند و
  /// تکراری‌ها هم نگه داشته می‌شوند (caller تصمیم می‌گیرد).
  static List<String> decode(String raw) {
    final out = <String>[];
    final seen = <String>{};
    for (final rawLine in raw.split(RegExp(r'[\r\n,;]+'))) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('#') || line.startsWith('//')) continue;
      if (seen.add(line)) out.add(line);
    }
    return out;
  }

  /// کپی لیست در کلیپ‌بورد + نمایش snackbar تأیید.
  static Future<void> copyAll(
    BuildContext context,
    List<String> items,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (items.isEmpty) {
      _snack(context, l10n.listIsEmpty);
      return;
    }
    await Clipboard.setData(ClipboardData(text: encode(items)));
    if (!context.mounted) return;
    _snack(context, '${items.length} · ${l10n.copiedToClipboard}');
  }

  /// خواندن از کلیپ‌بورد. آیتم‌های جدید (تکراری‌ها حذف) برمی‌گردند.
  static Future<List<String>?> readNew(
    BuildContext context,
    List<String> existing,
  ) async {
    final l10n = AppLocalizations.of(context);
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final raw = data?.text;
    if (raw == null || raw.trim().isEmpty) {
      if (context.mounted) _snack(context, l10n.nothingToImport);
      return null;
    }
    final known = existing.toSet();
    final fresh = decode(raw).where((e) => !known.contains(e)).toList();
    return fresh;
  }

  /// تأیید حذف همه‌ی آیتم‌ها.
  static Future<bool> confirmClearAll(
    BuildContext context,
    List<String> items,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (items.isEmpty) return false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${l10n.clearAll}?'),
        content: Text('${items.length}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelBtn),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.clearAll),
          ),
        ],
      ),
    );
    return ok == true;
  }

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class EditableListDialogs {
  EditableListDialogs._();

  static Future<String?> showAdd(BuildContext context, String label) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${l10n.addNew} · $label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
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
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              tooltip: l10n.delete,
                              onPressed: () {
                                items.removeAt(index);
                                setDialogState(() {});
                                Navigator.pop(ctx, (
                                  action: 'delete',
                                  value: item,
                                ));
                              },
                            ),
                            onTap: () => Navigator.pop(ctx, (
                              action: 'select',
                              value: item,
                            )),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.close),
                ),
                // ─── کپی همه آیتم‌ها در کلیپ‌بورد ───
                TextButton.icon(
                  onPressed: () => EditableListClipboard.copyAll(ctx, items),
                  icon: const Icon(Icons.copy_all, size: 18),
                  label: Text(l10n.copyAllToClipboard),
                ),
                // ─── وارد کردن آیتم‌ها از کلیپ‌بورد ───
                TextButton.icon(
                  onPressed: () async {
                    final fresh = await EditableListClipboard.readNew(
                      ctx,
                      items,
                    );
                    if (fresh == null || !ctx.mounted) return;
                    if (fresh.isEmpty) return;
                    items.addAll(fresh);
                    setDialogState(() {});
                    Navigator.pop(ctx, (action: 'import', value: null));
                  },
                  icon: const Icon(Icons.content_paste_go, size: 18),
                  label: Text(l10n.importFromClipboard),
                ),
                // ─── حذف همه آیتم‌ها ───
                TextButton.icon(
                  onPressed: items.isEmpty
                      ? null
                      : () async {
                          final ok = await EditableListClipboard.confirmClearAll(
                            ctx,
                            items,
                          );
                          if (!ok || !ctx.mounted) return;
                          Navigator.pop(ctx, (action: 'clear', value: null));
                        },
                  icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                  label: Text(l10n.clearAll),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
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
