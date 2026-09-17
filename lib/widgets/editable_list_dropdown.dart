// lib/widgets/editable_list_dropdown.dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'editable_list/editable_list_dialogs.dart';

class EditableListDropdown extends StatefulWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final ValueChanged<List<String>> onListChanged;

  const EditableListDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.onListChanged,
  });

  @override
  State<EditableListDropdown> createState() => _EditableListDropdownState();
}

class _EditableListDropdownState extends State<EditableListDropdown> {
  late List<String> _items;
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _items = List<String>.from(widget.items);
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant EditableListDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _items = List<String>.from(widget.items);
    }
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  Future<void> _showAddDialog() async {
    final result = await EditableListDialogs.showAdd(context, widget.label);
    if (!mounted) return;
    if (result == null) return;

    if (!_items.contains(result)) {
      setState(() => _items = [..._items, result]);
      widget.onListChanged(_items);
    }
    setState(() => _currentValue = result);
    widget.onChanged(result);
  }

  Future<void> _showManageDialog() async {
    while (true) {
      if (!mounted) return;

      final result = await EditableListDialogs.showManage(
        context,
        widget.label,
        _items,
      );

      if (!mounted) return;
      if (result == null) return;

      switch (result.action) {
        case 'delete':
          setState(() {
            _items.remove(result.value);
          });
          widget.onListChanged(List.from(_items));
          if (_currentValue == result.value) {
            setState(() => _currentValue = '');
            widget.onChanged('');
          }
          break;

        case 'select':
          setState(() => _currentValue = result.value ?? '');
          widget.onChanged(result.value ?? '');
          return;

        case 'add':
          if (!mounted) return;
          await _showAddDialog();
          return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final effectiveValue =
        _items.contains(_currentValue) ? _currentValue : null;
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: effectiveValue,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: widget.label,
              isDense: true,
            ),
            hint: Text(l10n.select),
            items: _items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _currentValue = v);
                widget.onChanged(v);
              }
            },
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: l10n.manageList,
          onPressed: _showManageDialog,
        ),
      ],
    );
  }
}
